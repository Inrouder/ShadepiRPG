#!/usr/bin/env python3
"""v0.48.0 · ClaudeHelper: original synthesized ambience loops (no recordings).

ambient_rain       rain on glass and wet pavement, soft drips
ambient_city       distant traffic rumble with a far siren swell
ambient_vent       ventilation hum and airflow for hideouts and the hangar
ambient_lake       crickets, light wind and gentle water at the lake
ambient_net        low digital drone for the deep dive

Each loop is 12 s, mono 22050 Hz, and crossfaded end-to-start so it repeats
without a click. Played quietly underneath music and effects.
"""
import wave
from pathlib import Path
import numpy as np

RATE = 22050
SECONDS = 12.0
N = int(RATE * SECONDS)
ROOT = Path(__file__).resolve().parents[2] / "assets" / "audio"
rng = np.random.default_rng(4812)
t = np.arange(N) / RATE

def lowpass(x, cutoff):
    a = np.exp(-2 * np.pi * cutoff / RATE)
    y = np.empty_like(x); acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y

def highpass(x, cutoff):
    return x - lowpass(x, cutoff)

def loop_fade(x, fade=1.5):
    """Crossfade the tail into the head so sample N-1 flows into sample 0."""
    f = int(RATE * fade)
    head, tail = x[:f].copy(), x[-f:].copy()
    w = np.linspace(0, 1, f)
    x = x[:-f].copy()
    x[:f] = head * w + tail * (1 - w)
    return x

def save(name, x, level=0.55):
    x = loop_fade(x)
    x = x / (np.max(np.abs(x)) or 1) * level
    data = (x * 32767).astype(np.int16)
    with wave.open(str(ROOT / (name + ".wav")), "wb") as w:
        w.setparams((1, 2, RATE, 0, "NONE", "PCM"))
        w.writeframes(data.tobytes())
    print("wrote", name, round(len(data) / RATE, 2), "s")

def noise():
    return rng.standard_normal(N + int(RATE * 1.5))

TT = np.arange(N + int(RATE * 1.5)) / RATE

def rain():
    hiss = highpass(lowpass(noise(), 5200), 900) * 0.5
    body = lowpass(noise(), 700) * 0.35
    x = hiss + body
    for _ in range(170):  # individual drops on glass
        at = rng.integers(0, len(x) - 900)
        f = rng.uniform(1800, 4200)
        k = np.arange(700)
        x[at:at + 700] += np.sin(2 * np.pi * f * k / RATE) * np.exp(-k / rng.uniform(60, 160)) * rng.uniform(0.2, 0.7)
    return x

def city():
    rumble = lowpass(noise(), 140) * 1.6
    swell = 0.6 + 0.4 * np.sin(2 * np.pi * TT / 6.0)
    x = rumble * swell + lowpass(noise(), 1200) * 0.12
    # distant siren: two tones, heavily filtered, rises and fades once per loop
    env = np.clip(np.sin(np.pi * np.clip((TT - 3.0) / 6.0, 0, 1)), 0, 1) ** 2
    tone = np.where((TT * 1.1) % 1.0 < 0.5, 690, 920)
    phase = np.cumsum(2 * np.pi * tone / RATE)
    x += lowpass(np.sin(phase), 1500) * env * 0.08
    return x

def vent():
    hum = 0.5 * np.sin(2 * np.pi * 50 * TT) + 0.25 * np.sin(2 * np.pi * 100 * TT) + 0.08 * np.sin(2 * np.pi * 150 * TT)
    air = lowpass(highpass(noise(), 180), 1400) * 0.55
    flutter = 1 + 0.12 * np.sin(2 * np.pi * 0.25 * TT)
    return hum * 0.45 + air * flutter

def lake():
    wind = lowpass(noise(), 380) * (0.6 + 0.4 * np.sin(2 * np.pi * TT / 4.0)) * 0.7
    water = lowpass(highpass(noise(), 120), 900) * (0.5 + 0.5 * np.sin(2 * np.pi * TT / 2.4) ** 2) * 0.3
    x = wind + water
    for c in range(3):  # three crickets with their own rhythm and pitch
        f = 4300 + c * 380
        rate = 2.4 + c * 0.55
        gate = ((TT * rate) % 1.0 < 0.18).astype(float)
        trill = (np.sin(2 * np.pi * 38 * TT) > 0).astype(float)
        x += np.sin(2 * np.pi * f * TT) * gate * trill * (0.05 + 0.02 * c)
    return x

def net():
    drone = sum(np.sin(2 * np.pi * f * TT + p) * a for f, p, a in [(55, 0, 0.5), (82.5, 1, 0.3), (110.3, 2, 0.2)])
    shimmer = lowpass(noise(), 2600) * (0.08 + 0.06 * np.sin(2 * np.pi * TT / 3.0))
    blips = np.zeros_like(TT)
    for _ in range(24):
        at = rng.integers(0, len(TT) - 2000)
        k = np.arange(1600)
        blips[at:at + 1600] += np.sin(2 * np.pi * rng.choice([660, 880, 1320]) * k / RATE) * np.exp(-k / 300) * 0.12
    return drone * 0.6 + shimmer + blips

if __name__ == "__main__":
    save("ambient_rain", rain())
    save("ambient_city", city())
    save("ambient_vent", vent())
    save("ambient_lake", lake())
    save("ambient_net", net())
