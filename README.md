# Sanitext Hot-Key Cleaner

Instantly clean any **selected text** in any app and paste it back in – with one
keystroke – using [sanitext](https://pypi.org/project/sanitext/).

* Works on **Ubuntu 22.04+** under **Xorg (i3)** or **Wayland (Sway, Hyprland,
  GNOME, KDE)**  
* Uses only tiny CLI helpers (`xclip` / `wl-clipboard`, `xdotool` / `wtype`)  
* No editor-specific plugins required

---

## Repository contents

| File | Purpose |
|------|---------|
| `sanitext_selection.py` | Reads text from `stdin`, sanitises it with **sanitext**, prints the result. |
| `clean_hotkey.sh` | Glue script: grabs the current selection (PRIMARY), calls `sanitext_selection.py`, puts the cleaned text into the Clipboard, then sends **Ctrl + V** (Wayland or Xorg automatically). |
| `install.sh` | One-click installer – installs dependencies, copies the two scripts to `~/.local/bin`, and tells you which key-binding to add. |
| `README.md` | You are here. |

---

## Quick start

```bash
git clone https://github.com/you/your-repo.git
cd your-repo
./install.sh

