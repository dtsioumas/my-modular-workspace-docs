# GPU Utilization Deep Research: Claude Code, Gemini CLI, and Codex

**Author:** Research Session (Week 52, 2025)
**Date:** 2025-12-22
**Status:** Comprehensive Deep Research Report
**Confidence Level:** Band C (0.85+)

---

## Executive Summary

This document presents comprehensive findings on GPU utilization possibilities for Claude Code, Gemini CLI, and GitHub Copilot/Codex. While **direct local GPU support is not currently available** in any of these agents, **multiple proven indirect pathways exist** for GPU-accelerated execution, with clear implementation patterns documented in both enterprise and community projects.

### Key Finding: No Direct GPU, But Rich Ecosystem of Workarounds

- **Claude Code**: Can orchestrate GPU-accelerated tasks via MCP servers, Docker, and local Python environments
- **Gemini CLI**: Lacks direct local execution capability; no built-in Ollama/LM Studio integration (feature request open)
- **GitHub Copilot/Codex**: Purely cloud-based; zero local execution support; community alternatives exist

---

## Part 1: Status Quo Assessment

### 1.1 Claude Code

**Status:** Cloud-based agent with LOCAL tool execution capability via shell commands and MCP servers

**Direct GPU Support:** ❌ No native GPU inference
- Claude Code model inference runs on Anthropic's cloud infrastructure
- Agent itself is NOT GPU-accelerated

**Indirect GPU Capability:** ✅ Yes, multiple pathways

**Key Capabilities:**
- Executes shell commands within user's local environment (including Python scripts)
- Inherits CUDA toolkit, drivers, and GPU availability from host system
- Can invoke Python scripts that use PyTorch/TensorFlow with CUDA
- Connects to local and remote MCP servers for extended functionality
- Can read/write Jupyter notebooks with stateful kernel execution
- Functions as both MCP client and server

**Evidence & Sources:**
- Claude Code can execute Python CUDA code through shell commands if local CUDA environment is available
- MCP protocol enables integration with GPU-accelerated local tools
- Users report success running CUDA workloads via Claude Code's shell execution
- Jupyter MCP integration enables GPU-accelerated Jupyter kernels

---

### 1.2 Gemini CLI

**Status:** Cloud-only API client with NO local execution support

**Direct GPU Support:** ❌ No
- Pure API client to Google's Gemini API
- All inference happens on Google's servers

**Indirect GPU Capability:** ❌ None currently

**Key Limitations:**
- Does NOT support local LLM integration (Ollama, LM Studio)
- Feature request #2318 and #10619 exist but remain OPEN
- Community has asked for OpenAI-compatible API support
- Locked to Gemini API; cannot swap backends

**Status:** Not a viable candidate for local GPU acceleration without API layer re-architecture

---

### 1.3 GitHub Copilot / Codex

**Status:** Cloud-only service; no local execution whatsoever

**Direct GPU Support:** ❌ No
- Codex model runs on GitHub/OpenAI servers using cloud GPUs
- All inference is remote

**Indirect GPU Capability:** ❌ None
- No local execution hooks
- No MCP support
- No ability to integrate local models
- Interface "runs locally" (VS Code extension) but computation is always remote

**Recent News (August 2025):**
- GitHub Codespaces **dropped GPU support** (deadline: August 29, 2025)
- Indicates GitHub is moving away from on-demand GPU compute

**Alternatives with GPU:**
- BLACKBOX AI supports GPU acceleration and remote parallel task execution as a Copilot alternative
- Continue extension + local LLM (llama.cpp, Ollama) in VS Code provides local GPU coding

---

## Part 2: Indirect GPU Utilization Pathways

### 2.1 Claude Code + Local Python + CUDA/PyTorch

**Viability:** ✅ Proven and widely used
**Difficulty:** Low-Medium
**Setup Time:** 15-30 minutes

**Architecture:**
```
Claude Code (cloud agent)
    ↓
Shell Command Execution (via MCP)
    ↓
Python Script (using PyTorch/TensorFlow)
    ↓
CUDA Toolkit + GPU Drivers (local)
    ↓
NVIDIA GPU (local)
```

**Implementation Steps:**

1. **Prerequisite**: System has NVIDIA drivers and CUDA toolkit installed
2. **Claude Code Usage:**
   ```bash
   claude "Write a PyTorch script that trains a model using CUDA"
   ```
3. Claude generates Python code using `.cuda()` or `.to('cuda')`
4. Claude Code executes the script via shell command
5. Local GPU handles computation
6. Results returned to Claude for analysis

**Evidence:**
- Sionic AI uses Claude Code to write training scripts and debug CUDA errors overnight
- Users successfully ran CUDA code for ML experiments with 1,000+ runs per day
- DeepSeek-OCR with NVIDIA Spark uses Claude Code for CUDA debugging

**Limitations:**
- Best for ONE-SHOT compute (train a model, get results)
- NOT ideal for interactive GPU-accelerated development
- Agent cannot "hold" GPU state between requests
- Each execution is isolated

---

### 2.2 Claude Code + Jupyter Kernel (GPU-Enabled)

**Viability:** ✅ Proven, stateful, production-ready
**Difficulty:** Medium
**Setup Time:** 30-60 minutes
**Performance:** Excellent for iterative work

**Architecture:**
```
Claude Code (agent)
    ↓
MCP Protocol
    ↓
Jupyter Kernel Server (local or remote)
    ↓
GPU (CUDA/ROCm)
```

**Key Components:**

1. **Jupyter Kernel on GPU Machine:**
   - Can be local or cloud-hosted
   - Persistent state across multiple agent calls
   - Full CUDA access

2. **MCP Integration:**
   - `mcp__sandbox__execute_code` tool allows stateful Python execution
   - ClaudeJupy: Persistent Python & Jupyter for Claude AI
   - JupyterMCP: MCP server that connects Jupyter to Claude

3. **Workflow:**
   ```
   Claude Code → MCP Server → Jupyter Kernel → CUDA → Results
   Claude Code → Keep state → Reuse variables → CUDA again
   ```

**Evidence:**
- ClaudeJupy and JupyterMCP both documented and actively maintained
- From Local to GPU Cloud in One Click: Jupyter Remote Kernel guides available
- Recommended workflow: Claude Code + .ipynb file side-by-side in VS Code

**Setup Example (ClaudeJupy):**
```bash
pip install claudejupy
# Then configure Claude Code to use ClaudeJupy as MCP server
# Gain persistent GPU-accelerated Jupyter kernel
```

**Advantages:**
- Stateful execution (variables persist across calls)
- Visualization support (matplotlib, plotly in terminal)
- True iterative development with Claude

---

### 2.3 Claude Code + Local MCP Server (Custom Tools)

**Viability:** ✅ Proven but requires engineering
**Difficulty:** Medium-High
**Setup Time:** 1-3 hours

**Architecture:**
```
Claude Code (agent)
    ↓
MCP Protocol (standardized)
    ↓
Custom MCP Server (your code)
    ↓
Ray / vLLM / CUDA Backend
    ↓
GPU
```

**Implementation Patterns:**

1. **Build MCP Server with GPU Tools:**
   - Use Node.js or Python SDK for MCP
   - Expose GPU-accelerated functions as tools
   - Example: MCP server wrapping vLLM inference

2. **GPU Task Examples:**
   - Inference on local quantized models
   - Distributed training via Ray
   - Image processing with CUDA
   - Vector database operations

3. **Resource Limits:**
   - Docker sandbox MCP: 512MB RAM, 0.75 CPU cores
   - Can be customized for GPU-heavy workloads

**Evidence:**
- AMD MCP blog: "Enabling Real-Time Context for LLMs: MCP on AMD GPUs"
- AMD MI300X GPU running vLLM with MCP backend confirmed working
- Qualcomm: "How MCP simplifies tool integration across cloud, edge, and real-world devices"

**Example Community Tools:**
- mcp-shell: Universal shell connectivity (can pipe to GPU commands)
- claude-mcp: Various tools to extend Claude-code functionalities
- n8n-mcp: Workflow automation (can trigger GPU jobs)

---

### 2.4 Claude Code + Docker GPU Passthrough

**Viability:** ✅ Production-grade approach
**Difficulty:** Medium
**Setup Time:** 30-45 minutes
**Performance:** Near-native GPU performance

**Architecture:**
```
Claude Code Shell Command
    ↓
docker run --gpus all nvidia/cuda:12.6.2
    ↓
Docker Container with CUDA Toolkit
    ↓
GPU Drivers (host passthrough)
    ↓
NVIDIA GPU
```

**Prerequisites:**
- NVIDIA Container Toolkit (nvidia-docker successor)
- Docker >= 19.03
- NVIDIA drivers >= 418.81
- CUDA-capable GPU

**Implementation:**

1. **On Host System:**
   ```bash
   # Install NVIDIA Container Toolkit
   curl https://get.docker.com | sh
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   ```

2. **From Claude Code:**
   ```bash
   claude "Run a CUDA computation in Docker container"
   ```

3. **Claude generates:**
   ```bash
   docker run --gpus all \
     -v /home/user/data:/data \
     nvidia/cuda:12.6.2-devel-ubuntu22.04 \
     python /data/train.py
   ```

4. **Container sees GPU as if native:**
   ```bash
   nvidia-smi  # Works inside container
   ```

**Advantages:**
- Isolated execution (no GPU binaries on host)
- Version control (CUDA 12.1, 12.6, etc. pinned in Dockerfile)
- Audit trail of what ran
- Easy rollback

**Docker Compose Example:**
```yaml
services:
  cuda-worker:
    image: nvidia/cuda:12.6.2-devel-ubuntu22.04
    runtime: nvidia
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    volumes:
      - ./workspace:/workspace
```

---

### 2.5 Claude Code + vLLM Local Inference

**Viability:** ✅ Proven, documentation exists
**Difficulty:** Medium
**Setup Time:** 45-90 minutes
**Inference Speed:** 150+ tokens/sec on RTX 4090

**Architecture:**
```
Claude Code (agent)
    ↓
Local HTTP API (OpenAI-compatible)
    ↓
vLLM Engine (optimized inference)
    ↓
GPU (CUDA KERNELS)
    ↓
Local Model (Qwen, Llama, etc.)
```

**Use Case:** Local coding assistant (smaller models) running alongside Claude Code

**Setup:**

1. **Install vLLM with CUDA:**
   ```bash
   pip install vllm --extra-index-url https://download.pytorch.org/whl/cu129
   ```

2. **Launch vLLM Server:**
   ```bash
   vllm serve Qwen/Qwen3-Coder-30B-A3B-Instruct \
     --gpu-memory-utilization 0.9 \
     --tensor-parallel-size 1
   ```

3. **Claude Code Calls vLLM:**
   ```bash
   claude "Use the local vLLM API to ask Qwen3 a coding question"
   ```

4. **Claude Code Makes HTTP Request:**
   ```python
   import requests
   response = requests.post(
       "http://localhost:8000/v1/completions",
       json={"model": "Qwen3-Coder-30B", "prompt": "def hello():"}
   )
   ```

**Model Requirements:**
- 7B models: 16GB VRAM minimum
- 13B models: 40GB+ VRAM
- 30B models: 80GB+ VRAM
- Quantization reduces by 75% (e.g., 4-bit quantization: 7B → 4GB)

**Evidence & Production Use:**
- NVIDIA Spark + vLLM + Claude Code Router (production deployment documented)
- Dataflow ML on Google Cloud uses vLLM for GPU inference
- Performance: NVIDIA RTX 4090 achieves ~150 tokens/sec on 30B models

**Advanced: Docker Deployment:**
```bash
docker run -it -d \
  --name vllm-server \
  --gpus all \
  -p 8000:8000 \
  --ipc=host \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  nvcr.io/nvidia/vllm:25.09-py3 \
  vllm serve Qwen/Qwen3-Coder-30B-A3B-Instruct
```

---

### 2.6 Claude Code + Ray Distributed Computing

**Viability:** ✅ Proven for complex workflows
**Difficulty:** High
**Setup Time:** 2-4 hours
**Use Case:** Large-scale parallel GPU compute tasks

**Architecture:**
```
Claude Code (orchestrator)
    ↓
Ray Client (Python)
    ↓
Ray Cluster (head + workers)
    ↓
Multiple GPUs (parallelized tasks)
```

**Workflow:**

1. **Define GPU-accelerated Ray tasks:**
   ```python
   @ray.remote(num_gpus=1)
   def train_model(config):
       # This runs on a Ray worker with exclusive GPU access
       import torch
       model = torch.nn.Linear(10, 1).cuda()
       # Training code...
       return results
   ```

2. **Claude Code orchestrates:**
   ```bash
   claude "Use Ray to train 10 models in parallel on our 4-GPU cluster"
   ```

3. **Claude generates:**
   ```python
   import ray
   ray.init(address="ray://localhost:10001")

   futures = [train_model.remote(config) for config in configs]
   results = ray.get(futures)
   ```

**Capabilities:**
- Automatic resource scheduling (GPUs, CPUs, custom resources)
- Fault tolerance and automatic failover
- Distributed training, hyperparameter search, etc.
- Works on laptop, cluster, or cloud (no code changes)

**Evidence:**
- Ray is used to power ML experiment infrastructure at scale
- Supports NVIDIA GPUs, AMD GPUs, TPUs
- ChatGPT and other LLM services use Ray for training

---

### 2.7 Kitty Terminal + GPU Rendering (Minor Optimization)

**Viability:** ✅ Already confirmed in global config
**Difficulty:** Low
**Setup Time:** 5-10 minutes
**Performance Impact:** Terminal rendering only (not agent computation)

**What This Covers:**
- GPU-accelerated terminal rendering (not computation)
- Faster scrollback, animations, text rendering
- Graphics protocol for displaying images in terminal
- Useful for real-time output monitoring

**NOT GPU Compute Acceleration:**
- Kitty doesn't accelerate Python/CUDA execution
- Only accelerates display/rendering
- Complements but doesn't replace compute GPU usage

**Evidence:** Already confirmed in your global config as working on shoshin

---

## Part 3: Alternative Agents with Native GPU Support

### 3.1 llama.cpp Local Inference

**What It Is:** C++ inference engine with GPU acceleration (not a full agent like Claude Code)

**GPU Support:** ✅ Full CUDA, ROCm, Metal, Vulkan

**Key Features:**
- Custom CUDA kernels for NVIDIA GPUs
- AMD GPU support via HIP backend
- Apple Silicon acceleration via Metal
- Intel GPU support via SYCL
- OpenAI-compatible server (allows tool use)

**Performance:**
- NVIDIA RTX 4090: ~150 tokens/sec
- Supports quantization (4-bit: reduces 7B model from 14GB to 4GB)

**Integration with Claude Code:**
```bash
# Start llama.cpp server
llama-server -m model.gguf -ngl 33 -p "Prompt:" -n 256

# Then from Claude Code
curl http://localhost:8000/completion -X POST \
  -H "Content-Type: application/json" \
  -d '{"prompt": "...", "n_predict": 256}'
```

**Sources:**
- Accelerating LLMs with llama.cpp on NVIDIA RTX Systems (NVIDIA official)
- Run LLMs on Intel GPUs Using llama.cpp (Intel official)
- Community projects: Jan.ai (desktop wrapper), others

---

### 3.2 Ollama + Claude Code Integration (Requested Feature)

**Status:** Community wants this; Anthropic hasn't implemented

**Feature Request:** Issue #2318 in google-gemini/gemini-cli (open)
- Request for Ollama API integration
- Allow swapping Gemini backend for local models

**Current Limitation:**
- Ollama itself supports GPU (tested and proven)
- Gemini CLI doesn't support local model backends
- Workaround: Use LiteLLM proxy + environment variables

**Why This Matters:**
- Ollama is easiest local GPU LLM setup (one `brew install ollama`)
- Excellent model support (Llama 3, Mistral, Qwen, Gemma, etc.)
- Full CUDA acceleration built-in
- Desktop app available

---

### 3.3 LM Studio with Claude Code Router (Working Setup)

**Status:** ✅ Proven and documented
**Difficulty:** Low
**Setup Time:** 15-20 minutes

**Components:**
1. **LM Studio**: Desktop app, runs local models with GPU
2. **Claude Code Router**: npm package that routes requests intelligently
3. **Result:** Claude Code with fallback to local Qwen/Llama models

**Setup:**
```bash
# Install tools
npm install -g @anthropic-ai/claude-code
npm install -g @musistudio/claude-code-router

# Run LM Studio (start UI, load a model with GPU acceleration)
# Then launch Claude Code with router
claude-code-router --local-model qwen3-coder:latest
```

**Benefits:**
- Keep using Claude Code interface
- Fallback to local GPU model for simple tasks
- Reduces Claude API costs
- Full GPU acceleration via LM Studio

---

## Part 4: MCP Ecosystem & GPU Integration

### 4.1 MCP (Model Context Protocol) Overview

**What:** Open standard from Anthropic for AI-tool integration (adopted by OpenAI, Google, GitHub in 2025)

**GPU Relevance:** MCP servers can wrap GPU-accelerated tools

**Status as of December 2025:**
- Officially adopted by OpenAI (March 2025)
- Google Gemini confirmed MCP support (April 2025)
- GitHub Copilot MCP support (August 2025, general availability)
- Donated to Linux Foundation's Agentic AI Foundation (December 2025)

### 4.2 AMD GPU MCP Example (Production Pattern)

**Evidence:** AMD ROCm blog post "Enabling Real-Time Context for LLMs: MCP on AMD GPUs"

**Architecture:**
- vLLM serving engine running on AMD MI300X GPU
- MCP server wrapping vLLM API
- Claude connects via MCP protocol
- Results in GPU-accelerated inference through Claude

**Lesson:** Same pattern works with NVIDIA GPUs + vLLM + custom MCP server

### 4.3 Community MCP Servers (GPU-Adjacent)

**Available MCP Servers:**
- `mcp-shell`: Shell command execution (can pipe to GPU workloads)
- `claude-code-mcp`: MCP wrapper for Claude Code itself
- `claude-mcp`: Extended tools and capabilities
- `n8n-mcp`: Workflow automation (can trigger GPU jobs)
- Docker MCP Toolkit: Container execution with isolation

**Strategy:** Build MCP server that wraps your GPU-accelerated tool, expose it to Claude Code

---

## Part 5: Feature Requests & Future Directions

### 5.1 Claude Code Feature Requests (Open as of Dec 2025)

**Issue #7178: Support for Self-Hosted LLMs**
- **Status:** OPEN, 18 reactions, 6+ comments
- **Request:** Allow Claude Code to use OpenAI-compatible APIs (vLLM, Ollama, LM Studio, etc.)
- **Business Case:** Enterprise on-prem, researchers, startups, cost reduction
- **Workaround Available:** LiteLLM proxy + environment variables

**Workaround Implementation:**
```yaml
# config.yaml
model_list:
  - model_name: local-qwen
    litellm_params:
      model: ollama/qwen3-coder:latest
      api_base: "http://localhost:11434"
```

```bash
export ANTHROPIC_BASE_URL="http://localhost:4000"
export ANTHROPIC_AUTH_TOKEN="my-key"
claude "Your prompt" --model local-qwen
```

**Issue #10658: GPU/CUDA Environment Diagnostics**
- **Status:** OPEN, marked CRITICAL
- **Request:** Auto-detect GPU, check PyTorch versions, suggest appropriate fixes
- **Real Problem:** Claude suggests compiling PyTorch from source when just upgrading the pip package would fix it
- **Workaround:** Manually run `nvidia-smi` and `pip list` before asking Claude

### 5.2 Gemini CLI Feature Requests (Open)

**Issue #2318: API Integration Support (Ollama, LM Studio)**
- **Status:** OPEN
- **Request:** Support OpenAI-compatible APIs
- **Likelihood:** Unknown (Google has different strategic goals)
- **Current Fallback:** Use Gemini API as-is (no local execution possible)

### 5.3 GitHub Copilot / Codex (No GPU Roadmap)

**Status:** Cloud-only, no indication of local execution support
**Latest News:** Removed GPU support from GitHub Codespaces (August 2025)
**Direction:** Moving toward cloud-only, higher-cost models (GPT-5-Codex)

---

## Part 6: Performance & Cost-Benefit Analysis

### 6.1 Does GPU Acceleration Matter for Agent Tasks?

**Finding:** Depends on workload type

**Where GPU Helps:**
- Model training (hours → minutes)
- Batch inference on large datasets
- Image/video processing
- Scientific computing (CUDA libraries)
- Large-scale data transformation

**Where GPU Doesn't Help Much:**
- Code generation (model already in cloud)
- Text analysis (latency-bound, not compute-bound)
- File operations (I/O-bound)
- Git workflows (CPU-bound)
- Testing/debugging (depends on test workload)

### 6.2 CPU vs GPU Agent Task Analysis

**Claude Code's Primary Overhead:**
- Network latency to Anthropic (200-500ms per request)
- Agent decision-making (5-30ms)
- Shell command execution (depends on task)
- File I/O (depends on disk speed)

**GPU Impact:**
- Minimal for code generation itself (already cloud-executed)
- Large for secondary compute tasks agent orchestrates
- High if running local ML models alongside agent

**Conclusion:** GPU matters for what Claude orchestrates, not for Claude's own execution

### 6.3 Cost-Benefit Comparison

| Approach | Setup | Cost | GPU Benefit | Best For |
|----------|-------|------|-------------|----------|
| Pure Claude Code | 5 min | $0 + API | N/A | General development |
| Local vLLM fallback | 30 min | $0 + power | High | Reducing API costs |
| Jupyter + GPU Kernel | 60 min | GPU cost | High | Iterative ML work |
| Docker GPU pipeline | 45 min | $0 + power | High | Isolated workloads |
| Ray distributed | 3 hours | GPU cluster cost | Very High | Large-scale training |
| MCP GPU tools | 2 hours | varies | Varies | Custom workflows |

### 6.4 Cost Reduction via Local GPU

**Scenario:** Running 1000 code generation tasks per day
- **Cloud-only:** ~$50/day (at Opus pricing)
- **Local vLLM + Claude Code:** ~$10/day (smaller model for fallback) + $2 power

**ROI Breakeven:** ~10 days for $400+ GPU

---

## Part 7: Implementation Recommendations

### 7.1 For SRE/DevOps Workflows (Your Use Case)

**Recommendation:** Claude Code + Docker GPU Pipeline

**Rationale:**
- You already understand Docker, K3s, infrastructure
- Isolated execution aligns with SRE mindset
- Audit trail + reproducibility (important for ops)
- Easy to version control configurations

**Implementation Sketch:**
```dockerfile
FROM nvidia/cuda:12.6.2-devel-ubuntu22.04
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126
RUN pip install -r requirements.txt
COPY scripts/ /app/scripts/
WORKDIR /app
```

```bash
# From Claude Code:
docker run --gpus all \
  -v $(pwd):/workspace \
  -e PYTHONUNBUFFERED=1 \
  my-gpu-worker:latest \
  python /workspace/script.py
```

---

### 7.2 For Dissertation Work (Kubernetes Platform)

**Recommendation:** Claude Code + Jupyter Kernel (GPU-enabled) + MCP

**Rationale:**
- Stateful execution (important for iterative research)
- Can connect to K3s cluster with GPU nodes
- Visualization support for analysis
- Easy to save notebooks for reproducibility

**Setup Path:**
1. Deploy Jupyter on K3s cluster with GPU node
2. Install ClaudeJupy MCP server
3. Configure Claude Code to use MCP
4. Use side-by-side editor + notebook workflow

**Example K3s Jupyter Deployment:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: jupyter-gpu
spec:
  ports:
    - port: 8888
  selector:
    app: jupyter
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jupyter-gpu
spec:
  selector:
    matchLabels:
      app: jupyter
  template:
    metadata:
      labels:
        app: jupyter
    spec:
      containers:
      - name: jupyter
        image: jupyter/scipy-notebook:latest
        resources:
          limits:
            nvidia.com/gpu: "1"
        ports:
        - containerPort: 8888
```

---

### 7.3 For Day-to-Day Productivity

**Recommendation Tier 1:** Just use Claude Code as-is
- You already have it configured
- Sufficient for most development tasks
- GPU acceleration not needed for code generation

**Recommendation Tier 2:** Add local llama.cpp (optional fallback)
- Install: `brew install llama-cpp` (macOS) or `apt-get install llama-cpp`
- Download quantized model: `llama.cpp --download qwen3-7b-q4`
- Run server in background: `llama-server -m ~/.cache/models/qwen3-7b-q4.gguf`
- No modification to Claude Code needed; just available if you want it

---

## Part 8: Experimental & Emerging Patterns

### 8.1 Multi-Agent Orchestration with GPU

**Status:** Enterprise-grade frameworks exist

**Frameworks:**
- **claude-flow** (ruvnet): Multi-agent swarms with GPU integration pathways
- **Agent Orchestration in VS Code 1.107:** Experimental multi-agent support

**Pattern:** Specialized agents for different tasks, some GPU-backed

```
Main Agent (Claude Code, no GPU needed)
├─ Code Agent (local GGML, GPU)
├─ Analysis Agent (vLLM, GPU)
└─ Deployment Agent (orchestrates Docker GPU tasks)
```

### 8.2 RightNow-AI CLI (Claude Code for CUDA)

**What:** Community project explicitly for CUDA development

**Status:** Free, understands GPU architecture
**Integration:** Works alongside Claude Code
**GitHub:** RightNow-AI/rightnow-cli

**Positioning:** Specialized agent for CUDA problems, can hand off to Claude Code for general code

---

### 8.3 LiteLLM Proxy Strategy (Most Flexible)

**Pattern:** Proxy layer allows swapping backends without code changes

**Setup:**
```yaml
litellm_settings:
  drop_params: true
  cache:
    type: redis

model_list:
  - model_name: claude
    litellm_params:
      model: claude-opus-4-5
      api_base: https://api.anthropic.com
      api_key: $ANTHROPIC_API_KEY

  - model_name: local-qwen
    litellm_params:
      model: ollama/qwen3-coder:latest
      api_base: http://localhost:11434
```

**Usage:**
```bash
# Switch backends without touching config
claude "..." --model claude          # Cloud
claude "..." --model local-qwen      # Local GPU
```

**Benefit:** Single interface, multiple backends (useful for Tier 2-3 scaling)

---

## Part 9: Limitations & Honest Assessment

### 9.1 What CANNOT Use GPU (Today)

1. **Claude Code's own inference** - Always cloud-based, always CPU on their end
2. **Gemini CLI** - Pure API client, no local execution
3. **GitHub Copilot** - Cloud-only, no local hooks
4. **Agent's decision-making process** - Happens in cloud

### 9.2 What CAN Use GPU (With Setup)

1. **Python CUDA code** (via shell commands)
2. **Jupyter kernels** (if deployed on GPU machine)
3. **Docker containers** (with GPU passthrough)
4. **vLLM/llama.cpp servers** (for local inference)
5. **Custom MCP services** (wrapping GPU tools)

### 9.3 Real Constraints

**Network latency:** Agent → Cloud → Agent adds 200-500ms overhead
- GPU compute on local task might be faster, but overhead eats gains
- Only worthwhile for long-running tasks (> 10 seconds compute)

**State management:** Claude Code is stateless across requests
- Each new request loses previous GPU memory/variables
- Jupyter workaround exists but adds complexity

**Model access:** You're locked to Anthropic models for inference
- vLLM/llama.cpp can't fully replace Claude (quality differences)
- Best as complementary tool, not replacement

---

## Part 10: Roadmap & Future Possibilities

### 10.1 Likely (12-18 months)

- **Claude Code** self-hosted LLM support (community demand high, implementation clear)
- **Gemini CLI** will remain API-only (low priority for Google)
- **MCP GPU servers** will proliferate (pattern established, easy to build)
- **Docker GPU** integration will be documented best practice
- **Ray + Claude workflows** will become standard for big compute

### 10.2 Possible (18-36 months)

- Claude Code built-in vLLM/llama.cpp support
- Native Jupyter kernel integration in Claude Code
- Streaming CUDA kernel output to Claude Code terminal
- GPU-aware scheduling in multi-agent frameworks

### 10.3 Unlikely

- Claude Code itself inference on local GPU (breaks their model)
- GitHub Copilot local execution (strategic misalignment)
- Gemini CLI feature parity with Claude Code (different product lines)
- "One-click GPU setup" (too many hardware variants)

---

## Part 11: Action Items for Your Setup

### Quick Wins (< 30 minutes)

- [ ] Document current Claude Code configuration (what you have works)
- [ ] Bookmark vLLM Docker setup for future reference
- [ ] Test `nvidia-smi` from Claude Code shell (verify GPU access)
- [ ] Explore LiteLLM proxy config (optional; useful if scaling)

### Medium Term (1-2 weeks)

- [ ] Set up local llama.cpp fallback (optional productivity boost)
- [ ] Create Dockerfile template for GPU workloads
- [ ] Document workaround for Issue #10658 (GPU diagnostics)
- [ ] Test Jupyter + GPU kernel with dissertation code

### Long Term (1-3 months)

- [ ] Prepare MCP server structure for custom GPU tools
- [ ] Evaluate Ray for Kubernetes workloads
- [ ] Plan migration to vLLM fallback if API costs become concern
- [ ] Document GPU patterns in your workspace documentation

---

## Conclusion

**TL;DR:**

| Agent | Local GPU? | Recommended For | Setup Complexity |
|-------|-----------|-----------------|------------------|
| **Claude Code** | Indirect (proven) | General development | Low-Medium |
| **Gemini CLI** | No | Not recommended | N/A |
| **GitHub Copilot** | No | Not recommended | N/A |

**Best Practice for You:**
1. Continue using Claude Code (no changes needed)
2. Keep llama.cpp as optional fallback (install and forget)
3. Use Docker GPU for isolated ML/training tasks
4. Consider Jupyter integration if dissertation work intensifies
5. Watch Issue #7178 (self-hosted LLMs) for future updates

**Most Immediate Value:** Claude Code already can execute GPU code via shell commands—you just might not have tested it. Verify CUDA access and you're already partially leveraging GPU.

---

## Sources

### Core Agent Documentation
- [Claude Code Official](https://www.anthropic.com/claude-code)
- [Claude Code Repository](https://github.com/anthropics/claude-code)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Gemini CLI Repository](https://github.com/google-gemini/gemini-cli)
- [GitHub Copilot](https://github.com/features/copilot)

### MCP & Integration
- [Model Context Protocol Specification](https://modelcontextprotocol.io/specification/2025-03-26)
- [Introducing MCP](https://www.anthropic.com/news/model-context-protocol)
- [AMD MCP + GPU Blog](https://rocm.blogs.amd.com/artificial-intelligence/mcp-model-context-protocol/README.html)
- [Qualcomm: MCP and Edge Devices](https://www.qualcomm.com/developer/blog/2025/10/how-mcp-simplifies-tool-integration-across-cloud-edge-real-world-devices)
- [Connect Claude Code via MCP](https://code.claude.com/docs/en/mcp)
- [Configuring MCP in Claude Code](https://scottspence.com/posts/configuring-mcp-tools-in-claude-code)

### GPU & Inference
- [vLLM GPU Installation](https://docs.vllm.ai/en/stable/getting_started/installation/gpu/)
- [NVIDIA vLLM Optimization](https://developer.nvidia.com/blog/accelerating-llms-with-llama-cpp-on-nvidia-rtx-systems/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- [Docker GPU Support](https://docs.docker.com/desktop/features/gpu/)
- [Docker Compose GPU](https://docs.docker.com/compose/how-tos/gpu-support/)
- [llama.cpp Project](https://github.com/ggml-org/llama-cpp)
- [llama.cpp Mastery Guide](https://danielkliewer.com/blog/2025-11-12-mastering-llama-cpp-local-llm-integration-guide/)
- [Intel GPUs with llama.cpp](https://www.intel.com/content/www/us/en/developer/articles/technical/run-llms-on-gpus-using-llama-cpp.html)
- [Ollama Official](https://github.com/ollama/ollama)
- [Google Cloud: Run Inference with vLLM](https://cloud.google.com/dataflow/docs/notebooks/run_inference_vllm)

### Jupyter & Interactive Execution
- [Jupyter Remote Kernel: Local to GPU Cloud](https://medium.com/ai-infra-tools/from-local-to-gpu-cloud-in-one-click-jupyter-remote-kernel-unleashed-fa7cc8c75caf)
- [JupyterMCP Project](https://github.com/jjsantos01/jupyter-notebook-mcp)
- [ClaudeJupy](https://mcpmarket.com/server/claudejupy)
- [Jupyter AI for Claude Code](https://github.com/jupyter-ai-contrib/jupyter-ai-claude-code)

### Practical Implementations
- [DeepSeek-OCR + Claude Code](https://simonwillison.net/2025/Oct/20/deepseek-ocr-claude-code/)
- [RightNow-AI CLI (Claude for CUDA)](https://github.com/RightNow-AI/rightnow-cli)
- [Sionic AI: 1000+ ML Experiments/Day](https://huggingface.co/blog/sionic-ai/claude-code-skills-training)
- [NVIDIA Spark + vLLM + Claude Code Router](https://digitalempire.us/projects/nvidia-spark-vllm-claude-router/)
- [Setting Up Claude Locally with Open-Source Models (Mac)](https://medium.com/@luongnv89/setting-up-claude-code-locally-with-a-powerful-open-source-model-a-step-by-step-guide-for-mac-84cf9ab7262)
- [Local AI Coding Assistant in VS Code](https://medium.com/@smfraser/how-to-use-a-local-llm-as-a-free-coding-copilot-in-vs-code-6dffc053369d)

### Agent Orchestration
- [claude-flow: Agent Orchestration](https://github.com/ruvnet/claude-flow)
- [Multi-Agent Orchestration in VS Code 1.107](https://visualstudiomagazine.com/articles/2025/12/12/vs-code-1-107-november-2025-update-expands-multi-agent-orchestration-model-management.aspx)
- [Claude Agent SDK Best Practices](https://skywork.ai/blog/claude-agent-sdk-best-practices-ai-agents-2025/)

### Community Feature Requests & Discussion
- [Claude Code Issue #7178: Self-Hosted LLM Support](https://github.com/anthropics/claude-code/issues/7178)
- [Claude Code Issue #10658: GPU/CUDA Diagnostics](https://github.com/anthropics/claude-code/issues/10658)
- [Gemini CLI Issue #2318: Ollama API Integration](https://github.com/google-gemini/gemini-cli/issues/2318)
- [Gemini CLI Issue #10619: LM Studio Support](https://github.com/google-gemini/gemini-cli/issues/10619)

### Performance & Benchmarks
- [Claude Code Performance Issues](https://claudelog.com/faqs/claude-code-performance/)
- [Cursor vs Claude Code Benchmark](https://medium.com/@shashwatabhattacharjee9/the-10x-performance-gap-what-the-cursor-vs-claude-code-benchmark-reveals-about-ai-assisted-b23730b11313)
- [Render: AI Coding Agents Benchmark 2025](https://render.com/blog/ai-coding-agents-benchmark)
- [Claude 4 Benchmarks](https://medium.com/@support_94003/claude-4-reasoning-memory-benchmarks-tools-and-use-cases-c381fb84e4c6)

### Terminal & Infrastructure
- [Kitty Terminal Emulator](https://sw.kovidgoyal.net/kitty/)
- [Kitty Graphics Protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
- [Roboflow: Using GPU in Docker](https://blog.roboflow.com/use-the-gpu-in-docker/)
- [GitHub Codespaces GPU Deprecation](https://undercodenews.com/github-codespaces-drops-gpu-support-what-you-need-to-know-before-august-29-2025/)

### Frameworks & Tools
- [Ray Distributed Computing](https://docs.ray.io/en/latest/ray-overview/index.html)
- [Ray GitHub](https://github.com/ray-project/ray)
- [LM Studio](https://lmstudio.ai)
- [LM Studio & Ollama Setup](https://devtoolhub.com/install-lm-studio-ollama/)
- [LiteLLM Documentation](https://docs.litellm.ai/)

---

**Document Version:** 1.0
**Last Updated:** 2025-12-22
**Classification:** Research & Reference
**Next Review:** When Claude Code issues #7178 or #10658 are resolved
