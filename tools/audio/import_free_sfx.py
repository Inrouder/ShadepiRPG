#!/usr/bin/env python3
"""v0.54.0 · ClaudeHelper: replace the synthesized noise-burst effects with free recordings.

All sources are CC0 1.0 (public domain); see assets/audio/CREDITS.md. The script only
converts, trims, layers and levels them – file names stay, so no game code changes.

  python3 tools/audio/import_free_sfx.py <folder with the three source checkouts>

Expected inside the folder (git clones):
  Free-SFX/Superpowers/...                      github.com/EternityForest/Free-SFX
      (mirror of the Superpowers Asset Packs by Sparklin Labs / Pixel-boy)
  kenney-impact-sounds-for-godot/...            github.com/Boyquotes/kenney-impact-sounds-for-godot
  kenney-sci-fi-sounds-for-godot/...            github.com/Boyquotes/kenney-sci-fi-sounds-for-godot
  atomcut-library/packs/opengameart-15-vocal-male-strainhurtpainjump-sounds/...
      github.com/novincode/atomcut-library (qubodup's OpenGameArt pack)
Needs ffmpeg and numpy.
"""
import subprocess
import sys
import wave
from pathlib import Path
import numpy as np

RATE = 44100
OUT = Path(__file__).resolve().parents[2] / "assets" / "audio"
W = "Free-SFX/Superpowers/western-fps-2d/"
T = "Free-SFX/Superpowers/top-down-shooter/"
KI = "kenney-impact-sounds-for-godot/addons/kenney impact sounds/"
KS = "kenney-sci-fi-sounds-for-godot/addons/kenney sci-fi sounds/"
V = "atomcut-library/packs/opengameart-15-vocal-male-strainhurtpainjump-sounds/audio/slightscream-"

# target: (layers [(source, gain, pitch)], max seconds, peak level)
JOBS = {
    "pistol":          ([(W + "gun-5.opus", 1.0, 1.0)], 0.45, 0.80),
    "drive_shot":      ([(W + "gun-3.opus", 1.0, 1.08)], 0.40, 0.72),
    "prop_blast":      ([(W + "explosion-2.opus", 1.0, 1.0), (KS + "low_frequency_explosion_000.ogg", 0.7, 1.0)], 1.5, 0.85),
    "drive_explosion": ([(W + "explosion-1.opus", 1.0, 0.94), (KS + "low_frequency_explosion_001.ogg", 0.8, 1.0)], 1.7, 0.85),
    "drive_laser":     ([(KS + "laser_large_002.ogg", 1.0, 1.0)], 0.9, 0.72),
    "hit":             ([(KI + "impact_punch_heavy_001.ogg", 1.0, 1.0), (W + "impact-1.opus", 0.5, 1.0)], 0.4, 0.78),
    "slash":           ([(W + "woosh-3.opus", 1.0, 1.15), (T + "sword-2.opus", 0.55, 1.0)], 0.4, 0.70),
    "prop_hit":        ([(KI + "impact_plate_light_002.ogg", 1.0, 1.0)], 0.35, 0.70),
    "prop_metal":      ([(KI + "impact_metal_heavy_003.ogg", 1.0, 1.0)], 0.7, 0.78),
    "prop_wood":       ([(KI + "impact_wood_heavy_001.ogg", 1.0, 1.0), (KI + "impact_plank_medium_002.ogg", 0.6, 1.0)], 0.6, 0.78),
    "enemy_attack_0":  ([(V + "11.m4a", 1.0, 0.96)], 0.5, 0.80),
    "enemy_attack_1":  ([(V + "02.m4a", 1.0, 0.92)], 0.5, 0.80),
    "enemy_hurt_0":    ([(V + "12.m4a", 1.0, 0.97)], 0.6, 0.80),
    "enemy_hurt_1":    ([(V + "08.m4a", 1.0, 0.94)], 0.6, 0.80),
    "enemy_hurt_2":    ([(V + "01.m4a", 1.0, 1.0)], 0.6, 0.80),
    "enemy_death_0":   ([(V + "10.m4a", 1.0, 0.88)], 1.1, 0.80),
    "enemy_death_1":   ([(V + "15.m4a", 1.0, 0.86)], 1.2, 0.80),
    "enemy_death_2":   ([(V + "05.m4a", 1.0, 0.84)], 1.1, 0.80),
}

def decode(path: Path, pitch: float) -> np.ndarray:
    # Pitch by resampling: decode at RATE*pitch and play at RATE (pitch < 1 = deeper, longer).
    cmd = ["ffmpeg", "-v", "error", "-i", str(path), "-ac", "1", "-ar", str(int(RATE / pitch)), "-f", "s16le", "-"]
    raw = subprocess.run(cmd, check=True, capture_output=True).stdout
    return np.frombuffer(raw, dtype=np.int16).astype(np.float64) / 32768.0

def trim(x: np.ndarray) -> np.ndarray:
    loud = np.nonzero(np.abs(x) > 0.012)[0]
    return x[max(0, loud[0] - 40):] if len(loud) else x

def build(name, layers, seconds, peak, root: Path):
    parts = [trim(decode(root / src, pitch)) * gain for src, gain, pitch in layers]
    out = np.zeros(max(len(p) for p in parts))
    for p in parts:
        out[:len(p)] += p
    out = out[:int(seconds * RATE)]
    fade_in, fade_out = int(0.002 * RATE), min(len(out) // 3, int(0.08 * RATE))
    out[:fade_in] *= np.linspace(0, 1, fade_in)
    out[-fade_out:] *= np.linspace(1, 0, fade_out)
    out *= peak / (np.max(np.abs(out)) or 1.0)
    with wave.open(str(OUT / (name + ".wav")), "wb") as w:
        w.setparams((1, 2, RATE, 0, "NONE", "PCM"))
        w.writeframes((out * 32767).astype(np.int16).tobytes())
    print(f"{name:16} {len(out) / RATE:.2f}s  <- " + " + ".join(Path(s).name for s, _, _ in layers))

def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    root = Path(sys.argv[1])
    for name, (layers, seconds, peak) in JOBS.items():
        build(name, layers, seconds, peak, root)

if __name__ == "__main__":
    main()
