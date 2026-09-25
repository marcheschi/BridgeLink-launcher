#!/usr/bin/env python3
"""Generate build/windows/BridgeLinkLauncher.ico from the app logo.

Requires Pillow (pip install pillow). Run from the project root:
    python3 build/windows/make_ico.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "src/main/resources/images/logo.png"
OUT = ROOT / "build/windows/BridgeLinkLauncher.ico"

# Windows wants the classic sizes; Pillow stores them in a single .ico file.
SIZES = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]


def main() -> None:
    img = Image.open(SRC).convert("RGBA")
    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.save(OUT, format="ICO", sizes=SIZES)
    print(f"OK: wrote {OUT} ({OUT.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
