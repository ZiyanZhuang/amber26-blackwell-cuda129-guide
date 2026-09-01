#!/usr/bin/env python3
"""Fail if likely private infrastructure identifiers or credentials enter this repository."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

TEXT_SUFFIXES = {".md", ".txt", ".tsv", ".csv", ".py", ".sh", ".yml", ".yaml", ".json", ".toml", ".ini", ".cfg"}
PATTERNS = {
    "private IPv4 address": r"(?<![\w.])(?:10|127|169\.254|172\.(?:1[6-9]|2[0-9]|3[01])|192\.168)(?:\.\d{1,3}){2}(?![\w.])",
    "public IPv4 address": r"(?<![\w.])(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-5])(?:\.\d{1,3}){3}(?![\w.])",
    "Windows user path": r"[A-Za-z]:\\Users\\",
    "private mount path": r"/(?:mnt|workspace|home|data)/",
    "SSH identity": r"\broot@",
    "access token": r"\b(?:gh[pousr]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})\b",
    "private key block": r"-----BEGIN [A-Z ]*PRIVATE KEY-----",
}
SKIP = {".git", "__pycache__"}
SELF = Path(__file__).resolve()

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    root = Path(parser.parse_args().root).resolve()
    findings: list[str] = []
    for path in root.rglob("*"):
        if not path.is_file() or any(part in SKIP for part in path.parts) or path.resolve() == SELF or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            findings.append(f"{path.relative_to(root)}: non-UTF-8 text candidate")
            continue
        for label, expression in PATTERNS.items():
            if re.search(expression, text, flags=re.IGNORECASE):
                findings.append(f"{path.relative_to(root)}: {label}")
    if findings:
        print("FAIL: potential sensitive content found:", *findings, sep="\n  - ")
        return 1
    print("PASS: no configured sensitive-content patterns found")
    return 0

if __name__ == "__main__":
    sys.exit(main())
