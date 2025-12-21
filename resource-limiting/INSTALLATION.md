# Installation Guide: Resource Limiting for Nix/Home-Manager

## Prerequisites

- systemd-based Linux distribution (systemd 231+)
- cgroups v2 enabled (default on most modern distros)
- chezmoi configured and managing your dotfiles

## Installation Steps

### 1. Apply the Configuration

The configuration is already managed by chezmoi. To apply it:

```bash
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles

# Review what will be changed
chezmoi diff

# Apply the changes
chezmoi apply ~/.bashrc.d/90-resource-limits.sh

# Or apply everything
chezmoi apply
```

### 2. Reload Your Shell

```bash
# Reload bashrc to activate the wrappers
source ~/.bashrc

# Or start a new shell session
exec bash
```

### 3. Verify Installation

```bash
# Check that wrappers are installed
type nix
# Expected output: nix is a function

type home-manager
# Expected output: home-manager is a function

# Check configuration
show-resource-limits
# Should display current limits
```

## Testing

### Test 1: Basic Functionality

```bash
# Run a simple command (should not use systemd-run for --version)
nix --version

# Run a command that should be wrapped
nix-shell -p hello --run "echo 'Resource limiting works!'"
```

### Test 2: Resource Limits in Action

Create a test script to verify memory limiting:

```bash
# Create a memory-hungry nix derivation
cat > /tmp/memory-test.nix <<'EOF'
let
  pkgs = import <nixpkgs> {};
in
  pkgs.runCommand "memory-test" {} ''
    echo "Starting memory allocation test..."
    # Allocate ~2GB to trigger OOM
    dd if=/dev/zero of=/dev/null bs=1M count=2048
    echo "Test result: should not reach here if limits work" > $out
  ''
EOF

# Try to build it (should hit memory limit and be killed)
nix-build /tmp/memory-test.nix

# Expected: Process killed due to OOM
```

### Test 3: Monitor Resource Usage

```bash
# In terminal 1: Start a build
nix-build '<nixpkgs>' -A hello

# In terminal 2: Monitor resources
systemd-cgtop
# Look for "Resource-limited nix" processes

# Or use the helper function
show-resource-limits
```

### Test 4: Custom Limits

```bash
# Run a command with custom resource limits
run-limited 256M 512M -- nix-shell -p figlet --run "figlet 'Limited!'"
```

## Rollback (if needed)

If you need to temporarily disable or remove the resource limiting:

### Temporary Disable (Current Session)

```bash
# Unset the wrapper functions
unset -f nix home-manager

# Commands now run without limits
nix build ...
```

### Permanent Removal

```bash
# Remove the wrapper file
rm ~/.bashrc.d/90-resource-limits.sh

# Reload shell
source ~/.bashrc
```

## Customization

### Adjust Memory Limits

Edit the configuration file:

```bash
chezmoi edit ~/.bashrc.d/90-resource-limits.sh

# Modify these values:
readonly MEMORY_HIGH="512M"  # Increase if needed
readonly MEMORY_MAX="1G"     # Increase if needed
```

Apply changes:

```bash
chezmoi apply ~/.bashrc.d/90-resource-limits.sh
source ~/.bashrc
```

### Add CPU Limits

Uncomment and configure the CPU quota:

```bash
chezmoi edit ~/.bashrc.d/90-resource-limits.sh

# Uncomment this line:
readonly CPU_QUOTA="100%"  # Adjust percentage as needed
```

### Wrap Additional Commands

To wrap other resource-intensive commands, add functions to the config:

```bash
# Example: Wrap 'cargo' commands
cargo() {
    _run_with_limits "cargo" cargo "$@"
}
export -f cargo
```

## Troubleshooting

### Issue: Commands fail with "Failed to create bus connection"

**Cause**: systemd user session not properly initialized

**Solution**:
```bash
# Check if systemd user session is running
systemctl --user status

# If not running, enable lingering
loginctl enable-linger $USER
```

### Issue: "Unknown lvalue 'MemoryHigh'"

**Cause**: Old systemd version (< 231)

**Solution**: Upgrade systemd or use `MemoryLimit=` instead (deprecated but works on older versions):

```bash
# Edit the config to use MemoryLimit instead
readonly MEMORY_LIMIT="1G"

# Update systemd_args to use:
-p "MemoryLimit=${MEMORY_LIMIT}"
```

### Issue: Resource limits not being enforced

**Diagnosis**:
```bash
# Check if cgroups v2 is in use
mount | grep cgroup2

# Check if process is in correct cgroup
cat /proc/$(pgrep -xo nix)/cgroup

# Should show something like:
# 0::/user.slice/user-1001.slice/user@1001.service/app.slice/run-*.scope
```

### Issue: Builds are too slow

The throttling behavior when approaching `MemoryHigh` can slow down builds significantly.

**Solutions**:
1. Increase `MEMORY_HIGH` to give more headroom
2. Close other applications to free RAM
3. Add swap space
4. Use `command nix` to bypass limits for specific large builds

## Integration with Home-Manager (Future Enhancement)

For a more integrated solution, you could move this configuration to home-manager:

```nix
# home-manager configuration
programs.bash.initExtra = ''
  source ${./resource-limits.sh}
'';

# Or using chezmoi integration via home-manager
home.file.".bashrc.d/90-resource-limits.sh".source = ./resource-limits.sh;
```

However, per ADR-005, since this is a simple bash script that works cross-platform,
keeping it in chezmoi is the recommended approach.

## Monitoring and Maintenance

### Regular Checks

```bash
# Monthly: Review memory usage patterns
journalctl --user -u "run-*.scope" --since "30 days ago" | grep -i oom

# Check system-wide OOM events
journalctl -k --since "30 days ago" | grep -i "out of memory"
```

### Adjusting Based on Usage

If you see frequent OOM kills:
- Increase limits
- Add more RAM
- Enable swap

If builds are consistently under the limit:
- You can decrease limits to be more conservative
- Or leave as-is for safety margin

## Advanced: System-Wide Slice Configuration

For system-wide application of limits (affects all users), create a systemd slice:

```bash
# Requires root
sudo tee /etc/systemd/system/nix-builds.slice <<EOF
[Slice]
Description=Resource limits for all Nix builds
MemoryAccounting=yes
MemoryHigh=75%
MemoryMax=90%
CPUAccounting=yes
CPUQuota=400%
EOF

sudo systemctl daemon-reload

# Update wrapper to use this slice
# Add to systemd_args: --slice=nix-builds.slice
```

## Questions?

For issues or questions:
1. Check the main [README.md](README.md) for usage examples
2. Review [troubleshooting](#troubleshooting) section above
3. Check systemd logs: `journalctl --user -xe`
4. Verify cgroup configuration: `systemctl --user show run-*.scope`
