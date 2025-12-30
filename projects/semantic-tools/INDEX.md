# Project: Semantic Search & AI Discovery Tools

**Status:** ACTIVE
**Goal:** Implement a multi-layered semantic search capability (ck, semtools, semantic-grep) for the entire workspace.

## Documentation Index

- [**RESEARCH.md**](RESEARCH.md): Consolidated research on GPU acceleration for embedding models (NVIDIA GTX 960), ONNX runtime optimization, and model benchmarks.
- [**PLAN.md**](PLAN.md): Integration plan for `ck`, `semtools`, and `semantic-grep`. Rebuilding `ck` for GPU support.
- [**USAGE.md**](USAGE.md): Comparative usage guide for all semantic tools in the workspace.

## Core Toolset
- **CK (Code Knowledge)**: Primary hybrid search tool (semantic + BM25) with TUI and MCP server.
- **Semantic-Grep**: Lightweight Go-based semantic search for quick command-line queries.
- **Semtools**: Python-based document processing and embedding utilities.
- **Codex RAG**: Advanced retrieval-augmented generation for AI agents.

## Key Optimizations
- **GPU Acceleration**: Offloading embedding generation to NVIDIA GPU via ONNX Runtime to save CPU cycles.
- **Hybrid Search**: Combining vector search with traditional keyword matching for maximum recall.
- **Context Compaction**: Techniques to minimize token usage when feeding search results to LLMs.
