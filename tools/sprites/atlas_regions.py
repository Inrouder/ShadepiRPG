#!/usr/bin/env python3
"""v0.52.0 · ClaudeHelper: every pose atlas together with the exact rectangles the game cuts out.

One table for the audit (audit_atlases.py) and the calibration (calibrate_atlases.py).
Rectangles mirror the constants / JSON catalogs the scripts use at runtime.
"""
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

def grid(path, cols, rows):
    """Cells exactly as Sprite2D frames / the scripts' rounding cut them, from the real image size."""
    width, height = _size(path)
    out = []
    for r in range(rows):
        for c in range(cols):
            x0, x1 = round(c * width / cols), round((c + 1) * width / cols)
            y0, y1 = round(r * height / rows), round((r + 1) * height / rows)
            out.append((x0, y0, x1 - x0, y1 - y0))
    return out

def _size(path):
    with open(ROOT / path, "rb") as f:
        head = f.read(24)
    return struct.unpack(">II", head[16:24])

def _json_regions(node, out):
    if isinstance(node, dict):
        if "region" in node:
            out.append(tuple(int(v) for v in node["region"]))
        else:
            for value in node.values():
                _json_regions(value, out)
    elif isinstance(node, list):
        for value in node:
            _json_regions(value, out)
    return out

def catalog():
    """Returns {relative png path: [(x, y, w, h), ...]}"""
    a = {}
    hero = "assets/sprites/heroes/"
    npc = "assets/sprites/npcs/"
    for name in ["raven", "shadepi"]:
        a[hero + name + ".png"] = grid(hero + name + ".png", 8, 32)
    for name in ["jackal", "kenzo", "punk-1", "punk-2", "punk-3", "punk-4", "shooter-violet", "shooter-visor"]:
        a[npc + name + ".png"] = grid(npc + name + ".png", 8, 32)
    a[hero + "combat-poses.png"] = grid(hero + "combat-poses.png", 8, 4)
    a[hero + "raven-hand-cast.png"] = _json_regions(json.loads((ROOT / hero / "raven-hand-cast.json").read_text()), [])
    a[npc + "contact-poses.png"] = _json_regions(json.loads((ROOT / npc / "contact-poses.json").read_text()), [])
    a[npc + "ice-guardian-combat.png"] = grid(npc + "ice-guardian-combat.png", 4, 2)
    a["assets/story/reactions/poses.png"] = [(80,70,280,365),(455,120,390,315),(870,250,465,185),(1400,15,295,420),(65,460,310,405),(445,585,310,280),(800,640,455,225),(1265,690,495,175)]
    a["assets/story/sanctuary/poses-game.png"] = [(0,0,512,512),(512,0,512,512),(1024,0,512,512),(0,512,410,512),(472,512,552,512),(1024,512,512,512)]
    a["assets/story/tower/kenzo-poses.png"] = [(0,0,768,512),(768,0,768,512),(0,512,768,512),(768,512,768,512)]
    a["assets/story/ice-bath/poses.png"] = [(0,0,384,512),(384,0,384,512),(768,0,384,512),(1152,0,384,512),(0,512,384,512),(384,512,352,512),(744,512,384,512),(1128,512,408,512)]
    a["assets/story/chapter-one/poses.png"] = [(0,0,443,443),(443,0,444,443),(887,0,443,443),(1330,0,444,443),(0,443,443,444),(443,443,444,444),(887,443,443,444),(1330,443,444,444)]
    a["assets/story/lake/poses-moon.png"] = grid("assets/story/lake/poses-moon.png", 4, 2)
    a["assets/vehicles/motorcycle/riding.png"] = grid("assets/vehicles/motorcycle/riding.png", 3, 3)
    a["assets/vehicles/pursuit/car.png"] = grid("assets/vehicles/pursuit/car.png", 3, 3)
    a["assets/vehicles/pursuit/drone.png"] = grid("assets/vehicles/pursuit/drone.png", 2, 2)
    a["assets/vehicles/aerodyne/airframe.png"] = grid("assets/vehicles/aerodyne/airframe.png", 3, 2)
    a["assets/vehicles/aerodyne/banks.png"] = grid("assets/vehicles/aerodyne/banks.png", 3, 2)
    a["assets/memories/legacy/shadepi-aura.png"] = grid("assets/memories/legacy/shadepi-aura.png", 4, 4)
    mem = "assets/memories/"
    attack = json.loads((ROOT / mem / "attack/actors.json").read_text())
    sheet_for = {"idle": "warriors-ready", "run_a": "warriors-run", "run_b": "warriors-run", "combat": "combat",
                 "civilian": "residents", "walk_cycle": "residents-walk", "attack": "bots"}
    for identity, poses in attack.items():
        for key, frames in poses.items():
            sheet = "bots" if identity == "bot" and key != "combat" else sheet_for[key]
            a.setdefault(mem + "attack/" + sheet + ".png", []).extend(_json_regions(frames, []))
    sacrifice = json.loads((ROOT / mem / "sacrifice/actors.json").read_text())
    a[mem + "sacrifice/minotaur.png"] = _json_regions(sacrifice["minotaur"], [])
    a[mem + "sacrifice/ly-charge.png"] = _json_regions(sacrifice["ly"], [])
    legacy = json.loads((ROOT / mem / "legacy/actors.json").read_text())
    a[mem + "legacy/characters.png"] = _json_regions(legacy["figures"], [])
    a[mem + "legacy/master-death.png"] = _json_regions(legacy["master_death"], [])
    return {k: sorted(set(v)) for k, v in a.items()}
