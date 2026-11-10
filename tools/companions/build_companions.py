#!/usr/bin/env python3
"""v0.53.0 · ClaudeHelper: hand-placed pixel art for the two companions of player two.

assets/sprites/companions/drone.png    4x2 frames of 28x22
    row 0: hover (rotor phases 0-3), row 1: firing (muzzle flash at the sensor eye)
    Raven's scout drone: matte black hull, cyan seams and eye like her suit.
assets/sprites/companions/nanites.png  8x2 motes of 7x7
    row 0: white glowing nanite motes (calm), row 1: red (attacking)
Every pixel comes from the small ramps below; nothing is scaled or smoothed.
"""
from PIL import Image
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "sprites", "companions")

HULL = {"o": (6, 8, 12), "1": (18, 22, 30), "2": (33, 39, 51), "3": (58, 68, 84), "4": (104, 118, 138)}
CYAN = {"a": (16, 78, 96), "b": (38, 170, 196), "c": (120, 240, 250), "d": (232, 255, 255)}
HOT = {"r": (255, 96, 120), "y": (255, 214, 140), "w": (255, 250, 236)}
PAL = {**HULL, **CYAN, **HOT}

# 28x22. Pods left/right (cols 0-7 and 20-27), hull in the middle, eye at the front (bottom).
BODY = [
    "............................",
    "............................",
    "............................",
    "............oooo............",
    "..........oo3443oo..........",
    ".........o23444432o.........",
    "..ooooo..o2b3333b2o..ooooo..",
    ".o22222oo12bb22bb21oo22222o.",
    ".o23332o1122bccb2211o23332o.",
    ".o22222o11222bb22211o22222o.",
    "..ooooo.o1122222211o.ooooo..",
    "...o1o..o11abccba11o..o1o...",
    "...o1o...o1bcddcb1o...o1o...",
    "....o....o11bccb11o....o....",
    "..........o111111o..........",
    "...........oo11oo...........",
    ".............oo.............",
    "............................",
    "............................",
    "............................",
    "............................",
    "............................",
]
# Rotor blur per phase: row offsets relative to pod top (row 5), drawn above each pod.
ROTORS = [
    ["..3444443..", ".4.......4."],
    [".344444443.", "..........."],
    ["...34443...", "44.......44"],
    ["..4444444..", ".3.......3."],
]

def put(img, x, y, key, alpha=255):
    if 0 <= x < img.width and 0 <= y < img.height and key in PAL:
        img.putpixel((x, y), PAL[key] + (alpha,))

def drone_frame(phase, firing):
    img = Image.new("RGBA", (28, 22), (0, 0, 0, 0))
    for y, row in enumerate(BODY):
        for x, ch in enumerate(row):
            if ch != ".":
                put(img, x, y, ch)
    for pod_x in (-1, 18):
        for ry, row in enumerate(ROTORS[phase]):
            for rx, ch in enumerate(row):
                if ch != ".":
                    put(img, pod_x + rx, 4 + ry, ch, 150 if ry else 200)
    # Underside thruster shimmer, alternating so the hover feels alive.
    for x in (12, 13, 14, 15):
        if (x + phase) % 2 == 0:
            put(img, x, 17, "b", 170)
            put(img, x, 18, "a", 110)
    # Status lamp on the hull blinks.
    put(img, 13, 5, "c" if phase % 2 == 0 else "b")
    if firing:
        flash = ["..w..", ".wyw.", "wyryw", ".wyw.", "..w.."]
        for fy, row in enumerate(flash):
            for fx, ch in enumerate(row):
                if ch != "." and (phase % 2 == 0 or ch != "w" or fy == 2 or fx == 2):
                    put(img, 11 + fx, 12 + fy, ch)
        put(img, 13, 12, "d"); put(img, 14, 12, "d")
    return img

MOTES = [
    [".......", ".......", "...1...", "..131..", "...1...", ".......", "......."],
    [".......", "...1...", "..121..", ".12321.", "..121..", "...1...", "......."],
    [".......", ".......", "..12...", "..23...", ".......", ".......", "......."],
    [".......", "..1.1..", "...2...", "..131..", "...2...", "..1.1..", "......."],
    [".......", ".......", "...2...", "...3...", ".......", ".......", "......."],
    ["...1...", "...1...", "..121..", "1123211", "..121..", "...1...", "...1..."],
    [".......", ".......", ".......", "...3...", ".......", ".......", "......."],
    [".......", "..11...", ".1231..", ".1321..", "..11...", ".......", "......."],
]
WHITE = {"1": (150, 200, 232, 150), "2": (214, 238, 252, 235), "3": (255, 255, 255, 255)}
RED = {"1": (190, 30, 52, 160), "2": (255, 92, 104, 240), "3": (255, 226, 214, 255)}

def main():
    os.makedirs(OUT, exist_ok=True)
    sheet = Image.new("RGBA", (28 * 4, 22 * 2), (0, 0, 0, 0))
    for row, firing in enumerate([False, True]):
        for phase in range(4):
            sheet.paste(drone_frame(phase, firing), (phase * 28, row * 22))
    sheet.save(os.path.join(OUT, "drone.png"))
    motes = Image.new("RGBA", (7 * 8, 7 * 2), (0, 0, 0, 0))
    for row, ramp in enumerate([WHITE, RED]):
        for i, shape in enumerate(MOTES):
            for y, line in enumerate(shape):
                for x, ch in enumerate(line):
                    if ch != ".":
                        motes.putpixel((i * 7 + x, row * 7 + y), ramp[ch])
    motes.save(os.path.join(OUT, "nanites.png"))
    print("wrote drone.png", sheet.size, "nanites.png", motes.size)

if __name__ == "__main__":
    main()
