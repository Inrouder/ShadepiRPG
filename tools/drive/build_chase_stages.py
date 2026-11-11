#!/usr/bin/env python3
"""v0.58.0 · ClaudeHelper: Kulissen für die Etappen 2 und 3 der Motorrad-Verfolgung.

Beide entstehen aus den vorhandenen gemalten Kulissen des Spiels, damit Pinselstrich, Körnung
und Farbwelt übereinstimmen:

  assets/world/painted/tunnel.png   1672×941  Tunnel: Fahrbahn und Gehwegplatten aus highway.png,
                                               Wände aus dessen Dachtechnik, Natriumlicht
  assets/world/painted/skyway.png   1672×941  Hochstraße (RGBA): dieselbe Fahrbahn mit Leitplanken;
                                               die Seiten sind durchsichtig, darunter zieht im
                                               Spiel airspace.png langsamer vorbei

Senkrecht kachelbar: alle Aufbauten wiederholen sich im Takt der Bildhöhe, die Fahrbahn wird an
der Naht weich überblendet. Aufruf aus dem Repository-Wurzelverzeichnis:
  python3 tools/drive/build_chase_stages.py
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
PAINTED = ROOT / "assets/world/painted"
W, H = 1672, 941
ROAD = (473, 1200)          # Asphalt in highway.png
WALK = (340, 1333)          # Außenkante der Gehwegplatten


def seamless(img, band=90):
    """Überblendet die untere Kante mit der oberen, damit die Kachel ohne Naht läuft."""
    a = np.asarray(img).astype(np.float32)
    out = a.copy()
    for i in range(band):
        t = i / band
        out[H - band + i] = a[H - band + i] * (1 - t) + a[band - 1 - i][..., :] * t * 0 + a[i] * t
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), img.mode)


def grade(img, tint, saturation, gain):
    a = np.asarray(img.convert("RGB")).astype(np.float32)
    grey = a @ np.array([0.3, 0.59, 0.11], np.float32)
    a = grey[..., None] + (a - grey[..., None]) * saturation
    a = a * np.array(tint, np.float32) * gain
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8))


def glow(size, color, strength):
    """Weicher, in Stufen gesetzter Lichtfleck (keine glatten Verläufe – gemalte Anmutung)."""
    w, h = size
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.hypot((xx - w / 2) / (w / 2), (yy - h / 2) / (h / 2))
    level = np.clip(1 - d, 0, 1) ** 1.6
    level = np.floor(level * 7) / 7
    rgba = np.zeros((h, w, 4), np.uint8)
    rgba[..., :3] = color
    rgba[..., 3] = (level * 255 * strength).astype(np.uint8)
    return Image.fromarray(rgba, "RGBA")


def noise(rng, w, h, cell):
    grid = rng.random((h // cell + 2, w // cell + 2))
    img = Image.fromarray((grid * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
    return np.asarray(img).astype(np.float32) / 255.0


def tunnel():
    rng = np.random.default_rng(58)
    src = Image.open(PAINTED / "highway.png").convert("RGB")
    out = Image.new("RGB", (W, H), (14, 15, 20))
    # Fahrbahn und Gehwegplatten: Neonspiegelungen fast herausnehmen, warm einfärben.
    deck = seamless(grade(src.crop((WALK[0], 0, WALK[1], H)), (1.0, 0.86, 0.66), 0.28, 0.82))
    out.paste(deck, (WALK[0], 0))
    # Wände: Betonplatten aus Rauschen, Pinselkörnung von den Gehwegplatten geliehen.
    for x0, x1 in [(0, WALK[0]), (WALK[1], W)]:
        ww = x1 - x0
        grain = noise(rng, ww, H, 5) * 0.5 + noise(rng, ww, H, 37) * 0.5
        wrap = np.concatenate([grain, grain[:1]], axis=0)[:H]
        base = np.stack([52 + wrap * 34, 54 + wrap * 32, 62 + wrap * 30], axis=-1)
        fade = np.linspace(0.45, 1.0, ww) if x0 == 0 else np.linspace(1.0, 0.45, ww)
        wall = Image.fromarray(np.clip(base * fade[None, :, None], 0, 255).astype(np.uint8))
        out.paste(seamless(wall), (x0, 0))
    d = ImageDraw.Draw(out, "RGBA")
    step = H / 4
    for side in (0, 1):
        inner = WALK[0] if side == 0 else WALK[1]
        sign = -1 if side == 0 else 1
        # Wandkante und Kabeltrassen.
        d.rectangle([inner - 14, 0, inner + 2, H] if side == 0 else [inner - 2, 0, inner + 14, H], fill=(20, 21, 28, 255))
        for k, (offset, colour) in enumerate([(34, (96, 78, 54)), (48, (58, 62, 74)), (60, (38, 96, 104))]):
            x = inner + sign * offset
            d.rectangle([x - 4, 0, x + 4, H], fill=(18, 19, 25, 255))
            d.rectangle([x - 2, 0, x + 1, H], fill=colour + (255,))
            d.line([(x - 2, 0), (x - 2, H)], fill=(170, 160, 140, 120))
        for i in range(4):
            y = int(i * step)
            # Rippen des Tunnels und Plattenfugen.
            x0, x1 = (0, inner - 14) if side == 0 else (inner + 14, W)
            d.rectangle([x0, y + 6, x1, y + 22], fill=(24, 25, 33, 255))
            d.rectangle([x0, y + 6, x1, y + 8], fill=(104, 106, 118, 200))
            d.line([(x0, y + 118), (x1, y + 118)], fill=(22, 23, 30, 255), width=3)
            # Schaltkasten mit Warnstreifen.
            bx = inner + sign * 150
            d.rectangle([bx - 34, y + 44, bx + 34, y + 96], fill=(44, 48, 60, 255), outline=(14, 15, 20, 255), width=3)
            d.rectangle([bx - 28, y + 50, bx + 28, y + 60], fill=(210, 160, 40, 255))
            for s in range(-28, 28, 14):
                d.polygon([(bx + s, y + 60), (bx + s + 7, y + 50), (bx + s + 12, y + 50), (bx + s + 5, y + 60)], fill=(26, 24, 22, 255))
            d.rectangle([bx - 24, y + 68, bx - 8, y + 88], fill=(30, 160, 150, 255) if i % 2 else (190, 60, 50, 255))
    out = out.convert("RGBA")
    # Strahlventilatoren: die Lüfter der Dachtechnik aus der Stadtkulisse, nachgedunkelt.
    fan = grade(src.crop((12, 76, 200, 178)), (1.0, 0.9, 0.74), 0.5, 0.78).convert("RGBA")
    for i in (1, 3):
        out.alpha_composite(fan, (58, int(i * step) + 128 - 235 if i == 3 else int(i * step) + 128))
        out.alpha_composite(fan.transpose(Image.FLIP_LEFT_RIGHT), (W - 58 - fan.size[0], int((i - 1) * step) + 128))
    # Lampen: Natriumdampf im Wechsel mit türkisem Notlicht; Lichtinseln auf Fahrbahn und Wand.
    for i in range(4):
        y = int(i * step) + 150
        colour = (255, 168, 72) if i % 2 == 0 else (72, 226, 216)
        for inner, sign in [(WALK[0], 1), (WALK[1], -1)]:
            pool = glow((520, 300), colour, 0.42 if i % 2 == 0 else 0.3)
            for yy in (y, y - H, y + H):
                out.alpha_composite(pool, (max(0, inner + sign * 150 - 260), yy - 150)) if -300 < yy - 150 < H else None
            lamp = ImageDraw.Draw(out)
            lamp.rectangle([inner - 10, y - 26, inner + 10, y + 26], fill=(26, 27, 34, 255))
            lamp.rectangle([inner - 5 + sign * 3, y - 20, inner + 5 + sign * 3, y + 20], fill=colour + (255,))
            lamp.rectangle([inner - 2 + sign * 3, y - 16, inner + 2 + sign * 3, y + 16], fill=(255, 246, 220, 255))
    # Deckenträger über der Fahrbahn: dunkle Bänder mit Schattenkante.
    beams = ImageDraw.Draw(out, "RGBA")
    for i in (0, 2):
        y = int(i * step) + 4
        beams.rectangle([0, y + 26, W, y + 44], fill=(0, 0, 0, 70))
        beams.rectangle([WALK[0] - 14, y, WALK[1] + 14, y + 26], fill=(16, 17, 23, 235))
        beams.rectangle([WALK[0] - 14, y, WALK[1] + 14, y + 3], fill=(120, 110, 96, 220))
        for x in range(WALK[0], WALK[1], 92):
            beams.rectangle([x, y + 8, x + 10, y + 18], fill=(70, 66, 60, 255))
    # Seiten in die Dunkelheit laufen lassen.
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    shade = 1.0 - 0.55 * np.clip((np.abs(xx - W / 2) - 520) / 320, 0, 1) ** 1.3
    px = np.asarray(out.convert("RGB")).astype(np.float32) * shade[..., None]
    Image.fromarray(np.clip(px, 0, 255).astype(np.uint8)).save(PAINTED / "tunnel.png", optimize=True)


def skyway():
    src = Image.open(PAINTED / "highway.png").convert("RGB")
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    deck = seamless(grade(src.crop((WALK[0], 0, WALK[1], H)), (0.78, 0.9, 1.12), 0.55, 0.9)).convert("RGBA")
    out.alpha_composite(deck, (WALK[0], 0))
    d = ImageDraw.Draw(out, "RGBA")
    step = H / 4
    for inner, sign in [(WALK[0], -1), (WALK[1], 1)]:
        # Randträger der Brücke und doppelte Leitplanke.
        x0, x1 = (inner - 46, inner) if sign < 0 else (inner, inner + 46)
        d.rectangle([x0, 0, x1, H], fill=(24, 27, 38, 255))
        d.rectangle([x0 if sign < 0 else x1 - 6, 0, x0 + 6 if sign < 0 else x1, H], fill=(10, 11, 18, 255))
        for offset, colour in [(20, (150, 164, 190)), (30, (92, 104, 130))]:
            x = inner - sign * -offset if sign > 0 else inner - offset
            d.rectangle([x - 3, 0, x + 3, H], fill=(14, 16, 24, 255))
            d.rectangle([x - 1, 0, x + 1, H], fill=colour + (255,))
        rail = inner + sign * -26 if False else inner - sign * 0
        for i in range(12):
            y = int(i * H / 12) + 20
            px = inner + sign * 25
            d.rectangle([px - 6, y - 5, px + 6, y + 5], fill=(60, 68, 88, 255), outline=(10, 11, 18, 255))
        for i in range(4):
            y = int(i * step) + 60
            # Rote Warnleuchte am Brückenrand und Dehnfuge quer über das Deck.
            cx = inner + sign * 38
            d.rectangle([cx - 6, y - 6, cx + 6, y + 6], fill=(255, 70, 80, 255), outline=(40, 10, 16, 255))
            d.rectangle([cx - 2, y - 2, cx + 2, y + 2], fill=(255, 210, 200, 255))
    for i in (0, 2):
        y = int(i * step) + 180
        d.rectangle([WALK[0], y, WALK[1], y + 7], fill=(12, 13, 20, 255))
        d.rectangle([WALK[0], y + 7, WALK[1], y + 9], fill=(120, 132, 156, 200))
        for x in range(WALK[0] + 8, WALK[1], 26):
            d.rectangle([x, y + 1, x + 12, y + 5], fill=(44, 50, 66, 255))
    # Lichtmasten: Ausleger nach innen, kaltweiße Lichtinseln auf dem Asphalt.
    for i in range(4):
        y = int(i * step) + 120
        for inner, sign in [(WALK[0], 1), (WALK[1], -1)]:
            if (i + (sign > 0)) % 2:
                continue
            pool = glow((560, 340), (190, 226, 255), 0.34)
            clip = Image.new("RGBA", (W, H), (0, 0, 0, 0))
            for yy in (y, y - H, y + H):
                clip.alpha_composite(pool, (max(0, inner + sign * 190 - 280), max(-340, yy - 170))) if -340 < yy - 170 < H else None
            mask = Image.new("L", (W, H), 0)
            ImageDraw.Draw(mask).rectangle([WALK[0], 0, WALK[1], H], fill=255)
            clip.putalpha(Image.composite(clip.getchannel("A"), mask.point(lambda v: 0), mask))
            out.alpha_composite(clip)
            lamp = ImageDraw.Draw(out)
            lamp.rectangle([min(inner, inner + sign * 120), y - 4, max(inner, inner + sign * 120), y + 4], fill=(30, 34, 46, 255))
            lamp.rectangle([inner + sign * 96 - 16, y - 9, inner + sign * 96 + 16, y + 9], fill=(40, 46, 62, 255), outline=(10, 11, 18, 255))
            lamp.rectangle([inner + sign * 96 - 11, y - 5, inner + sign * 96 + 11, y + 5], fill=(214, 240, 255, 255))
            lamp.rectangle([inner - 12, y - 12, inner + 12, y + 12], fill=(52, 60, 80, 255), outline=(10, 11, 18, 255))
    # Stützpfeiler ragen seitlich unter dem Deck hervor (über der Stadt, mit Schattenwurf).
    under = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    u = ImageDraw.Draw(under)
    for i in (1, 3):
        y = int(i * step) + 30
        u.rectangle([WALK[0] - 150, y, WALK[1] + 150, y + 70], fill=(18, 20, 30, 255))
        u.rectangle([WALK[0] - 150, y, WALK[1] + 150, y + 5], fill=(84, 96, 124, 255))
        for x in (WALK[0] - 150, WALK[1] + 110):
            u.rectangle([x, y + 16, x + 40, y + 54], fill=(34, 40, 56, 255), outline=(8, 9, 14, 255))
            u.rectangle([x + 14, y + 28, x + 26, y + 42], fill=(84, 232, 248, 255))
    under.alpha_composite(out)
    under.save(PAINTED / "skyway.png", optimize=True)


if __name__ == "__main__":
    tunnel(); skyway()
    for name in ["tunnel", "skyway"]:
        p = PAINTED / f"{name}.png"
        print(name, Image.open(p).size, Image.open(p).mode, p.stat().st_size // 1024, "KB")
