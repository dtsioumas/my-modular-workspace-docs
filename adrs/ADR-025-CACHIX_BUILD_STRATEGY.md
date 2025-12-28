# ADR-025: Cachix Build Strategy and Limits

## Status
Accepted

## Context
We utilize the `modular-workspace` Cachix repository to store binary artifacts. We have a strict **5GB storage limit**. Indiscriminate caching of all builds (especially large debug symbols or intermediate build artifacts) will exhaust this limit quickly.

## Decision
1.  **Selective Caching:** Only "leaf" packages (final binaries) and time-consuming intermediate dependencies (e.g., compiled heavy libraries) should be pushed to Cachix.
2.  **Custom Builds Priority:** Custom-built runtimes (optimized Node.js/Python) and AI tools (`gemini-cli`, `exa`, `firecrawl`) are HIGH PRIORITY for caching.
3.  **Exclusions:** Do not push standard `nixpkgs` packages unless modified. Do not push `devShell` environments unless they are used in CI.
4.  **Builder Role:** The `shoshin` workspace is designated as the primary builder. Future cloud builders must adhere to this caching policy.
5.  **Maintenance:** A monthly maintenance job must run `cachix garbage-collect` (if available) or manual pruning to stay within limits.

## Consequences
- **Positive:** Efficient use of storage, fast downloads for custom tools on other machines.
- **Negative:** Requires manual monitoring of cache usage.
