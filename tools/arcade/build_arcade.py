#!/usr/bin/env python3
"""v0.57.0 · ClaudeHelper: Grafiken für den Arcade-Automaten „NEON KOMBAT“.

Schreibt nach assets/arcade/:
  stage-rooftop.webp 1920×1080  Kampfbühne: Night-City-Skyline aus dem Hauptmenübild (gespiegelt
                                 zur symmetrischen Arena) über einem nassen Dach mit Spiegelung
  cabinet.png         132×204    Arcade-Automat für die Halle (3 Bildschirmpixel je 44×68 Weltpixel)
  sparks.png          6 Bilder 96×96  Treffer-Funken (Pixel, harte Kanten)

Aufruf aus dem Repository-Wurzelverzeichnis:  python3 tools/arcade/build_arcade.py
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/arcade"
HORIZON = 742          # Bodenkante der Bühne in Bildpixeln (1080er Bild)


def stage():
    city = Image.open(ROOT / "assets/menu/start-city.png").convert("RGB")
    half = city.crop((110, 0, 760, 502))                       # Skyline mit Mond und Drache
    wide = Image.new("RGB", (1300, 502))
    wide.paste(half, (0, 0)); wide.paste(ImageOps.mirror(half), (650, 0))
    sky = wide.resize((1920, HORIZON), Image.LANCZOS)
    out = Image.new("RGB", (1920, 1080), (8, 10, 18))
    out.paste(sky, (0, 0))
    # Nasses Dach: Spiegelung der Stadt, nach unten dunkler, waagrecht verwischt.
    depth = 1080 - HORIZON
    mirror = ImageOps.flip(sky.crop((0, HORIZON - depth, 1920, HORIZON))).filter(ImageFilter.BoxBlur(6))
    mirror = mirror.resize((1920, depth), Image.BILINEAR)
    floor = np.asarray(mirror).astype(np.float32)
    fade = np.linspace(0.42, 0.10, depth, dtype=np.float32)[:, None, None]
    base = np.array([20, 24, 36], np.float32)
    ground = base * np.linspace(1.15, 0.7, depth, dtype=np.float32)[:, None, None] + floor * fade
    out.paste(Image.fromarray(np.clip(ground, 0, 255).astype(np.uint8)), (0, HORIZON))
    draw = ImageDraw.Draw(out)
    # Plattenfugen in Perspektive.
    row, step = HORIZON + 14, 14.0
    while row < 1080:
        draw.line([(0, row), (1920, row)], fill=(9, 11, 19), width=2)
        draw.line([(0, row + 2), (1920, row + 2)], fill=(46, 54, 76), width=1)
        step *= 1.42; row = int(row + step)
    for k in range(-14, 15):
        top = 960 + k * 92; bottom = 960 + k * 250
        draw.line([(top, HORIZON + 14), (bottom, 1080)], fill=(10, 12, 20), width=2)
    # Geländer mit Neonband an der Dachkante.
    draw.rectangle([0, HORIZON - 4, 1920, HORIZON + 10], fill=(14, 16, 26))
    draw.rectangle([0, HORIZON + 4, 1920, HORIZON + 6], fill=(255, 62, 150))
    draw.rectangle([0, HORIZON + 7, 1920, HORIZON + 7], fill=(120, 24, 80))
    for x in range(30, 1920, 124):
        draw.rectangle([x, HORIZON - 58, x + 7, HORIZON + 2], fill=(18, 21, 33))
        draw.rectangle([x, HORIZON - 58, x + 1, HORIZON + 2], fill=(58, 68, 96))
    for y, shade in [(HORIZON - 58, (36, 42, 62)), (HORIZON - 32, (24, 28, 44))]:
        draw.rectangle([0, y, 1920, y + 5], fill=shade)
        draw.rectangle([0, y, 1920, y + 1], fill=(70, 82, 112))
    # Randabdunklung, damit Figuren und Anzeige lesbar bleiben.
    yy, xx = np.mgrid[0:1080, 0:1920].astype(np.float32)
    vignette = 1.0 - 0.38 * np.clip(((xx - 960) / 960) ** 2 * 0.8 + ((yy - 520) / 620) ** 2 * 0.5, 0, 1)
    pixels = np.asarray(out).astype(np.float32) * vignette[..., None]
    Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8)).save(OUT / "stage-rooftop.webp", quality=88, method=6)


def cabinet():
    w, h = 132, 204
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    steel, dark, edge, light = (38, 44, 60), (22, 26, 38), (12, 13, 22), (86, 98, 128)
    pink, cyan, amber = (255, 62, 150), (84, 232, 248), (255, 190, 80)
    # Seitenwand (links sichtbar) und Front.
    d.polygon([(8, 30), (26, 14), (26, 196), (8, 200)], fill=dark, outline=edge)
    d.rectangle([26, 14, 122, 198], fill=steel, outline=edge)
    d.rectangle([27, 15, 28, 197], fill=light)
    d.line([(10, 34), (10, 198)], fill=(48, 56, 78))
    for y in range(44, 190, 26):                                   # Neonstreifen der Seitenwand
        d.polygon([(11, y), (23, y - 9), (23, y - 3), (11, y + 6)], fill=pink if (y // 26) % 2 else cyan)
    # Leuchtschild.
    d.rectangle([30, 18, 118, 44], fill=(30, 10, 40), outline=edge)
    d.rectangle([32, 20, 116, 42], fill=(70, 16, 74))
    for i, x in enumerate(range(36, 112, 8)):                      # Pixelbuchstaben-Andeutung „NEON KOMBAT“
        colour = cyan if i < 4 else pink
        d.rectangle([x, 25, x + 4, 37], fill=colour)
        d.rectangle([x + 1, 28 + (i * 3) % 6, x + 3, 30 + (i * 3) % 6], fill=(70, 16, 74))
    d.rectangle([32, 20, 116, 21], fill=(255, 170, 220))
    # Bildschirm mit zwei Kämpfern und Lebensbalken.
    d.rectangle([32, 50, 116, 112], fill=edge)
    d.rectangle([36, 54, 112, 108], fill=(16, 22, 48))
    d.rectangle([36, 86, 112, 108], fill=(26, 20, 52))
    d.rectangle([36, 96, 112, 97], fill=pink)
    d.rectangle([40, 58, 70, 61], fill=amber); d.rectangle([78, 58, 108, 61], fill=amber)
    d.rectangle([64, 58, 70, 61], fill=(120, 30, 40))
    for x, colour, flip in [(50, (210, 60, 70), 1), (92, cyan, -1)]:
        d.rectangle([x - 3, 72, x + 3, 84], fill=colour)           # Rumpf
        d.rectangle([x - 2, 66, x + 2, 71], fill=(230, 200, 180))  # Kopf
        d.rectangle([x - 3, 85, x - 1, 95], fill=colour); d.rectangle([x + 1, 85, x + 3, 95], fill=colour)
        d.rectangle([x + 4 * flip, 74, x + 11 * flip, 76] if flip > 0 else [x - 11, 74, x - 4, 76], fill=colour)
    d.rectangle([68, 72, 74, 78], fill=(255, 246, 200)); d.rectangle([70, 70, 72, 80], fill=amber)   # Treffer
    for y in range(55, 108, 4):
        d.line([(36, y), (112, y)], fill=(10, 14, 30))
    d.rectangle([36, 54, 112, 55], fill=(60, 90, 140))
    # Bedienpult.
    d.polygon([(26, 118), (122, 118), (126, 136), (22, 136)], fill=(52, 60, 84), outline=edge)
    d.rectangle([24, 136, 124, 142], fill=dark, outline=edge)
    for x, colour in [(44, pink), (88, cyan)]:
        d.rectangle([x - 1, 114, x + 1, 126], fill=(170, 176, 190))
        d.ellipse([x - 5, 106, x + 5, 116], fill=colour, outline=edge)
        for i in range(3):
            d.ellipse([x + 10 + i * 8, 122 + (i % 2) * 4, x + 16 + i * 8, 128 + (i % 2) * 4], fill=[amber, colour, (236, 240, 248)][i], outline=edge)
    # Sockel mit Münzschacht.
    d.rectangle([34, 150, 114, 190], fill=dark, outline=edge)
    d.rectangle([60, 158, 72, 176], fill=(60, 68, 92), outline=edge); d.rectangle([65, 161, 67, 170], fill=amber)
    d.rectangle([78, 158, 90, 176], fill=(60, 68, 92), outline=edge); d.rectangle([83, 161, 85, 170], fill=amber)
    d.rectangle([26, 192, 122, 198], fill=edge)
    d.rectangle([26, 190, 122, 191], fill=pink)
    img.save(OUT / "cabinet.png", optimize=True)


def sparks(size=48, count=6):
    rng = np.random.default_rng(57)
    angles = rng.random(18) * np.pi * 2
    lengths = 0.5 + rng.random(18) * 0.5
    sheet = Image.new("RGBA", (size * 2 * count, size * 2), (0, 0, 0, 0))
    for f in range(count):
        t = f / (count - 1)
        img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        core = int(9 * (1 - t) ** 1.5)
        if core > 0:
            d.rectangle([size // 2 - core, size // 2 - core // 2, size // 2 + core, size // 2 + core // 2], fill=(255, 250, 220, 255))
            d.rectangle([size // 2 - core // 2, size // 2 - core, size // 2 + core // 2, size // 2 + core], fill=(255, 250, 220, 255))
        for angle, length in zip(angles, lengths):
            r0 = size * 0.46 * length * min(1.0, t * 1.8)
            r1 = size * 0.46 * length * min(1.0, t * 1.8 + 0.28 * (1 - t))
            if t > 0.3 + length * 0.6:
                continue
            p0 = (size / 2 + np.cos(angle) * r0, size / 2 + np.sin(angle) * r0)
            p1 = (size / 2 + np.cos(angle) * r1, size / 2 + np.sin(angle) * r1)
            d.line([p0, p1], fill=(255, 214, 92, 255) if t < 0.5 else (255, 146, 38, 255), width=2)
        sheet.paste(img.resize((size * 2, size * 2), Image.NEAREST), (f * size * 2, 0))
    sheet.save(OUT / "sparks.png", optimize=True)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    stage(); cabinet(); sparks()
    for name in ["stage-rooftop.webp", "cabinet.png", "sparks.png"]:
        print(name, Image.open(OUT / name).size, (OUT / name).stat().st_size // 1024, "KB")
