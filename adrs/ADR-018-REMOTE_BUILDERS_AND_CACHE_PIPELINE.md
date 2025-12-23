# ADR-018: Remote Builders & Cachix Pipeline

**Status:** Proposed  
**Date:** 2025-12-24  
**Authors:** Mitsos, Codex  

---

## Context

- Heavy packages (Codex CLI, ONNX Runtime, MCP servers) are compiled locally on shoshin, consuming 1–2 hours and ~12 GB RAM per cold rebuild.
- New hosts (Kinoite WSL, future Fedora Atomic, CI runners) need these binaries but rebuilding them individually is wasteful.
- We already plan to push hardware-aware builds (ADR-017). To fully benefit, we need a reproducible cache pipeline plus disposable builders for burst workloads.
- Terraform is the preferred IaC tool for provisioning cloud resources; Cachix is the binary cache service of choice.

---

## Decision

1. **Terraform-managed builders:**  
   - Maintain a new repo (`infra/builders`) with Terraform modules that can spin up and tear down temporary x86_64-linux machines (Hetzner, Fly.io, or preferred provider).  
   - Each builder installs Nix, enables the SSH build user, trusts Cachix keys, and exposes itself via `nix build --option builders`.  
   - Outputs: `terraform apply` brings up N machines, `terraform destroy` removes them after builds finish.

2. **Cachix pipeline:**  
   - Every successful build of `.#homeConfigurations."<user@host>".activationPackage` and standalone heavy packages (Codex, ONNX, MCP servers) must be uploaded to a dedicated Cachix cache (public or private).  
   - Local development uses `cachix watch-store my-modular-workspace`. CI uses the Cachix GitHub Action with the same signing key.

3. **CI integration:**  
   - Add a workflow (GitHub Actions or Forgejo) that runs on push:  
     1. `nix develop .#ci --command ./ci/build-home.sh` to build activation packages.  
     2. `cachix push my-modular-workspace result`.  
     3. Optionally run `nix flake check`.  
   - CI runners can be the Terraform builders themselves (self-hosted) or GitHub-hosted runners that offload builds via `nix.settings.builders`.

4. **Documentation & Secrets:**  
   - Store the Cachix auth token and Terraform cloud credentials in the existing secrets manager (KeePassXC) and mirror them to CI secrets.  
   - Update `docs/nixos/REMOTE_BUILDERS.md` and `docs/home-manager/HARDWARE_OPTIMIZATIONS.md` to remind contributors that any new hardware-aware package must have a cache step before merging.

---

## Consequences

### Positive
- Cold starts on any machine reuse cached binaries; `home-manager switch` becomes fast and deterministic.
- Burst workloads move off the desktop—run Terraform to allocate a beefy builder, run `nix build`, push to Cachix, then destroy the builder.
- CI can validate PRs using the same Terraform module, ensuring consistent environments.

### Negative
- Terraform/IaC adds operational overhead (state files, cloud credentials).  
- Private Cachix caches may incur cost; we must monitor usage.  
- Builders must be secured (SSH keys, firewall) to avoid unauthorized builds.

### Neutral / Risks
- Cachix outages fall back to source builds; keep local builds working.  
- Misconfigured builders could leak secrets—use limited IAM roles and rotate keys regularly.

---

## Implementation Plan

1. **Terraform repo skeleton:**  
   - `modules/builder` (inputs: region, CPU/RAM, nix installer, cachix key).  
   - `modules/cache-proxy` (optional, nar-serve).  
   - `environments/{dev,prod}` with backend configuration and variables.

2. **Builder bootstrap script:**  
   - Install Nix (multi-user).  
   - Import Cachix signing key, start `cachix watch-store`.  
   - Enable SSH build users (`/etc/nix/machines` entry).  
   - Optionally install monitoring/alerts.

3. **CI workflow:**  
   - Add `.github/workflows/build.yml` (or Forgejo equivalent).  
   - Steps: checkout repo, install Nix, set up Cachix action, run `nix build` for activation packages + heavy packages, push to cache.  
   - Optionally call `terraform apply`/`destroy` around the build if using ephemeral builders.

4. **Local developer workflow:**  
   - Add shell alias (`hmfast-cache`) that runs `hm-switch-fast` and streams results to Cachix.  
   - Document fallback commands for manual cache push (`cachix push my-cache $(nix path-info --recursive result)`).

5. **Documentation updates:**  
   - Expand `docs/nixos/RESOURCE-MANAGEMENT.md` with builder instructions.  
   - Reference this ADR from `README.md` sections covering caching and hardware-aware builds.

Once the Terraform modules and CI workflow land, every new host/workspace will simply point to the existing Cachix cache for instant bootstrapping.
