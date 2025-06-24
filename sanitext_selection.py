#!/usr/bin/env python3

import sys, argparse, pathlib
from sanitext.text_sanitization import sanitize_text, get_allowed_characters

def build_allowed(args):
    if not (args.allow_emoji or args.allow_chars or args.allow_file):
        return None
    allowed = get_allowed_characters(allow_emoji=args.allow_emoji)
    if args.allow_chars:
        allowed.update(set(args.allow_chars))
    if args.allow_file:
        for ch in pathlib.Path(args.allow_file).read_text(encoding="utf-8"):
            allowed.add(ch)
    return allowed

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--allow-emoji", action="store_true")
    p.add_argument("--allow-chars", help="zusätzliche Zeichen (String)")
    p.add_argument("--allow-file",  help="Datei mit erlaubten Zeichen")
    args = p.parse_args()
    clean = sanitize_text(sys.stdin.read(), allowed_characters=build_allowed(args))
    sys.stdout.write(clean)

if __name__ == "__main__":
    main()

