#!/usr/bin/env python3
"""v0.48.0 · ClaudeHelper: pixel alarm beacon and floor emergency light for the tower escape.

assets/story/tower/alarm-lights.png (64x12):
  x 0..47  four 12x12 beacon frames: wall bracket + red dome, the reflector band turns
  x 48..57 one 10x7 recessed floor chevron (LED on), x 58..63 unused
  row 2 is not used; dim floor state is drawn by modulating the lit LED.
"""
from PIL import Image
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "story", "tower", "alarm-lights.png")
RED = [(42, 10, 16), (110, 20, 36), (184, 35, 60), (255, 74, 94), (255, 176, 184), (255, 240, 242)]
GUN = [(13, 17, 22), (35, 43, 51), (59, 70, 80), (95, 109, 120)]

# Beacon: '.' empty, 'o' outline, g0..g3 gunmetal, r0..r5 red (digits after letter).
DOME = [
    "....oooo....",
    "...o2233o...",
    "..o122332o..",
    "..o122332o..",
    ".o11223321o.",
    ".o11222221o.",
    ".oooooooooo.",
]
BASE = [
    "oaaaabbbbaao",
    "obccccccccbo",
    "oaaaaaaaaaao",
    ".oo......oo.",
    "..o......o..",
]

def beacon(img, ox, frame):
    band = [2, 4, 7, -9][frame]  # column of the hot reflector band; negative = facing away
    for y, row in enumerate(DOME):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            if ch == "o":
                img.putpixel((ox + x, y), GUN[0] + (255,))
                continue
            level = int(ch)
            if band >= 0 and abs(x - band) <= 1 and 0 < y < 6:
                level = 5 if x == band else 4
            elif band < 0:
                level = max(1, level - 1)
            img.putpixel((ox + x, y), RED[level] + (255,))
    for y, row in enumerate(BASE):
        for x, ch in enumerate(row):
            if ch == ".":
                continue
            col = {"o": GUN[0], "a": GUN[1], "b": GUN[3], "c": GUN[2]}[ch]
            img.putpixel((ox + x, 7 + y), col + (255,))

CHEV = [
    "oooooooooo",
    "o3..3....o",
    "o.4..4...o",
    "o..5..5..o",
    "o.4..4...o",
    "o3..3....o",
    "oooooooooo",
]

def floor_chevron(img, ox):
    # Recessed housing with an inner LED chevron pointing right (escape direction).
    for y, row in enumerate(CHEV):
        for x, ch in enumerate(row):
            if ch == "o":
                img.putpixel((ox + x, 2 + y), GUN[1] + (255,))
            elif ch == ".":
                img.putpixel((ox + x, 2 + y), RED[0] + (255,))
            else:
                img.putpixel((ox + x, 2 + y), RED[int(ch)] + (255,))
    return img

def main():
    img = Image.new("RGBA", (64, 12), (0, 0, 0, 0))
    for f in range(4):
        beacon(img, f * 12, f)
    floor_chevron(img, 48)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    img.save(OUT)
    print("wrote", OUT, img.size)

if __name__ == "__main__":
    main()
