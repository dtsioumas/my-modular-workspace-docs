# Plasma Hardware Data Capture Guide

**Purpose:** Provide a repeatable workflow for gathering monitor/GPU metadata and updating `.chezmoidata/hardware.yaml` so Plasma templates remain host-agnostic.

---

## 1. Collect Monitor Details (Linux/KDE)

1. **List connectors & resolutions**
   ```bash
   kscreen-doctor -o
   ```
   Note each output name (`HDMI-A-1`, `DP-1`, `eDP-1`) and the active mode (width × height @ refresh).

2. **Capture EDID + hashes**
   ```bash
   xrandr --prop | sed -n "/$CONNECTOR/,/EDID/{/EDID/!p}" | tr -d '\n' | sha1sum
   ```
   Replace `$CONNECTOR` with the actual output (e.g., `HDMI-A-1`). Store:
   - `edid_identifier` (vendor/product from `kscreen-doctor`)
   - `edid_hash` (SHA1 above)

3. **Gather scale & position**
   ```bash
   plasmashell --replace &  # optional
   qdbus org.kde.KWin /KWin org.kde.KWin.supportInformation | grep -A3 "geometry"
   ```
   Or read `~/.config/kwinoutputconfig.json` before applying chezmoi.

4. **Brightness / HDR flags**
   - Check `System Settings → Display and Monitor → Night Color` for `allowSdrSoftwareBrightness`.
   - HDR availability appears in `kscreen-doctor -o` (look for `highDynamicRange`).

## 2. Collect GPU Info

```bash
glxinfo | grep "OpenGL renderer"
nvidia-smi --query-gpu=name --format=csv,noheader  # on NVIDIA
```

Record the vendor/model under `hardware.hosts.<hostname>.gpu`.

## 3. Update `.chezmoidata/hardware.yaml`

Example snippet:

```yaml
hardware:
  hosts:
    shoshin:
      gpu:
        vendor: "NVIDIA"
        model: "GeForce GTX 960"
      monitors:
        - name: "LG UltraWide (EDID GSM 30626)"
          connector: "HDMI-A-1"
          width: 3440
          height: 1440
          refresh_hz: 60
          refresh_raw: 59987
          scale: 1.05
          position: { x: 0, y: 0 }
          orientation: "landscape"
          hdr: false
          edid_identifier: "GSM 30626 463701 4 2025 0"
          edid_hash: "6dab3b16f26efdd87415f2c3bc410d74"
```

## 4. Apply & Verify

1. `chezmoi apply ~/.config/kwinrc ~/.config/kwinoutputconfig.json`
2. Restart Plasma: `kquitapp6 plasmashell && kstart6 plasmashell`
3. Confirm `System Settings → Display and Monitor` shows the expected scaling/positions.

## 5. Windows / WSL Hosts

For `system-laptop01` (Windows):

1. Install [Monitor Asset Manager](https://www.entechtaiwan.com/util/moninfo.shtm) or use PowerShell:
   ```powershell
   Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID | Select-Object -Property *
   ```
2. Extract the EDID vendor/product, native resolution, and brightness capabilities.
3. Update the `hardware.yaml` entry for `system-laptop01`.

For WSL (`gyakusatsu`):

1. Run `wsl -d <distro> xrandr --prop` inside the graphical session (X410/xrdp).
2. If only a virtual monitor exists, set `connector` to the reported name (often `XWAYLAND0`) and record the virtual resolution.

---

Keeping `hardware.yaml` current ensures every host renders KDE layouts correctly without manual edits. Always re-run `chezmoi diff ~/.config/kwinoutputconfig.json` after updating hardware data to validate the template output.
