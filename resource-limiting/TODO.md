# Resource Limiting Implementation TODO

## Installation Checklist

- [ ] Review the implementation in `dotfiles/dot_bashrc.d/90-resource-limits.sh`
- [ ] Read the [README.md](README.md) for full understanding
- [ ] Read the [INSTALLATION.md](INSTALLATION.md) for installation steps
- [ ] Decide if the default limits (512MB soft, 1GB hard) are appropriate for your needs
- [ ] Apply the configuration via chezmoi
  ```bash
  cd ~/.MyHome/MySpaces/my-modular-workspace/dotfiles
  chezmoi apply ~/.bashrc.d/90-resource-limits.sh
  ```
- [ ] Reload your shell: `source ~/.bashrc` or `exec bash`
- [ ] Verify installation: `type nix` should show "nix is a function"
- [ ] Test with a simple command: `nix --version`
- [ ] Monitor with `show-resource-limits`

## Testing Checklist

- [ ] Test nix command with monitoring:
  ```bash
  # Terminal 1
  nix-shell -p hello --run hello

  # Terminal 2
  systemd-cgtop
  ```
- [ ] Test home-manager command:
  ```bash
  # If safe to do so
  home-manager build
  ```
- [ ] Verify memory limiting works (optional - will trigger OOM):
  ```bash
  # Creates a command that tries to allocate 2GB
  run-limited 512M 1G -- bash -c 'a=$(yes | head -n $((2*1024*1024*1024)))'
  # Should be killed before completion
  ```
- [ ] Test bypassing limits:
  ```bash
  command nix --version
  ```

## Configuration Tuning (After Testing)

- [ ] Monitor typical nix build memory usage
  ```bash
  # During a typical build, check:
  systemd-cgtop
  ```
- [ ] Adjust limits if needed:
  - [ ] If builds are frequently OOM killed: increase `MEMORY_MAX`
  - [ ] If builds are too slow: increase `MEMORY_HIGH`
  - [ ] If you want CPU limiting: uncomment `CPU_QUOTA`
- [ ] Document your customizations in this file

## Optional Enhancements

- [ ] Create systemd slice for persistent configuration (see [INSTALLATION.md](INSTALLATION.md#advanced-system-wide-slice-configuration))
- [ ] Add wrappers for other heavy commands (cargo, gcc, etc.)
- [ ] Set up monitoring/alerting for OOM events
- [ ] Create a systemd timer to review OOM events monthly

## Integration with Existing Setup

- [ ] Check if this conflicts with any existing bash configuration
- [ ] Verify it works with your existing chezmoi setup
- [ ] Test in a non-interactive shell (e.g., scripts that call nix)
- [ ] Document any issues found

## Documentation

- [ ] Add a note about this setup to your main workspace README
- [ ] Consider creating an ADR (Architecture Decision Record) for this
  - Title: "ADR-XXX: Resource Limiting for Nix/Home-Manager Commands"
  - Context: OOMD killing processes, need declarative limits
  - Decision: Shell wrappers using systemd-run
  - Consequences: See [README.md](README.md#troubleshooting)

## Future Considerations

- [ ] Monitor for systemd updates that might change behavior
- [ ] Consider migrating to home-manager if chezmoi becomes limiting
- [ ] Evaluate if systemd slice approach is better for your use case
- [ ] Set up regular reviews (quarterly?) to adjust limits based on usage

## Notes

### Current Configuration
- Soft limit: 512MB
- Hard limit: 1GB
- CPU limit: (not set)

### Customizations Made
(Document any changes you make to the default configuration here)

### Issues Encountered
(Track any problems you face and their solutions here)
