#!/usr/bin/env python3
"""Builds assets/fonts/ShadepiPixel.ttf for the pixel-art menus and terminals.

Base: Jersey 10 (SIL OFL 1.1, The Soft Type Project Authors). Its glyphs sit on
a 75-unit grid; the em is rescaled from 1400 to 1500 units so that one font pixel
is exactly one screen pixel at font size 20 (the game's 640x360 viewport).
Jersey 10 lacks the arrows, ticks and circles the terminals use, so this script
adds them as square-pixel glyphs on the same grid. Renamed per OFL section 3.

Usage: python3 build_pixel_font.py <jersey-10-latin.woff2> <jersey-10-latin-ext.woff2> <out.ttf>
"""
import sys
from fontTools.ttLib import TTFont
from fontTools.merge import Merger
from fontTools.pens.ttGlyphPen import TTGlyphPen

PX = 75
CELL = 2 * PX   # symbol pixels are 2x2 font pixels, matching Jersey's 2 px strokes
# Pixel symbols, rows top to bottom; the last row sits on the baseline.
SYMBOLS = {
    0x2192: ["...#...", "....#..", "#######", "....#..", "...#..."],            # →
    0x2190: ["...#...", "..#....", "#######", "..#....", "...#..."],            # ←
    0x2191: ["..#..", ".###.", "#.#.#", "..#..", "..#..", "..#..", "..#.."],     # ↑
    0x2193: ["..#..", "..#..", "..#..", "..#..", "#.#.#", ".###.", "..#.."],     # ↓
    0x2713: ["......#", ".....##", "#...##.", "##.##..", ".###...", "..#...."], # ✓
    0x2717: ["#....#", "##..##", ".####.", ".####.", "##..##", "#....#"],     # ✗
    0x25CB: [".###.", "#...#", "#...#", "#...#", ".###."],                      # ○
    0x25CF: [".###.", "#####", "#####", "#####", ".###."],                      # ●
    0x25B6: ["#....", "##...", "###..", "####.", "###..", "##...", "#...."],    # ▶
    0x25C6: ["..#..", ".###.", "#####", ".###.", "..#.."],                      # ◆
    0x25A0: ["#####", "#####", "#####", "#####", "#####"],                      # ■
    0x03A9: [".###.", "#...#", "#...#", "#...#", ".#.#.", "##.##"],             # Ω
}
LIFT = {}

def glyph(rows, lift):
    pen = TTGlyphPen(None)
    height = len(rows)
    for r, row in enumerate(rows):
        y0 = (height - 1 - r + lift) * CELL
        x = 0
        while x < len(row):
            if row[x] != "#":
                x += 1
                continue
            start = x
            while x < len(row) and row[x] == "#":
                x += 1
            left, right = PX + start * CELL, PX + x * CELL   # 1 px side bearing
            pen.moveTo((left, y0)); pen.lineTo((left, y0 + CELL))
            pen.lineTo((right, y0 + CELL)); pen.lineTo((right, y0)); pen.closePath()
    return pen.glyph(), len(rows[0]) * CELL + 2 * PX

def main(latin, latin_ext, out):
    parts = []
    for path in (latin, latin_ext):
        font = TTFont(path)
        font.flavor = None
        tmp = path + ".ttf"
        font.save(tmp)
        parts.append(tmp)
    font = Merger().merge(parts)
    font["head"].unitsPerEm = 1500
    glyf, hmtx, cmap = font["glyf"], font["hmtx"], font["cmap"]
    order = font.getGlyphOrder()
    for code, rows in SYMBOLS.items():
        name = "px%04X" % code
        g, advance = glyph(rows, LIFT.get(code, 0))
        glyf[name] = g
        hmtx[name] = (advance, PX)
        order.append(name)
        for table in cmap.tables:
            if table.isUnicode():
                table.cmap[code] = name
    font.setGlyphOrder(order)
    for record in font["name"].names:
        if record.nameID in (1, 4, 16):
            record.string = "Shadepi Pixel"
        elif record.nameID == 6:
            record.string = "ShadepiPixel-Regular"
        elif record.nameID == 3:
            record.string = "ShadepiPixel-Regular;derived from Jersey 10"
    font["maxp"].numGlyphs = len(order)
    font.save(out)

if __name__ == "__main__":
    main(*sys.argv[1:4])
