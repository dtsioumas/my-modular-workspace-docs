# Open Semantic Search - Enterprise Document Search Platform

**Tool:** Open Semantic Search
**Repository:** https://github.com/opensemanticsearch/open-semantic-search
**Website:** https://opensemanticsearch.org
**Stars:** 1.1k
**License:** GPL-3.0
**Language:** Shell (71.4%), Dockerfile (24.6%), JavaScript (4%)
**Installation:** Docker Compose or Debian packages

---

## Overview

Open Semantic Search is a comprehensive research tool for searching, browsing, analyzing, and exploring large document collections. It's designed for enterprise use cases like investigative journalism, OSINT, and research institutions.

### Key Differentiator

- **Full Platform** - Not just a CLI tool, but a complete search server
- **ETL Framework** - Crawling, text extraction, OCR, NER
- **Web UI** - Faceted search interface
- **Knowledge Graph** - Neo4j integration for relationship mapping

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Search Server** | Integrated Solr-based full-text search |
| **Document ETL** | Crawling, extraction, OCR, metadata |
| **OCR** | Image and PDF text extraction |
| **NER** | Named entity recognition (spaCy) |
| **Thesaurus** | Metadata management via ontologies |
| **Faceted Search** | Multi-dimensional filtering UI |
| **Knowledge Graph** | Neo4j graph database integration |

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                Open Semantic Search                  │
├─────────────────────────────────────────────────────┤
│  Web UI (Port 8080)                                 │
│    └── Faceted Search Interface                     │
├─────────────────────────────────────────────────────┤
│  Services (Docker Compose)                          │
│    ├── Solr (Search Engine)                        │
│    ├── Tika (Text Extraction)                       │
│    ├── spaCy (NER)                                  │
│    └── Neo4j (Knowledge Graph)                      │
├─────────────────────────────────────────────────────┤
│  ETL Framework (Python)                             │
│    └── Document Processing Pipeline                 │
└─────────────────────────────────────────────────────┘
```

---

## Installation

### Via Docker Compose (Recommended)

```bash
# Clone repository
git clone --recurse-submodules --remote-submodules \
  https://github.com/opensemanticsearch/open-semantic-search.git
cd open-semantic-search

# Build and run
docker-compose build
docker-compose up

# Access at http://localhost:8080/search/
```

### Via Debian Package

```bash
# Build deb package
./build-deb

# Install on Debian/Ubuntu
sudo dpkg -i open-semantic-search_*.deb
```

---

## Use Cases

### 1. Investigative Journalism

- Import leaked documents
- OCR scanned PDFs
- Entity extraction (names, organizations)
- Knowledge graph visualization

### 2. OSINT Research

- Crawl web sources
- Faceted filtering by entity type
- Timeline analysis
- Relationship mapping

### 3. Enterprise Document Management

- Index corporate documents
- Thesaurus-based tagging
- Compliance auditing
- Discovery/eDiscovery

---

## Services & Dependencies

| Service | Purpose | Port |
|---------|---------|------|
| Solr | Full-text search | 8983 |
| Tika Server | Text extraction | 9998 |
| spaCy Services | NER | 5000 |
| Neo4j | Knowledge graph | 7474 |
| Web UI | Search interface | 8080 |

**Resource Requirements:**
- RAM: 8GB+ recommended
- Disk: Varies by document volume
- CPU: Multi-core for NER

---

## Assessment for My-Modular-Workspace

### Pros

- Comprehensive feature set
- Web UI included
- Strong document processing
- Knowledge graph capabilities

### Cons

- **Heavy resource footprint** (multiple Docker containers)
- **Complex setup** (many services to manage)
- **GPL-3.0 license** (copyleft implications)
- **Overkill for personal use** (designed for enterprise)
- **Not CLI-focused** (web UI primary interface)
- **No MCP integration** (not designed for AI agents)
- **Maintenance burden** (Solr, Neo4j, etc.)

### Verdict: NOT RECOMMENDED for My-Modular-Workspace

**Reasons:**
1. Too heavy for personal workspace
2. No Claude Code/MCP integration
3. Designed for document research, not code search
4. Requires running multiple services
5. Better alternatives exist (ck, semtools)

---

## Comparison

| Criteria | Open Semantic Search | ck | semtools |
|----------|---------------------|-----|----------|
| Complexity | High (multi-service) | Low (single binary) | Medium (CLI) |
| Resource Usage | Heavy | Light | Light |
| MCP Support | No | Yes | No |
| Code Search | No | Yes | Limited |
| Document Parsing | Yes (Tika) | No | Yes (LlamaParse) |
| Offline | Yes | Yes | Partial |
| License | GPL-3.0 | MIT/Apache | MIT |

---

## When to Use Open Semantic Search

Use Open Semantic Search if you need:
- Enterprise document management
- OCR for large PDF collections
- Named entity extraction at scale
- Knowledge graph visualization
- Faceted search web interface

**Don't use it for:**
- Personal workspace search
- Code search
- Claude Code integration
- Lightweight CLI workflows

---

## References

- **GitHub:** https://github.com/opensemanticsearch/open-semantic-search
- **Website:** https://opensemanticsearch.org
- **Documentation:** https://opensemanticsearch.org/doc/search/
- **Architecture:** https://github.com/opensemanticsearch/open-semantic-search/blob/master/docs/doc/modules/README.md

---

## Changelog

| Date | Notes |
|------|-------|
| 2025-04-19 | Last commit (typo fix) |
| 2025-12-01 | Documented for my-modular-workspace |

---

**Status:** NOT RECOMMENDED for integration
**Reason:** Too heavy, no MCP support, designed for enterprise
**Alternative:** Use **ck** for code search, **semtools** for document parsing

---

**Maintained by:** mitsio
**Documentation Path:** `docs/tools/open-semantic-search.md`
