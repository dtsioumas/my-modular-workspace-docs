# Chezmoi Migration Documentation

**Created:** 2025-11-17
**Purpose:** Comprehensive guide for migrating from home-manager to chezmoi on NixOS

---

## 📚 Documentation Overview

This directory contains complete documentation for setting up chezmoi and gradually migrating from home-manager, in preparation for future Fedora migration.

### Documents

1. **[01-chezmoi-overview.md](01-chezmoi-overview.md)**
   - What is chezmoi?
   - Key features and capabilities
   - Architecture and how it works
   - Comparison with home-manager
   - Why use chezmoi with NixOS

2. **[02-migration-strategy.md](02-migration-strategy.md)**
   - Phased migration approach (6 weeks)
   - Hybrid NixOS + chezmoi setup
   - Step-by-step migration phases
   - Rollback plans
   - Migration checklists

3. **[03-implementation-guide.md](03-implementation-guide.md)**
   - Hands-on setup instructions
   - Command reference
   - Template examples
   - Secrets management with KeePassXC
   - Troubleshooting guide

4. **[04-best-practices.md](04-best-practices.md)**
   - Repository organization patterns
   - Template best practices
   - Security guidelines
   - Performance optimization
   - Common pitfalls to avoid

---

## 🚀 Quick Start

### For First-Time Readers

**Read in order:**
1. Start with **01-chezmoi-overview.md** to understand the tool
2. Review **02-migration-strategy.md** to plan your approach
3. Follow **03-implementation-guide.md** for hands-on setup
4. Reference **04-best-practices.md** as you build your configs

### For Quick Reference

- **Need commands?** → See [03-implementation-guide.md](03-implementation-guide.md#quick-reference)
- **Need templates?** → See [04-best-practices.md](04-best-practices.md#template-patterns)
- **Migration timeline?** → See [02-migration-strategy.md](02-migration-strategy.md#migration-phases)
- **Architecture info?** → See [01-chezmoi-overview.md](01-chezmoi-overview.md#architecture)

---

## 🎯 Migration Goals

### Primary Objectives

1. ✅ **Decouple home configs from NixOS**
   - Separate dotfiles from Nix expressions
   - Enable cross-platform compatibility

2. ✅ **Prepare for Fedora migration**
   - Configs work on both NixOS and Fedora
   - Smooth transition path

3. ✅ **Maintain system stability**
   - Gradual migration (not big bang)
   - Keep home-manager as fallback
   - Test thoroughly at each phase

4. ✅ **Improve secrets management**
   - Better KeePassXC integration
   - Encrypted sensitive files
   - No secrets in Git

### Success Criteria

- [ ] All personal configs managed by chezmoi
- [ ] Secrets handled via KeePassXC + age
- [ ] Platform-agnostic dotfiles
- [ ] Tested on fresh NixOS install
- [ ] Ready for Fedora migration
- [ ] Documentation complete

---

## 📅 Recommended Timeline

### Phase 1: Setup & Testing (Week 1)
- Install chezmoi
- Create dotfiles repository
- Migrate simple configs (bashrc, gitconfig)
- Test alongside home-manager

### Phase 2: Shell & Editor (Week 2)
- Migrate shell configurations
- Migrate editor configs (nvim)
- Remove from home-manager
- Test thoroughly

### Phase 3: Application Configs (Week 3-4)
- Migrate app-specific configs
- Setup KeePassXC integration
- Create platform-specific templates

### Phase 4: Secrets & Encryption (Week 4-5)
- Setup age encryption
- Encrypt sensitive files
- Test secret retrieval

### Phase 5: Package Management (Week 5-6)
- Document package lists
- Create install scripts for Fedora
- Prepare migration manifests

### Phase 6: Cleanup & Optimization (Week 6-7)
- Minimize home-manager
- Optimize chezmoi setup
- Complete documentation
- Final testing

---

## 🔧 Current System State

### What You Have

```
NixOS System (shoshin)
├── System Configuration
│   └── ~/.config/nixos/
│       ├── configuration.nix
│       ├── hosts/shoshin/
│       └── modules/
│           ├── system/
│           │   ├── usb-mouse-fix.nix
│           │   └── ...
│           └── workspace/
│               ├── rclone-bisync.nix
│               ├── keepassxc.nix
│               └── ...
│
└── Home-Manager
    └── ~/.config/nixos/home/mitso/
        ├── home.nix
        ├── keepassxc.nix
        └── ...
```

### What You'll Build

```
Hybrid System
├── NixOS (System Level)
│   └── Core system, services, hardware
│
├── Home-Manager (Minimal)
│   └── Nix-specific integration only
│
└── Chezmoi (Dotfiles)
    └── ~/.local/share/chezmoi/
        ├── Application configs
        ├── Shell configs
        ├── Secrets (encrypted)
        └── Install scripts
```

---

## 🔑 Key Features Covered

### Chezmoi Capabilities

- ✅ **Templates** - Platform-specific configs
- ✅ **Secrets** - KeePassXC integration
- ✅ **Encryption** - age-based file encryption
- ✅ **External resources** - Import from GitHub, archives
- ✅ **Run scripts** - Automated setup tasks
- ✅ **Cross-platform** - Works on NixOS, Fedora, macOS, etc.
- ✅ **Git integration** - Native version control

### NixOS Integration

- ✅ Keep system packages in NixOS
- ✅ Maintain systemd services via home-manager
- ✅ Gradual migration approach
- ✅ Rollback capability
- ✅ VM testing support

---

## 📖 Documentation Sources

This documentation is based on:

### Official Documentation
- [Chezmoi Official Docs](https://www.chezmoi.io/)
- [Chezmoi GitHub Repository](https://github.com/twpayne/chezmoi)
- [Chezmoi User Guide](https://www.chezmoi.io/user-guide/)

### Research & Community
- [Migrating from Nix and Home Manager](https://htdocs.dev/posts/migrating-from-nix-and-home-manager-to-homebrew-and-chezmoi/)
- [Using chezmoi on NixOS - Discussion](https://discourse.nixos.org/t/using-chezmoi-on-nixos/30699)
- [Dotfiles Journey with Chezmoi + NixOS](https://seds.nl/notes/my-journey-in-managing-dotfiles/)
- Context7 MCP (Latest chezmoi documentation)

### Research Date
**2025-11-17** - All documentation reflects latest chezmoi best practices

---

## 🛠️ Tools & Prerequisites

### Required

- **NixOS** - Already installed (shoshin)
- **Git** - Already configured
- **GitHub account** - For dotfiles repo
- **KeePassXC** - Already setup at `~/MyVault/`

### To Install

- **chezmoi** - Dotfile manager
- **age** - Encryption tool

### Installation

```nix
# Add to ~/.config/nixos/home/mitso/home.nix
home.packages = with pkgs; [
  chezmoi
  age
];
```

Apply:
```bash
sudo nixos-rebuild switch
```

---

## 💡 Tips for Success

### Do's ✅

1. **Read all docs first** before starting migration
2. **Start small** - migrate simple configs first
3. **Test thoroughly** at each phase
4. **Use dry-run** before applying changes
5. **Commit frequently** to Git
6. **Document decisions** as you go
7. **Keep backups** of important configs

### Don'ts ❌

1. **Don't rush** the migration
2. **Don't skip testing** phases
3. **Don't commit secrets** unencrypted
4. **Don't modify both** chezmoi and home-manager for same file
5. **Don't forget** to backup your age key
6. **Don't ignore** warnings or errors

---

## 🔗 Quick Links

### Internal Documentation
- [Overview](01-chezmoi-overview.md)
- [Migration Strategy](02-migration-strategy.md)
- [Implementation Guide](03-implementation-guide.md)
- [Best Practices](04-best-practices.md)

### External Resources
- [Chezmoi Website](https://www.chezmoi.io/)
- [Chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Template Reference](https://www.chezmoi.io/reference/templates/)
- [Command Reference](https://www.chezmoi.io/reference/commands/)

---

## 📝 Next Steps

1. **Read** all four documentation files
2. **Plan** your migration timeline
3. **Create** GitHub dotfiles repository
4. **Start** with Phase 1 from migration strategy
5. **Test** frequently and thoroughly
6. **Document** any issues or solutions

---

## 🤝 Support

### Getting Help

- **Chezmoi Docs:** https://www.chezmoi.io/
- **NixOS Discourse:** https://discourse.nixos.org/
- **GitHub Issues:** https://github.com/twpayne/chezmoi/issues

### Contributing

Found an issue or improvement? Update these docs and commit changes.

---

## 📜 License

This documentation is for personal use. Chezmoi itself is MIT licensed.

---

**Created by:** Research session with Claude Code
**Date:** 2025-11-17
**Version:** 1.0

**Ready to start?** → Begin with [01-chezmoi-overview.md](01-chezmoi-overview.md)
