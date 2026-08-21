---
name: ghostty-config
description: Use when configuring the Ghostty terminal emulator, working with Ghostty config files, or looking up Ghostty settings and options.
---

## When to Use This Skill

- Working with Ghostty configuration files.
- Looking up valid configuration options.
- Troubleshooting Ghostty settings.
- Finding available fonts or themes.
- Understanding Ghostty-specific features.

---

## Quick Reference

### Access Local Documentation

Ghostty includes comprehensive built-in documentation. Use these commands in your terminal:

- **Full config reference with inline docs:** `ghostty +show-config --default --docs`
- **List available fonts:** `ghostty +list-fonts`
- **Search for specific config options:** `ghostty +show-config --default --docs | grep -A 10 "keyword"`

### Configuration File Location

- **Source:** `config/ghostty/config`
- **Installed:** `~/.config/ghostty/config`

---

## Common Configuration Patterns

### Font Configuration

```bash
# 1. List available fonts first
ghostty +list-fonts

# 2. Then configure in config file:
font-family = Maple Mono NF
font-size = 14
```

### Theme & Colors

```bash
# Search for color-related options
ghostty +show-config --default --docs | grep -i "color"
```

### Key Bindings

```bash
# Search for keybind options
ghostty +show-config --default --docs | grep -i "keybind"
```

---

## Searching Documentation

| Goal                          | Command                                |
| :---------------------------- | :------------------------------------- | -------------------------- | ------------ |
| **Find specific option docs** | `ghostty +show-config --default --docs | grep -B 2 -A 20 "^font-"`  |
| **Search by keyword**         | `ghostty +show-config --default --docs | grep -i "clipboard" -A 10` |
| **List all config keys**      | `ghostty +show-config --default        | grep "^[a-z]"              | cut -d= -f1` |

---

## Validation & Testing

- **Test Syntax:** Ghostty will report errors on startup. Run:  
   `ghostty --config-file=path/to/config`
- **View Active Config:** (Shows applied defaults + user config)  
   `ghostty +show-config`

---

## Common Configuration Categories

- **Font:** `font-family`, `font-size`, `font-style`, `font-feature`
- **Colors:** `background`, `foreground`, `palette`, `theme`
- **Window:** `window-padding-x/y`, `window-theme`, `window-decoration`
- **Shell:** `shell-integration-features`, `command`, `working-directory`
- **Keybinds:** `keybind = trigger=action[:parameter]`
- **Bell:** `bell-features`, `bell-audio-path`, `bell-audio-volume`
- **Performance:** `renderer`, `vsync`
- **macOS:** `macos-titlebar-style`, `macos-option-as-alt`

---

## Examples

### 1. Adding a Font

1.  Find the name: `ghostty +list-fonts | grep -i "JetBrains"`
2.  Add to config:
    ```ini
    font-family = JetBrains Mono
    font-family = Apple Color Emoji  # Fallback for emoji
    font-size = 14
    ```

### 2. Custom Keybindings

Syntax: `keybind = [prefix:]trigger=action[:parameter]`

```ini
keybind = ctrl+shift+c=copy_to_clipboard
keybind = ctrl+shift+v=paste_from_clipboard
keybind = ctrl+c>v=new_split:right
```

### 3. Configuring Bell

```ini
# Search docs: ghostty +show-config --default --docs | grep -A 50 "^# Bell features"

# Only show title emoji, no dock bounce
bell-features = no-attention,title
```

---

## Configuration Format Rules

- **Comments:** Start with `#`
- **Booleans:** Use `true` or `false`
- **Multi-values:** Repeat the key (e.g., for fallback fonts)
- **Defaults:** An empty value (`key = `) resets to default.
- **Quotes:** Generally **not needed** (e.g., `font-family = JetBrains Mono`).

### Keybind Prefixes

- `global:` — System-wide (needs accessibility permissions).
- `all:` — Apply to all surfaces.
- `unconsumed:` — Pass to program if not consumed.
- `performable:` — Only if action can be performed.

---

## Troubleshooting

- **Config not loading:** Check `~/.config/ghostty/config`. Unknown fields are silently ignored.
- **Font not found:** Use `ghostty +list-fonts`. Names are case-sensitive and usually require the full family name.
- **Colors:** Use hex format `#RRGGBB` or `#RRGGBBAA`.
- **Keybindings:** Check for system-level conflicts. Some actions are platform-specific (GTK vs macOS).

---

## Additional Resources

- **Built-in docs:** `ghostty +show-config --default --docs`
- **Man pages:** `man ghostty`
- **List fonts:** `ghostty +list-fonts`
- **Show active config:** `ghostty +show-config`
