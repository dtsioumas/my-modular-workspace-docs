# Resource Limiting Quick Reference

## TL;DR

Commands `nix` and `home-manager` are automatically wrapped with resource limits:
- **Soft limit**: 512MB (throttling)
- **Hard limit**: 1GB (OOM kill)

## Essential Commands

```bash
# Show current configuration and usage
show-resource-limits

# Monitor resource usage in real-time
systemd-cgtop

# Run command with custom limits
run-limited 256M 512M -- command args

# Bypass resource limits (one-off)
command nix build .#package

# Bypass resource limits (session)
unset -f nix home-manager
```

## Configuration File

Location: `~/.bashrc.d/90-resource-limits.sh`

Key variables:
```bash
readonly MEMORY_HIGH="512M"    # Soft limit
readonly MEMORY_MAX="1G"       # Hard limit
readonly CPU_QUOTA="100%"      # (optional)
```

## Apply Changes

```bash
# Via chezmoi
cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
chezmoi apply ~/.bashrc.d/90-resource-limits.sh
source ~/.bashrc

# Direct edit (not recommended)
vim ~/.bashrc.d/90-resource-limits.sh
source ~/.bashrc
```

## Common Issues

| Issue | Solution |
|-------|----------|
| Command fails with OOM | Increase limits or use `command nix` to bypass |
| Build is very slow | Memory throttling active, increase `MEMORY_HIGH` |
| "Failed to create bus connection" | Run `loginctl enable-linger $USER` |
| Limits not enforced | Check `mount \| grep cgroup2` (needs cgroups v2) |

## Monitoring

```bash
# Check if command is limited
type nix                    # Should show: "nix is a function"

# View current running processes
systemctl --user list-units "run-*.scope"

# Check cgroup of a process
cat /proc/$(pgrep nix)/cgroup

# View OOM events
journalctl --user | grep -i oom

# System-wide memory pressure
cat /proc/pressure/memory
```

## Examples

### Normal usage (transparent)
```bash
nix build .#mypackage        # Automatically limited
home-manager switch          # Automatically limited
```

### Custom limits for specific command
```bash
# Very limited (for testing)
run-limited 128M 256M -- nix-shell -p hello

# More generous (for large builds)
run-limited 2G 4G -- nix build .#large-package

# With CPU limit
run-limited 512M 1G 50% -- heavy-command
```

### Bypass for one command
```bash
command nix build .#huge-package
command home-manager switch
```

### Temporary disable for session
```bash
unset -f nix home-manager
# Commands now run unlimited
nix build ...
# Re-enable by sourcing bashrc or starting new shell
```

## Files Structure

```
~/.bashrc.d/
└── 90-resource-limits.sh              # Main wrapper script

docs/resource-limiting/
├── README.md                          # Full documentation
├── INSTALLATION.md                    # Installation guide
└── QUICK-REFERENCE.md                 # This file
```

## Understanding Memory Limits

```
0MB ────────────────────────────────────────────────── Usage
                                      ▼
                              512MB (MemoryHigh)
                                    |
                            Throttling begins
                            Memory reclaimed
                                    |
                                  1GB (MemoryMax)
                                    |
                                OOM Kill
```

## Performance Impact

- **< 512MB**: Normal performance
- **512MB - 1GB**: Throttled (50-90% slower)
- **> 1GB**: Process killed (OOM)

Typical nix builds: 200-800MB
Typical home-manager switch: 100-300MB

## systemd Integration

Resource limits are enforced via:
- Transient systemd scopes (auto-created)
- cgroups v2 memory controller
- MemoryHigh for soft limiting (preferred)
- MemoryMax for hard limiting (last resort)

View systemd configuration:
```bash
systemctl --user show run-*.scope | grep Memory
```

## See Also

- Full documentation: [README.md](README.md)
- Installation steps: [INSTALLATION.md](INSTALLATION.md)
- systemd resource control: `man systemd.resource-control`
- cgroups v2: `man cgroups`
