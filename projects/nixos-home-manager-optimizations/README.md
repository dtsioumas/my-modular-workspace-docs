# NixOS + Home-Manager Optimizations Project

**Project Status:** Active Implementation
**Target Workspace:** shoshin (初心)
**Start Date:** 2025-12-30

---

## Quick Links

### Main Plan
- **[OPTIMIZATION_PLAN.md](./OPTIMIZATION_PLAN.md)** - Unified implementation plan

### Research Documents (Required Reading)

| Document | Topic |
|----------|-------|
| [Bootstrap Research](../../researches/2025-12-30_NIXOS_SYSTEM_LIBS_OVERLAY_BOOTSTRAP_RESEARCH.md) | Why glibc/zlib can't be overridden in home-manager |
| [System Libs Expansion](../../researches/2025-12-30_EXPANDED_SYSTEM_LIBS_AND_NIXOS_OPTIMIZATIONS.md) | Additional safe libraries for optimization |
| [Electron Apps](../../researches/2025-12-30_ELECTRON_APPS_OPTIMIZATION_RESEARCH.md) | GPU flags, V8 limits, systemd cgroups |
| [Plasma Desktop](../../researches/2025-12-30_PLASMA_DESKTOP_OPTIMIZATION_RESEARCH.md) | KWin, Baloo, Plasmashell optimization |
| [VA-API/VDPAU](../../researches/2025-12-30_VAAPI_VDPAU_GPU_ACCELERATION_RESEARCH.md) | GPU video acceleration for NVIDIA |

### Architecture Decision Records

| ADR | Topic | Status |
|-----|-------|--------|
| [ADR-017](../../adrs/ADR-017-HARDWARE_AWARE_BUILD_OPTIMIZATIONS.md) | Hardware-Aware Build Optimizations | ✅ |
| [ADR-024](../../adrs/ADR-024-LANGUAGE_RUNTIME_HARDWARE_OPTIMIZATIONS.md) | Language Runtime Optimizations | ✅ |
| [ADR-028](../../adrs/ADR-028-COMPREHENSIVE_RUNTIME_AND_BUILD_OPTIMIZATIONS.md) | Comprehensive Optimizations | ✅ |

### Implementation Files

| Layer | File | Status |
|-------|------|--------|
| **NixOS** | `hosts/shoshin/nixos/modules/system/overlays/system-libs-nixos-optimized.nix` | 📝 To Create |
| **Home-Manager** | `home-manager/modules/system/overlays/system-libs-hardware-optimized.nix` | ✅ Done |
| **Electron Apps** | `home-manager/modules/apps/electron-optimized/` | 📝 To Create |
| **Hardware Profile** | `home-manager/modules/profiles/config/hardware/shoshin.nix` | ✅ Done |

---

## Project Overview

This project optimizes the shoshin workspace at multiple levels:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Hardware Profile (shoshin.nix)                   │
│  CPU: i7-6700K Skylake | GPU: GTX 960 | RAM: 16GB + 12GB zram      │
└─────────────────────────────────────────────────────────────────────┘
                                  │
           ┌──────────────────────┴──────────────────────┐
           ▼                                             ▼
┌─────────────────────────────┐           ┌─────────────────────────────┐
│      NixOS Level            │           │     Home-Manager Level      │
│  /etc/nixos/                │           │  ~/.config/home-manager/    │
├─────────────────────────────┤           ├─────────────────────────────┤
│ Phase 1: Bootstrap-Critical │           │ Phase 1: Post-Bootstrap     │
│   - glibc (3-8% universal)  │           │   - zstd, bzip2, xz         │
│   - zlib (10-20% compress)  │           │   - openssl (AES-NI)        │
├─────────────────────────────┤           │   - sqlite, curl, pcre2     │
│ Phase 5: GPU Acceleration   │           ├─────────────────────────────┤
│   - nvidia-vaapi-driver     │           │ Phase 2: Language Runtimes  │
│   - VDPAU configuration     │           │   - Node.js, Python, Rust   │
│   - Kernel params           │           ├─────────────────────────────┤
└─────────────────────────────┘           │ Phase 3: Electron Apps      │
                                          │   - Max GPU leverage        │
                                          │   - Systemd cgroups         │
                                          ├─────────────────────────────┤
                                          │ Phase 4: Plasma Desktop     │
                                          │   - KWin compositor         │
                                          │   - Baloo indexer           │
                                          └─────────────────────────────┘
```

---

## Expected Performance Gains

| Category | Optimization | Expected Improvement |
|----------|-------------|---------------------|
| **Universal** | glibc + zlib (NixOS) | 3-8% all operations |
| **Crypto** | openssl AES-NI | 20-40% crypto ops |
| **Compression** | zstd/bzip2/xz | 15-30% compress/decompress |
| **Language Runtimes** | Node.js/Python/Rust PGO | 10-30% execution |
| **Electron Apps** | GPU + V8 limits | 30-40% RAM reduction |
| **Video Playback** | VA-API/VDPAU | 30-50% CPU reduction |
| **Desktop** | KWin/Baloo optimized | 30-40% RAM reduction |

---

## Implementation Status

| Phase | Description | Status | Notes |
|-------|-------------|--------|-------|
| Phase 1.1 | NixOS glibc/zlib | 📝 Pending | High risk, staged rollout |
| Phase 1.2 | Home-Manager system libs | ✅ Done | Bootstrap-safe |
| Phase 2 | Language Runtimes | ✅ Done | PGO enabled |
| Phase 3 | Electron Apps | 📝 Pending | Max GPU leverage |
| Phase 4 | Plasma Desktop | 📝 Pending | KWin/Baloo |
| Phase 5 | GPU Acceleration | ⚙️ Partial | VA-API configured |

---

## Quick Start

### 1. Read the Research
```bash
# Essential reading before implementation
ls docs/researches/2025-12-30*.md
```

### 2. Check Hardware Profile
```bash
cat home-manager/modules/profiles/config/hardware/shoshin.nix
```

### 3. Follow the Plan
```bash
cat docs/projects/nixos-home-manager-optimizations/OPTIMIZATION_PLAN.md
```

### 4. Implement Phase by Phase
```bash
# Phase 1.1: NixOS (after creating overlay)
sudo nixos-rebuild switch --flake /etc/nixos#shoshin

# Phase 1.2: Home-Manager (already done)
home-manager switch --flake .#mitsio@shoshin
```

---

## Safety Notes

### NixOS Changes (High Risk)
- Always have previous generation available
- Keep NixOS live USB ready
- Test basic commands after switch: `ls`, `cat`, `grep`, `git`, `nix-build`

### Rollback Commands
```bash
# NixOS immediate rollback
sudo nixos-rebuild switch --rollback

# Home-Manager rollback
home-manager generations  # list
# then switch to previous generation
```

---

## Contributing

This project follows the my-modular-workspace conventions:
- All documentation in `docs/` repo
- Hardware-specific configs in hardware profiles
- Pre-commit hooks enforce ADR compliance

---

**Last Updated:** 2025-12-30
