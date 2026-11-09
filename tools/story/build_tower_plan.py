#!/usr/bin/env python3
"""v0.48.0 · ClaudeHelper: hand-placed pixel hologram of the Arasaka tower plan.

Builds assets/story/tower-plan.png: four 64x96 frames side by side.
Frame 0 is the base hologram, frames 1-3 are additive highlight layers:
1 = elevator shaft and guard floor, 2 = private landing pad, 3 = landing scanner.
Every pixel is placed explicitly; no smoothing or scaling is applied.
"""
from PIL import Image
import os

W, H = 64, 96
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "story", "tower-plan.png")

C = {
    "deep": (11, 42, 51), "dim": (24, 96, 112), "mid": (44, 160, 178), "lit": (79, 227, 240),
    "hot": (184, 251, 255), "side": (17, 70, 84),
    "red": (255, 79, 110), "red_hi": (255, 170, 186), "amber": (255, 179, 71), "amber_hi": (255, 226, 140),
    "mag": (224, 108, 255), "mag_hi": (246, 200, 255),
}

def frame():
    return Image.new("RGBA", (W, H), (0, 0, 0, 0))

def put(img, x, y, col, a=255):
    if 0 <= x < W and 0 <= y < H:
        r, g, b = C[col]
        img.putpixel((x, y), (r, g, b, a))

def hline(img, x0, x1, y, col, a=255):
    for x in range(x0, x1 + 1):
        put(img, x, y, col, a)

def vline(img, x, y0, y1, col, a=255):
    for y in range(y0, y1 + 1):
        put(img, x, y, col, a)

# Tower geometry (front face + receding right side face).
FX0, FX1 = 25, 46          # front face columns
TOP, BASE = 31, 84         # tower body rows
SIDE = 7                   # side face width, rises 1px per 2px
PH_X0, PH_X1, PH_TOP = 28, 43, 20   # penthouse block
PAD_Y = 19                 # landing pad deck row

def side_offset(i):
    return i // 2

def base_frame():
    img = frame()
    # Projector cone from the console emitter to the tower foot (dithered light).
    for y in range(BASE + 1, 93):
        t = (y - BASE) / (93 - BASE)
        half = int(13 - 9 * t)
        for x in range(36 - half, 36 + half + 1):
            if (x + y) % 2 == 0:
                put(img, x, y, "dim", int(70 + 60 * t))
    hline(img, 31, 41, 93, "mid", 220)
    hline(img, 29, 43, 94, "dim", 200)
    hline(img, 32, 40, 95, "deep", 230)
    put(img, 36, 93, "hot"); put(img, 35, 93, "lit"); put(img, 37, 93, "lit")
    # Side face: darker translucent fill, receding upward.
    for i in range(SIDE):
        x = FX1 + 1 + i
        for y in range(TOP - side_offset(i), BASE - side_offset(i) + 1):
            put(img, x, y, "side", 70)
        put(img, x, TOP - side_offset(i), "mid", 200)
        put(img, x, BASE - side_offset(i), "dim", 200)
    vline(img, FX1 + SIDE, TOP - side_offset(SIDE - 1), BASE - side_offset(SIDE - 1), "dim", 210)
    # Front face fill and floor grid.
    for y in range(TOP, BASE + 1):
        for x in range(FX0, FX1 + 1):
            put(img, x, y, "deep", 60)
    for y in range(TOP + 3, BASE, 4):
        hline(img, FX0 + 1, FX1 - 1, y, "dim", 150)
        for i in range(SIDE):   # floors continue on the side face
            put(img, FX1 + 1 + i, y - side_offset(i), "deep", 170)
    # Windows: two bright pixels per bay, irregular lit pattern for depth.
    for row, y in enumerate(range(TOP + 1, BASE - 1, 4)):
        for col, x in enumerate(range(FX0 + 2, FX1 - 1, 3)):
            if col == 3:
                continue  # elevator shaft column
            lit = (row * 7 + col * 3) % 5
            put(img, x, y + 1, "lit" if lit == 0 else "mid", 230 if lit == 0 else 150)
            put(img, x, y + 2, "mid" if lit == 0 else "dim", 170 if lit == 0 else 120)
    # Side face window columns (receding, darker).
    for i in (2, 4, 6):
        for y in range(TOP + 2, BASE - 1, 4):
            put(img, FX1 + i, y - side_offset(i) + 1, "dim", 150)
    # Soft one-pixel glow halo outside the left rim and roof line.
    for y in range(TOP, BASE + 1, 2):
        put(img, FX0 - 1, y, "mid", 60)
    for x in range(FX0, FX1 + 1, 2):
        put(img, x, TOP - 1, "mid", 55)
    # Lobby: brighter entrance band at the tower foot.
    for x in range(FX0 + 6, FX1 - 5):
        put(img, x, BASE - 2, "lit" if x % 2 else "hot", 200)
        put(img, x, BASE - 1, "mid", 170)
    # Front outline with lit left rim and shaded right rim.
    vline(img, FX0, TOP, BASE, "lit", 235)
    vline(img, FX1, TOP, BASE, "mid", 225)
    hline(img, FX0, FX1, TOP, "lit", 235)
    hline(img, FX0, FX1, BASE, "mid", 225)
    # Elevator shaft (base layer, quiet).
    for y in range(PH_TOP + 4, BASE):
        put(img, 35, y, "dim", 140)
        put(img, 36, y, "deep", 160)
    # Penthouse block with glass band.
    for y in range(PH_TOP, TOP):
        for x in range(PH_X0, PH_X1 + 1):
            put(img, x, y, "deep", 80)
    hline(img, PH_X0, PH_X1, PH_TOP, "lit", 240)
    vline(img, PH_X0, PH_TOP, TOP, "lit", 230)
    vline(img, PH_X1, PH_TOP, TOP, "mid", 220)
    for x in range(PH_X0 + 2, PH_X1 - 1):
        put(img, x, PH_TOP + 3, "lit" if x % 3 else "hot", 200)
        put(img, x, PH_TOP + 4, "mid", 160)
        put(img, x, PH_TOP + 7, "mid" if x % 2 else "dim", 150)
    for i in range(4):  # penthouse side face
        x = PH_X1 + 1 + i
        put(img, x, PH_TOP - side_offset(i), "mid", 190)
        for y in range(PH_TOP - side_offset(i) + 1, TOP - side_offset(i)):
            put(img, x, y, "side", 80)
    # Landing pad cantilever to the left of the penthouse roof.
    hline(img, 10, PH_X0, PAD_Y, "mid", 220)
    hline(img, 11, PH_X0 - 1, PAD_Y + 1, "dim", 200)
    for x in range(12, PH_X0, 3):  # truss under the deck
        put(img, x, PAD_Y + 2, "dim", 150)
        put(img, x + 1, PAD_Y + 3, "deep", 160)
    pad = [(15, -1), (16, -2), (17, -2), (18, -2), (19, -2), (20, -2), (21, -1)]
    for x, dy in pad:
        put(img, x, PAD_Y + dy, "lit", 210)
    put(img, 14, PAD_Y - 1, "mid", 200); put(img, 22, PAD_Y - 1, "mid", 200)
    # Scanner mast at the pad edge.
    vline(img, 10, PAD_Y - 9, PAD_Y - 1, "mid", 220)
    put(img, 9, PAD_Y - 10, "lit"); put(img, 10, PAD_Y - 10, "hot"); put(img, 11, PAD_Y - 10, "lit")
    put(img, 9, PAD_Y - 11, "mid"); put(img, 11, PAD_Y - 11, "mid")
    # Antenna and roof beacon.
    vline(img, 39, PH_TOP - 8, PH_TOP - 1, "dim", 200)
    put(img, 39, PH_TOP - 9, "hot")
    # Corner registration ticks of a projected plan.
    for x, y in [(1, 1), (W - 2, 1), (1, 88), (W - 2, 88)]:
        put(img, x, y, "mid", 200)
        put(img, x + (1 if x < 5 else -1), y, "dim", 180)
        put(img, x, y + (1 if y < 5 else -1), "dim", 180)
    return img

def elevator_frame():
    img = frame()
    for y in range(PH_TOP + 4, BASE):
        put(img, 35, y, "red", 230 if y % 4 else 150)
        put(img, 36, y, "red_hi" if y % 6 == 0 else "red", 170)
    # Guard floor: one storey below the penthouse.
    gy = TOP + 3
    hline(img, FX0 + 1, FX1 - 1, gy, "red", 220)
    hline(img, FX0 + 1, FX1 - 1, gy + 4, "red", 150)
    for x in (28, 32, 41):
        put(img, x, gy + 2, "red_hi"); put(img, x, gy + 1, "red", 200)
    for x in range(34, 38):  # elevator car parked on the guard floor
        put(img, x, gy + 1, "red_hi", 240); put(img, x, gy + 2, "red", 240)
    return img

def pad_frame():
    img = frame()
    hline(img, 10, PH_X0, PAD_Y, "amber", 240)
    hline(img, 11, PH_X0 - 1, PAD_Y + 1, "amber", 160)
    for x, dy in [(15, -1), (16, -2), (17, -2), (18, -2), (19, -2), (20, -2), (21, -1), (14, -1), (22, -1)]:
        put(img, x, PAD_Y + dy, "amber_hi", 250)
    for x, dy in [(16, -3), (18, -4), (20, -3)]:  # rising landing marker
        put(img, x, PAD_Y + dy, "amber", 200)
    put(img, 18, PAD_Y - 5, "amber_hi")
    # Hatch from the pad into the penthouse.
    vline(img, PH_X0 + 2, PH_TOP + 1, PH_TOP + 5, "amber", 220)
    return img

def scanner_frame():
    img = frame()
    vline(img, 10, PAD_Y - 9, PAD_Y - 1, "mag", 230)
    put(img, 9, PAD_Y - 10, "mag_hi"); put(img, 10, PAD_Y - 10, "mag_hi"); put(img, 11, PAD_Y - 10, "mag_hi")
    # Dithered scan fan reaching up and out into the approach airspace (up-left).
    for i in range(1, 11):
        cx, cy = 10 - (i * 9) // 10, PAD_Y - 10 - (i * 8) // 10
        spread = i // 3
        for k in range(-spread, spread + 1):
            if (i + k) % 2 == 0:
                put(img, cx - k, cy + k, "mag", max(70, 220 - i * 14))
    for i in (3, 6, 9):
        put(img, 10 - (i * 9) // 10, PAD_Y - 10 - (i * 8) // 10, "mag_hi", 230)
    return img

def main():
    sheet = Image.new("RGBA", (W * 4, H), (0, 0, 0, 0))
    for i, f in enumerate([base_frame(), elevator_frame(), pad_frame(), scanner_frame()]):
        sheet.paste(f, (i * W, 0))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    sheet.save(OUT)
    print("wrote", OUT, sheet.size)

if __name__ == "__main__":
    main()
