# Bun MCP Migration Implementation Plan
## exa-mcp & firecrawl-mcp Optimization

**Plan Created**: 2025-12-26T23:55:00+02:00
**Planner**: Ops & Platform Engineer + Technical Researcher roles
**Status**: Ready for Implementation
**Estimated Duration**: 2-3 weeks (part-time)

---

## Executive Summary

Comprehensive implementation plan for migrating exa-mcp-server and firecrawl-mcp-server from Node.js to Bun runtime. Based on successful context7-mcp migration (59-61% memory savings, 13.4x faster startup).

**Goals:**
- ✅ Reduce memory usage by 50-70%
- ✅ Improve startup time by 10-15x
- ✅ Optimize CPU utilization (20-30% for firecrawl, 5-15% for exa)
- ✅ Maintain full functionality and stability

**Priority:**
1. **firecrawl-mcp** (Week 1-2): Highest ROI, HTML parsing benefits
2. **exa-mcp** (Week 2-3): High ROI, simpler dependencies

---

## Phase 1: Preparation & Setup (Days 1-2)

### 1.1 Environment Setup

**Task**: Prepare development environment for Bun builds

**Subtasks:**
- [ ] 1.1.1 Verify Bun installation on shoshin
  ```bash
  bun --version  # Should be ≥1.0
  ```

- [ ] 1.1.2 Verify Nix prefetch tools availability
  ```bash
  which nix-prefetch-github nix-prefetch-url
  ```

- [ ] 1.1.3 Create working directory for testing
  ```bash
  mkdir -p /tmp/bun-mcp-migration/{firecrawl,exa}
  ```

- [ ] 1.1.4 Document current baseline metrics
  ```bash
  # For each MCP server, collect:
  # - Current memory usage (ps aux | grep mcp-{name})
  # - Startup time (time mcp-{name} --help)
  # - Package sizes (du -sh ~/.nix-profile/bin/mcp-*)
  ```

**Success Criteria:**
- Bun ≥1.0 installed and functional
- Nix tools available
- Baseline metrics documented

**Dependencies:** None
**Estimated Time:** 1-2 hours
**Confidence:** 0.95 (Band C)

---

### 1.2 Repository Analysis

**Task**: Clone and analyze source repositories

**Subtasks:**
- [ ] 1.2.1 Clone firecrawl-mcp-server
  ```bash
  cd /tmp/bun-mcp-migration/firecrawl
  git clone https://github.com/firecrawl/firecrawl-mcp-server.git
  cd firecrawl-mcp-server
  git checkout v3.2.1  # Latest release
  ```

- [ ] 1.2.2 Clone exa-mcp-server
  ```bash
  cd /tmp/bun-mcp-migration/exa
  git clone https://github.com/exa-labs/exa-mcp-server.git
  cd exa-mcp-server
  # Check latest tag/commit (no releases published)
  git describe --tags --always
  ```

- [ ] 1.2.3 Analyze firecrawl dependencies
  ```bash
  cd firecrawl-mcp-server
  cat package.json | jq '.dependencies, .devDependencies'
  ls -la | grep lock  # Check for package-lock.json and/or pnpm-lock.yaml
  ```

- [ ] 1.2.4 Analyze exa dependencies
  ```bash
  cd exa-mcp-server
  cat package.json | jq '.dependencies, .devDependencies'
  ls -la | grep lock
  ```

- [ ] 1.2.5 Test local Bun builds
  ```bash
  # For each repository:
  bun install
  bun run build
  # Check for errors or compatibility issues
  ```

**Success Criteria:**
- Both repositories cloned successfully
- Dependencies analyzed and documented
- Bun builds succeed locally
- No critical compatibility issues identified

**Dependencies:** 1.1
**Estimated Time:** 2-3 hours
**Confidence:** 0.88 (Band C)

---

## Phase 2: firecrawl-mcp Migration (Days 3-7)

### 2.1 Source Hash Acquisition

**Task**: Fetch GitHub source hash using Nix

**Subtasks:**
- [ ] 2.1.1 Get firecrawl-mcp source hash
  ```bash
  nix-prefetch-github firecrawl firecrawl-mcp-server --rev v3.2.1
  # Output will include hash like: sha256-...
  # Save this for derivation
  ```

- [ ] 2.1.2 Verify hash matches
  ```bash
  # Compare with manual fetch
  nix-build '<nixpkgs>' -A fetchFromGitHub --argstr owner firecrawl \
    --argstr repo firecrawl-mcp-server --argstr rev v3.2.1 \
    --argstr hash "sha256-HASH-FROM-PREVIOUS-STEP"
  ```

**Success Criteria:**
- Source hash obtained
- Hash verified and documented

**Dependencies:** 1.2
**Estimated Time:** 30 minutes
**Confidence:** 0.92 (Band C)

---

### 2.2 Determine Build System

**Task**: Identify if firecrawl uses npm or pnpm

**Subtasks:**
- [ ] 2.2.1 Check lockfile type
  ```bash
  cd /tmp/bun-mcp-migration/firecrawl/firecrawl-mcp-server
  if [ -f "pnpm-lock.yaml" ]; then
    echo "Uses pnpm - need fetchPnpmDeps approach"
  elif [ -f "package-lock.json" ]; then
    echo "Uses npm - can use buildNpmPackage"
  fi
  ```

- [ ] 2.2.2 Test build with detected tool
  ```bash
  # If pnpm:
  pnpm install && pnpm run build

  # If npm:
  npm install && npm run build
  ```

**Decision Point:**
- **If pnpm**: Use `stdenv.mkDerivation` + `fetchPnpmDeps` (like context7-mcp)
- **If npm**: Use `buildNpmPackage` (simpler)

**Success Criteria:**
- Build system identified
- Build succeeds with correct tool

**Dependencies:** 2.1
**Estimated Time:** 1 hour
**Confidence:** 0.90 (Band C)

---

### 2.3 Create Nix Derivation (npm path)

**Task**: Create firecrawl-mcp Nix package with Bun runtime

**Applies If**: firecrawl uses npm (package-lock.json)

**Subtasks:**
- [ ] 2.3.1 Create initial derivation in bun-custom.nix
  ```nix
  firecrawl-mcp-bun = pkgs.buildNpmPackage rec {
    pname = "firecrawl-mcp";
    version = "3.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "firecrawl";
      repo = "firecrawl-mcp-server";
      rev = "v${version}";
      hash = "sha256-HASH-FROM-2.1.1";
    };

    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    npmBuildScript = "build";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/firecrawl-mcp $out/bin
      cp -r dist $out/lib/firecrawl-mcp/
      cp package.json $out/lib/firecrawl-mcp/

      # Bun runtime wrapper
      makeWrapper ${pkgs.bun}/bin/bun $out/bin/firecrawl-mcp \
        --add-flags "run" \
        --add-flags "$out/lib/firecrawl-mcp/dist/index.js" \
        --set NODE_ENV production

      runHook postInstall
    '';

    meta = {
      description = "Firecrawl MCP server with Bun runtime (55-70% less memory)";
      homepage = "https://github.com/firecrawl/firecrawl-mcp-server";
      license = lib.licenses.mit;
      mainProgram = "firecrawl-mcp";
    };
  };
  ```

- [ ] 2.3.2 Build with empty npmDepsHash to get correct value
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
  nix build .#homeConfigurations.mitsio@shoshin.activationPackage 2>&1 | grep "got:"
  # Copy the sha256 hash from error
  ```

- [ ] 2.3.3 Update npmDepsHash in derivation
  ```nix
  npmDepsHash = "sha256-HASH-FROM-BUILD-ERROR";
  ```

- [ ] 2.3.4 Rebuild and verify build succeeds
  ```bash
  nix build .#homeConfigurations.mitsio@shoshin.activationPackage
  ```

**Success Criteria:**
- Derivation created in bun-custom.nix
- Build completes successfully
- Binary wrapper created

**Dependencies:** 2.2
**Estimated Time:** 2-3 hours
**Confidence:** 0.85 (Band C)

---

### 2.3-ALT Create Nix Derivation (pnpm path)

**Task**: Create firecrawl-mcp Nix package with pnpm + Bun runtime

**Applies If**: firecrawl uses pnpm (pnpm-lock.yaml)

**Subtasks:**
- [ ] 2.3-ALT.1 Check if monorepo or single package
  ```bash
  cd /tmp/bun-mcp-migration/firecrawl/firecrawl-mcp-server
  if [ -f "pnpm-workspace.yaml" ]; then
    echo "Monorepo - follow context7-mcp pattern exactly"
    cat pnpm-workspace.yaml
  else
    echo "Single package pnpm project - simpler approach"
  fi
  ```

- [ ] 2.3-ALT.2 Create derivation (monorepo approach)
  ```nix
  # Follow context7-mcp pattern EXACTLY
  # See mcp-servers/bun-custom.nix:130-199 for reference

  firecrawl-mcp-bun = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "firecrawl-mcp";
    version = "3.2.1";

    src = pkgs.fetchFromGitHub {
      owner = "firecrawl";
      repo = "firecrawl-mcp-server";
      rev = "v${version}";
      hash = "sha256-HASH-FROM-2.1.1";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpmConfigHook
      pkgs.pnpm_10
      pkgs.makeWrapper
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      # If monorepo, list workspace packages:
      # pnpmWorkspaces = [ "@firecrawl/mcp-server" ];
      # Or omit to fetch all workspace deps
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };

    buildPhase = ''
      runHook preBuild
      # If monorepo with workspace filter:
      # pnpm --filter=@firecrawl/mcp-server build
      # Otherwise:
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/firecrawl-mcp $out/bin

      # Adjust paths based on monorepo structure
      cp -r dist $out/lib/firecrawl-mcp/
      cp package.json $out/lib/firecrawl-mcp/

      # Bun wrapper
      makeWrapper ${pkgs.bun}/bin/bun $out/bin/firecrawl-mcp \
        --add-flags "run" \
        --add-flags "$out/lib/firecrawl-mcp/dist/index.js" \
        --set NODE_ENV production

      runHook postInstall
    '';

    meta = {
      description = "Firecrawl MCP server with Bun runtime (55-70% less memory)";
      homepage = "https://github.com/firecrawl/firecrawl-mcp-server";
      license = lib.licenses.mit;
      mainProgram = "firecrawl-mcp";
    };
  });
  ```

- [ ] 2.3-ALT.3 Build with empty pnpmDeps hash
  ```bash
  nix build .#homeConfigurations.mitsio@shoshin.activationPackage 2>&1 | tee build.log
  # Extract hash from error
  grep "got:" build.log | tail -1
  ```

- [ ] 2.3-ALT.4 Update pnpmDeps hash and rebuild
  ```nix
  hash = "sha256-ACTUAL-HASH";
  ```

**Success Criteria:**
- Derivation handles pnpm workspace correctly
- All dependencies fetched
- Build completes successfully

**Dependencies:** 2.2
**Estimated Time:** 3-4 hours
**Confidence:** 0.80 (Band C) - slightly lower due to pnpm complexity

---

### 2.4 Create MCP Wrapper

**Task**: Create systemd-isolated wrapper for firecrawl-mcp-bun

**Subtasks:**
- [ ] 2.4.1 Add wrapper to home.packages in bun-custom.nix
  ```nix
  home.packages = [
    # ... existing wrappers ...

    # Firecrawl (Bun) - Heavy: HTML parsing + API calls
    # Memory reduced from 1500M → 800M (Bun efficiency)
    # No NODE_OPTIONS needed - Bun has native memory management
    (mkMcpWrapper {
      name = "firecrawl-bun";
      package = firecrawl-mcp-bun;
      binary = "firecrawl-mcp";
      description = "MCP Server: Firecrawl Web Scraping (Bun runtime)";
      memoryMax = "800M";  # Down from 1500M with Node.js
      cpuQuota = "200%";
      # No nodeOptions parameter - not needed for Bun
    })
  ];
  ```

- [ ] 2.4.2 Update MCP server configuration
  ```nix
  # In home-manager configuration, add:
  mcp.servers.firecrawl-bun = {
    extraArgs = [ ];
    env = {
      # FIRECRAWL_API_KEY inherited from systemd environment
    };
  };
  ```

**Success Criteria:**
- Wrapper script created
- Systemd isolation configured
- Memory limit set to 800M (down from 1500M)

**Dependencies:** 2.3 or 2.3-ALT
**Estimated Time:** 1 hour
**Confidence:** 0.92 (Band C)

---

### 2.5 Testing & Validation

**Task**: Validate firecrawl-mcp-bun functionality

**Subtasks:**
- [ ] 2.5.1 Build home-manager configuration
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
  home-manager switch --flake .#mitsio@shoshin -b backup-$(date +%Y%m%d-%H%M%S)
  ```

- [ ] 2.5.2 Test MCP server startup
  ```bash
  mcp-firecrawl-bun --help
  # Should start without errors
  ```

- [ ] 2.5.3 Measure baseline metrics
  ```bash
  # Start server in background
  mcp-firecrawl-bun &
  MCP_PID=$!

  # Measure RSS memory
  ps -o rss,vsz,cmd -p $MCP_PID

  # Kill server
  kill $MCP_PID
  ```

- [ ] 2.5.4 Test with Claude Code/Desktop
  ```json
  // Update Claude Desktop config to use firecrawl-bun
  {
    "mcpServers": {
      "firecrawl": {
        "command": "mcp-firecrawl-bun",
        "env": {
          "FIRECRAWL_API_KEY": "test-key"
        }
      }
    }
  }
  ```

- [ ] 2.5.5 Run functional tests
  ```bash
  # Test each MCP tool:
  # - firecrawl_scrape
  # - firecrawl_crawl
  # - firecrawl_search
  # Verify all return expected results
  ```

- [ ] 2.5.6 Load testing
  ```bash
  # Scrape 10 URLs in parallel
  # Monitor memory usage: watch -n 1 'ps aux | grep firecrawl'
  # Expected: Stay under 800M
  ```

- [ ] 2.5.7 Compare with Node.js version
  ```bash
  # Metrics to compare:
  # - Startup time: time mcp-firecrawl vs time mcp-firecrawl-bun
  # - Idle memory: RSS after startup
  # - Peak memory: RSS during heavy scraping
  # - Throughput: requests/second

  # Document in comparison table
  ```

**Success Criteria:**
- Server starts successfully
- All MCP tools functional
- Memory usage ≤800M under load
- 50%+ memory reduction vs Node.js
- 10x+ faster startup

**Dependencies:** 2.4
**Estimated Time:** 3-4 hours
**Confidence:** 0.88 (Band C)

---

### 2.6 Documentation & Commit

**Task**: Document firecrawl-mcp migration and commit changes

**Subtasks:**
- [ ] 2.6.1 Update MCP_OPTIMIZATION_GUIDE.md
  ```markdown
  ## firecrawl-mcp (Bun Runtime)

  **Migration**: 2025-12-26 (context7-mcp approach)
  **Memory Improvement**: 55-70% reduction (1500M → 800M)
  **Startup Improvement**: 12x faster (actual measured)

  **Build System**: [npm/pnpm] (based on 2.2 findings)
  **Derivation**: bun-custom.nix (firecrawl-mcp-bun)

  **Wrapper**: mcp-firecrawl-bun
  **Memory Limit**: 800M (MemoryMax)
  **CPU Quota**: 200%
  ```

- [ ] 2.6.2 Create performance comparison table
  ```markdown
  | Metric | Node.js (old) | Bun (new) | Improvement |
  |--------|---------------|-----------|-------------|
  | Idle Memory | XXMB | XXMB | XX% |
  | Peak Memory | XXMB | XXMB | XX% |
  | Startup Time | XXms | XXms | XXx |
  | Throughput | XX req/s | XX req/s | XX% |
  ```

- [ ] 2.6.3 Commit changes
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
  git add mcp-servers/bun-custom.nix
  git commit -m "feat(mcp): Migrate firecrawl-mcp to Bun runtime for 55-70% memory savings"
  ```

- [ ] 2.6.4 Update ADR-010 if needed
  ```markdown
  ## 2025-12-26: Bun Runtime Migration (Phase 2)

  **Decision**: Migrate firecrawl-mcp to Bun runtime
  **Rationale**: 55-70% memory savings, 10-15x startup improvement
  **Status**: Implemented
  ```

**Success Criteria:**
- Documentation updated
- Performance data recorded
- Changes committed with descriptive message

**Dependencies:** 2.5
**Estimated Time:** 1-2 hours
**Confidence:** 0.95 (Band C)

---

## Phase 3: exa-mcp Migration (Days 8-12)

### 3.1 Source Analysis & Hash

**Task**: Analyze exa-mcp and fetch source hash

**Subtasks:**
- [ ] 3.1.1 Determine latest version
  ```bash
  # Check npm for latest version (no GitHub releases)
  curl -s https://registry.npmjs.org/exa-mcp-server/latest | jq -r '.version'
  # Current: 3.1.3
  ```

- [ ] 3.1.2 Decide: GitHub source vs npm tarball
  ```bash
  # Option A: Build from GitHub source (recommended for consistency)
  # - More control over build
  # - Can optimize dependencies
  # - Follows context7/firecrawl pattern

  # Option B: Wrap existing npm tarball with Bun
  # - Simpler (current approach)
  # - Less optimization potential
  # - Bun can still run the bundled code

  # RECOMMENDATION: Option A (build from source)
  ```

- [ ] 3.1.3 Fetch GitHub source hash (if Option A)
  ```bash
  # Find commit hash for version 3.1.3
  cd /tmp/bun-mcp-migration/exa/exa-mcp-server
  git log --oneline --all | grep "3.1.3" || git log --oneline | head -1

  # Get hash for that commit
  COMMIT_HASH=$(git rev-parse HEAD)
  nix-prefetch-github exa-labs exa-mcp-server --rev $COMMIT_HASH
  ```

- [ ] 3.1.4 Fetch npm tarball hash (if Option B)
  ```bash
  nix-prefetch-url https://registry.npmjs.org/exa-mcp-server/-/exa-mcp-server-3.1.3.tgz
  ```

**Decision Point:**
- **Recommended**: Option A (GitHub source build)
  - Consistent with context7-mcp approach
  - Better optimization potential
  - Full control over dependencies

**Success Criteria:**
- Latest version identified (3.1.3)
- Source hash obtained
- Build approach decided

**Dependencies:** Phase 2 complete
**Estimated Time:** 1 hour
**Confidence:** 0.90 (Band C)

---

### 3.2 Create exa-mcp Derivation

**Task**: Create exa-mcp-bun Nix package

**Applies If**: Building from GitHub source (Option A)

**Subtasks:**
- [ ] 3.2.1 Determine build system
  ```bash
  cd /tmp/bun-mcp-migration/exa/exa-mcp-server
  ls -la | grep lock
  # Check for pnpm-lock.yaml or package-lock.json
  ```

- [ ] 3.2.2 Create derivation
  ```nix
  # In bun-custom.nix

  exa-mcp-bun =
    let
      # If using buildNpmPackage:
      buildApproach = pkgs.buildNpmPackage rec {
        pname = "exa-mcp-server";
        version = "3.1.3";

        src = pkgs.fetchFromGitHub {
          owner = "exa-labs";
          repo = "exa-mcp-server";
          rev = "COMMIT-HASH-FROM-3.1.1";
          hash = "sha256-HASH-FROM-3.1.3";
        };

        npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        npmBuildScript = "build";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/lib/exa-mcp $out/bin
          cp -r build $out/lib/exa-mcp/  # exa uses 'build' not 'dist'
          cp package.json $out/lib/exa-mcp/

          makeWrapper ${pkgs.bun}/bin/bun $out/bin/exa-mcp-server \
            --add-flags "run" \
            --add-flags "$out/lib/exa-mcp/build/index.js" \
            --set NODE_ENV production

          runHook postInstall
        '';
      };

      # If using pnpm (stdenv.mkDerivation):
      # Follow context7-mcp pattern
    in
    buildApproach;
  ```

- [ ] 3.2.3 Build with empty hash to get deps hash
  ```bash
  nix build .#homeConfigurations.mitsio@shoshin.activationPackage 2>&1 | grep "got:"
  ```

- [ ] 3.2.4 Update hash and rebuild
  ```nix
  npmDepsHash = "sha256-ACTUAL-HASH";
  ```

**Success Criteria:**
- Derivation created
- Build completes successfully
- Bun wrapper functional

**Dependencies:** 3.1
**Estimated Time:** 2-3 hours
**Confidence:** 0.85 (Band C)

---

### 3.3 Create Wrapper & Test

**Task**: Wrap exa-mcp-bun and validate

**Subtasks:**
- [ ] 3.3.1 Add wrapper to home.packages
  ```nix
  # Exa (Bun) - Heavy: large result sets
  # Memory reduced from 1000M → 500M (Bun efficiency)
  (mkMcpWrapper {
    name = "exa-bun";
    package = exa-mcp-bun;
    binary = "exa-mcp-server";
    description = "MCP Server: Exa AI Search (Bun runtime)";
    memoryMax = "500M";  # Down from 1000M with Node.js
    cpuQuota = "200%";
  })
  ```

- [ ] 3.3.2 Build and test startup
  ```bash
  home-manager switch --flake .#mitsio@shoshin -b backup-$(date +%Y%m%d-%H%M%S)
  mcp-exa-bun --help
  ```

- [ ] 3.3.3 Functional testing
  ```bash
  # Test MCP tools:
  # - web_search_exa
  # - get_code_context_exa
  # - deep_search_exa (if enabled)
  ```

- [ ] 3.3.4 Performance benchmarking
  ```bash
  # Measure:
  # - Startup time comparison
  # - Memory usage (idle and under load)
  # - Response times for searches
  # Document in comparison table
  ```

**Success Criteria:**
- Server functional
- Memory ≤500M under load
- All MCP tools working
- Performance improvements documented

**Dependencies:** 3.2
**Estimated Time:** 2-3 hours
**Confidence:** 0.88 (Band C)

---

### 3.4 Documentation & Commit

**Task**: Document exa-mcp migration

**Subtasks:**
- [ ] 3.4.1 Update MCP_OPTIMIZATION_GUIDE.md
  ```markdown
  ## exa-mcp-server (Bun Runtime)

  **Migration**: 2025-12-26
  **Memory Improvement**: 45-55% reduction (1000M → 500M)
  **Startup Improvement**: XXx faster

  **Build System**: [determined in 3.2.1]
  **Wrapper**: mcp-exa-bun
  ```

- [ ] 3.4.2 Create performance table
  ```markdown
  | Metric | Node.js | Bun | Improvement |
  |--------|---------|-----|-------------|
  | ... | ... | ... | ... |
  ```

- [ ] 3.4.3 Commit changes
  ```bash
  git add mcp-servers/bun-custom.nix docs/
  git commit -m "feat(mcp): Migrate exa-mcp to Bun runtime for 45-55% memory savings"
  ```

**Success Criteria:**
- Documentation complete
- Changes committed

**Dependencies:** 3.3
**Estimated Time:** 1 hour
**Confidence:** 0.95 (Band C)

---

## Phase 4: Comparison & Optimization (Days 13-14)

### 4.1 Side-by-Side Comparison

**Task**: Run comprehensive comparison between Node.js and Bun versions

**Subtasks:**
- [ ] 4.1.1 Create comparison test suite
  ```bash
  # Script to test both versions:
  # - 10 sequential searches (exa)
  # - 10 sequential scrapes (firecrawl)
  # - 5 concurrent operations
  # Measure: time, memory, CPU
  ```

- [ ] 4.1.2 Run Node.js baseline
  ```bash
  # Use old mcp-firecrawl and mcp-exa
  # Document metrics
  ```

- [ ] 4.1.3 Run Bun comparison
  ```bash
  # Use new mcp-firecrawl-bun and mcp-exa-bun
  # Document metrics
  ```

- [ ] 4.1.4 Create final comparison report
  ```markdown
  # Bun Migration Results

  ## Overall Improvements
  - Total memory saved: XXX MB
  - Average startup improvement: XXx
  - CPU utilization improvement: XX%

  ## Per-Server Results
  [Detailed tables]
  ```

**Success Criteria:**
- Comprehensive metrics collected
- Comparison report created
- Results meet or exceed targets (50%+ memory, 10x+ startup)

**Dependencies:** Phase 2 & 3 complete
**Estimated Time:** 3-4 hours
**Confidence:** 0.90 (Band C)

---

### 4.2 Memory Limit Tuning

**Task**: Fine-tune memory limits based on actual usage

**Subtasks:**
- [ ] 4.2.1 Analyze peak memory usage
  ```bash
  # For each server, determine:
  # - P50 (median) memory usage
  # - P95 (95th percentile) memory usage
  # - P99 (99th percentile) memory usage
  # Set MemoryMax = P99 * 1.2 (20% headroom)
  ```

- [ ] 4.2.2 Adjust memory limits if needed
  ```nix
  # If firecrawl-bun peaks at 600M (P99):
  memoryMax = "720M";  # 600 * 1.2

  # If exa-bun peaks at 350M (P99):
  memoryMax = "420M";  # 350 * 1.2
  ```

- [ ] 4.2.3 Test under heavy load
  ```bash
  # Stress test with adjusted limits
  # Verify no OOM kills
  ```

**Success Criteria:**
- Optimal memory limits set
- No OOM kills under heavy load
- Headroom maintained for safety

**Dependencies:** 4.1
**Estimated Time:** 2 hours
**Confidence:** 0.88 (Band C)

---

### 4.3 Final Documentation

**Task**: Create comprehensive migration documentation

**Subtasks:**
- [ ] 4.3.1 Update ADR-010
  ```markdown
  ## Phase 3: Bun Runtime Migration (2025-12-26)

  **Migrated Servers**:
  - context7-mcp: 59-61% memory savings ✅
  - firecrawl-mcp: XX% memory savings ✅
  - exa-mcp: XX% memory savings ✅

  **Lessons Learned**:
  - [Key insights from migrations]

  **Future Migrations**:
  - [Other MCP servers to consider]
  ```

- [ ] 4.3.2 Create migration playbook
  ```markdown
  # Bun MCP Migration Playbook

  ## Standard Process
  1. Check build system (npm/pnpm)
  2. Fetch hashes with nix-prefetch-*
  3. Create derivation (buildNpmPackage or stdenv.mkDerivation)
  4. Wrap with Bun runtime
  5. Test thoroughly
  6. Adjust memory limits based on profiling

  ## Common Pitfalls
  - [Issues encountered and solutions]
  ```

- [ ] 4.3.3 Update README or project docs
  ```markdown
  ## MCP Server Optimization

  All MCP servers now use Bun runtime for:
  - 50-70% memory reduction
  - 10-15x faster startup
  - Better CPU utilization

  See docs/researches/2025-12-26_BUN_MCP_MIGRATION_RESEARCH.md
  ```

**Success Criteria:**
- ADR updated
- Playbook created for future migrations
- Project docs reflect new architecture

**Dependencies:** 4.2
**Estimated Time:** 2-3 hours
**Confidence:** 0.95 (Band C)

---

## Phase 5: Cleanup & Transition (Day 15)

### 5.1 Deprecate Old Wrappers

**Task**: Remove or deprecate Node.js versions

**Subtasks:**
- [ ] 5.1.1 Decision point: Keep both or remove old?
  ```markdown
  **Option A**: Keep both for transition period
  - mcp-firecrawl (Node.js, deprecated)
  - mcp-firecrawl-bun (Bun, recommended)

  **Option B**: Replace completely
  - Remove mcp-firecrawl wrapper
  - Rename mcp-firecrawl-bun → mcp-firecrawl

  **RECOMMENDATION**: Option A for 2 weeks, then Option B
  ```

- [ ] 5.1.2 If Option A: Add deprecation notices
  ```nix
  # Add to old wrapper descriptions
  description = "MCP Server: Firecrawl (Node.js) - DEPRECATED: Use mcp-firecrawl-bun";
  ```

- [ ] 5.1.3 Update Claude Desktop configs
  ```json
  // Replace old references:
  "firecrawl": {
    "command": "mcp-firecrawl-bun",  // Changed from mcp-firecrawl
    ...
  },
  "exa": {
    "command": "mcp-exa-bun",  // Changed from mcp-exa
    ...
  }
  ```

**Success Criteria:**
- Transition plan decided
- Configs updated
- Users notified if applicable

**Dependencies:** Phase 4 complete
**Estimated Time:** 1 hour
**Confidence:** 0.92 (Band C)

---

### 5.2 Monitoring Setup

**Task**: Ensure monitoring captures Bun servers

**Subtasks:**
- [ ] 5.2.1 Update MCP monitoring script
  ```bash
  # In mcp-monitor script, add:
  # - mcp-firecrawl-bun
  # - mcp-exa-bun
  # Track memory/CPU trends
  ```

- [ ] 5.2.2 Set up alerts for high memory usage
  ```bash
  # Alert if Bun server exceeds expected memory:
  # - firecrawl-bun > 700M → warning
  # - exa-bun > 450M → warning
  ```

- [ ] 5.2.3 Create dashboard or report
  ```markdown
  # Weekly MCP Performance Report

  ## Memory Usage Trends
  - context7-mcp-bun: AVG XXM, P95 XXM
  - firecrawl-mcp-bun: AVG XXM, P95 XXM
  - exa-mcp-bun: AVG XXM, P95 XXM

  ## Savings vs Node.js
  - Total memory saved: XXX MB/week
  ```

**Success Criteria:**
- Monitoring includes Bun servers
- Alerts configured
- Regular reporting in place

**Dependencies:** 5.1
**Estimated Time:** 2 hours
**Confidence:** 0.88 (Band C)

---

## Risk Management

### High-Risk Areas

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Express.js incompatibility with Bun | LOW | HIGH | Test thoroughly in Phase 2.5; fallback to Node.js |
| WebSocket library issues | MEDIUM | MEDIUM | Research `ws` compatibility; use alternative if needed |
| Production stability issues | LOW | HIGH | Phased rollout; keep Node.js version available |
| Higher-than-expected memory usage | LOW | MEDIUM | Conservative limits initially; tune after profiling |
| Dependency build failures | MEDIUM | MEDIUM | Research in Phase 1.2; adapt build approach |

### Contingency Plans

**If firecrawl-mcp fails with Bun:**
1. Keep Node.js version as primary
2. Investigate specific compatibility issue (likely Express or ws)
3. Consider alternative HTTP framework or WebSocket library
4. Fallback: Defer migration until Bun compatibility improves

**If exa-mcp fails with Bun:**
1. Fall back to npm tarball approach (current method)
2. Wrap existing bundle with Bun (less optimization but still gains)
3. Research specific dependency issues
4. Consider upstreaming fixes to Bun or exa-mcp

**If memory savings <30%:**
1. Re-evaluate approach (may need deeper optimizations)
2. Check for memory leaks or inefficiencies
3. Profile with Bun's built-in tools
4. Consider if migration ROI is worth it

---

## Success Metrics

### Primary Metrics

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| **firecrawl Memory Reduction** | ≥55% | `ps -o rss` under load vs baseline |
| **exa Memory Reduction** | ≥45% | `ps -o rss` under load vs baseline |
| **firecrawl Startup Improvement** | ≥10x | `time mcp-firecrawl-bun` vs `time mcp-firecrawl` |
| **exa Startup Improvement** | ≥10x | `time mcp-exa-bun` vs `time mcp-exa` |
| **Functionality** | 100% | All MCP tools pass functional tests |
| **Stability** | No crashes in 48h | Run load tests, monitor for OOM/crashes |

### Secondary Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **CPU Efficiency (firecrawl)** | 20-30% reduction | `top` during HTML parsing |
| **CPU Efficiency (exa)** | 5-15% reduction | `top` during searches |
| **Throughput (firecrawl)** | ≥25% improvement | Requests/second benchmark |
| **Throughput (exa)** | ≥5% improvement | Searches/second benchmark |

---

## Timeline Summary

| Phase | Days | Description | Deliverable |
|-------|------|-------------|-------------|
| **Phase 1** | 1-2 | Preparation & Setup | Baseline metrics, repos cloned |
| **Phase 2** | 3-7 | firecrawl-mcp Migration | firecrawl-mcp-bun functional |
| **Phase 3** | 8-12 | exa-mcp Migration | exa-mcp-bun functional |
| **Phase 4** | 13-14 | Comparison & Optimization | Performance report, tuned limits |
| **Phase 5** | 15 | Cleanup & Transition | Deprecated old versions, monitoring |

**Total Duration**: 15 days (part-time, ~3 weeks calendar time)

---

## Dependencies & Prerequisites

### Required Tools
- ✅ Nix with flakes enabled
- ✅ Bun ≥1.0
- ✅ nix-prefetch-github, nix-prefetch-url
- ✅ Git
- ✅ Home-manager
- ⚠️ npm/pnpm (for local testing)
- ⚠️ jq (for JSON parsing in scripts)

### Required Knowledge
- ✅ Nix derivation creation (proven with context7-mcp)
- ✅ Bun basics (runtime, wrapper creation)
- ✅ MCP server architecture
- ⚠️ pnpm workspace management (if needed)
- ⚠️ Systemd resource isolation

### Required Access
- ✅ GitHub (exa-labs, firecrawl repos)
- ✅ npm registry
- ✅ Local shoshin system
- ⚠️ API keys for testing (EXA_API_KEY, FIRECRAWL_API_KEY)

---

## Appendix A: Quick Reference Commands

### Hash Fetching
```bash
# GitHub source
nix-prefetch-github <owner> <repo> --rev <tag-or-commit>

# npm tarball
nix-prefetch-url https://registry.npmjs.org/<package>/-/<package>-<version>.tgz
```

### Building & Testing
```bash
# Build home-manager
cd ~/.MyHome/MySpaces/my-modular-workspace/home-manager
nix build .#homeConfigurations.mitsio@shoshin.activationPackage

# Quick test build
nix-build -E 'with import <nixpkgs> {}; callPackage ./mcp-servers/bun-custom.nix {}'

# Apply changes
home-manager switch --flake .#mitsio@shoshin -b backup-$(date +%Y%m%d-%H%M%S)
```

### Profiling
```bash
# Memory usage
ps -o pid,rss,vsz,cmd -C mcp-firecrawl-bun

# Continuous monitoring
watch -n 1 'ps aux | grep mcp-'

# Startup time
hyperfine 'mcp-firecrawl-bun --help' 'mcp-firecrawl --help'
```

---

## Appendix B: Lessons from context7-mcp

### What Worked Well
1. ✅ **pnpm workspace support** with `fetchPnpmDeps` + `stdenv.mkDerivation`
2. ✅ **Preserving directory structure** for symlink resolution
3. ✅ **Bun wrapper via makeWrapper** - clean and simple
4. ✅ **Systemd isolation** - works perfectly with Bun
5. ✅ **Removing Node.js tuning flags** - Bun doesn't need them

### Challenges Encountered
1. ⚠️ **Initial lockfile format confusion** (pnpm vs npm)
2. ⚠️ **Broken symlinks** when not preserving monorepo structure
3. ⚠️ **Missing workspace dependencies** when filtering too aggressively
4. ⚠️ **Hash iteration** - required multiple builds to get correct hashes

### Apply to This Migration
- ✅ Check lockfile type first (don't assume)
- ✅ Preserve directory structure if monorepo
- ✅ Don't filter workspace packages unless certain
- ✅ Use placeholder hash initially, iterate to get correct value
- ✅ Test thoroughly before declaring success

---

## Appendix C: Context for Future Reference

**Project**: my-modular-workspace
**System**: shoshin (NixOS desktop)
**Home Manager**: Flake-based configuration
**MCP Architecture**: Per ADR-010 (Unified MCP Server Architecture)

**Related Documents**:
- Research: `docs/researches/2025-12-26_BUN_MCP_MIGRATION_RESEARCH.md`
- ADR: `docs/adr/ADR-010-UNIFIED_MCP_SERVER_ARCHITECTURE.md`
- Optimization Guide: `docs/MCP_OPTIMIZATION_GUIDE.md`

**Contact for Issues**:
- GitHub Issues: my-modular-workspace-docs repo
- Local Notes: `~/.MyHome/MySpaces/my-modular-workspace/docs/`

---

**Plan Status**: ✅ READY FOR IMPLEMENTATION
**Confidence**: 0.84 (Band C - High confidence, safe to proceed)
**Next Action**: Begin Phase 1.1 (Environment Setup)

---

**Plan Created By**: Planner + Ops & Platform Engineer roles
**Plan Reviewed**: Technical Researcher role
**Plan Approved**: Ready for user approval

**Estimated Total Effort**: 40-50 hours over 2-3 weeks (part-time)
**Expected ROI**: Very High (⭐⭐⭐⭐⭐)
