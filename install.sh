#!/usr/bin/env bash
#
# install.sh – sets up the Sanitext hot-key workflow on Ubuntu-based systems
# Works for both Xorg (i3) and Wayland (Sway / Hyprland / GNOME).
#
# 1. Installs required packages
# 2. Puts the two helper scripts into ~/.local/bin
# 3. Ensures they are executable
# 4. Prints a short hint for adding the i3 / Sway binding
#

set -euo pipefail

echo "— Installing system packages (requires sudo)…"
sudo apt update
sudo apt install -y xclip xdotool wl-clipboard wtype python3 python3-pip

echo "— Installing Python dependency: sanitext"
python3 -m pip install --user --upgrade pip
python3 -m pip install --user sanitext

echo "— Creating ~/.local/bin if needed"
mkdir -p "$HOME/.local/bin"

echo "— Copying helper scripts"
install -m 755 sanitext_selection.py "$HOME/.local/bin/sanitext_selection.py"
install -m 755 clean_hotkey.sh        "$HOME/.local/bin/clean_hotkey.sh"

echo
echo "Installation complete."
echo
echo "Add this line to your i3 or Sway config, reload, and press Mod+Ctrl+H:"
echo '    bindsym $mod+Ctrl+h exec --no-startup-id ~/.local/bin/clean_hotkey.sh'
echo
echo "Tip: on GNOME/KDE you can bind ~/.local/bin/clean_hotkey.sh to any shortcut"
echo "     via the system keyboard-settings panel."

