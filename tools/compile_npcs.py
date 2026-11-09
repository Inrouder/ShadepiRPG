# v0.46.2 · CodexAI: Quellwerkzeug mit Schreibzugriff; überschreibt Spielatlanten.
# Nicht beim normalen Setup ausführen. Status und Voraussetzungen: tools/README.md.
"""Pack illustrated NPC keyframes into Godot atlases without redrawing art.

Requires Pillow. Source: transparent 1536x1024 PNG, eight directions across
four rows (idle, left stride, right stride, attack). Output: 1024x5120 RGBA,
eight animation frames across 32 rows, matching the existing HQ heroes.

Connected components preserve weapon tips crossing a column boundary while
keeping adjacent poses separate. The original RGBA colors and translucent
edges are retained. One scale is used for every pose of a character; feet
are aligned at y=152. Invalid/missing or clipped frames stop compilation.

Run all NPCs: python tools/compile_npcs.py
Run selected NPCs: python tools/compile_npcs.py jackal kenzo
Extraction bounds and scale are recorded in tools/npc_sources/atlas-report.json.
"""

import argparse
from array import array
from collections import deque
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
NAMES = (
    "jackal", "kenzo", "punk-1", "punk-2", "punk-3", "punk-4",
    "shooter-visor", "shooter-violet",
)
DIRECTIONS = (
    "south", "west", "east", "north", "northwest", "northeast",
    "southwest", "southeast",
)
SOURCE_SIZE = (1536, 1024)
SOURCE_CELL = (192, 256)
CELL = (128, 160)
FOOT = (64, 152)


def neighbours(index, width, height):
    x, y = index % width, index // width
    if x:
        yield index - 1
    if x + 1 < width:
        yield index + 1
    if y:
        yield index - width
    if y + 1 < height:
        yield index + width


def extract_row(source, row):
    """Return eight cropped RGBA poses plus core-derived foot anchors."""
    strip = source.crop((0, row * 256, 1536, (row + 1) * 256))
    alpha = strip.getchannel("A").tobytes()
    width, height = strip.size
    labels = array("I", [0]) * len(alpha)
    component = 0
    for start, value in enumerate(alpha):
        if value < 32 or labels[start]:
            continue
        component += 1
        labels[start] = component
        pending = [start]
        while pending:
            index = pending.pop()
            for neighbour in neighbours(index, width, height):
                if not labels[neighbour] and alpha[neighbour] >= 32:
                    labels[neighbour] = component
                    pending.append(neighbour)
    if not component:
        raise ValueError(f"Source row {row + 1} is empty")

    selected = []
    for column in range(8):
        counts = [0] * (component + 1)
        for y in range(height):
            for x in range(column * 192, (column + 1) * 192):
                counts[labels[y * width + x]] += 1
        counts[0] = 0
        label = max(range(1, component + 1), key=counts.__getitem__)
        if counts[label] < 150:
            raise ValueError(f"No substantial pose at row {row + 1}, column {column + 1}")
        selected.append(label)
    if len(set(selected)) != 8:
        raise ValueError(f"Poses touch/overlap in row {row + 1}; source needs separate silhouettes")

    core_labels = array("I", labels)
    # Expand only through existing translucent pixels; never invent opacity.
    distance = bytearray(len(alpha))
    fringe = deque(index for index, label in enumerate(labels) if label)
    while fringe:
        index = fringe.popleft()
        if distance[index] >= 12:
            continue
        for neighbour in neighbours(index, width, height):
            if alpha[neighbour] and not labels[neighbour]:
                labels[neighbour] = labels[index]
                distance[neighbour] = distance[index] + 1
                fringe.append(neighbour)

    poses = []
    for column, label in enumerate(selected):
        core = Image.frombytes("L", strip.size, bytes(255 if item == label else 0 for item in core_labels))
        core_bounds = core.getbbox()
        left, top, right, bottom = core_bounds
        if top == 0 or bottom == height or left == 0 or right == width:
            raise ValueError(f"Pose touches source sheet/row boundary at row {row + 1}, column {column + 1}")
        leg_top = top + round((bottom - top) * 0.7)
        legs = core.crop((0, leg_top, width, bottom)).getbbox()
        center_x = (legs[0] + legs[2]) / 2
        pose = strip.copy()
        pose.putalpha(Image.frombytes("L", strip.size, bytes(value if item == label else 0 for value, item in zip(alpha, labels))))
        bounds = pose.getbbox()
        cropped = pose.crop(bounds)
        anchor = (center_x - bounds[0], bottom - bounds[1])
        poses.append({
            "image": cropped,
            "anchor": anchor,
            "source_row": row,
            "direction": DIRECTIONS[column],
            "source_bounds": [bounds[0], bounds[1] + row * 256, bounds[2], bounds[3] + row * 256],
            "core_bounds": [left, top + row * 256, right, bottom + row * 256],
        })
    return poses


def pack_character(name, root=ROOT):
    source_path = root / "tools/npc_sources" / f"{name}-keyframes.png"
    with Image.open(source_path) as original:
        if original.size != SOURCE_SIZE:
            raise ValueError(f"{source_path.name}: expected {SOURCE_SIZE}, got {original.size}")
        if "A" not in original.getbands():
            raise ValueError(f"{source_path.name}: real alpha transparency is required")
        source = original.convert("RGBA")
    extrema = source.getchannel("A").getextrema()
    if extrema[0] != 0 or extrema[1] < 128:
        raise ValueError(f"{source_path.name}: must contain transparent background and visible art")
    poses = [extract_row(source, row) for row in range(4)]
    scale = 0.5
    # Leave two pixels of transparent margin and keep a uniform character size.
    for row in poses:
        for pose in row:
            x, y = pose["anchor"]
            width, height = pose["image"].size
            for extent, available in ((x, FOOT[0] - 2), (width - x, CELL[0] - FOOT[0] - 2), (y, FOOT[1] - 2), (height - y, CELL[1] - FOOT[1] - 2)):
                if extent > 0:
                    scale = min(scale, available / extent)
    if scale < 0.3:
        raise ValueError(f"{name}: oversized pose would shrink the entire character too far ({scale:.3f})")

    metadata = []
    frames = []
    for row in poses:
        packed_row = []
        for pose in row:
            image = pose["image"]
            size = (max(1, round(image.width * scale)), max(1, round(image.height * scale)))
            image = image.resize(size, Image.Resampling.LANCZOS)
            offset = (round(FOOT[0] - pose["anchor"][0] * scale), round(FOOT[1] - pose["anchor"][1] * scale))
            if offset[0] < 0 or offset[1] < 0 or offset[0] + size[0] > CELL[0] or offset[1] + size[1] > CELL[1]:
                raise ValueError(f"{name}: clipping at source row {pose['source_row']}, {pose['direction']}")
            frame = Image.new("RGBA", CELL)
            frame.alpha_composite(image, offset)
            bounds = frame.getbbox()
            if bounds is None:
                raise ValueError(f"{name}: extracted an empty frame")
            metadata.append({key: value for key, value in pose.items() if key != "image"} | {"packed_bounds": list(bounds), "offset": list(offset)})
            packed_row.append(frame)
        frames.append(packed_row)

    sequences = {
        "idle": [0] * 8,
        "walk": [0, 1, 1, 0, 0, 2, 2, 0],
        "attack": [0, 0, 3, 3, 3, 3, 0, 0],
        "hurt": [0] * 8,
    }
    sheet = Image.new("RGBA", (1024, 5120))
    for state, sequence in enumerate(sequences.values()):
        for direction in range(8):
            for frame, source_row in enumerate(sequence):
                sheet.alpha_composite(frames[source_row][direction], (frame * CELL[0], (state * 8 + direction) * CELL[1]))
    nonempty = sum(sheet.crop((x * 128, y * 160, (x + 1) * 128, (y + 1) * 160)).getbbox() is not None for y in range(32) for x in range(8))
    if nonempty != 256:
        raise ValueError(f"{name}: only {nonempty}/256 output frames have artwork")
    output = root / "assets/sprites/npcs" / f"{name}.png"
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(".tmp.png")
    sheet.save(temporary, optimize=True)
    temporary.replace(output)
    return {"source": str(source_path.relative_to(root)).replace("\\", "/"), "output": str(output.relative_to(root)).replace("\\", "/"), "scale": scale, "source_poses": 32, "nonempty_frames": nonempty, "atlas_size": [1024, 5120], "poses": metadata}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("names", nargs="*", choices=NAMES)
    args = parser.parse_args()
    names = args.names or NAMES
    missing = [name for name in names if not (ROOT / "tools/npc_sources" / f"{name}-keyframes.png").is_file()]
    if missing:
        parser.error("Missing keyframe sources: " + ", ".join(missing))
    report_path = ROOT / "tools/npc_sources/atlas-report.json"
    report = json.loads(report_path.read_text(encoding="utf-8")) if report_path.exists() else {}
    for name in names:
        report[name] = pack_character(name)
        print(f"{name}: 32 poses -> 256 nonempty frames, scale {report[name]['scale']:.4f}")
    report_path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
