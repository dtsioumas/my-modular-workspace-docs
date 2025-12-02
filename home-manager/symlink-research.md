# Declarative Symlink Management Tools - Research Summary

**Date:** 2025-11-18
**Purpose:** Comprehensive research on declarative symlink management alternatives

---

## 🎯 Research Question

**Goal:** Find the best tool for declaratively managing symlinks from `~/.MyHome/` to `~` that:
- ✅ Is declarative (configuration as code)
- ✅ Works on NixOS now
- ✅ Works on Fedora later (migration ready)
- ✅ Is reproducible and version-controlled
- ✅ Handles directory symlinks (not just dotfiles)

---

## 📊 Tools Discovered

### Category 1: NixOS-Native Solutions

#### 1. **Home-Manager** ⭐ (RECOMMENDED for NixOS)

**Stars:** 8,880+ on GitHub
**Language:** Nix
**Type:** Full user environment manager

**Key Features:**
- ✅ **Declarative** - Pure Nix configuration
- ✅ **`mkOutOfStoreSymlink`** - Create symlinks to arbitrary paths
- ✅ **Works on Fedora** - Standalone mode available
- ✅ **Integrated** - Part of Nix ecosystem
- ✅ **Reproducible** - Same config = same result

**Example:**
```nix
{ config, ... }:
{
  home.file."Documents".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.MyHome/Documents";
}
```

**Pros:**
- Already using it
- Most declarative solution
- Full integration with NixOS
- Can run on any Linux (standalone)
- Version controlled
- Reproducible

**Cons:**
- Tied to Nix ecosystem (but works on non-NixOS)
- Evaluation time for large configs
- Learning curve for Nix language

**Migration Path:**
```
NixOS (now):
└── Home-Manager with mkOutOfStoreSymlink

Fedora (later):
└── Home-Manager standalone (same config!)
```

---

#### 2. **NixOS Configuration** (System-level)

**Type:** System configuration management

**Example:**
```nix
systemd.tmpfiles.rules = [
  "L+ /home/user/Documents - - - - /home/user/.MyHome/Documents"
];
```

**Pros:**
- System-level management
- Very declarative
- Part of NixOS

**Cons:**
- NixOS only (doesn't migrate to Fedora)
- System-level (overkill for user symlinks)
- Harder to version control separately

**Verdict:** ❌ Not recommended (use Home-Manager instead)

---

### Category 2: General Dotfile Managers

#### 3. **Chezmoi** (Already Researched)

**Stars:** 16,597
**Language:** Go
**Type:** Dotfile manager with templates

**Key Features:**
- ✅ Cross-platform
- ✅ Templates (Go templates)
- ✅ Secrets management
- ❌ Copies files (not symlinks by default)
- ✅ Can create symlinks via templates

**Symlink Support:**
```bash
# Create symlink template
# File: symlink_Documents.tmpl
{{ .chezmoi.homeDir }}/.MyHome/Documents
```

**Pros:**
- Cross-platform
- Great for complex dotfiles
- Templates and secrets
- Works everywhere

**Cons:**
- Not primarily for symlinks
- More overhead than needed
- Copies files by default

**Verdict:** ✅ Good for dotfiles, not ideal for pure symlink management

---

#### 4. **Dotbot** ⭐ (EXCELLENT for symlinks)

**Stars:** 7,672
**Language:** Python
**Type:** Lightweight dotfile bootstrapper

**Key Features:**
- ✅ **Declarative YAML config**
- ✅ **Built for symlinks**
- ✅ Idempotent
- ✅ Cross-platform
- ✅ Minimal dependencies

**Example:**
```yaml
# install.conf.yaml
- link:
    ~/.config/nvim: .config/nvim
    ~/Documents:
      path: .MyHome/Documents
      force: true
    ~/Downloads:
      path: .MyHome/Downloads
      force: true
```

**Usage:**
```bash
./install  # Run dotbot
```

**Pros:**
- Simple YAML configuration
- Built specifically for symlinks
- Lightweight (single Python script)
- Easy to understand
- Cross-platform

**Cons:**
- Requires Python
- Less integrated than Home-Manager
- Manual execution needed

**Verdict:** ✅ **Excellent choice for pure symlink management**

---

#### 5. **yadm** (Yet Another Dotfiles Manager)

**Stars:** 6,009
**Language:** Shell
**Type:** Git-based dotfile manager

**Key Features:**
- ✅ Git wrapper for dotfiles
- ✅ Templates
- ✅ Encryption
- ❌ Not primarily symlink-focused

**Approach:**
- Treats `$HOME` as a Git repository
- Uses alternative worktree
- Symlinks not the primary mechanism

**Verdict:** ❌ Not ideal for this use case

---

#### 6. **rcm** (thoughtbot)

**Stars:** 3,205
**Language:** Shell scripts
**Type:** Dotfile management suite

**Key Features:**
- ✅ Well-documented shell scripts
- ✅ Symlink management
- ✅ macOS/Linux support

**Example:**
```bash
# Tag-based organization
mkrc ~/.vimrc
rcup  # Create symlinks
```

**Pros:**
- Simple shell scripts
- macOS friendly (Homebrew)
- Tag-based organization

**Cons:**
- Less declarative
- Shell script overhead
- Not as flexible

**Verdict:** ⚠️ Good but less declarative than Dotbot

---

#### 7. **GNU Stow** (Already Researched)

**Stars:** N/A (GNU project)
**Language:** Perl
**Type:** Symlink farm manager

**Key Features:**
- ✅ Automatic symlink creation
- ❌ Designed for dotfiles within stow directory
- ❌ Not for arbitrary directory symlinks

**Limitations:**
```bash
# Stow creates: ~/target → ~/dotfiles/package/target
# You want: ~/target → ~/.MyHome/target

# Stow doesn't work well for this!
```

**Verdict:** ❌ Not suitable for your use case

---

### Category 3: Custom Solutions

#### 8. **Custom Shell Script**

**Type:** DIY solution
**Language:** Bash/Shell

**Example:**
```bash
#!/bin/bash
# setup-symlinks.sh

MYHOME="$HOME/.MyHome"

ln -sf "$MYHOME/Documents" "$HOME/Documents"
ln -sf "$MYHOME/Downloads" "$HOME/Downloads"
ln -sf "$MYHOME/Pictures" "$HOME/Pictures"
# ... more symlinks
```

**Pros:**
- ✅ Simple
- ✅ No dependencies
- ✅ Full control
- ✅ Cross-platform

**Cons:**
- ❌ Not declarative
- ❌ Manual updates
- ❌ No idempotency checking

**Verdict:** ⚠️ Works but less maintainable

---

#### 9. **Dotfiles + Make**

**Type:** Makefile-based management
**Language:** Make

**Example:**
```makefile
# Makefile
.PHONY: symlinks

MYHOME := $(HOME)/.MyHome

symlinks:
	ln -sf $(MYHOME)/Documents $(HOME)/Documents
	ln -sf $(MYHOME)/Downloads $(HOME)/Downloads
```

**Pros:**
- Declarative targets
- Standard tool
- Easy to run

**Cons:**
- Make syntax
- Not ideal for this use case

**Verdict:** ⚠️ Works but overkill

---

## 🏆 Comparison Matrix

| Tool | Declarative | NixOS | Fedora | Symlinks | Complexity | Stars |
|------|-------------|-------|--------|----------|------------|-------|
| **Home-Manager** | ✅✅✅ | ✅ | ✅ | ✅ | High | 8,880 |
| **Dotbot** | ✅✅ | ✅ | ✅ | ✅✅✅ | Low | 7,672 |
| **Chezmoi** | ✅✅ | ✅ | ✅ | ⚠️ | Medium | 16,597 |
| **rcm** | ✅ | ✅ | ✅ | ✅✅ | Low | 3,205 |
| **yadm** | ✅ | ✅ | ✅ | ⚠️ | Medium | 6,009 |
| **Stow** | ✅ | ✅ | ✅ | ❌ | Low | N/A |
| **Custom Script** | ❌ | ✅ | ✅ | ✅ | Very Low | N/A |

---

## 💡 Recommendations for Your Use Case

### Current Situation Recap
- **System:** NixOS (shoshin)
- **Need:** Symlink directories from `~/.MyHome/` to `~`
- **Future:** Migrating to Fedora
- **Already using:** Home-Manager
- **Want:** Declarative, reproducible, version-controlled

---

### Option 1: Home-Manager (BEST for NixOS) ⭐⭐⭐

**Recommendation:** **Use Home-Manager with `mkOutOfStoreSymlink`**

**Why:**
1. ✅ Already using it
2. ✅ Most declarative solution
3. ✅ Works on Fedora (standalone mode)
4. ✅ Same configuration file works on both!
5. ✅ Fully version controlled
6. ✅ Reproducible

**Implementation:**
```nix
# symlinks.nix
{ config, ... }:
let
  myHome = "${config.home.homeDirectory}/.MyHome";
in
{
  home.file = {
    "Documents".source = config.lib.file.mkOutOfStoreSymlink "${myHome}/Documents";
    "Downloads".source = config.lib.file.mkOutOfStoreSymlink "${myHome}/Downloads";
    "Pictures".source = config.lib.file.mkOutOfStoreSymlink "${myHome}/Pictures";
    # ... more
  };
}
```

**Migration to Fedora:**
```bash
# On Fedora (future)
# Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Install Home-Manager standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Apply SAME configuration!
home-manager switch
```

---

### Option 2: Dotbot (BEST for simplicity) ⭐⭐

**Recommendation:** **Use Dotbot for pure symlink management**

**Why:**
1. ✅ Built specifically for symlinks
2. ✅ Simple YAML config
3. ✅ Minimal dependencies (Python)
4. ✅ Cross-platform
5. ✅ Declarative
6. ✅ Easy to understand

**Implementation:**
```yaml
# install.conf.yaml
- defaults:
    link:
      relink: true
      create: true

- link:
    ~/Documents: .MyHome/Documents
    ~/Downloads: .MyHome/Downloads
    ~/Pictures: .MyHome/Pictures
    ~/Videos: .MyHome/Videos
    ~/Music: .MyHome/Music
    ~/Projects: .MyHome/Projects
    ~/.config/home-manager: .MyHome/MySpaces/my-modular-workspace/home-manager
```

**Setup:**
```bash
# Clone Dotbot
git submodule add https://github.com/anishathalye/dotbot
git config -f .gitmodules submodule.dotbot.ignore dirty

# Create install script
cat > install <<'EOF'
#!/bin/bash
./dotbot/bin/dotbot -d . -c install.conf.yaml
EOF
chmod +x install

# Run
./install
```

**Migration to Fedora:**
```bash
# On Fedora
git clone <your-repo>
./install  # Same command!
```

---

### Option 3: Hybrid Approach ⭐⭐⭐

**Recommendation:** **Dotbot for symlinks + Home-Manager for everything else**

**Why:**
- ✅ Best of both worlds
- ✅ Simple symlink management (Dotbot)
- ✅ Full environment management (Home-Manager)
- ✅ Clear separation of concerns

**Architecture:**
```
Home-Manager:
├── Packages (nix packages)
├── Programs (declarative configs)
├── Services (systemd user services)
└── Nix-specific integration

Dotbot:
└── Directory symlinks (~/.MyHome/* → ~)

Chezmoi (optional):
└── Complex dotfiles with templates
```

**Workflow:**
```bash
# Setup symlinks
./install  # Dotbot

# Setup environment
home-manager switch  # Home-Manager

# Manage complex dotfiles
chezmoi apply  # Chezmoi (if needed)
```

---

## 🎯 Final Verdict

### For Your Specific Use Case

**Primary Recommendation: Home-Manager** ⭐⭐⭐

**Reasons:**
1. You're already using it on NixOS
2. Most declarative solution available
3. Works on Fedora (standalone)
4. Same config works everywhere
5. Fully integrated solution
6. No additional tools needed

**Implementation:**
- Create `symlinks.nix` module
- Use `mkOutOfStoreSymlink` for all directory symlinks
- Import in `home.nix`
- Commit to Git

**Migration Path:**
- NixOS: Home-Manager as NixOS module
- Fedora: Home-Manager standalone (same config!)

---

**Alternative: Dotbot** ⭐⭐

**If you want:**
- Simpler, single-purpose tool
- Just symlink management
- Faster iteration (no Nix evaluation)
- Minimal dependencies

**Trade-off:**
- Separate tool to manage
- Less integration
- Still need Home-Manager for packages/services

---

## 📚 Resources

### Home-Manager
- **Manual:** https://nix-community.github.io/home-manager/
- **mkOutOfStoreSymlink Guide:** https://gvolpe.github.io/blog/home-manager-dotfiles-management/
- **Standalone Installation:** https://nix-community.github.io/home-manager/index.html#sec-install-standalone

### Dotbot
- **GitHub:** https://github.com/anishathalye/dotbot
- **Documentation:** https://github.com/anishathalye/dotbot/wiki

### Tool Comparison
- **Dotfiles Tools List:** https://dotfiles.github.io/utilities/
- **Chezmoi Comparison:** https://www.chezmoi.io/comparison-table/

---

## 📝 Action Items

### For Next Session

1. **Decide on approach:**
   - [ ] Home-Manager only (recommended)
   - [ ] Dotbot only (simpler)
   - [ ] Hybrid (both)

2. **If Home-Manager:**
   - [ ] Create `symlinks.nix`
   - [ ] Add directory mappings
   - [ ] Import in `home.nix`
   - [ ] Test and apply

3. **If Dotbot:**
   - [ ] Add Dotbot as submodule
   - [ ] Create `install.conf.yaml`
   - [ ] Create `install` script
   - [ ] Test and commit

4. **Document:**
   - [ ] Update session summary
   - [ ] Document chosen approach
   - [ ] Create migration guide

---

## 🔑 Key Insights

### 1. Home-Manager is Underrated for Symlinks

Many people don't know about `mkOutOfStoreSymlink` or how to use it with flakes. It's actually the most declarative solution available.

### 2. Not Everything Needs to be Complex

Simple symlink management doesn't require complex tooling. Dotbot proves this with a 7,000+ star YAML-based solution.

### 3. Separation of Concerns

Different tools for different jobs:
- **Home-Manager:** Full environment (packages, services, system integration)
- **Dotbot:** Just symlinks (simple, fast, focused)
- **Chezmoi:** Complex dotfiles (templates, secrets)

### 4. Migration is Easier Than You Think

Home-Manager works on any Linux distribution, not just NixOS. Your migration path is clear.

---

**Created:** 2025-11-18
**Last Updated:** 2025-11-18
**Next Review:** When implementing symlink solution
