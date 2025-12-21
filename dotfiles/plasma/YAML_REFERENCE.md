# Plasma YAML Reference

Map κάθε Plasma config που έχει γίνει template στο `.chezmoidata/plasma.yaml`.

| Config | YAML Section | Keys |
|--------|--------------|------|
| `powerdevilrc` | `power.ac.*` | `display.dim_timeout`, `display.off_timeout`, `display.off_when_locked_timeout`, `display.dim_when_idle`, `performance.profile`, `suspend.auto_suspend_timeout`, `suspend.power_button_action`, `suspend.sleep_mode`, `suspend.auto_suspend_action`, `run_script.idle_timeout` |
| `plasmanotifyrc` | `notifications.*` | `dnd_when_screen_mirrored`, `low_priority_history`, `popup_position`, `history_apps[]` |
| `krunnerrc` | `krunner.*` | `activate_when_typing_on_desktop`, `free_floating`, `history_behavior` |
| `plasma_workspace.notifyrc` | `workspace_notifications.*` | `device_added`, `device_removed`, `message_critical` |
| `ksmserverrc` | `session_manager.*` | `legacy_saved_count`, `session_saved_count` |
| `kglobalshortcutsrc` | `shortcuts.*` | `flameshot.capture`, `flameshot.launch`, `ksmserver.lock_session`, `spectacle.*`, `plasmashell.clipboard_action`, `plasmashell.show_on_mouse_pos` |

> **Workflow μετά από GUI αλλαγή:**
> 1. Εφάρμοσε την αλλαγή στο GUI.
> 2. Άνοιξε το YAML (`codium ~/.local/share/chezmoi/.chezmoidata/plasma.yaml`) και ενημέρωσε το σχετικό key.
> 3. `chezmoi apply ~/.config/<file>` για να διασφαλίσεις ότι το declarative state συμβαδίζει.
> 4. `chezmoi diff` για να βεβαιωθείς ότι το repo δεν έχει άλλες διαφορές.
