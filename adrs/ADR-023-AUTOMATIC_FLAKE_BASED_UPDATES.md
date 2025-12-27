# ADR-023: Automatic Flake-Based Updates for Custom Builds

## Status
Accepted

## Context
We maintain custom builds of several AI tools (`gemini-cli`, `exa`, `firecrawl`) to optimize for the Bun runtime. Currently, updating these requires manually changing hash values in Nix files, which is tedious and breaks the flow of `nix flake update`. We want an automated workflow where updating the flake inputs automatically propagates to the builds without manual intervention.

## Decision
1.  All custom builds MUST be defined as flake inputs in `home-manager/flake.nix` (or the relevant project flake).
2.  Builds MUST derive their source directly from these flake inputs.
3.  We will use `dream2nix` (or compatible builders) to handle dependencies automatically where possible, avoiding hardcoded `npmDepsHash` that requires manual updates, OR use builders that allow lock-file derivation from the source input.
4.  The goal is that running `nix flake update` should be sufficient to upgrade the tool and its build.

## Consequences
- **Positive:** Simplified maintenance, always-up-to-date tools, "dirty" git tree warnings reduced.
- **Negative:** Complexity in setting up `dream2nix` or similar tools to handle impure/lockless dependency resolution during evaluation or build time.
