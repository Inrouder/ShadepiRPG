#!/usr/bin/env python3
"""v0.60.1 · ClaudeHelper: Hintertür der Gasse auf Figurenmaß bringen.

Im gelieferten Bild ist die Tür links rund 2,4 Figuren hoch. Das Werkzeug verkleinert die ganze
Türeinheit (Rahmen, Lampe, Schloss) auf etwa 1,3 Figurenhöhen, lässt sie auf dem Gehweg stehen
und füllt die frei gewordene Wand mit dem Blech der Nachbarwand.

Aufruf:  python3 tools/passages/fit_backalley_door.py <gasse_1.png>
Schreibt assets/world/painted/backalley.webp.
"""
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
UNIT = (86, 262, 196, 716)        # Türeinheit im Original
BLOCK = (86, 562, 108, 716)       # Betonblock links unten bleibt, wie er ist
DOOR = (108, 262, 196, 716)       # verkleinert wird nur Rahmen, Lampe und Blatt
SCALE = 0.55
WALL = (4, 205, 46, 258)          # ruhiges Wandblech links oben, ohne Plakate und Halterung


def main(source: str) -> None:
    img = Image.open(source).convert("RGB")
    unit = img.crop(UNIT)
    block = img.crop(BLOCK)
    door = img.crop(DOOR)
    w, h = unit.size
    # Wandfüllung: kleine Stücke des Nachbarblechs zufällig neu gelegt – Körnung und Farbe
    # bleiben, erkennbare Formen (Kanten, Plakate) wiederholen sich nicht.
    rng = np.random.default_rng(601)
    patch = np.asarray(img.crop(WALL))
    ph, pw = patch.shape[:2]
    cell = 6
    quilt = np.zeros((h + cell * 2, w + cell * 2, 3), np.uint8)
    for gy in range(0, h + cell, cell):
        for gx in range(0, w + cell, cell):
            sx = int(rng.integers(0, pw - cell)); sy = int(rng.integers(0, ph - cell))
            piece = patch[sy:sy + cell, sx:sx + cell]
            if rng.random() < 0.5: piece = piece[:, ::-1]
            quilt[gy:gy + cell, gx:gx + cell] = piece
    from PIL import ImageFilter
    # Weiche Farbflecken aus dem Flickwerk, darüber nur dessen feine Körnung – so bleiben keine
    # Kachelkanten stehen.
    mosaic = Image.fromarray(quilt[:h, :w])
    base = np.asarray(mosaic.filter(ImageFilter.GaussianBlur(7))).astype(np.float32)
    grain = np.asarray(mosaic).astype(np.float32) - np.asarray(mosaic.filter(ImageFilter.GaussianBlur(1.6))).astype(np.float32)
    streaks = rng.normal(0.0, 5.0, (1, w, 1)).astype(np.float32)          # senkrechte Laufspuren
    fill = Image.fromarray(np.clip(base + grain * 0.55 + streaks, 0, 255).astype(np.uint8))
    # Licht der Neonröhre rechts oben: nach rechts und oben leicht ins Pink ziehen.
    a = np.asarray(fill).astype(np.float32)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    glow = np.clip(xx / w, 0, 1) ** 2 * np.clip(1 - yy / h, 0, 1) * 0.55
    a = a * (1 - glow[..., None] * 0.35) + np.array([214, 40, 130], np.float32) * glow[..., None] * 0.35
    fill = Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))
    d = ImageDraw.Draw(fill)
    for seam in (150, 300):                       # Plattenfugen wie an der Nachbarwand
        d.line([(0, seam), (w, seam)], fill=(20, 16, 28), width=2)
        d.line([(0, seam + 2), (w, seam + 2)], fill=(86, 70, 98), width=1)
    d.line([(1, 0), (1, h)], fill=(18, 14, 26), width=2)
    for x, yy_ in [(8, 12), (w - 10, 12), (8, 162), (w - 10, 162), (8, 312), (w - 10, 312)]:
        d.rectangle([x, yy_, x + 2, yy_ + 2], fill=(120, 104, 128))
    img.paste(fill, UNIT[:2])
    img.paste(block, BLOCK[:2])
    # Verkleinerte Tür auf den Gehweg stellen.
    small = door.resize((round(door.size[0] * SCALE), round(door.size[1] * SCALE)), Image.LANCZOS)
    x = DOOR[0] + (door.size[0] - small.size[0]) // 2
    y = UNIT[3] - small.size[1]
    img.paste(small, (x, y))
    out = ROOT / "assets/world/painted/backalley.webp"
    img.save(out, quality=92, method=6)
    print("door", (x, y, x + small.size[0], y + small.size[1]), "->", out)


if __name__ == "__main__":
    main(sys.argv[1])
