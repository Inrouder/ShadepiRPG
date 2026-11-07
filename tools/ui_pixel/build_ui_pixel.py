#!/usr/bin/env python3
"""Pixel-art UI skins for Shadepi's menus and Raven's hacking decks.

The pieces were drawn in the Pixelwright studio (project "Shadepi UI") on the
game's 640x360 pixel grid; this script holds the same pixel grids as source so
the PNGs can be rebuilt and recoloured without the studio. Every theme shares
one steel body; only the neon (primary) and hot (accent) ramps are swapped, so
each target system keeps its own colour without new shapes.

Output (all 1x, nearest filtering in Godot):
  assets/ui/<theme>/frame.png   64x64 nine-slice panel, margins 22 (edges tile every 20 px)
  assets/ui/<theme>/button.png  64x72 = normal / focus / pressed / disabled (64x18 each)
  assets/ui/<theme>/cells.png   64x16 = idle / open / cursor / used (16x16 each)
  assets/ui/<theme>/header.png  64x20 title plate
  assets/ui/<theme>/parts.png   48x16 slider track, fill, grabbers, list chevron
  assets/ui/emblems.png         144x24 = raven, jackal, order, artos, tower, lake

Usage: python3 tools/ui_pixel/build_ui_pixel.py   (from the repository root)
"""
import os
from PIL import Image

STEEL = ["#0b0e17", "#141b28", "#1f2a3b", "#2f3e54", "#4a5d78", "#7487a3"]
BASE = {
    "neon": ["#0c3440", "#135f70", "#1fa9bd", "#62e3ee", "#cffcff"],
    "hot": ["#3b0b2e", "#7d1a5f", "#d23a8c", "#ff7fc0"],
}
# Theme ramps, darkest first: primary replaces neon, accent replaces hot.
THEMES = {
    "raven": (BASE["neon"], BASE["hot"]),
    "jackal": (["#3b0b2e", "#7d1a5f", "#d23a8c", "#ff5fa2", "#ffd6ea"], ["#4a2a06", "#9a5f0e", "#f0a62a", "#ffcf7a"]),
    "order": (["#26302a", "#4d5e52", "#a9b8ad", "#e9e2cf", "#fffaf0"], ["#4a3606", "#8c6a1c", "#d9b45a", "#f5dc96"]),
    "artos": (["#3d2604", "#8a5a0c", "#e09520", "#ffb43a", "#ffe7bd"], ["#25300f", "#4f6524", "#a8c66c", "#d6ecaa"]),
    "tower": (["#3d0710", "#7d1222", "#c8243c", "#ff3150", "#ffd0d6"], ["#4a3606", "#8c6a1c", "#d8b765", "#f5e0a0"]),
    "lake": (["#16233a", "#2f4a72", "#7fa6d8", "#bcd8ff", "#f0f7ff"], ["#0c3440", "#135f70", "#3fc8d8", "#7ff0ff"]),
}
EMBLEM_ORDER = ["raven", "jackal", "order", "artos", "tower", "lake"]

def rgba(hex_color):
    h = hex_color.lstrip("#")
    values = [int(h[i:i + 2], 16) for i in range(0, len(h), 2)]
    return tuple(values + [255] * (4 - len(values)))

def ui_palette(theme):
    primary, accent = THEMES[theme]
    pal = {".": (0, 0, 0, 0), "g": rgba("#070a12f0"), "h": rgba("#0b1220d8")}
    for key, color in zip("oabcde", STEEL):
        pal[key] = rgba(color)
    for key, color in zip("mnqlw", primary):
        pal[key] = rgba(color)
    for key, color in zip("prs", accent[1:]):
        pal[key] = rgba(color)
    return pal

EMBLEM_PALETTE = {
    ".": (0, 0, 0, 0), "o": rgba(STEEL[0]), "a": rgba(STEEL[1]), "b": rgba(STEEL[2]), "c": rgba(STEEL[3]),
    "d": rgba(STEEL[4]), "e": rgba(STEEL[5]), "m": rgba("#0c3440"), "n": rgba("#135f70"), "q": rgba("#1fa9bd"),
    "l": rgba("#62e3ee"), "w": rgba("#cffcff"), "p": rgba("#7d1a5f"), "r": rgba("#d23a8c"), "s": rgba("#ff7fc0"),
    "A": rgba("#4a2a06"), "B": rgba("#9a5f0e"), "C": rgba("#f0a62a"), "D": rgba("#ffe08a"),
    "x": rgba("#3d0710"), "y": rgba("#8e1626"), "z": rgba("#ff3b4e"),
    "f": rgba("#5d667a"), "g": rgba("#a3aec2"), "h": rgba("#e4ebf5"), "i": rgba("#ffffff"),
}

def image(rows, palette):
    rows = ["".join(r) for r in rows]
    im = Image.new("RGBA", (len(rows[0]), len(rows)))
    for y, row in enumerate(rows):
        assert len(row) == im.width, (y, len(row))
        for x, key in enumerate(row):
            im.putpixel((x, y), palette[key])
    return im

def grid(w,h,ch='.'): return [[ch]*w for _ in range(h)]
def put(g,x,y,c):
    if 0<=y<len(g) and 0<=x<len(g[0]): g[y][x]=c

def fleck(x, y, salt=0):
    """Deterministic 0..99 noise for brushed-metal flecks."""
    v = (x * 73856093) ^ (y * 19349663) ^ (salt * 83492791)
    return (v ^ (v >> 13)) % 100

def frame(S=64):
    g = grid(S,S,'g')
    top = 'odcban'      # outline, highlight, bevel, bevel, shadow, neon dim
    bot = 'oabcbm'
    for y in range(S):
        for x in range(S):
            dt, db, dl, dr = y, S-1-y, x, S-1-x
            m = min(dt, db, dl, dr)
            if m >= 6: continue
            # light from top-left: top/left win ties against bottom/right
            if dt == m and dt <= dr: g[y][x] = top[m]
            elif dl == m and dl <= db: g[y][x] = top[m]
            else: g[y][x] = bot[m]
            # brushed steel: sparse light and dark flecks in the bevel bands
            if m in (2, 3):
                n = fleck(x, y)
                if n < 9: g[y][x] = 'd' if g[y][x] in 'cb' and n < 4 else ('a' if n < 7 else g[y][x])
    # plate seams with rivets, centred in the tiling middle (repeat every 20 px)
    for k in (31,):
        for band in range(1, 5):
            for (x, y, side) in ((k, band, 'top'), (k, S-1-band, 'bot'), (band, k, 'left'), (S-1-band, k, 'right')):
                put(g, x, y, 'o')
                hx, hy = (x+1, y) if side in ('top', 'bot') else (x, y+1)
                put(g, hx, hy, 'd' if side in ('top', 'left') else 'c')
        for (x, y) in ((k+3, 3), (3, k+3)):
            put(g, x, y, 'e'); put(g, x+1, y, 'c'); put(g, x, y+1, 'c'); put(g, x+1, y+1, 'a')
        for (x, y) in ((k+3, S-4), (S-4, k+3)):
            put(g, x, y, 'd'); put(g, x+1, y, 'b'); put(g, x, y+1, 'b'); put(g, x+1, y+1, 'o')
    # chamfer top-left and bottom-right (7 px diagonal)
    C = 7
    for k in range(C):
        for j in range(C-k):
            g[k][j] = '.'; g[S-1-k][S-1-j] = '.'
    for k in range(C):   # diagonal edge: outline then bevel inward
        put(g, C-k, k, 'o'); put(g, C-k+1, k, 'd'); put(g, C-k+2, k, 'c')
        put(g, S-1-(C-k), S-1-k, 'o'); put(g, S-2-(C-k), S-1-k, 'a'); put(g, S-3-(C-k), S-1-k, 'b')
    # bright neon corner brackets hugging the chamfers
    for x in range(C+2, C+14): put(g, x, 1, 'l')
    for y in range(C+2, C+14): put(g, 1, y, 'l')
    for k in range(1, C): put(g, C-k+1, k+1, 'w')
    put(g, C+14, 1, 'q'); put(g, 1, C+14, 'q')
    for x in range(S-C-15, S-C-2): put(g, x, S-2, 'q')
    for y in range(S-C-15, S-C-2): put(g, S-2, y, 'q')
    for k in range(1, C): put(g, S-1-(C-k)-1, S-1-k, 'q')
    # hot status LEDs top-right with a dark housing, corner screws
    for x in range(S-13, S-6): put(g, x, 1, 'o'); put(g, x, 4, 'o')
    for x in (S-12, S-11, S-10, S-9, S-8): put(g, x, 2, 'r'); put(g, x, 3, 'p')
    put(g, S-12, 2, 's')
    for (x,y) in ((S-4,3),(3,S-4)):
        put(g,x,y,'e'); put(g,x+1,y,'c'); put(g,x,y+1,'c'); put(g,x+1,y+1,'a')
    # worn edge scratches near the corners
    for (x, y) in ((24-12, 2), (25-12, 2), (S-20, S-3), (S-19, S-3), (2, S-16), (2, S-15)):
        put(g, x, y, 'e')
    # glass: inner lip and faint scanlines (period 4 tiles evenly)
    for y in range(6, S-6):
        for x in range(6, S-6):
            if g[y][x] != 'g': continue
            if y == 6 or x == 6 or (y - 6) % 4 == 3: g[y][x] = 'h'
    return g

def button_state(state, W=64, H=18):
    g = grid(W, H, '.')
    pal = {
        'normal':   dict(o='o', hi='c', fill='a', lo='o', sh='b', tab='n', tabhi='q', line='b'),
        'focus':    dict(o='q', hi='n', fill='b', lo='m', sh='a', tab='l', tabhi='w', line='m'),
        'pressed':  dict(o='l', hi='m', fill='n', lo='q', sh='m', tab='w', tabhi='w', line='q'),
        'disabled': dict(o='a', hi='b', fill='h', lo='o', sh='a', tab='b', tabhi='b', line='h'),
    }[state]
    C = 3
    for y in range(H):
        for x in range(W):
            # chamfer top-left / bottom-right
            if x + y < C or (W-1-x) + (H-1-y) < C: continue
            edge = x + y == C or (W-1-x) + (H-1-y) == C or x == 0 or y == 0 or x == W-1 or y == H-1
            if edge: g[y][x] = pal['o']; continue
            if y == 1: g[y][x] = pal['hi']
            elif y == H-2: g[y][x] = pal['sh']
            else: g[y][x] = pal['fill']
    # inner scanline texture every other row for depth
    for y in range(3, H-3, 2):
        for x in range(6, W-3):
            if g[y][x] == pal['fill']: g[y][x] = pal['line'] if state != 'pressed' else g[y][x]
    # left energy tab
    for y in range(3, H-3):
        for x in (2, 3, 4):
            g[y][x] = pal['tab']
        g[y][2] = pal['tabhi']
    if state == 'focus':   # chevron and right corner tick
        for (x, y) in ((W-6, H//2-2), (W-5, H//2-1), (W-4, H//2), (W-5, H//2+1), (W-6, H//2+2)):
            g[y][x] = 'w'
        for x in range(W-12, W-8): g[1][x] = 'l'
    if state == 'pressed':
        for x in range(3, W-2): g[1][x] = 'm'
    return g

def buttons():
    rows = []
    for st in ('normal', 'focus', 'pressed', 'disabled'):
        rows += button_state(st)
    return rows

def cell(state, S=16):
    g = grid(S, S, '.')
    o, hi, fill, lo, inner = {
        'idle':   ('o', 'c', 'a', 'a', None),
        'open':   ('q', 'm', 'b', 'n', 'n'),
        'cursor': ('l', 'w', 'b', 'n', 'n'),
        'used':   ('a', 'h', 'h', 'h', None),
    }[state]
    for y in range(S):
        for x in range(S):
            corner = (x in (0, S-1)) and (y in (0, S-1))
            if corner: continue
            if x in (0, S-1) or y in (0, S-1): g[y][x] = o
            elif y == 1: g[y][x] = hi
            elif y == S-2: g[y][x] = lo
            elif inner and (x in (1, S-2)): g[y][x] = inner
            else: g[y][x] = fill
    if state == 'cursor':   # bright corner brackets
        for (x, y) in ((0,1),(1,0),(0,2),(2,0),(S-1,1),(S-2,0),(S-1,2),(S-3,0),(0,S-2),(1,S-1),(0,S-3),(2,S-1),(S-1,S-2),(S-2,S-1),(S-1,S-3),(S-3,S-1)):
            g[y][x] = 'w'
    if state == 'idle':
        g[2][2] = 'c'
    return g

def cells():
    parts = [cell(s) for s in ('idle', 'open', 'cursor', 'used')]
    return [''.join(''.join(p[y]) for p in parts) for y in range(16)]

def header(W=64, H=20):
    g = grid(W, H, '.')
    for y in range(H):
        for x in range(W):
            if (W-1-x) + y < 8 and False: continue
            # slanted right end: cut a 45 degree wedge at the bottom right
            if x > W-1-(H-1-y) // 2 - 1 and x >= W-10: continue
            g[y][x] = 'h'
    # outline and bevel
    for y in range(H):
        row = g[y]
        xs = [x for x in range(W) if row[x] != '.']
        if not xs: continue
        row[xs[0]] = 'o'; row[xs[-1]] = 'q'
    for x in range(W):
        if g[0][x] != '.': g[0][x] = 'q'
        if g[H-1][x] != '.': g[H-1][x] = 'n'
        if g[1][x] == 'h': g[1][x] = 'm'
    # neon lower rail and left energy block
    for x in range(1, W-12):
        g[H-3][x] = 'n'
    for y in range(2, H-3):
        for x in (1, 2, 3):
            g[y][x] = 'l' if x == 1 else 'q'
    # hazard stripes before the slant
    for y in range(5, H-5):
        for x in range(W-21, W-13):
            if ((x + y) // 2) % 2 == 0: g[y][x] = 'r'
            else: g[y][x] = 'p'
    return g

def parts():
    W, H = 48, 16
    g = grid(W, H, '.')
    # slider track 16x6 at (0,0): dark groove with neon fill line
    for y in range(6):
        for x in range(16):
            if y in (0, 5): g[y][x] = 'o' if 0 < x < 15 else '.'
            elif x in (0, 15): g[y][x] = 'o'
            else: g[y][x] = 'a' if y < 3 else 'b'
    # slider fill 16x6 at (0,8)
    for y in range(6):
        for x in range(16):
            if y in (0, 5): g[8+y][x] = 'n' if 0 < x < 15 else '.'
            elif x in (0, 15): g[8+y][x] = 'n'
            else: g[8+y][x] = 'l' if y == 1 else ('q' if y < 4 else 'n')
    # grabber 10x14 at (18,1): chunky knob with grip lines
    for y in range(14):
        for x in range(10):
            edge = x in (0, 9) or y in (0, 13)
            corner = (x in (0, 9)) and (y in (0, 13))
            if corner: continue
            gx, gy = 18 + x, 1 + y
            if edge: g[gy][gx] = 'o'
            elif y == 1: g[gy][gx] = 'w'
            elif y == 12: g[gy][gx] = 'n'
            elif x in (3, 6) and 3 <= y <= 10: g[gy][gx] = 'n'
            else: g[gy][gx] = 'l'
    # grabber focused (bright outline) at (30,1)
    for y in range(14):
        for x in range(10):
            corner = (x in (0, 9)) and (y in (0, 13))
            if corner: continue
            gx, gy = 30 + x, 1 + y
            if x in (0, 9) or y in (0, 13): g[gy][gx] = 'w'
            elif y == 12: g[gy][gx] = 'q'
            elif x in (3, 6) and 3 <= y <= 10: g[gy][gx] = 'q'
            else: g[gy][gx] = 'w' if y == 1 else 'l'
    # list bullet chevron 5x7 at (42,4)
    for (x, y) in ((0,0),(1,1),(2,2),(3,3),(2,4),(1,5),(0,6),(1,0),(2,1),(3,2),(4,3),(3,4),(2,5),(1,6)):
        g[4+y][42+x] = 'l' if (x + y) % 2 else 'w'
    return g

EMBLEMS = {
    'raven': [
        '........................',
        'o......................o',
        'oo....................oo',
        'oqo..................oqo',
        'oqbo......oooo......obqo',
        'obqbo....obbbbo....obqbo',
        '.obqbo..obccccbo..obqbo.',
        '.obcqboooblcclbooobqcbo.',
        '.obcccbbbboddobbbbcccbo.',
        '..obccccbboddobbccccbo..',
        '..obbcccbbbddbbbcccbbo..',
        '..oobbbbbbboobbbbbbboo..',
        '..oaobbbbbbbbbbbbbboao..',
        '...oaobbbbbbbbbbbboao...',
        '..oaoaobbbbbbbbbboaoao..',
        '...oaoaobbbbbbbboaoao...',
        '....o.oaabbbbbbaao.o....',
        '......oaaobbbboaao......',
        '........oabbbbao........',
        '.......oaabbbbaao.......',
        '......oaoaabbaaoao......',
        '......o.oaoaaoao.o......',
        '........o.o..o.o........',
        '........................',
    ],
    'jackal': [
        '..o..................o..',
        '..oo................oo..',
        '..ogo..............ogo..',
        '..ogfo............ofgo..',
        '..ogrfo..........ofrgo..',
        '..ogrrfo........ofrrgo..',
        '..ogrrffo......offrrgo..',
        '..ogprfffoooooofffrpgo..',
        '..offffffgghhggffffffo..',
        '.offgggggghiihggggggffo.',
        '.ofgggggghhiihhggggggfo.',
        '.offsrggggghhgggggrsffo.',
        '..offrrrggghhgggrrrffo..',
        '..offfffggghhgggfffffo..',
        '...offffggggggggffffo...',
        '....offffggggggffffo....',
        '.....offffggggffffo.....',
        '......offffggffffo......',
        '......offffffffffo......',
        '.......offffffffo.......',
        '.......offfoofffo.......',
        '........ofoooofo........',
        '.........oooooo.........',
        '........................',
    ],
    'order': [
        '........................',
        '..oo....................',
        '.ohho........oo.........',
        '..ohhoo.....ohho........',
        '...oghhoo...ohgo........',
        '....ogghhoo.ohgo........',
        '.....ogghhhohhgo........',
        '....oogghhhhhhhoooo.....',
        '...ohggghhhhhhhhhhhoo...',
        '..ohgggghhhhoCDohhhhhoo.',
        '.ohggggggghhhoohhhhhhhio',
        '.oggggggggggghhhhhhhhhho',
        '.ogffggggggggggggggggggo',
        '.offffggggggoooooooooo..',
        '..offffggggo.ioioioio...',
        '..offffffgoooooooooooo..',
        '..offfffffgggggggggogo..',
        '...offffffffffffoo...og.',
        '...offfo.oooooo......og.',
        '..offo..............og..',
        '.offo..............oo...',
        'offo....................',
        'oo......................',
        '........................',
    ],
    'artos': [
        '........................',
        '........................',
        '........................',
        '........................',
        '........................',
        '........................',
        '..........oooo..........',
        '........oocddcoo........',
        '.......ocddqqddco.......',
        '......ocdqllllqdco......',
        'oooo..obdqlwwlqdbo..oooo',
        'oBCo.obcdqllllqdcbo.oCBo',
        'oBCooobcddddddddcboooCBo',
        'oABcbbbbccccccccbbbbcBAo',
        'oAAbbcccbbbbbbbbcccbbAAo',
        'oABcbbbbbbaaaabbbbbbcBAo',
        'oBCoobbbbaaaaaabbbbooCBo',
        'oBCo.oabaaaooaaabao.oCBo',
        'oooo.oaaoAAooAAoaao.oooo',
        '.oo...oooCCooCCooo...oo.',
        '..........oooo..........',
        '........................',
        '........................',
        '........................',
    ],
    'tower': [
        '...........oo...........',
        '...........zz...........',
        '...........oo...........',
        '..........oooo..........',
        '..........oyyo..........',
        '.........oyzzyo.........',
        '........oyzzzzyo........',
        '........ocbbbbco........',
        '........ocCbbCco........',
        '........ocbbbbco........',
        '.......oocbyybcoo.......',
        '.......ocbbbbbbco.......',
        '.......occbyybcco.......',
        '......oocbbbbbbcoo......',
        '......ocbCbyybCbco......',
        '......ocbbbbbbbbco......',
        '.....oocbbbyybbbcoo.....',
        '.....ocbCbbbbbbCbco.....',
        '.....ocbbbbyybbbbco.....',
        '....oocbCbbbbbbCbcoo....',
        '....ocbbbbbyybbbbbco....',
        '...oyyyyyyyyyyyyyyyyo...',
        '...oooooooooooooooooo...',
        '........................',
    ],
    'lake': [
        '........................',
        '..........oooo..........',
        '........oohhhgoo........',
        '.......ohiihgo..o.......',
        '......ohiihgo...........',
        '......ohihgo............',
        '......ohihgo............',
        '......ohiihgo...........',
        '.......ohiihgo..o.......',
        '........oohhhgoo........',
        '..........oooo..........',
        '........................',
        '....ooooooooooooooo.....',
        '..oonnnnnnnnnnnnnnnnoo..',
        '.onqqqqqqqqhhqqqqqqqqno.',
        'onnnnnnnnnnihnnnnnnnnnno',
        '.omnnqqqqnnhhnnqqqqnnmo.',
        '..ommnnnnnnhinnnnnnmmo..',
        '...oommmqqqhhqqqmmmoo...',
        '.....ooommmhhmmmooo.....',
        '........oooqqooo........',
        '..........oooo..........',
        '........................',
        '........................',
    ],
}


def main(root="."):
    out = os.path.join(root, "assets", "ui")
    pieces = {"frame": frame(), "button": buttons(), "cells": [list(r) for r in cells()],
              "header": header(), "parts": parts()}
    for theme in THEMES:
        os.makedirs(os.path.join(out, theme), exist_ok=True)
        pal = ui_palette(theme)
        for name, rows in pieces.items():
            image(rows, pal).save(os.path.join(out, theme, name + ".png"))
    sheet = [ "".join(EMBLEMS[name][y] for name in EMBLEM_ORDER) for y in range(24)]
    image(sheet, EMBLEM_PALETTE).save(os.path.join(out, "emblems.png"))

if __name__ == "__main__":
    main()
