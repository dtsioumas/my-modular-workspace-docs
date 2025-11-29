# Warp Terminal Installation on NixOS

## Discovery Process

### Initial Research
1. **Search Query**: "Warp terminal NixOS flake installation"
2. **Key Finding**: warp-terminal is available in nixpkgs unstable channel

### Package Information
- **Package Name**: `warp-terminal`
- **Version**: 0.2025.10.22.08.13.stable_01 (as of Nov 2025)
- **License**: Unfree (requires `allowUnfree = true`)
- **Source**: Available in nixpkgs unstable
- **Platforms**: x86_64-linux, x86_64-darwin, aarch64-linux, aarch64-darwin

### Installation Methods

#### Method 1: Direct from Unstable (Recommended)
Since the shoshin system already has nixpkgs-unstable configured in the flake, we can use the unstable channel directly.

```nix
# In modules/workspace/packages.nix or similar
{ config, pkgs, unstable, ... }:
{
  environment.systemPackages = [
    unstable.warp-terminal
  ];
  
  nixpkgs.config.allowUnfree = true; # Already set
}
```

#### Method 2: Using Overlay
If you want to pin a specific version:
```nix
nixpkgs.overlays = [
  (final: prev: {
    warp-terminal = unstable.warp-terminal;
  })
];
```

#### Method 3: Home-Manager
For user-specific installation:
```nix
home.packages = [ unstable.warp-terminal ];
```

## Implementation for Shoshin System

### Current Configuration Analysis
- **Flake**: Uses nixpkgs-unstable as input
- **Unfree**: Already enabled (`nixpkgs.config.allowUnfree = true`)
- **Structure**: Modular configuration with separate package files

### Recommended Implementation
Add to `/home/mitso/.config/nixos/modules/workspace/packages.nix`:

```nix
{ config, pkgs, claude-desktop, unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # ... existing packages ...
    
    # Terminal Emulators
    unstable.warp-terminal  # Modern Rust-based terminal
    
    # ... rest of packages ...
  ];
}
```

### Verification Steps
1. Check if unstable is passed to the module
2. Rebuild configuration: `sudo nixos-rebuild test`
3. If successful: `sudo nixos-rebuild switch`
4. Launch: `warp` command

## Troubleshooting

### Common Issues

#### GPU/Graphics Issues
Some users report needing discrete GPU access. If you encounter issues:
```bash
# Try with different GPU settings
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
warp
```

#### Missing Dependencies
Warp may require additional runtime dependencies. Check logs:
```bash
journalctl -xe | grep warp
```

## Alternative Terminals
If Warp doesn't work well, consider these alternatives available in NixOS:
- **Alacritty**: GPU-accelerated terminal (in nixpkgs stable)
- **Kitty**: Feature-rich, GPU-accelerated terminal
- **WezTerm**: Multiplexer and terminal emulator
- **Zellij**: Modern terminal multiplexer

## References
- Warp Homepage: https://www.warp.dev/
- NixOS Package Search: https://search.nixos.org/packages?channel=unstable&show=warp-terminal
- Package Source: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/wa/warp-terminal/package.nix

## Notes
- Warp is proprietary software requiring account creation
- It offers AI-powered features and modern UX
- Regular updates through nixpkgs-unstable channel