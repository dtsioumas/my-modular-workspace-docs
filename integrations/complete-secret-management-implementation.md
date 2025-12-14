# Complete Secret Management Implementation

**Date:** 2025-12-04  
**Status:** ✅ Ready to Implement

---

## File 1: Generic Secret Loader

**Path:** `home-manager/secrets/keepassxc-secret-loader.nix`

```nix
{ config, pkgs, lib, ... }:

{
  createSecretService = {
    name, description, secretToolAttrs, outputFile,
    validateCommand ? "", minLength ? 8
  }: {
    systemd.user.services."${name}" = {
      Unit = {
        Description = description;
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;

        # Security Hardening
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_UNIX";
        ReadWritePaths = [ "%t" ];

        ExecStart = pkgs.writeShellScript "load-${name}" ''
          #!/usr/bin/env bash
          set -euo pipefail

          validate_non_empty() {
            [[ -z "$SECRET" ]] && { echo "ERROR: Empty" >&2; exit 1; }
          }
          validate_min_length() {
            [[ ''${#SECRET} -lt $1 ]] && { echo "ERROR: Too short" >&2; exit 1; }
          }
          validate_format() {
            [[ ! "$SECRET" =~ $1 ]] && { echo "ERROR: Invalid $2" >&2; exit 1; }
          }

          SECRET=$(${pkgs.libsecret}/bin/secret-tool lookup \
            ${lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k} ${v}") secretToolAttrs)} \
            2>/dev/null || true)

          if [[ -z "$SECRET" ]]; then
            echo "WARNING: Secret not found. Is KeePassXC unlocked?" >&2
            exit 0
          fi

          validate_non_empty
          validate_min_length ${toString minLength}
          ${validateCommand}

          OUTPUT="$XDG_RUNTIME_DIR/${outputFile}"
          echo "$SECRET" > "$OUTPUT"
          chmod 600 "$OUTPUT"
          echo "${description} loaded successfully" >&2
        '';

        ExecStop = pkgs.writeShellScript "unload-${name}" ''
          rm -f "$XDG_RUNTIME_DIR/${outputFile}"
        '';
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
```

---

## File 2: Butterfish Secret Service

**Path:** `home-manager/secrets/butterfish-secret.nix`

```nix
{ config, pkgs, lib, ... }:

let
  secretLoader = import ./keepassxc-secret-loader.nix {
    inherit config pkgs lib;
  };
in

lib.mkIf pkgs.stdenv.isLinux {
  imports = [
    (secretLoader.createSecretService {
      name = "butterfish-api-key";
      description = "OpenAI API key for butterfish";
      secretToolAttrs = {
        application = "butterfish";
        account = "openai";
      };
      outputFile = "butterfish-api-key";
      minLength = 32;
      validateCommand = ''
        validate_format '^sk-[A-Za-z0-9]{48,}$' 'OpenAI API key format'
      '';
    })
  ];
}
```

---

## Bash Integration

Add to `dotfiles/dot_bashrc.tmpl`:

**1. HISTIGNORE (line ~5):**
```bash
export HISTIGNORE="${HISTIGNORE:+$HISTIGNORE:}*API_KEY*:*TOKEN*:*PASSWORD*:*secret-tool*"
```

**2. Butterfish loading (line ~240, after atuin):**
```bash
{{ if (eq .chezmoi.os "linux") }}
{{ if (not (env "WSL_DISTRO_NAME")) }}
{{ if (lookPath "butterfish") }}

if [[ -z "$SSH_CONNECTION" ]] && [[ -z "$SSH_CLIENT" ]]; then
  BUTTERFISH_KEY_FILE="$XDG_RUNTIME_DIR/butterfish-api-key"

  if [[ -f "$BUTTERFISH_KEY_FILE" ]]; then
    export OPENAI_API_KEY=$(cat "$BUTTERFISH_KEY_FILE")
    eval "$(butterfish shell-init bash)"
    alias bf='butterfish'
  fi
fi

{{ end }}
{{ end }}
{{ end }}
```

---

## Setup Commands

```bash
# 1. Create directory
mkdir -p home-manager/secrets

# 2. Store secret in KeePassXC
secret-tool store --label="OpenAI API Key (butterfish)" \
  application butterfish account openai

# 3. Create the nix files (copy content above)

# 4. Update home-manager/home.nix - add to imports:
#    ./secrets/butterfish-secret.nix

# 5. Apply
home-manager switch

# 6. Verify
systemctl --user status butterfish-api-key.service
ls -l $XDG_RUNTIME_DIR/butterfish-api-key
```

---

**Status:** ✅ Implementation code ready  
**Next:** Test, then create PLAN_V2 documents
