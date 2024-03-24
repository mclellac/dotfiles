# Hyprland Keybindings Cheatsheet

## General

- `SUPER + T`: Execute `gnome-terminal --hide-menubar`.
- `SUPER + V`: Execute
  `cliphist list | wofi -dmenu -p "󰆒" -theme \
~/.config/wofi/themes/clipboard.rasi | cliphist decode | wl-copy`.
- `SUPER + space`: Execute `wofi --show drun -theme ~/.config/wofi/style.css`.
- `SUPER + return`: Execute `$TERM` (Open a terminal).
- `SUPER_SHIFT + R`: Execute `hyprctl reload`.

## Containers

- `SUPER + W`: Toggle split (dwindle).
- `SUPER + F`: Fullscreen, 0.
- `SUPER + Q`: Kill active.
- `SUPER + P`: Workspace option, all pseudo.
- `SUPER + O`: Toggle floating.
- `SUPER_CONTROL + PLUS`: Split ratio, -0.1.
- `SUPER_CONTROL + MINUS`: Split ratio, +0.1.

## Mouse Bindings

- `SUPER + mouse:273`: Resize window.
- `SUPER + mouse:272`: Move window.

## Special Workspace

- `SUPER + MINUS`: Toggle special workspace.
- `SUPER_SHIFT + MINUS`: Move to workspace silent, special.

## Focus Movement

- `SUPER + h/j/k/l`: Move focus left/down/up/right.
- `SUPER + arrow keys`: Move focus in the direction of the arrow.

## Window Movement

- `SUPER_SHIFT + h/j/k/l`: Move window left/down/up/right.
- `SUPER_SHIFT + arrow keys`: Move window in the direction of the arrow.

## Workspaces

- `SUPER + 1-0`: Switch to workspace 1-10.
- `SUPER_SHIFT + 1-0`: Move window to workspace 1-10 silently.

Note: This is a simplified overview of the keybindings. For detailedunderstanding
understanding, refer to the original configuration file and Hyprland's
documentation.
