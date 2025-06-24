# Sanitext Hot‑Key Cleaner

**One keystroke to clean any selected text and paste it back – across Xorg and Wayland.**

This repository contains a tiny helper workflow powered by the Python library
[`sanitext`](https://pypi.org/project/sanitext/).  It removes zero‑width
characters, homoglyphs, smart quotes, and other Unicode gremlins, leaving you
with plain, safe text.

* ✅ Works on **Ubuntu 22.04+** under **i3wm**, **Sway**, **Hyprland**, **GNOME**,
  **KDE**, **XFCE** … basically any Xorg or Wayland session.
* ✅ No editor‑specific plugins – functions everywhere you can select text.
* ✅ Automatic paste‑back where the compositor allows synthetic keystrokes.
* ✅ Passive notification pops up so you always know what happened.

---

## Repository contents

| File                    | Purpose                                                                                                                                                                                                                                                                                                                                                           |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sanitext_selection.py` | Reads text from *stdin*, sanitises it with **sanitext**, prints the cleaned text to *stdout*.                                                                                                                                                                                                                                                                     |
| `clean_hotkey.sh`       | Glue script. 1) Grabs the current **PRIMARY** selection, 2) calls `sanitext_selection.py`, 3) puts the result in the clipboard, 4) tries to press **Ctrl + V** automatically, and 5) shows a small desktop notification. Flags:<br>  • `-v`, `--verbose` – debug output to *stderr*<br>  • `--no-uinput` – disable `ydotool` fallback (Wayland security‑friendly) |
| `install.sh`            | One‑shot installer – installs dependencies, copies the two helper scripts to `~/.local/bin`, sets executable bits, prints the key‑binding snippet for i3/Sway.                                                                                                                                                                                                    |
| `README.md`             | You are here.                                                                                                                                                                                                                                                                                                                                                     |

---

## Quick start

```bash
# clone the repo and run the installer
git clone https://github.com/you/sanitext-hotkey.git
cd sanitext-hotkey
./install.sh
```

Add the hot‑key (example for **i3**; swap `bindsym` syntax for Sway):

```ini
# ~/.config/i3/config
bindsym $mod+Ctrl+h exec --no-startup-id ~/.local/bin/clean_hotkey.sh
```

Reload your WM (`$mod+Shift+r` in i3, `$mod+Shift+c` in Sway).

**Workflow:**

1. Select some text.
2. Hit **Mod + Ctrl + H**.
3. A popup such as “42 chars cleaned & pasted” appears. The text has already
   replaced the original selection.

On GNOME/KDE, the message might say “cleaned – press Ctrl+V” if synthetic
keystrokes are blocked (see *Auto‑paste* below).

---

## Command‑line options

```bash
clean_hotkey.sh [-v|--verbose] [--no-uinput]
```

| Flag              | Meaning                                                                                                                 |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `-v`, `--verbose` | Print every internal step (protocol detection, lengths, fallback) to *stderr*.                                          |
| `--no-uinput`     | Never attempt the **ydotool** fallback (Wayland environments that lock `/dev/uinput`). You will need to paste manually. |

---

## Auto‑paste behaviour

| Environment                             | Primary tool | Works out‑of‑the‑box? |
| --------------------------------------- | ------------ | --------------------- |
| Xorg                                    | `xdotool`    | ✅ Yes                 |
| Wayland (wlroots: Sway, Hyprland, etc.) | `wtype`      | ✅ Yes                 |
| Wayland (GNOME Shell, KDE Plasma)       | `wtype`      | ❌ Blocked             |

If the first attempt fails and **ydotool** is present *and* the user can write
`/dev/uinput`, the script falls back to **ydotool**. Otherwise it simply puts
the cleaned text in the clipboard and notifies you to press **Ctrl + V**.

### Enabling the ydotool fallback (GNOME/KDE)

```bash
sudo apt install ydotool

# allow your user to access /dev/uinput without sudo
echo 'SUBSYSTEM=="uinput", GROUP="input", MODE="0660"' | \
  sudo tee /etc/udev/rules.d/70-uinput.rules
sudo usermod -aG input "$USER"
sudo udevadm control --reload-rules && sudo udevadm trigger
# log out & back in so the new group applies
```

After that, `clean_hotkey.sh` will paste automatically even on GNOME/KDE.

---

## Notifications

The script tries the following commands, in order, to show a 2–3 second popup:

1. `notify-send` (libnotify – GNOME, i3/dunst, XFCE, Cinnamon, Budgie…)
2. `kdialog --passivepopup` (KDE)
3. `zenity --notification`
4. `xmessage` (plain X11)
5. Fallback to *stderr* logging.

You can tweak notification behaviour easily – it’s isolated in the `notify()`
function at the top of `clean_hotkey.sh`.

---

## Customisation

| Want…                       | Do this                                                                                          |
| --------------------------- | ------------------------------------------------------------------------------------------------ |
| **Emojis allowed**          | Edit `sanitext_selection.py` → call `sanitize_text()` with `allow_emoji=True`.                   |
| **Different hot‑key**       | Change the `bindsym` / GNOME “Custom Shortcut” to whatever you like.                             |
| **Clipboard ‑not‑ PRIMARY** | Replace `--primary` and `-selection primary` with their clipboard variants in `clean_hotkey.sh`. |
| **No auto‑paste anywhere**  | Delete or comment out both `TRY_PASTE` lines and the ydotool section.                            |

---

## Troubleshooting

* **“No selection – nothing to do”** – you triggered the shortcut without any
  text highlighted. Select some text first.
* **Notification says “press Ctrl+V”** – your compositor blocks synthetic
  key events and ydotool is either missing or cannot access `/dev/uinput`.
  Follow the instructions above or paste manually.
* **Key‑binding doesn’t fire** – verify that `clean_hotkey.sh` is executable and
  in the path you bound (`~/.local/bin`). Use `$mod+Shift+e` (i3) to open a
  debug log.

---

## Uninstall

```bash
rm ~/.local/bin/sanitext_selection.py ~/.local/bin/clean_hotkey.sh
pip uninstall sanitext
```

Remove the key‑binding from your window‑manager config.

---

## License

MIT – see `LICENSE` for the full text.
