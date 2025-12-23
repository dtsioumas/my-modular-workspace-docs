# NixOS OOM Killer Tuning (for /etc/nixos/configuration.nix)
#
# This snippet provides recommended settings to make the OOM killer
# less aggressive on a desktop system, especially during memory-intensive
# builds or application usage. It trades potential swap usage for increased
# stability by preventing abrupt process terminations.
#
# Place this inside your NixOS configuration (e.g., in hardware-configuration.nix
# or a system-level module):
#
# -----------------------------------------------------------------------------
{ config, pkgs, lib, ... }:

{
  # Tune kernel parameters related to memory management and the OOM killer.
  # This section should be placed in your /etc/nixos/configuration.nix
  # or a system-level NixOS module.
  boot.kernel.sysctl = {
    # vm.overcommit_memory: Controls memory overcommit behavior.
    #   0 (default): Heuristic overcommit. Kernel estimates if allocation is possible.
    #                Can lead to unexpected OOM kills for processes.
    #   1: Always overcommit. Kernel always grants memory requests, relying on
    #      swap or OOM killer only when actually out of physical/swap memory.
    #      Generally preferred for desktops to prevent OOM kills of user apps,
    #      but can lead to swap thrashing if applications are memory-hungry.
    #   2: Never overcommit. Kernel performs strict memory accounting. Only
    #      allocations that fit into physical RAM + swap *overcommit_ratio*
    #      are allowed. Can cause allocations to fail (return NULL) more often.
    #
    # We choose '1' to prioritize not killing user processes for desktop stability.
    "vm.overcommit_memory" = 1;

    # vm.oom_kill_allocating_task: Specifies which task is killed when OOM occurs.
    #   0: The OOM killer performs a heuristic search to find and kill the
    #      "worst" process (most memory-hungry or misbehaving). This often
    #      protects the task that *triggered* the OOM.
    #   1 (default): The task that triggers the OOM is killed. Can be disruptive.
    #
    # We choose '0' to allow the OOM killer to select a more appropriate victim,
    # potentially protecting critical applications or long-running builds.
    "vm.oom_kill_allocating_task" = 0;

    # vm.swappiness: Controls how aggressively the kernel swaps out anonymous memory.
    #   Lower values: Kernel tries to keep more pages in physical RAM, preferring
    #                 to drop cache/buffers first.
    #   Higher values: Kernel swaps out anonymous memory more aggressively.
    #
    # Default is 60. For systems with ZRAM (like yours), a higher swappiness can
    # be beneficial as ZRAM provides compressed swap in RAM, which is much faster
    # than disk swap. We set a moderate value to encourage ZRAM usage without
    # excessive thrashing.
    "vm.swappiness" = 70; # Slightly higher to leverage ZRAM more.

    # kernel.panic_on_oops: Set to 0 to prevent a kernel panic on an OOPS.
    "kernel.panic_on_oops" = 0;

    # kernel.panic: Timeout in seconds before rebooting on a kernel panic.
    "kernel.panic" = 10;
  };

  # Additional ZRAM tuning (assuming ZRAM is enabled and configured in your NixOS)
  # Ensure ZRAM configuration is robust.
  # This should be part of your system's `swap` configuration.
  # Example (adjust based on your actual ZRAM setup):
  # services.zramSwap.enable = true;
  # services.zramSwap.algorithm = "zstd";
  # services.zramSwap.compressionRatio = 0.75; # e.g., 75% of RAM as swap
}
