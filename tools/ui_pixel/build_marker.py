#!/usr/bin/env python3
"""v0.48.0 · ClaudeHelper: pixel interaction marker replacing vector circle/arrow hints.

assets/ui/marker.png, two rows (0 = cyan "bereit", 1 = red "gesperrt/warten"):
  x 0..95   three 32x14 floor-ring pulse frames
  x 96..106 one 11x9 chevron, drawn only while the target is still out of reach
Every pixel is set explicitly from a small material ramp.
"""
from PIL import Image
import math, os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "assets", "ui", "marker.png")
RAMPS = [
    [(11, 26, 34), (31, 111, 124), (63, 196, 212), (143, 244, 251), (233, 255, 255)],
    [(42, 13, 20), (138, 34, 56), (244, 93, 121), (255, 166, 184), (255, 240, 243)],
]
RW, RH, ROW = 32, 14, 14

def ring(img, ox, oy, ramp, frame):
    cx, cy = 15.5, 6.5
    rx, ry = 12.0, 4.6
    for y in range(RH):
        for x in range(RW):
            dx, dy = (x + 0.5 - cx - 0.5) / rx, (y + 0.5 - cy - 0.5) / ry
            d = math.hypot(dx, dy)
            ang = math.atan2(dy, dx)
            top = dy < 0
            if 0.86 <= d <= 1.08:
                shade = 3 if top else 2
                if frame == 1:
                    shade = min(4, shade + 1)
                if abs(math.sin(ang)) > 0.97 or abs(math.cos(ang)) > 0.985:  # N/E/S/W ticks
                    shade = 4
                img.putpixel((ox + x, oy + y), ramp[shade] + (255,))
            elif 1.08 < d <= 1.24:
                img.putpixel((ox + x, oy + y), ramp[0] + (230,))
            elif 0.72 <= d < 0.86 and top:
                img.putpixel((ox + x, oy + y), ramp[1] + (150,))
            elif frame == 2 and 1.3 <= d <= 1.42 and (x + y) % 2 == 0 and 0 < y < RH - 1:
                img.putpixel((ox + x, oy + y), ramp[2] + (140,))

CHEVRON = [
    "0000000000 ",
    "03300000330",
    "03440004430",
    "00344044300",
    " 003444300 ",
    "  0034300  ",
    "   00300   ",
    "    000    ",
    "     0     ",
]

def chevron(img, ox, oy, ramp):
    for y, row in enumerate(CHEVRON):
        for x, ch in enumerate(row):
            if ch == " ":
                continue
            level = int(ch)
            alpha = 235 if level == 0 else 255
            img.putpixel((ox + x, oy + y), ramp[level] + (alpha,))

def main():
    img = Image.new("RGBA", (RW * 3 + 11, ROW * 2), (0, 0, 0, 0))
    for r, ramp in enumerate(RAMPS):
        for f in range(3):
            ring(img, f * RW, r * ROW, ramp, f)
        chevron(img, RW * 3, r * ROW, ramp)
    img.save(OUT)
    print("wrote", OUT, img.size)

if __name__ == "__main__":
    main()
