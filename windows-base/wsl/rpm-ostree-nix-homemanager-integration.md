# RPM-OSTree, Nix & Home-Manager Integration on Fedora Kinoite WSL2

**Date**: 2025-12-18
**Research Phase**: Technical Analysis
**Status**: Research Complete

---

## Executive Summary

**Key Finding**: Nix and home-manager CAN be successfully installed and used on Fedora Silverblue/Kinoite, including in WSL2 environments. This provides a powerful hybrid approach combining rpm-ostree's immutability with Nix's declarative package management.

**Recommendation**: Use a **three-tier strategy**:
1. **rpm-ostree** (minimal base system packages)
2. **Nix + home-manager** (user-level packages and dotfiles)
3. **Toolbox/Distrobox** (development containers)

---

## Can Nix Work on Fedora Kinoite?

### ✅ YES - Officially Supported

**Source**: [Julian Hofer - How to install Nix on Fedora Silverblue](https://julianhofer.eu/blog/2022/silverblue-nix/)

Fedora Silverblue/Kinoite is **officially supported** by the [Determinate Systems Nix installer](https://github.com/DeterminateSystems/nix-installer), which provides a cleaner installation process than the standard Nix installer.

### Installation Method

```bash
# Install Nix on Silverblue/Kinoite
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Source nix-daemon to start using Nix
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

**Why this installer works better:**
- Designed for immutable systems
- Handles SELinux properly
- Creates necessary directories without conflicts
- Cleaner uninstallation process

---

## Home-Manager Integration

### Installation Steps

After Nix is installed, home-manager can be set up as follows:

```bash
# Add nixpkgs-unstable channel
nix-channel --add https://nixos.org/channels/nixpkgs-unstable

# Add home-manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

# Update channels
nix-channel --update

# Install home-manager
nix-shell '<home-manager>' -A install
```

### Usage

```bash
# Edit configuration
home-manager edit

# Apply changes
home-manager switch

# Update
nix-channel --update
home-manager switch
```

### Example Configuration

```nix
{ config, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    userName  = "Dimitris Tsioumas";
    userEmail = "dtsioumas0@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autostash = true;
    };
  };

  # Install packages
  home.packages = with pkgs; [
    bat
    fd
    gh
    ripgrep
    ansible
    kubectl
    helm
  ];
}
```

---

## Integration with Distrobox/Toolbox

### Seamless Integration

**Critical Discovery**: Distrobox/Toolbox automatically **mounts /nix** inside containers!

```bash
# Install distrobox
rpm-ostree install --apply-live distrobox

# Enter container
distrobox enter

# Nix packages are immediately available!
bat ~/.config/git/config  # Works inside container
```

**This means:**
- Nix-installed tools work across base system AND containers
- No need to reinstall tools in each container
- Unified package management experience

---

## Three-Tier Package Management Strategy

Based on research findings and community best practices:

### Tier 1: RPM-OSTree (Minimal Base System)

**Purpose**: System-critical packages only

**Install via**: `rpm-ostree install`

**What to layer:**
```bash
sudo rpm-ostree install \
  vim \
  git \
  htop \
  tmux \
  distrobox \
  ansible  # Only if needed system-wide
```

**Rule**: If it integrates deeply with systemd or core system, layer it.

**Warning**: Don't layer too many packages! From Universal Blue community:
> "Don't (try to avoid having to) use ostree to layer packages because the system can get unstable, updates take longer and might break things"

### Tier 2: Nix + Home-Manager (User Packages & Config)

**Purpose**: User-level tools, declarative dotfiles

**Managed by**: home-manager switch

**What to install:**
- CLI development tools (ripgrep, fd, bat, fzf)
- Language runtimes (if not in containers)
- Cross-platform utilities
- Dotfile management via home-manager modules

**Benefits:**
- Declarative configuration
- Atomic updates and rollbacks
- Cross-platform (works on NixOS too if you migrate)
- User-level only (no sudo required)

### Tier 3: Toolbox/Distrobox (Development Environments)

**Purpose**: Project-specific tools, isolated environments

**Create containers for:**
```bash
# General development
toolbox create dev-general

# SRE/Ops tools
toolbox create sre-tools

# Python-specific projects
distrobox create --image docker.io/library/python:3.12 python-dev

# Go development
toolbox create golang-dev
```

**What belongs here:**
- Project dependencies
- Language-specific toolchains
- Experimental/frequently changing tools

---

## Home-Manager vs Chezmoi Decision

Based on your ADR-005 criteria:

### Use Home-Manager For:

✅ **Package installation** (Nix packages)
✅ **Complex configurations** with Nix-specific logic
✅ **Systemd user services** (via home-manager modules)
✅ **Programs with dedicated home-manager modules** (git, vim, tmux, etc.)

### Use Chezmoi For:

✅ **Cross-platform simple dotfiles** (.bashrc, .vimrc, etc.)
✅ **Machine-specific templating** (hostname, paths)
✅ **Files that need to work on both Kinoite AND Windows** (if applicable)
✅ **Application settings** (KDE config, etc.) per ADR-005

### Recommended Hybrid Approach:

```
my-modular-workspace/
├── home-manager/
│   ├── home.nix                    # Nix packages + complex modules
│   └── programs/
│       ├── git.nix                 # Using programs.git module
│       └── tmux.nix                # Using programs.tmux module
│
└── chezmoi/
    ├── dot_bashrc.tmpl             # Simple shell config
    ├── dot_config/
    │   ├── kitty/kitty.conf.tmpl   # App-specific settings
    │   └── kde/                    # KDE Plasma configs
    └── .chezmoiignore              # Conditional inclusion
```

**Philosophy:**
- Home-manager = "How to install and configure programs"
- Chezmoi = "My personal settings and preferences"

---

## Kinoite-Specific Considerations

### 1. Desktop Environment

Fedora Kinoite includes KDE Plasma by default via rpm-ostree:

```bash
# Check current deployment
rpm-ostree status

# Kinoite base includes:
# - KDE Plasma 6
# - Wayland (with X11 fallback)
# - Plasma system settings
```

**Don't layer KDE packages unless missing!** The base image already includes them.

### 2. Flatpak for GUI Applications

```bash
# GUI apps should use Flatpak
flatpak install flathub \
  com.visualstudio.code.oss \
  org.mozilla.firefox \
  org.keepassxc.KeePassXC \
  org.libreoffice.LibreOffice
```

**Why Flatpak over Nix for GUI apps:**
- Better desktop integration on Kinoite
- Sandboxed by default
- KDE Discover integration
- Automatic updates via Flatpak

### 3. WSL2 Specific Notes

When using Kinoite in WSL2:

```bash
# Nix installation works the same
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# No special configuration needed
# /nix is created in the WSL2 filesystem
# Performance is good (native Linux filesystem)
```

**Note**: Systemd works in WSL2 (enabled by default in recent versions), so systemd user services from home-manager will work.

---

## Performance Considerations

### Nix Store Size

Nix stores everything in `/nix/store/`, which can grow large:

```bash
# Check Nix store size
du -sh /nix/store/

# Cleanup old generations
nix-collect-garbage -d

# Home-manager specific cleanup
home-manager expire-generations '-30 days'
```

**Best practice**: Run garbage collection monthly.

### Update Speed

```bash
# Updating Nix packages is FAST
nix-channel --update
home-manager switch
# Usually completes in <1 minute

# Compare to rpm-ostree
sudo rpm-ostree upgrade
# Requires download, staging, reboot
# Takes several minutes + reboot time
```

**Advantage**: Nix updates don't require reboots!

---

## Migration Path from NixOS

### Current Shoshin (NixOS) Setup

From your `hosts/shoshin/` configuration:
- NixOS 25.05 (stable system)
- Home-manager (unstable packages) per ADR-001
- KDE Plasma 6
- K3s for containers

### Translating to Kinoite + Nix

| NixOS Component | Kinoite Equivalent | Notes |
|----------------|-------------------|-------|
| **System packages** | rpm-ostree layering | Minimal only |
| **Home-manager** | ✅ Same! | Works identically |
| **KDE Plasma** | Included in Kinoite base | No action needed |
| **K3s** | Podman + Kind/K3s | Containers work normally |
| **Systemd services** | home-manager user services | Same syntax |

### Example Translation:

**NixOS (system)**:
```nix
# configuration.nix
environment.systemPackages = with pkgs; [
  vim git htop
];
```

**Kinoite (rpm-ostree)**:
```bash
sudo rpm-ostree install vim git htop
```

**Home-Manager** (SAME on both):
```nix
# home.nix
home.packages = with pkgs; [
  ripgrep fd bat ansible kubectl
];
```

---

## Ansible Integration

### Installing Ansible

**Option 1**: Via rpm-ostree (system-wide)
```bash
sudo rpm-ostree install ansible
```

**Option 2**: Via Nix + home-manager (user-level)
```nix
# home.nix
home.packages = with pkgs; [
  ansible
  ansible-lint
];
```

**Option 3**: In toolbox (isolated)
```bash
toolbox create ansible-env
toolbox enter ansible-env
sudo dnf install ansible ansible-lint
```

**Recommendation**: Option 1 (rpm-ostree) for simplicity, as Ansible will manage system-level configs.

### Ansible + Home-Manager Workflow

```bash
# 1. Update home-manager config
home-manager edit
home-manager switch

# 2. Run Ansible playbook for system configs
cd ~/my-modular-workspace
ansible-playbook ansible/playbooks/kinoite-setup.yml

# 3. rpm-ostree changes require reboot
sudo systemctl reboot
```

---

## Implementation Checklist

### Phase 1: Install Nix on Kinoite WSL2

- [ ] Import Fedora Kinoite to WSL2
- [ ] Install Nix using Determinate Systems installer
- [ ] Verify `/nix` directory created
- [ ] Source nix-daemon profile

### Phase 2: Setup Home-Manager

- [ ] Add nixpkgs-unstable channel
- [ ] Add home-manager channel
- [ ] Install home-manager
- [ ] Create initial `home.nix` configuration
- [ ] Test `home-manager switch`

### Phase 3: Install Distrobox

- [ ] Layer distrobox via rpm-ostree
- [ ] Create development container
- [ ] Verify /nix is mounted in container
- [ ] Test Nix commands inside container

### Phase 4: Configure Hybrid Workflow

- [ ] Define which configs go to home-manager
- [ ] Define which configs go to chezmoi
- [ ] Update my-modular-workspace structure
- [ ] Document decision criteria (per ADR-005)

---

## Potential Issues & Solutions

### Issue 1: SELinux Denials

**Symptom**: Nix commands fail with permission errors

**Solution**: Determinate Systems installer handles SELinux properly. If issues occur:
```bash
# Check SELinux status
getenforce

# Temporary workaround (NOT recommended)
sudo setenforce 0

# Proper fix: Check installer docs
```

### Issue 2: /nix Directory Conflicts

**Symptom**: rpm-ostree complains about /nix

**Solution**: Nix installer creates /nix correctly. Don't manually create it.

### Issue 3: Systemd User Services Not Starting

**Symptom**: Home-manager services don't auto-start

**Solution**: Enable lingering for user
```bash
loginctl enable-linger $USER
```

---

## References

### Official Documentation

- [Determinate Systems Nix Installer](https://github.com/DeterminateSystems/nix-installer)
- [Home-Manager Manual](https://nix-community.github.io/home-manager/)
- [Fedora Silverblue Docs](https://docs.fedoraproject.org/en-US/fedora-silverblue/)

### Community Resources

- [Julian Hofer - Nix on Silverblue](https://julianhofer.eu/blog/2022/silverblue-nix/)
- [Fedora Discussion - Nix on ostree](https://discussion.fedoraproject.org/t/making-nix-on-ostree-fedora-work/98228)
- [Reddit - Nix on Silverblue experiences](https://www.reddit.com/r/Fedora/comments/jem11d/trying_to_install_nix_on_silverblue/)

### Related ADRs

- [ADR-001: NixOS Stable vs Home-Manager Unstable](../../adrs/ADR-001-NIXPKGS_UNSTABLE_ON_HOME_MANAGER_AND_STABLE_ON_NIXOS.md)
- [ADR-005: Chezmoi Migration Criteria](../../adrs/ADR-005-CHEZMOI_MIGRATION_CRITERIA.md)

---

**Action Confidence**: 0.90 (High)
- Nix on Silverblue is well-documented and proven
- Home-manager integration confirmed by multiple sources
- Three-tier strategy aligns with community best practices

**Next Steps:**
1. Test Nix installation in Kinoite WSL2
2. Create sample home-manager configuration
3. Document integration with existing my-modular-workspace structure
4. Update plan with implementation details

---

**Document Version**: 1.0
**Last Updated**: 2025-12-18
**Author**: Claude Code (Technical Researcher Role)
