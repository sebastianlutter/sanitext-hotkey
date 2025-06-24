#!/usr/bin/env python3
"""
Reads text from STDIN, cleans it with sanitext and writes the
result to STDOUT.

Options
-------
--allow-emoji            keep emoji characters
--allow-chars "xyz"      additionally allow these characters
--allow-file <path>      file containing extra whitelisted characters
"""
import sys
import argparse
import pathlib
from sanitext.text_sanitization import sanitize_text, get_allowed_characters


def build_allowed(args):
    """Return a *set* of allowed characters for sanitext (never None)."""
    allowed = get_allowed_characters(allow_emoji=args.allow_emoji)

    if args.allow_chars:
        allowed.update(set(args.allow_chars))
    if args.allow_file:
        allowed.update(
            set(
                pathlib.Path(args.allow_file)
                .read_text(encoding="utf-8", errors="ignore")
            )
        )
    return allowed


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--allow-emoji", action="store_true", help="allow emoji characters"
    )
    parser.add_argument(
        "--allow-chars",
        help="string of additional allowed characters, e.g. \"€£αβ\"",
    )
    parser.add_argument(
        "--allow-file", help="file with extra allowed characters (any format)"
    )
    args = parser.parse_args()

    cleaned = sanitize_text(sys.stdin.read(), allowed_characters=build_allowed(args))
    sys.stdout.write(cleaned)


if __name__ == "__main__":
    main()
