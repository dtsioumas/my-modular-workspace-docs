# Secret Management Implementation Guide

**Date:** 2025-12-04
**Status:** Ready for Implementation

## Overview

Systemd + KeePassXC pattern for secure API key management.

## Files to Create

### 1. home-manager/secrets/keepassxc-secret-loader.nix
### 2. home-manager/secrets/butterfish-secret.nix  
### 3. Update home-manager/home.nix
### 4. Update dotfiles/dot_bashrc.tmpl

See full implementation in session summary.

## Quick Start

```bash
# Create directory
mkdir -p home-manager/secrets

# Store secret
secret-tool store --label="OpenAI API Key (butterfish)" \
  application butterfish account openai

# Apply home-manager
home-manager switch

# Verify
systemctl --user status butterfish-api-key.service
```

**Next:** Create PLAN_V2 documents
