#!/usr/bin/env bash
# clean_hotkey.sh – grab PRIMARY selection, sanitise via sanitext, paste back
# Usage: clean_hotkey.sh [-v|--verbose] [--no-uinput]

set -euo pipefail

CLEANER="$HOME/.local/bin/sanitext_selection.py"

VERBOSE=0
USE_UINPUT=1         # allow ydotool fallback by default

# ----- helper: logging -------------------------------------------------------
log() {
  if [[ $VERBOSE -eq 1 ]]; then
    printf '[clean_hotkey] %s\n' "$*" >&2
  fi
}

# ----- helper: desktop notifications -----------------------------------------
notify() {
  local msg="$*"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Sanitext" "$msg" --expire-time=2500
    return
  fi

  if command -v kdialog >/dev/null 2>&1; then
    kdialog --passivepopup "$msg" 2 >/dev/null
    return
  fi

  if command -v zenity >/dev/null 2>&1; then
    (
      sleep 0.1
      zenity --notification --text="$msg"
    ) &
    return
  fi

  if command -v xmessage >/dev/null 2>&1; then
    (
      xmessage -timeout 2 "$msg" &
    )
    return
  fi

  # fallback – just log
  log "$msg"
}

# ----- argument parsing -------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -v|--verbose)
      VERBOSE=1
      ;;
    --no-uinput)
      USE_UINPUT=0
      ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [-v|--verbose] [--no-uinput]

  -v, --verbose   print debug messages to stderr
  --no-uinput     never use ydotool fallback (Wayland security-friendly)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

# ----- pick protocol ---------------------------------------------------------
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" || -n "${WAYLAND_DISPLAY:-}" ]]; then
  PROTO="wayland"

  SEL_CMD=(wl-paste --primary --no-newline)
  CLIP_CMD=(wl-copy)

  TRY_PASTE() { wtype -M ctrl -k v -m ctrl; }
else
  PROTO="xorg"

  SEL_CMD=(xclip -o -selection primary)
  CLIP_CMD=(xclip -i -selection clipboard)

  TRY_PASTE() { xdotool key --clearmodifiers ctrl+v; }
fi
log "Protocol: $PROTO"

# ----- grab selection --------------------------------------------------------
SEL="$("${SEL_CMD[@]}" 2>/dev/null || true)"
if [[ -z $SEL ]]; then
  notify "0 chars selected – nothing to do"
  log "Selection empty"
  exit 0
fi
log "Selection length: ${#SEL}"

# ----- clean -----------------------------------------------------------------
CLEANED="$(printf '%s' "$SEL" | "$CLEANER")"
log "Cleaned length:   ${#CLEANED}"

# ----- put into clipboard ----------------------------------------------------
printf '%s' "$CLEANED" | "${CLIP_CMD[@]}"
log "Clipboard updated"

# ----- try to paste ----------------------------------------------------------
if TRY_PASTE 2>/dev/null; then
  notify "${#CLEANED} chars cleaned & pasted"
  log "Pasted via built-in tool"
  exit 0
fi
log "Built-in paste failed"

# ----- ydotool fallback ------------------------------------------------------
if [[ $USE_UINPUT -eq 1 ]] && command -v ydotool >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null || [[ -w /dev/uinput ]]; then
    log "Using ydotool fallback"
    ydotool key 29:1 47:1 47:0 29:0   # Ctrl down, V press+release, Ctrl up
    notify "${#CLEANED} chars cleaned & pasted"
    exit 0
  fi
  log "ydotool present, but /dev/uinput not accessible"
fi

# ----- final notification ----------------------------------------------------
notify "${#CLEANED} chars cleaned – press Ctrl+V to paste"
exit 0
