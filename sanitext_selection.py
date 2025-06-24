#!/usr/bin/env python3
"""
Sanitext wrapper that *never* mangles normal code or Markdown.

Key features
============
* **Keeps every ASCII printable character (0x20–0x7E)** so source‑code snippets,
  JSON, HTML, Markdown punctuation, etc. remain intact.
* German umlauts **ä ö ü Ä Ö Ü ß** are whitelisted by default.
* Optional `--replace-char C` substitutes disallowed glyphs instead of deleting
  them.
* Flags `--allow-emoji`, `--allow-chars`, `--allow-file` extend the allow‑set.

CLI usage
---------
```
sanitext_selection.py [--replace-char X]
                       [--allow-emoji]
                       [--allow-chars "xyz"]
                       [--allow-file PATH]
```
"""

from __future__ import annotations

import argparse
import pathlib
import string
import sys
from typing import Optional, Set

from sanitext.text_sanitization import get_allowed_characters

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

ASCII_PRINTABLE: Set[str] = set(string.printable)  # space through ~ including \t\n
UMLAUTS: Set[str] = set("äöüÄÖÜß")

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def build_allowed(args: argparse.Namespace) -> Set[str]:
    """Compose the final allow‑set from defaults plus CLI additions."""

    allowed: Set[str] = set()

    # Start with sanitext's own base (letters, digits, common punct.)
    allowed.update(get_allowed_characters(allow_emoji=args.allow_emoji))

    # Ensure full ASCII printable range is kept (protects code/Markdown)
    allowed.update(ASCII_PRINTABLE)

    # German umlauts / sharp‑s
    allowed.update(UMLAUTS)

    # Caller‑supplied additions
    if args.allow_chars:
        allowed.update(set(args.allow_chars))

    if args.allow_file:
        file_chars = pathlib.Path(args.allow_file).read_text(
            encoding="utf-8", errors="ignore"
        )
        allowed.update(file_chars)

    return allowed


def sanitize_with_replacement(
    text: str,
    allowed: Set[str],
    replacement: Optional[str] = None,
) -> str:
    """Return *text* with disallowed glyphs either removed or replaced."""

    if replacement is None:
        return "".join(ch for ch in text if ch in allowed)

    return "".join(ch if ch in allowed else replacement for ch in text)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:  # noqa: D401   (simple function, no detailed docstring)
    parser = argparse.ArgumentParser(
        description=(
            "Sanitext cleaner that preserves ASCII code, Markdown, umlauts, etc."
        )
    )

    parser.add_argument(
        "--replace-char",
        metavar="C",
        help="substitute C for disallowed characters instead of deleting them",
    )
    parser.add_argument("--allow-emoji", action="store_true", help="keep emoji")
    parser.add_argument(
        "--allow-chars", help="string of additional characters to allow"
    )
    parser.add_argument(
        "--allow-file", help="file containing extra allowed characters"
    )

    args = parser.parse_args()

    allow_set = build_allowed(args)

    cleaned = sanitize_with_replacement(sys.stdin.read(), allow_set, args.replace_char)

    sys.stdout.write(cleaned)


if __name__ == "__main__":
    main()
