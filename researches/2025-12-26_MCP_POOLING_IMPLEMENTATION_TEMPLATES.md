# MCP Connection Pooling - Implementation Templates & Quick Reference
**Date:** 2025-12-26
**Purpose:** Copy-paste ready code for implementing connection pooling
**Target Audience:** Developers implementing pooling in specific servers

---

## Quick Start by Server

### firecrawl (Node.js/npm)

#### File: home-manager/mcp-servers/firecrawl-pool.nix

```nix
# Integration pattern for firecrawl with connection pooling
# This shows how to configure the npm package with pooling support

{ pkgs, stdenv, nodejs, ... }:

let
  # Firecrawl source with pooling patch
  firecrawlWithPooling = stdenv.mkDerivation {
    pname = "firecrawl-mcp-pooling";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "mendableai";
      repo = "firecrawl";
      rev = "main";
      sha256 = ""; # Update with actual hash
    };

    buildInputs = [
      nodejs
      pkgs.python311
      pkgs.jemalloc  # Memory efficiency
    ];

    buildPhase = ''
      export NODE_ENV=production
      export NODE_OPTIONS="--max-old-space-size=1000"

      # Install dependencies
      npm ci --production=false

      # Build with pooling enabled
      npm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist node_modules package.json $out/
    '';
  };

in {
  enable = true;
  package = firecrawlWithPooling;
  binary = "firecrawl-mcp.js";

  # Resource limits
  memoryMax = "1500M";
  cpuQuota = "200%";

  # Enable connection pooling via environment
  environment = {
    NODE_ENV = "production";
    FIRECRAWL_POOL_SIZE = "30";
    FIRECRAWL_POOL_MIN = "5";
    FIRECRAWL_POOL_TIMEOUT = "120000";
    FIRECRAWL_POOL_IDLE = "300000";
  };
}
```

#### File: src/mcp-servers/firecrawl-pooling.ts

```typescript
// Drop-in replacement for current firecrawl MCP
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import axios from 'axios';
import Pool from 'generic-pool';
import pino from 'pino';

const logger = pino();

// Connection pool factory
class FirecrawlClientFactory {
  constructor(private apiKey: string) {}

  async create() {
    logger.debug('Creating pooled Firecrawl client');
    return axios.create({
      baseURL: 'https://api.firecrawl.dev',
      headers: { Authorization: `Bearer ${this.apiKey}` },
      timeout: 120000,
      maxRedirects: 5,
    });
  }

  async destroy(client: any) {
    logger.debug('Destroying pooled Firecrawl client');
  }

  async validate(client: any) {
    try {
      await client.get('/health', { timeout: 3000 });
      return true;
    } catch {
      return false;
    }
  }
}

// Main pool manager
const factory = new FirecrawlClientFactory(process.env.FIRECRAWL_API_KEY!);
const poolSize = parseInt(process.env.FIRECRAWL_POOL_SIZE || '30');
const minSize = parseInt(process.env.FIRECRAWL_POOL_MIN || '5');

const clientPool = Pool.createPool(factory, {
  max: poolSize,
  min: minSize,
  idleTimeoutMillis: parseInt(process.env.FIRECRAWL_POOL_IDLE || '300000'),
  acquireTimeoutMillis: 5000,
  fifo: true,
  evictionRunIntervalMillis: 60000,
});

// MCP Server setup
const server = new Server({
  name: 'firecrawl-mcp',
  version: '1.0.0',
});

server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'crawl',
      description: 'Crawl a URL with connection pooling',
      inputSchema: {
        type: 'object',
        properties: {
          url: { type: 'string' },
          options: { type: 'object' },
        },
        required: ['url'],
      },
    },
    {
      name: 'batch_crawl',
      description: 'Crawl multiple URLs concurrently',
      inputSchema: {
        type: 'object',
        properties: {
          urls: { type: 'array', items: { type: 'string' } },
          options: { type: 'object' },
        },
        required: ['urls'],
      },
    },
  ],
}));

server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'crawl') {
      const client = await clientPool.acquire();
      try {
        logger.info('Crawling URL', { url: args.url });
        const response = await client.post('/v1/crawl', {
          url: args.url,
          ...(args.options || {}),
        });

        return {
          content: [
            {
              type: 'text',
              text: JSON.stringify(response.data, null, 2),
            },
          ],
        };
      } finally {
        await clientPool.release(client);
      }
    }

    if (name === 'batch_crawl') {
      logger.info('Batch crawling URLs', { count: args.urls.length });

      const promises = args.urls.map(async (url: string) => {
        const client = await clientPool.acquire();
        try {
          const response = await client.post('/v1/crawl', {
            url,
            ...(args.options || {}),
          });
          return { url, result: response.data };
        } finally {
          await clientPool.release(client);
        }
      });

      const results = await Promise.allSettled(promises);
      const successful = results.filter((r) => r.status === 'fulfilled');
      const failed = results.filter((r) => r.status === 'rejected');

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(
              {
                total: args.urls.length,
                successful: successful.length,
                failed: failed.length,
                results: successful.map((r) =>
                  r.status === 'fulfilled' ? r.value : null
                ),
              },
              null,
              2
            ),
          },
        ],
      };
    }

    return {
      content: [
        {
          type: 'text',
          text: `Unknown tool: ${name}`,
        },
      ],
    };
  } catch (error) {
    logger.error('Tool execution error', { tool: name, error });
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
    };
  }
});

// Monitor pool health
setInterval(() => {
  const status = clientPool.status();
  logger.debug('Pool status', {
    available: status.availableCount,
    waiting: status.waitingCount,
    idle: status.idleCount,
    size: status.size,
  });
}, 30000);

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('Shutting down, draining pool');
  await clientPool.drain();
  await clientPool.clear();
  process.exit(0);
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  logger.info('Firecrawl MCP with connection pooling started', {
    poolSize,
    minSize,
  });
}

main().catch((error) => {
  logger.error('Fatal error', error);
  process.exit(1);
});
```

#### Testing firecrawl pooling

```bash
# Test baseline throughput (without pool modifications)
npm test -- --testNamePattern="baseline"

# Test pooled throughput
npm test -- --testNamePattern="pooled"

# Load test (100 concurrent requests)
npm run load-test -- --concurrency=100 --duration=60

# Expected improvement: 10-20x
```

---

### exa (Node.js/npm)

#### File: src/pools/exa-pool.ts

```typescript
import axios, { AxiosInstance } from 'axios';
import Pool from 'generic-pool';
import pino from 'pino';

const logger = pino();

export interface ExaPoolConfig {
  apiKey: string;
  maxConnections?: number;
  minConnections?: number;
}

export class ExaPool {
  private pool: Pool.Pool<AxiosInstance>;

  constructor(config: ExaPoolConfig) {
    const factory = {
      create: async () => {
        logger.debug('Creating Exa client');
        return axios.create({
          baseURL: 'https://api.exa.ai',
          headers: {
            Authorization: `Bearer ${config.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 30000,
        });
      },

      destroy: async (client: AxiosInstance) => {
        // Cleanup
      },

      validate: async (client: AxiosInstance) => {
        try {
          await client.get('/health', { timeout: 3000 });
          return true;
        } catch {
          return false;
        }
      },
    };

    this.pool = Pool.createPool(factory, {
      max: config.maxConnections || 30,
      min: config.minConnections || 5,
      idleTimeoutMillis: 5 * 60 * 1000,
      acquireTimeoutMillis: 5000,
      fifo: true,
    });
  }

  async search(query: string, options?: any) {
    const client = await this.pool.acquire();
    try {
      logger.info('Searching', { query });
      const response = await client.post('/search', {
        query,
        ...options,
      });
      return response.data;
    } finally {
      await this.pool.release(client);
    }
  }

  async findSimilar(url: string, options?: any) {
    const client = await this.pool.acquire();
    try {
      logger.info('Finding similar', { url });
      const response = await client.post('/findSimilar', {
        url,
        ...options,
      });
      return response.data;
    } finally {
      await this.pool.release(client);
    }
  }

  async batchSearch(queries: string[], options?: any) {
    const promises = queries.map((query) => this.search(query, options));
    return Promise.allSettled(promises);
  }

  async drain() {
    await this.pool.drain();
    await this.pool.clear();
  }
}
```

#### Integration into MCP server

```typescript
import { ExaPool } from './pools/exa-pool';

const exaPool = new ExaPool({
  apiKey: process.env.EXA_API_KEY!,
  maxConnections: 30,
  minConnections: 5,
});

server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'search') {
    const result = await exaPool.search(
      request.params.arguments.query,
      request.params.arguments.options
    );
    return {
      content: [{ type: 'text', text: JSON.stringify(result) }],
    };
  }
});

process.on('SIGTERM', async () => {
  await exaPool.drain();
  process.exit(0);
});
```

---

### context7 (Bun)

#### File: src/pools/context7-pool.ts

```typescript
import axios, { AxiosInstance } from 'axios';
import Pool from 'generic-pool';

export class Context7Pool {
  private pool: Pool.Pool<AxiosInstance>;

  constructor(private apiKey: string) {
    const factory = {
      create: async () => {
        return axios.create({
          baseURL: 'https://mcp.context7.com',
          headers: {
            Authorization: `Bearer ${apiKey}`,
          },
          timeout: 30000,
        });
      },

      destroy: async (client: AxiosInstance) => {
        // Cleanup
      },

      validate: async (client: AxiosInstance) => {
        try {
          await client.get('/health');
          return true;
        } catch {
          return false;
        }
      },
    };

    this.pool = Pool.createPool(factory, {
      max: 50,
      min: 10,
      idleTimeoutMillis: 300000,
      acquireTimeoutMillis: 5000,
    });
  }

  async query(content: string, options?: any) {
    const client = await this.pool.acquire();
    try {
      const response = await client.post('/query', {
        content,
        ...options,
      });
      return response.data;
    } finally {
      await this.pool.release(client);
    }
  }

  async batchQuery(items: Array<{ content: string; options?: any }>) {
    const promises = items.map(({ content, options }) =>
      this.query(content, options)
    );
    return Promise.allSettled(promises);
  }

  async drain() {
    await this.pool.drain();
    await this.pool.clear();
  }
}
```

---

### ck-search (Rust)

#### File: src/pool/embedding_pool.rs

```rust
use deadpool::managed::{Object, Pool, Manager, RecycleResult, PoolError};
use ort::{InferenceSession, SessionBuilder};
use std::sync::Arc;
use anyhow::Result;

pub type EmbeddingSessionPool = Pool<EmbeddingSessionManager>;

pub struct EmbeddingSessionManager {
    model_path: String,
}

impl EmbeddingSessionManager {
    pub fn new(model_path: impl Into<String>) -> Self {
        Self {
            model_path: model_path.into(),
        }
    }
}

#[async_trait::async_trait]
impl Manager for EmbeddingSessionManager {
    type Type = Arc<InferenceSession>;
    type Error = ort::OrtError;

    async fn create(&self) -> Result<Arc<InferenceSession>, Self::Error> {
        let session = SessionBuilder::new()?
            .with_execution_providers(&[
                ort::ExecutionProvider::CUDA(Default::default()),
                ort::ExecutionProvider::CPU(Default::default()),
            ])?
            .commit_from_file(&self.model_path)?;

        Ok(Arc::new(session))
    }

    async fn recycle(
        &self,
        _obj: &mut Arc<InferenceSession>,
        _: &PoolError<Self::Error>,
    ) -> RecycleResult<Self::Error> {
        Ok(())
    }
}

pub struct EmbeddingPool {
    pool: EmbeddingSessionPool,
}

impl EmbeddingPool {
    pub async fn new(model_path: &str, pool_size: u32) -> Result<Self> {
        let manager = EmbeddingSessionManager::new(model_path);

        let pool = Pool::builder()
            .max_size(pool_size)
            .min_idle(Some(pool_size / 2))
            .build(manager)
            .await?;

        Ok(Self { pool })
    }

    pub async fn embed(&self, texts: &[String]) -> Result<Vec<Vec<f32>>> {
        let session = self.pool
            .get()
            .await
            .map_err(|e| anyhow::anyhow!("Pool error: {}", e))?;

        // Use session to generate embeddings
        // Implementation depends on your embedding logic
        // Session is automatically returned to pool when dropped

        Ok(vec![])
    }

    pub async fn batch_embed(
        &self,
        batch: Vec<Vec<String>>,
    ) -> Result<Vec<Vec<Vec<f32>>>> {
        let futures = batch
            .into_iter()
            .map(|texts| self.embed(&texts))
            .collect::<Vec<_>>();

        let results = futures::future::try_join_all(futures).await?;
        Ok(results)
    }
}
```

#### Usage in ck-search

```rust
#[tokio::main]
async fn main() -> Result<()> {
    let pool = EmbeddingPool::new(
        "models/all-mpnet-base-v2.onnx",
        8  // 8 concurrent sessions
    ).await?;

    // Handle requests using pooled sessions
    loop {
        let request = receiver.recv().await?;
        let texts = request.texts.clone();
        let pool = pool.clone();

        tokio::spawn(async move {
            match pool.embed(&texts).await {
                Ok(embeddings) => {
                    // Send response
                }
                Err(e) => {
                    eprintln!("Error: {}", e);
                }
            }
        });
    }
}
```

---

### mcp-shell (Go)

#### File: internal/pool/pool.go

```go
package pool

import (
    "context"
    "net"
    "sync"
    "time"
)

type Connection struct {
    Conn     net.Conn
    LastUsed time.Time
}

type ConnectionPool struct {
    address   string
    idle      chan *Connection
    active    int32
    maxSize   int
    timeout   time.Duration
    mu        sync.Mutex
    closed    bool
}

func NewConnectionPool(address string, maxSize int) *ConnectionPool {
    return &ConnectionPool{
        address: address,
        idle:    make(chan *Connection, maxSize),
        maxSize: maxSize,
        timeout: 30 * time.Second,
    }
}

func (p *ConnectionPool) Get(ctx context.Context) (*Connection, error) {
    select {
    case conn := <-p.idle:
        // Validate connection
        if time.Since(conn.LastUsed) > 5*time.Minute {
            conn.Conn.Close()
            return p.createConnection(ctx)
        }
        return conn, nil

    case <-ctx.Done():
        return nil, ctx.Err()

    default:
        return p.createConnection(ctx)
    }
}

func (p *ConnectionPool) Put(conn *Connection) {
    conn.LastUsed = time.Now()
    select {
    case p.idle <- conn:
        // Returned to pool
    default:
        // Pool full, close
        conn.Conn.Close()
    }
}

func (p *ConnectionPool) createConnection(ctx context.Context) (*Connection, error) {
    ctx, cancel := context.WithTimeout(ctx, p.timeout)
    defer cancel()

    dialer := net.Dialer{
        Timeout: p.timeout,
    }

    conn, err := dialer.DialContext(ctx, "tcp", p.address)
    if err != nil {
        return nil, err
    }

    return &Connection{
        Conn:     conn,
        LastUsed: time.Now(),
    }, nil
}

func (p *ConnectionPool) Close() error {
    p.mu.Lock()
    defer p.mu.Unlock()

    if p.closed {
        return nil
    }

    p.closed = true
    close(p.idle)

    for conn := range p.idle {
        conn.Conn.Close()
    }

    return nil
}
```

#### Usage in mcp-shell

```go
package main

import (
    "context"
    "time"

    "yourmodule/internal/pool"
)

func init() {
    // Create connection pool for TCP operations
    connPool := pool.NewConnectionPool("localhost:9000", 50)

    // Cleanup on shutdown
    go func() {
        <-ctx.Done()
        connPool.Close()
    }()
}

func processRequest(ctx context.Context, data []byte) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()

    conn, err := connPool.Get(ctx)
    if err != nil {
        return err
    }
    defer connPool.Put(conn)

    _, err = conn.Conn.Write(data)
    return err
}
```

---

### ast-grep (Python)

#### File: src/pool/api_pool.py

```python
import asyncio
import aiohttp
from typing import Optional, List, Dict, Any
from contextlib import asynccontextmanager
import logging

logger = logging.getLogger(__name__)

class APIConnectionPool:
    def __init__(
        self,
        base_url: str,
        max_connections: int = 50,
        timeout: int = 30,
    ):
        self.base_url = base_url
        self.max_connections = max_connections
        self.timeout = aiohttp.ClientTimeout(total=timeout)
        self.session: Optional[aiohttp.ClientSession] = None
        self.semaphore = asyncio.Semaphore(max_connections)

    async def __aenter__(self):
        connector = aiohttp.TCPConnector(
            limit=self.max_connections,
            limit_per_host=30,
            ttl_dns_cache=300,
            keepalive_timeout=30,
            force_close=False,
        )

        self.session = aiohttp.ClientSession(
            connector=connector,
            timeout=self.timeout,
        )
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
            await asyncio.sleep(0.25)

    async def request(
        self,
        method: str,
        endpoint: str,
        **kwargs
    ) -> Dict[str, Any]:
        if not self.session:
            raise RuntimeError("Pool not initialized")

        async with self.semaphore:
            try:
                async with self.session.request(
                    method,
                    f"{self.base_url}{endpoint}",
                    **kwargs
                ) as response:
                    if response.status >= 400:
                        raise aiohttp.ClientError(
                            f"HTTP {response.status}"
                        )
                    return await response.json()
            except asyncio.TimeoutError:
                logger.error(f"Timeout: {method} {endpoint}")
                raise

    async def batch_requests(
        self,
        requests: List[Dict[str, Any]],
        return_exceptions: bool = False
    ) -> List[Any]:
        tasks = [
            self.request(
                req['method'],
                req['endpoint'],
                json=req.get('data'),
            )
            for req in requests
        ]
        return await asyncio.gather(
            *tasks,
            return_exceptions=return_exceptions
        )

    @asynccontextmanager
    async def session_context(self):
        async with self:
            yield self


# Usage in MCP server
async def handle_request(pool: APIConnectionPool, query: str):
    return await pool.request('POST', '/search', json={'query': query})

async def main():
    async with APIConnectionPool('https://api.example.com', 50) as pool:
        result = await handle_request(pool, "example")
        print(result)
```

---

## Configuration Template (Nix)

```nix
# File: home-manager/mcp-servers/pooling-config.nix
# Reusable pooling configuration for all MCP servers

{ lib, ... }:

{
  # Connection pooling environment variables
  poolingDefaults = {
    # Maximum concurrent connections
    POOL_MAX_CONNECTIONS = "50";

    # Minimum idle connections to maintain
    POOL_MIN_CONNECTIONS = "10";

    # Idle timeout (milliseconds)
    POOL_IDLE_TIMEOUT = "300000";  # 5 minutes

    # Acquire timeout (milliseconds)
    POOL_ACQUIRE_TIMEOUT = "5000";

    # Validation interval (milliseconds)
    POOL_VALIDATE_INTERVAL = "60000";

    # Enable detailed pool logging
    POOL_DEBUG = "0";
  };

  # Per-server overrides
  serverConfigs = {
    firecrawl = {
      POOL_MAX_CONNECTIONS = "30";
      POOL_MIN_CONNECTIONS = "5";
      NODE_OPTIONS = "--max-old-space-size=1000";
    };

    exa = {
      POOL_MAX_CONNECTIONS = "30";
      POOL_MIN_CONNECTIONS = "5";
    };

    context7 = {
      POOL_MAX_CONNECTIONS = "50";
      POOL_MIN_CONNECTIONS = "10";
      BUN_RUNTIME_TRANSPILER_CACHE_PATH = "0";
    };

    ck_search = {
      POOL_MAX_SESSIONS = "8";  # Rust: sessions, not connections
      POOL_MIN_SESSIONS = "4";
    };
  };

  # Memory limits adjusted for pooling overhead
  memoryLimits = {
    firecrawl = "1500M";  # +300M for pooling
    exa = "1000M";        # +200M for pooling
    context7 = "1000M";   # No change (already optimized)
    ck_search = "2000M";  # +200M for session pool
  };
}
```

---

## Monitoring Template

```bash
#!/bin/bash
# File: ~/.local/bin/monitor-mcp-pools.sh
# Monitor connection pool health across MCP servers

set -euo pipefail

echo "MCP Connection Pool Health Monitor"
echo "=================================="
echo ""

# Function to check pool metrics
check_pool() {
    local server=$1
    local port=$2

    echo "Checking $server (port $port)..."

    # Try to connect and get pool status
    if nc -z localhost "$port" 2>/dev/null; then
        curl -s "http://localhost:$port/metrics/pool" 2>/dev/null | jq . || echo "No metrics available"
    else
        echo "  ❌ Server not responding"
    fi

    echo ""
}

# Monitor each pooled server
check_pool "firecrawl" 3001
check_pool "exa" 3002
check_pool "context7" 3003

# System metrics
echo "System Memory Pressure:"
echo "======================"

if [ -f /proc/pressure/memory ]; then
    cat /proc/pressure/memory | sed 's/^/  /'
fi

echo ""
echo "Per-Process Pool Statistics:"
echo "============================="

# Check Node.js servers
for process in firecrawl-mcp exa-mcp context7-mcp; do
    pid=$(pgrep -f "$process" || true)
    if [ -n "$pid" ]; then
        echo "Process: $process (PID: $pid)"
        echo "  Memory: $(ps -p "$pid" -o rss= | numfmt --to=iec-i --suffix=B)"
        echo "  CPU: $(ps -p "$pid" -o %cpu=)%"
    fi
done

echo ""
echo "Monitor updated: $(date)"
```

---

## Testing Template

```typescript
// File: __tests__/pool.integration.test.ts
// Integration tests for connection pooling

import { describe, it, expect, beforeEach, afterEach } from '@jest/globals';
import FirecrawlPool from '../pools/firecrawl-pool';

describe('Connection Pool Integration', () => {
  let pool: FirecrawlPool;

  beforeEach(() => {
    pool = new FirecrawlPool(process.env.API_KEY!, {
      maxConnections: 20,
      minConnections: 2,
    });
  });

  afterEach(async () => {
    await pool.drain();
  });

  it('should handle sequential requests with pool reuse', async () => {
    const start = Date.now();

    for (let i = 0; i < 10; i++) {
      await pool.request('GET', '/test');
    }

    const elapsed = Date.now() - start;

    // Should be fast due to connection reuse
    expect(elapsed).toBeLessThan(5000);
  });

  it('should handle concurrent requests', async () => {
    const start = Date.now();

    const promises = Array(100)
      .fill(null)
      .map(() => pool.request('GET', '/test'));

    await Promise.all(promises);

    const elapsed = Date.now() - start;

    // 100 concurrent on 20-connection pool
    expect(elapsed).toBeLessThan(30000);
  });

  it('should evict idle connections', async () => {
    // Acquire and release
    await pool.request('GET', '/test');

    const status1 = pool.getStatus();

    // Wait for idle timeout
    await new Promise(r => setTimeout(r, 100));

    // Pool should still have idle connections
    const status2 = pool.getStatus();
    expect(status2.availableCount).toBeGreaterThan(0);
  });

  it('should recover from failures', async () => {
    // First request fails
    try {
      await pool.request('GET', '/error');
    } catch (e) {
      // Expected
    }

    // Pool should still be functional
    const result = await pool.request('GET', '/test');
    expect(result).toBeDefined();
  });
});
```

---

## Troubleshooting Guide

### Issue: Pool exhaustion (waiting for connections)

**Symptoms:**
- Increasing latency over time
- "Timeout waiting for connection" errors
- Pool status shows high waiting count

**Solution:**
```typescript
// Debug: Log pool status
setInterval(() => {
  const status = pool.status();
  console.log(`Pool: available=${status.availableCount}, waiting=${status.waitingCount}`);

  if (status.waitingCount > 10) {
    console.warn('Pool exhaustion detected!');
    // Investigate request handlers
  }
}, 5000);

// Fix: Ensure proper cleanup
async function withConnection(fn) {
  const conn = await pool.acquire();
  try {
    return await Promise.race([
      fn(conn),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('Handler timeout')), 30000)
      )
    ]);
  } finally {
    pool.release(conn);  // MUST run
  }
}
```

### Issue: Memory leaks in pool

**Symptoms:**
- Memory grows over time
- `process.memoryUsage().heapUsed` keeps increasing

**Solution:**
```typescript
// Monitor heap usage
setInterval(() => {
  const mem = process.memoryUsage();
  const heapUsedPercent = (mem.heapUsed / mem.heapTotal) * 100;

  if (heapUsedPercent > 90) {
    console.warn('Heap pressure, draining pool');
    pool.drain().then(() => {
      if (global.gc) global.gc();  // Force GC if available
    });
  }
}, 10000);

// Ensure objects are properly freed
const factory = {
  destroy: async (client) => {
    // Cleanup all references
    client.defaults.headers = {};
    client.defaults = {};
  }
};
```

### Issue: Stale connections returning 503

**Symptoms:**
- Sporadic 503 errors after pool has been idle
- Errors clear after pool restart

**Solution:**
```typescript
const pool = Pool.createPool(factory, {
  // Validate connections before use
  validate: async (conn) => {
    try {
      await conn.head('/health', { timeout: 2000 });
      return true;
    } catch (e) {
      console.log('Invalid connection, removing:', e.message);
      return false;  // Will be destroyed
    }
  },

  // Evict old connections regularly
  evictionRunIntervalMillis: 30000,
  idleTimeoutMillis: 5 * 60 * 1000,
});
```

---

## Summary Table

| Server | Library | Impact | Effort | Status |
|--------|---------|--------|--------|--------|
| **firecrawl** | generic-pool (Node.js) | 10-20x | 6-8h | Template ready |
| **exa** | generic-pool (Node.js) | 10-20x | 3-4h | Template ready |
| **context7** | generic-pool (Bun) | 10-20x | 3-4h | Template ready |
| **ck-search** | deadpool (Rust) | 5-10x | 6-8h | Template ready |
| **mcp-shell** | sync.Pool (Go) | 5x | 2-3h | Template ready |
| **ast-grep** | aiohttp (Python) | 20x | 4-6h | Template ready |

---

**Status:** All templates ready for copy-paste implementation

**Next Step:** Choose target server and follow the template implementation
