#!/usr/bin/env python3
"""Original synthesized sounds for the Aerodyne flight (no recordings).

drive_roll        barrel-roll whoosh with a jet flutter
drive_near_miss   short Doppler swish for close calls
drive_laser_warn  rising charge whine of a defence drone
drive_laser       hard laser burst
drive_brake       brake-jet roar for the landing
drive_touchdown   heavy metal-on-metal landing thud with scrape
calib_tick        scanner metronome tick
calib_lock        code step locked (two rising pings)
calib_error       sync error buzz
calib_alarm       tower alarm (two-tone)
calib_accept      ID accepted chime
"""
import math
import random
import struct
import wave
from pathlib import Path

RATE = 24000
ROOT = Path(__file__).resolve().parents[2] / "assets" / "audio"

def save(name, data, level=24000):
    peak = max(abs(x) for x in data) or 1
    with wave.open(str(ROOT / (name + ".wav")), "wb") as w:
        w.setparams((1, 2, RATE, 0, "NONE", "PCM"))
        w.writeframes(b"".join(struct.pack("<h", round(x / peak * level)) for x in data))

def noise_filter(duration, seed, cutoff_from, cutoff_to, env):
    rng = random.Random(seed)
    low = 0.0
    out = []
    n = int(duration * RATE)
    for i in range(n):
        u = i / n
        cutoff = cutoff_from + (cutoff_to - cutoff_from) * u
        a = 1 - math.exp(-math.tau * cutoff / RATE)
        low += (rng.uniform(-1, 1) - low) * a
        out.append(low * env(i / RATE, u))
    return out

def tone(duration, f0, f1, shape="sine", env=lambda t, u: 1.0):
    out, phase = [], 0.0
    n = int(duration * RATE)
    for i in range(n):
        u = i / n
        phase += (f0 + (f1 - f0) * u) / RATE
        p = phase % 1.0
        s = math.sin(math.tau * p) if shape == "sine" else (1.0 if p < 0.5 else -1.0) if shape == "square" else 2 * p - 1
        out.append(s * env(i / RATE, u))
    return out

def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]

def main():
    save("drive_roll", mix(
        noise_filter(0.55, 11, 300, 2600, lambda t, u: math.sin(math.pi * u) ** 1.5),
        [x * 0.35 for x in tone(0.55, 90, 140, "saw", lambda t, u: (0.6 + 0.4 * math.sin(t * 70)) * math.sin(math.pi * u))]))
    save("drive_near_miss", noise_filter(0.32, 12, 3200, 500, lambda t, u: math.sin(math.pi * u) ** 2), 18000)
    save("drive_laser_warn", [x * (0.5 + 0.5 * (i % 1200 < 600)) for i, x in enumerate(
        tone(0.7, 380, 1500, "square", lambda t, u: 0.25 + 0.75 * u))], 14000)
    save("drive_laser", mix(
        tone(0.38, 1900, 320, "saw", lambda t, u: math.exp(-u * 4)),
        noise_filter(0.38, 13, 6000, 900, lambda t, u: math.exp(-u * 6) * 0.8)))
    save("drive_brake", mix(
        noise_filter(0.9, 14, 900, 400, lambda t, u: min(1, t * 12) * (1 - u) ** 0.6),
        [x * 0.4 for x in tone(0.9, 70, 55, "saw", lambda t, u: (1 - u))]))
    save("drive_touchdown", mix(
        [x * 1.0 for x in tone(0.7, 62, 38, "sine", lambda t, u: math.exp(-t * 7))],
        noise_filter(0.7, 15, 2400, 300, lambda t, u: math.exp(-t * 9) * 0.9),
        [x * 0.3 for x in tone(0.7, 1450, 980, "saw", lambda t, u: max(0, 1 - u * 1.4) * (0.5 + 0.5 * math.sin(t * 90)))]))
    save("calib_tick", tone(0.05, 2200, 2000, "sine", lambda t, u: math.exp(-u * 6)), 12000)
    save("calib_lock", mix(
        tone(0.12, 880, 880, "sine", lambda t, u: math.exp(-u * 3)),
        [0.0] * int(0.08 * RATE) + tone(0.16, 1320, 1320, "sine", lambda t, u: math.exp(-u * 3))), 20000)
    save("calib_error", tone(0.28, 140, 110, "square", lambda t, u: (1 - u) * (0.6 + 0.4 * (int(t * 40) % 2))), 15000)
    save("calib_alarm", mix(
        tone(0.35, 740, 740, "square", lambda t, u: 1 - u * 0.3),
        [0.0] * int(0.35 * RATE) + tone(0.35, 560, 560, "square", lambda t, u: 1 - u * 0.3)), 15000)
    save("calib_accept", mix(*[
        [0.0] * int(k * 0.09 * RATE) + tone(0.4, f, f, "sine", lambda t, u: math.exp(-u * 3.5))
        for k, f in enumerate((660, 880, 1320))]), 20000)

if __name__ == "__main__":
    main()
