#!/usr/bin/env python3
"""v0.56.0 · ClaudeHelper: Pixel-FX für die Motorrad-Verfolgung.

Schreibt nach assets/fx/drive/:
  explosion.png  10 Bilder 288×288   Feuerball mit Rauchrest
  smoke.png       6 Bilder 144×144   Rauchballen
  flame.png       6 Bilder  96×144   Flammenschleife für brennende Wracks
  chunks.png     12 Bilder  32×32    Betonbrocken, Blechteile, Bakenlampen
und assets/vehicles/pursuit/wreck.png (ausgebrannter Verfolgerwagen aus Bild 0 des Wagenblatts).

Alles harte Pixel ohne Kantenglättung, feste Palette, dunkle Kontur. Aufruf aus dem
Repository-Wurzelverzeichnis:  python3 tools/fx/build_drive_fx.py
"""
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/fx/drive"
OUTLINE = (26, 14, 22)
FIRE = [(255, 248, 214), (255, 214, 92), (255, 146, 38), (224, 66, 30), (126, 34, 34)]
SMOKE = [(96, 90, 104), (66, 61, 74), (42, 38, 50)]


def noise(size, cells, rng):
    """Weiches Werterauschen: grobes Zufallsgitter, bilinear vergrößert."""
    grid = rng.random((cells + 1, cells + 1))
    img = Image.fromarray((grid * 255).astype(np.uint8)).resize((size, size), Image.BILINEAR)
    return np.asarray(img).astype(np.float32) / 255.0


def fbm(size, rng, base=4):
    total = np.zeros((size, size), np.float32)
    for octave, weight in enumerate([0.55, 0.3, 0.15]):
        total += noise(size, base * 2 ** octave, rng) * weight
    return total


def outline(rgba):
    """Dunkle 1-Pixel-Kontur um alles Deckende."""
    alpha = rgba[..., 3] > 0
    grown = alpha.copy()
    grown[1:, :] |= alpha[:-1, :]; grown[:-1, :] |= alpha[1:, :]
    grown[:, 1:] |= alpha[:, :-1]; grown[:, :-1] |= alpha[:, 1:]
    edge = grown & ~alpha
    rgba[edge] = (*OUTLINE, 255)
    return rgba


def paint(levels, palette):
    """levels: int-Feld, -1 = leer, sonst Index in die Palette."""
    rgba = np.zeros((*levels.shape, 4), np.uint8)
    for index, color in enumerate(palette):
        rgba[levels == index] = (*color, 255)
    return rgba


def sheet(frames, scale):
    h, w = frames[0].shape[:2]
    out = Image.new("RGBA", (w * scale * len(frames), h * scale))
    for i, frame in enumerate(frames):
        out.paste(Image.fromarray(frame, "RGBA").resize((w * scale, h * scale), Image.NEAREST), (i * w * scale, 0))
    return out


def explosion(rng, size=144, count=10):
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    cx = cy = size / 2
    lumps = fbm(size, rng, 5)
    holes = fbm(size, rng, 7)
    angles = rng.random(26) * np.pi * 2
    speeds = 0.55 + rng.random(26) * 0.45
    frames = []
    for f in range(count):
        t = f / (count - 1)
        radius = size * 0.44 * (1 - (1 - t) ** 2.6) + 6
        rise = t * size * 0.07                      # Rauch steigt leicht
        dist = np.hypot(xx - cx, (yy - cy + rise) * 1.06)
        body = 1.0 - dist / radius + (lumps - 0.5) * 0.75
        heat = body * (1.35 - t * 1.55) + (lumps - 0.5) * 0.25
        levels = np.full((size, size), -1, np.int32)
        solid = body > 0.0
        # Rauchrest: innen, wo die Glut erloschen ist; franst mit der Zeit aus.
        erode = holes > (1.25 - t * 0.95)
        smoke = solid & ~erode
        tone = np.clip(((lumps + holes) * 1.5).astype(np.int32) - 1, 0, 2)
        levels[smoke] = 5 + tone[smoke]
        for index, threshold in enumerate([0.95, 0.68, 0.42, 0.2, 0.06]):
            mask = solid & (heat > threshold) & (levels > 4 - index if index else True)
            levels[solid & (heat > threshold)] = np.minimum(levels[solid & (heat > threshold)], index) if index == 0 else levels[solid & (heat > threshold)]
        # Glutstufen von kalt nach heiß auftragen, damit der Kern oben liegt.
        for index, threshold in reversed(list(enumerate([0.95, 0.68, 0.42, 0.2, 0.06]))):
            levels[solid & (heat > threshold)] = index
        if t > 0.82:                                # letzte Bilder lösen sich auf
            levels[holes > (1.05 - (t - 0.82) * 3.2)] = -1
        rgba = paint(levels, FIRE + SMOKE)
        # Funken: 2×2-Pixel, fliegen radial hinaus und verglühen.
        for angle, speed in zip(angles, speeds):
            reach = size * 0.5 * speed * (1 - (1 - min(1.0, t * 1.5)) ** 2)
            px = int(cx + np.cos(angle) * reach); py = int(cy + np.sin(angle) * reach + t * t * 9)
            if 2 <= px < size - 3 and 2 <= py < size - 3 and t < 0.25 + speed * 0.6:
                rgba[py:py + 2, px:px + 2] = (*FIRE[0 if t < 0.3 else 1 if t < 0.5 else 2], 255)
        frames.append(outline(rgba))
    return sheet(frames, 2)


def smoke(rng, size=72, count=6):
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    lumps = fbm(size, rng, 4); holes = fbm(size, rng, 6)
    frames = []
    for f in range(count):
        t = f / (count - 1)
        radius = size * (0.2 + 0.24 * t)
        dist = np.hypot(xx - size / 2, yy - size / 2)
        body = 1.0 - dist / radius + (lumps - 0.5) * 0.9
        levels = np.full((size, size), -1, np.int32)
        solid = (body > 0) & ~(holes > 1.2 - t * 0.75)
        levels[solid] = 2
        levels[solid & (body > 0.3) & (yy < size / 2 + 4)] = 1
        levels[solid & (body > 0.62) & (yy < size / 2)] = 0
        frames.append(outline(paint(levels, SMOKE)))
    return sheet(frames, 2)


def flame(rng, width=48, height=72, count=6):
    yy, xx = np.mgrid[0:height, 0:width].astype(np.float32)
    lumps = fbm(96, rng, 6)
    frames = []
    for f in range(count):
        shift = int(f * 96 / count)
        field = np.roll(lumps, -shift, axis=0)[:height, :width]   # Rauschen läuft nach oben
        up = (height - 6 - yy) / (height - 10)                    # 0 am Fuß, 1 an der Spitze
        sway = np.sin(up * 5.0 + f * np.pi * 2 / count) * 3.0 * up
        half = (width * 0.36) * (1 - up) ** 0.7 + 1.5
        side = np.abs(xx - width / 2 - sway) / half
        heat = (1 - side) * (1 - up * 0.55) + (field - 0.5) * 0.7
        heat[(up < 0) | (up > 1)] = -1
        levels = np.full((height, width), -1, np.int32)
        for index, threshold in reversed(list(enumerate([0.8, 0.56, 0.34, 0.16]))):
            levels[heat > threshold] = index
        frames.append(outline(paint(levels, FIRE)))
    return sheet(frames, 2)


def chunks(rng, size=16):
    """12 Bruchstücke: 0–5 Beton (zwei mit Warnstreifen), 6–9 Blech, 10–11 Bakenlampe."""
    concrete = [(170, 175, 184), (124, 129, 138), (84, 88, 98)]
    stripe = [(240, 190, 52), (176, 128, 30)]
    metal = [(110, 124, 146), (60, 68, 86), (34, 38, 52)]
    lamp = [(255, 120, 130), (220, 44, 70), (120, 20, 40)]
    frames = []
    yy, xx = np.mgrid[0:size, 0:size].astype(np.float32)
    for index in range(12):
        points = 5 + rng.integers(0, 3)
        angle = np.arctan2(yy - size / 2 + 0.5, xx - size / 2 + 0.5)
        dist = np.hypot(xx - size / 2 + 0.5, yy - size / 2 + 0.5)
        radii = (3.2 if index >= 10 else 3.6 + rng.random() * 2.6) * (0.6 + rng.random(points) * 0.7)
        sector = ((angle + np.pi) / (2 * np.pi) * points).astype(np.int32) % points
        squash = 0.55 if 6 <= index < 10 else 1.0     # Blech: lange Splitter
        solid = np.hypot((xx - size / 2 + 0.5), (yy - size / 2 + 0.5) / squash) < radii[sector]
        palette = lamp if index >= 10 else metal if index >= 6 else concrete
        levels = np.full((size, size), -1, np.int32)
        levels[solid] = 1
        levels[solid & (yy + xx * 0.4 < size * 0.62)] = 0      # Licht von oben links
        levels[solid & (yy - xx * 0.3 > size * 0.42)] = 2
        rgba = paint(levels, palette)
        if index in (1, 4):                                    # Warnstreifen der Bake
            band = solid & (((xx + yy) // 3) % 2 == 0)
            rgba[band & (levels <= 1)] = (*stripe[0], 255)
            rgba[band & (levels == 2)] = (*stripe[1], 255)
        frames.append(outline(rgba))
    return sheet(frames, 2)


def wreck(rng):
    """Ausgebrannter Wagen: Bild 0 des Verfolgerblatts, verrußt, Scheiben geborsten, Glutnester."""
    atlas = Image.open(ROOT / "assets/vehicles/pursuit/car.png").convert("RGBA")
    cell = np.asarray(atlas.crop((0, 0, 418, 418))).astype(np.float32)
    rgb, alpha = cell[..., :3], cell[..., 3]
    grey = rgb @ np.array([0.3, 0.59, 0.11], np.float32)
    soot = fbm(418, rng, 9)
    block = np.kron(fbm(105, rng, 12), np.ones((4, 4), np.float32))[:418, :418]   # grobe Rußflecken
    dark = grey * (0.2 + soot * 0.22)
    out = np.stack([dark * 1.05 + 6, dark * 0.95 + 4, dark * 0.98 + 8], axis=-1)
    bright = grey > 150                                   # Lichter, Scheiben, Chrom → geborsten/erloschen
    out[bright] = out[bright] * 0.55
    ember = (block > 0.63) & (alpha > 200) & (soot > 0.45)
    out[ember] = (232, 92, 30)
    out[ember & (block > 0.7)] = (255, 196, 84)
    holes = (block < 0.2) & (soot < 0.42)                 # weggerissenes Blech
    alpha = np.where(holes, 0, alpha)
    result = np.dstack([np.clip(out, 0, 255), alpha]).astype(np.uint8)
    result[..., 3] = np.where(result[..., 3] > 127, 255, 0)
    return Image.fromarray(result, "RGBA")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    explosion(np.random.default_rng(56)).save(OUT / "explosion.png", optimize=True)
    smoke(np.random.default_rng(57)).save(OUT / "smoke.png", optimize=True)
    flame(np.random.default_rng(58)).save(OUT / "flame.png", optimize=True)
    chunks(np.random.default_rng(59)).save(OUT / "chunks.png", optimize=True)
    wreck(np.random.default_rng(60)).save(ROOT / "assets/vehicles/pursuit/wreck.png", optimize=True)
    for name in ["explosion", "smoke", "flame", "chunks"]:
        print(name, Image.open(OUT / f"{name}.png").size)


if __name__ == "__main__":
    main()
