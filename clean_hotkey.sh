#!/usr/bin/env bash
set -euo pipefail
CLEANER="$HOME/.local/bin/sanitext_selection.py"

if [[ "${XDG_SESSION_TYPE:-}" == "wayland" || -n "${WAYLAND_DISPLAY:-}" ]]; then
  # -------- Wayland Pfad --------
  SEL="$(wl-paste --primary --no-newline 2>/dev/null || wl-paste --no-newline)"
  CLEANED="$(printf '%s' "$SEL" | "$CLEANER")"
  printf '%s' "$CLEANED" | wl-copy                           # -> Clipboard
  wtype -M ctrl -k v -m ctrl || notify-send "sanitext" "Bereinigt – Strg+V drücken"
else
  # -------- Xorg Pfad ----------
  SEL="$(xclip -o -selection primary)"
  CLEANED="$(printf '%s' "$SEL" | "$CLEANER")"
  printf '%s' "$CLEANED" | xclip -i -selection clipboard
  xdotool key --clearmodifiers ctrl+v
fi

