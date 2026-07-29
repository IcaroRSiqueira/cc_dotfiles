# Tmux Key Mappings

Prefix key is `C-a` (Ctrl+a).

## Sessions

| Key | Action |
|---|---|
| `C-a d` | Detach from current session |
| `C-a C-a` | Switch to last active window |

## Windows

| Key | Action |
|---|---|
| `C-a c` | Create new window (in current directory) |
| `C-a r` | Reload tmux configuration |

## Panes

### Creating panes

| Key | Action |
|---|---|
| `C-a v` | Vertical split (side by side) |
| `C-a s` | Horizontal split (top and bottom) |

### Navigating panes

Pane navigation is shared with vim — works seamlessly across vim splits and tmux panes.

| Key | Action |
|---|---|
| `C-h` | Move to left pane |
| `C-j` | Move to pane below |
| `C-k` | Move to pane above |
| `C-l` | Move to right pane |

### Resizing panes

| Key | Action |
|---|---|
| `Shift-Left/Right` | Resize horizontally (small step) |
| `Shift-Up/Down` | Resize vertically (small step) |
| `C-Left/Right` | Resize horizontally (large step) |
| `C-Up/Down` | Resize vertically (large step) |
| `C-z` | Toggle zoom on current pane |

## Synchronization

Send the same input to all panes in a window — useful for running the same command on multiple servers.

| Key | Action |
|---|---|
| `C-a e` | Enable pane synchronization |
| `C-a E` | Disable pane synchronization |

## Copy Mode

Enter copy mode with `C-a C-[`. Uses vi keybindings.

| Key | Action |
|---|---|
| `v` | Begin selection |
| `C-v` | Toggle rectangle selection |
| `y` | Copy selection to clipboard |
| `Enter` | Copy selection to clipboard |

## Status Bar

The status bar shows:
- Current session name and user (left)
- Window list (center)
- Battery status, hostname, and date/time (right)

The default theme is the warm VS Code-inspired palette, with the status bar placed at the top. You can switch themes with `bin/tmux-theme`.

## Theme switching

```bash
bin/tmux-theme warm
```

To apply the theme immediately in an active tmux session, the script reloads the configuration for you.

## Windows Terminal palette

If you use Windows Terminal with WSL, you can add the following scheme to the `schemes` array in `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`:

```json
{
  "name": "Ubuntu NES Theme",
  "background": "#f2f0e3",
  "foreground": "#2d2d2d",
  "cursorColor": "#b11e14",
  "selectionBackground": "#d9a39e",
  "black": "#2d2d2d",
  "blue": "#0f4ac6",
  "cyan": "#70a598",
  "green": "#4ab118",
  "purple": "#665993",
  "red": "#b11e14",
  "yellow": "#b25e00",
  "white": "#5c5952",
  "brightBlack": "#85827a",
  "brightBlue": "#1997c6",
  "brightCyan": "#70a598",
  "brightGreen": "#4ab118",
  "brightPurple": "#9b5953",
  "brightRed": "#ea3323",
  "brightYellow": "#964b00",
  "brightWhite": "#2d2d2d"
}
```

Windows are automatically renamed to the current directory.
