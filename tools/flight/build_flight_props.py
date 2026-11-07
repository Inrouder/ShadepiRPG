#!/usr/bin/env python3
"""Pixel-art props for the Aerodyne flight (top-down, 1:1 in the 640x360 view).

Output: assets/world/hq/flight-props.png (nearest filtering), atlas layout:
  (0,0)    defence drone frame A  40x32   Kenzō's tower guard, rotor blades at 0°
  (40,0)   defence drone frame B  40x32   blades at 45°
  (80,0)   skybridge truss tile   32x26   tiles horizontally
  (112,0)  skybridge gap pylon     10x34  hazard stripes + warning lamp (mirror for the right side)
  (122,0)  scanner emitter         24x24  ring with a cyan lens (tower scanner head)

Light comes from the top left; steel ramp shared with the pixel UI.
Usage: python3 tools/flight/build_flight_props.py  (from the repository root)
"""
import math
import os
from PIL import Image

def rgba(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), a)

STEEL = [rgba(c) for c in ["#0b0e17", "#141b28", "#1f2a3b", "#2f3e54", "#4a5d78", "#7487a3", "#a3aec2"]]
RED = [rgba(c) for c in ["#3d0710", "#8e1626", "#ff3b4e", "#ffb0b8"]]
AMBER = [rgba(c) for c in ["#4a2a06", "#9a5f0e", "#f0a62a", "#ffe08a"]]
CYAN = [rgba(c) for c in ["#0c3440", "#135f70", "#1fa9bd", "#62e3ee", "#cffcff"]]
CLEAR = (0, 0, 0, 0)

class Canvas:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[CLEAR] * w for _ in range(h)]

    def put(self, x, y, c):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = c

    def get(self, x, y):
        return self.px[y][x] if 0 <= x < self.w and 0 <= y < self.h else CLEAR

    def rect(self, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.put(x, y, c)

    def line(self, x0, y0, x1, y1, c):
        steps = int(max(abs(x1 - x0), abs(y1 - y0))) or 1
        for i in range(steps + 1):
            t = i / steps
            self.put(x0 + (x1 - x0) * t, y0 + (y1 - y0) * t, c)

    def outline(self, c):
        solid = [[self.px[y][x][3] > 0 for x in range(self.w)] for y in range(self.h)]
        for y in range(self.h):
            for x in range(self.w):
                if solid[y][x]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < self.w and 0 <= ny < self.h and solid[ny][nx]:
                        self.px[y][x] = c
                        break

    def image(self):
        im = Image.new("RGBA", (self.w, self.h))
        for y in range(self.h):
            for x in range(self.w):
                im.putpixel((x, y), self.px[y][x])
        return im

def drone(angle):
    c = Canvas(40, 32)
    rotors = [(8, 7), (31, 7), (8, 24), (31, 24)]
    # arms first, under everything
    for rx, ry in rotors:
        c.line(20, 16, rx, ry, STEEL[2])
        c.line(20, 15, rx, ry - 1, STEEL[3])
    for rx, ry in rotors:
        for a in range(0, 360, 4):
            r = math.radians(a)
            for rad, col in ((6, None), (5, STEEL[1])):
                x, y = rx + math.cos(r) * rad, ry + math.sin(r) * rad
                if col is None:
                    lit = math.cos(r + math.radians(45)) < -0.2   # top-left light
                    col = STEEL[5] if lit else STEEL[3]
                c.put(x, y, col)
        for y in range(ry - 4, ry + 5):
            for x in range(rx - 4, rx + 5):
                if (x - rx) ** 2 + (y - ry) ** 2 <= 16:
                    c.put(x, y, (11, 14, 23, 150))
        b = math.radians(angle)
        for s in (-4, -3, -2, 2, 3, 4):
            c.put(rx + math.cos(b) * s, ry + math.sin(b) * s, STEEL[4])
            c.put(rx + math.cos(b + math.pi / 2) * s, ry + math.sin(b + math.pi / 2) * s, STEEL[3])
        c.put(rx, ry, STEEL[5])
    # gun pods pointing down (toward the Aerodyne)
    for gx in (13, 25):
        c.rect(gx, 18, gx + 1, 26, STEEL[3])
        c.put(gx, 18, STEEL[5])
        c.rect(gx, 27, gx + 1, 27, RED[2])
    # armoured octagon body
    for y in range(9, 24):
        for x in range(12, 28):
            cut = min(x - 12, 27 - x, y - 9, 23 - y)
            if (x - 12) + (y - 9) < 4 or (27 - x) + (y - 9) < 4 or (x - 12) + (23 - y) < 4 or (27 - x) + (23 - y) < 4:
                continue
            if cut == 0:
                col = STEEL[0]
            elif (x - 12) + (y - 9) < 6 or y == 10 or x == 13:
                col = STEEL[5]
            elif (27 - x) + (23 - y) < 6 or y == 22 or x == 26:
                col = STEEL[1]
            else:
                col = STEEL[3]
            c.put(x, y, col)
    # panel seams and rivets
    c.line(15, 13, 24, 13, STEEL[2])
    c.line(15, 20, 24, 20, STEEL[2])
    for x, y in ((15, 12), (24, 12), (15, 21), (24, 21)):
        c.put(x, y, STEEL[6])
    # red sensor eye with glint
    for y in range(14, 19):
        for x in range(17, 23):
            d = (x - 19.5) ** 2 + (y - 16.5) ** 2
            if d <= 7.5:
                c.put(x, y, RED[0] if d > 5 else (RED[1] if d > 2.5 else RED[2]))
    c.put(19, 16, RED[3])
    c.put(18, 15, (255, 255, 255, 255))
    # amber status lamps on the hull
    c.put(13, 15, AMBER[2])
    c.put(26, 15, AMBER[2])
    c.outline(STEEL[0])
    return c

def bridge_tile():
    c = Canvas(32, 26)
    def rail(y0, rows):
        for i, col in enumerate(rows):
            c.rect(0, y0 + i, 31, y0 + i, col)
    rail(0, [STEEL[0], STEEL[6], STEEL[4], STEEL[3], STEEL[1]])
    rail(21, [CYAN[1], STEEL[4], STEEL[3], STEEL[2], STEEL[0]])
    # truss: verticals every 16 px and X braces, open grid between
    for x0 in (0, 16):
        c.rect(x0, 5, x0 + 1, 20, STEEL[3])
        c.put(x0, 5, STEEL[5])
        c.line(x0 + 2, 6, x0 + 15, 19, STEEL[3])
        c.line(x0 + 2, 19, x0 + 15, 6, STEEL[4])
    # walkway plate with grating
    c.rect(0, 11, 31, 14, STEEL[2])
    c.rect(0, 11, 31, 11, STEEL[4])
    c.rect(0, 14, 31, 14, STEEL[1])
    for x in range(1, 32, 3):
        c.put(x, 12, STEEL[1])
        c.put(x + 1, 13, STEEL[1])
    # neon strip lamps along the lower rail
    for x in (3, 11, 19, 27):
        c.put(x, 21, CYAN[4])
        c.put(x + 1, 21, CYAN[3])
    # rain highlights on the top rail
    for x in (6, 7, 22):
        c.put(x, 2, (207, 220, 235, 255))
    return c

def pylon():
    c = Canvas(10, 34)
    c.rect(1, 4, 8, 32, STEEL[3])
    c.rect(1, 4, 1, 32, STEEL[5])
    c.rect(8, 4, 8, 32, STEEL[1])
    for y in range(7, 30):
        for x in range(2, 8):
            if ((x + y) // 3) % 2 == 0:
                c.put(x, y, AMBER[2] if y % 2 else AMBER[1])
            else:
                c.put(x, y, STEEL[0])
    # warning lamp on top
    c.rect(3, 0, 6, 3, RED[1])
    c.rect(4, 1, 5, 2, RED[2])
    c.put(4, 1, RED[3])
    c.outline(STEEL[0])
    return c

def emitter():
    c = Canvas(24, 24)
    for y in range(24):
        for x in range(24):
            d = math.hypot(x - 11.5, y - 11.5)
            if d <= 11:
                lit = (x + y) < 20
                col = STEEL[0] if d > 10.2 else (STEEL[5] if lit and d > 8.5 else (STEEL[3] if d > 8.5 else STEEL[1]))
                if d <= 6.5:
                    col = CYAN[0] if d > 5.5 else (CYAN[2] if d > 3 else CYAN[3])
                if d <= 1.6:
                    col = CYAN[4]
                c.put(x, y, col)
    for a in range(0, 360, 45):
        r = math.radians(a)
        c.put(11.5 + math.cos(r) * 9.5, 11.5 + math.sin(r) * 9.5, STEEL[6])
    c.put(8, 8, (255, 255, 255, 255))
    return c

def main(root="."):
    atlas = Image.new("RGBA", (146, 34))
    atlas.alpha_composite(drone(0).image(), (0, 0))
    atlas.alpha_composite(drone(45).image(), (40, 0))
    atlas.alpha_composite(bridge_tile().image(), (80, 0))
    atlas.alpha_composite(pylon().image(), (112, 0))
    atlas.alpha_composite(emitter().image(), (122, 0))
    atlas.save(os.path.join(root, "assets", "world", "hq", "flight-props.png"))

if __name__ == "__main__":
    main()
