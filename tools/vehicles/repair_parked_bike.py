#!/usr/bin/env python3
"""v0.57.1 · ClaudeHelper: geparktes Motorrad ohne Lücke (Nutzerbericht vom 11. November 2026).

Das alte Bild `assets/world/hq/bike-parked.png` hatte dort, wo im Fahrbild die Fahrer sitzen, eine
flache Ersatzfläche und zwei durchsichtige Querstreifen. Dieses Werkzeug ersetzt genau diesen
Mittelteil (Zeilen 122–222) durch Rahmen, Lenker, Tank und Sitzbank. Verkleidung, Motor, Heck und
Räder bleiben Pixel für Pixel erhalten; der rote Lack des Tanks stammt aus der vorhandenen
Frontverkleidung.

Quelle ist die Fassung aus dem Git-Stand vor v0.57.1 (einmalig nach
`tools/vehicles/bike-parked-source.png` gesichert), damit ein zweiter Lauf dasselbe Ergebnis gibt.
Aufruf aus dem Repository-Wurzelverzeichnis:  python3 tools/vehicles/repair_parked_bike.py
"""
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(__file__).with_name("bike-parked-source.png")
TARGET = ROOT / "assets/world/hq/bike-parked.png"
CX = 113                       # Längsachse des Motorrads


def noise(shape, rng, amount):
    return rng.integers(-amount, amount + 1, shape)


def main():
    rng = np.random.default_rng(571)
    old = np.asarray(Image.open(SOURCE).convert("RGBA")).astype(np.int32)
    h, w = old.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]

    # 1 · Ersatzfläche entfernen.
    art = old.copy()
    art[122:219, 67:160] = 0

    # 2 · Rahmen unter allem: dunkler Stahl mit Blechstößen, schließt beide Querstreifen.
    frame_mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(frame_mask).polygon([(56, 118), (168, 118), (181, 150), (181, 208), (176, 226), (48, 226), (43, 208), (43, 150)], fill=255)
    inside = np.asarray(frame_mask) > 0
    steel = np.zeros((h, w, 4), np.int32)
    shade = 1.0 - 0.5 * (np.abs(xx - CX) / 70.0) ** 1.6
    base = np.stack([40 * shade, 37 * shade, 40 * shade], axis=-1) + noise((h, w, 1), rng, 5)
    steel[..., :3] = base
    steel[..., 3] = 255
    for y in (133, 158, 184, 207):                         # Blechstöße
        steel[y, :, :3] -= 14; steel[y + 1, :, :3] += 9
    for y in range(126, 222, 13):                          # Nieten
        for x in (62, 164):
            steel[y:y + 2, x:x + 2, :3] = (92, 90, 96)
    steel[~inside] = 0
    edge = inside & ~(np.roll(inside, 1, 1) & np.roll(inside, -1, 1) & np.roll(inside, 1, 0) & np.roll(inside, -1, 0))
    steel[edge, :3] = (12, 11, 14)

    out = steel.astype(np.float32)
    alpha = art[..., 3:4].astype(np.float32) / 255.0       # altes Bild darüber (halbtransparente Ränder mischen sauber)
    out[..., :3] = out[..., :3] * (1 - alpha) + art[..., :3] * alpha
    out[..., 3] = np.maximum(out[..., 3], art[..., 3])
    out = out.astype(np.int32)

    def stamp(mask, colour):
        out[mask, :3] = colour; out[mask, 3] = 255

    # 3 · Rote Rahmenrohre zwischen Verkleidung, Tank und Motor.
    paint = old[44:92, 84:142, :3]                         # Lack der Frontverkleidung
    for side in (-1, 1):
        for y in range(124, 152):
            x0 = CX + side * (30 + (y - 124) * 0.55)
            xs = np.arange(int(x0) - 3, int(x0) + 4)
            out[y, xs, :3] = (paint[(y * 3) % 48, (xs * 2) % 58] * 0.62).astype(np.int32)
            out[y, xs, 3] = 255
            out[y, [xs[0], xs[-1]], :3] = (30, 10, 12)

    # 4 · Lenker mit Griffen und Armaturen.
    stamp((yy >= 125) & (yy <= 129) & (xx >= 52) & (xx <= 174), (58, 60, 68))
    stamp((yy == 125) & (xx >= 52) & (xx <= 174), (120, 124, 134))
    stamp((yy == 130) & (xx >= 52) & (xx <= 174), (14, 14, 18))
    for x0, x1 in ((40, 58), (168, 186)):
        stamp((yy >= 124) & (yy <= 131) & (xx >= x0) & (xx <= x1), (22, 21, 26))
        stamp((yy == 124) & (xx >= x0) & (xx <= x1), (70, 68, 78))
        for x in range(x0 + 2, x1, 4):
            stamp((yy >= 125) & (yy <= 130) & (xx == x), (10, 10, 13))
    stamp((yy >= 121) & (yy <= 133) & (np.abs(xx - CX) <= 9), (34, 35, 42))          # Gabelbrücke
    stamp((yy >= 123) & (yy <= 126) & (np.abs(xx - CX) <= 5), (70, 200, 220))        # Anzeige
    stamp((yy == 133) & (np.abs(xx - CX) <= 9), (10, 10, 13))

    # 5 · Tank: Lack aus der Verkleidung, gewölbt schattiert.
    ty = (yy - 156) / 24.0
    half = 30.0 - 7.0 * np.clip(ty, 0, 1) ** 2 - 12.0 * np.clip(-ty, 0, 1) ** 2.2    # vorn schmaler
    tank = (np.abs(ty) <= 1.0) & (np.abs(xx - CX) <= half)
    src = paint[np.clip(yy - 132, 0, 47), np.clip(xx - 84, 0, 57)]
    curve = 1.12 - 0.62 * (np.abs(xx - CX) / np.maximum(half, 1)) ** 2 - 0.25 * np.clip(ty, 0, 1)
    lacquer = np.clip(src * curve[..., None], 0, 255).astype(np.int32)
    out[tank, :3] = lacquer[tank]; out[tank, 3] = 255
    rim = tank & ~(np.roll(tank, 1, 1) & np.roll(tank, -1, 1) & np.roll(tank, 1, 0) & np.roll(tank, -1, 0))
    stamp(rim, (38, 10, 12))
    stamp(tank & (np.abs(xx - (CX - 12)) <= 1) & (yy >= 140) & (yy <= 166), (244, 150, 132))   # Glanzstreifen
    cap = (xx - CX) ** 2 + (yy - 146) ** 2
    stamp(cap <= 30, (40, 40, 46)); stamp(cap <= 16, (132, 134, 142)); stamp(cap <= 4, (60, 62, 70))

    # 6 · Sitzbank für zwei: schwarzes Leder mit Naht und Glanzkante.
    sy = (yy - 176) / 42.0
    seat_half = 31.0 - 6.0 * np.clip(sy, 0, 1) ** 1.5
    seat = (yy >= 176) & (yy <= 218) & (np.abs(xx - CX) <= seat_half)
    corner = (yy > 212) & (np.abs(xx - CX) > seat_half - (yy - 212) * 1.2)
    seat &= ~corner
    leather = np.stack([30, 28, 35], axis=-1) * (1.08 - 0.5 * (np.abs(xx - CX) / 32.0) ** 2)[..., None] + noise((h, w, 1), rng, 3)
    out[seat, :3] = leather[seat].astype(np.int32); out[seat, 3] = 255
    seat_rim = seat & ~(np.roll(seat, 1, 1) & np.roll(seat, -1, 1) & np.roll(seat, 1, 0) & np.roll(seat, -1, 0))
    inner = seat & np.roll(seat, 4, 1) & np.roll(seat, -4, 1) & np.roll(seat, 4, 0) & np.roll(seat, -4, 0)
    stitch = inner & ~(np.roll(inner, 1, 1) & np.roll(inner, -1, 1) & np.roll(inner, 1, 0) & np.roll(inner, -1, 0))
    stamp(stitch & ((xx + yy) % 3 == 0), (104, 98, 112))
    stamp(seat & (yy >= 196) & (yy <= 197), (12, 11, 15))                              # Stufe Fahrer / Sozius
    stamp(seat & (yy == 198), (62, 58, 70))
    stamp(seat & (yy >= 178) & (yy <= 179) & (np.abs(xx - CX) <= seat_half - 5), (66, 62, 76))   # Glanzkante vorn
    stamp(seat_rim, (9, 8, 11))

    out = np.clip(out, 0, 255).astype(np.uint8)
    Image.fromarray(out, "RGBA").save(TARGET, optimize=True)
    print("geschrieben:", TARGET.relative_to(ROOT), out.shape)


if __name__ == "__main__":
    main()
