# v0.46.2 · CodexAI: Quellwerkzeug mit Schreibzugriff; überschreibt Spielatlanten.
# Nicht beim normalen Setup ausführen. Status und Voraussetzungen: tools/README.md.
"""Pack generated hero keyframes without redrawing the character artwork.

Requires Pillow. The source has eight directions in four rows: idle, left
stride, right stride and attack. Components recover weapon tips that cross a
source grid line, while excluding parts of the neighbouring pose. Original
RGBA colours and translucent edges are retained.
"""
from array import array
from collections import deque
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CELL = (128, 160)
DIRECTIONS = ["south", "west", "east", "north", "northwest", "northeast", "southwest", "southeast"]


def extract_row(source, row):
    strip = source.crop((0, row * 256, 1536, (row + 1) * 256))
    alpha = strip.getchannel("A").tobytes()
    width, height = strip.size
    labels = array("I", [0]) * len(alpha)
    component = 0
    # A visible core separates characters even when faint weapon glows overlap.
    for start, value in enumerate(alpha):
        if value < 32 or labels[start]:
            continue
        component += 1
        labels[start] = component
        pending = [start]
        while pending:
            index = pending.pop()
            x, y = index % width, index // width
            neighbours = []
            if x: neighbours.append(index - 1)
            if x + 1 < width: neighbours.append(index + 1)
            if y: neighbours.append(index - width)
            if y + 1 < height: neighbours.append(index + width)
            for neighbour in neighbours:
                if not labels[neighbour] and alpha[neighbour] >= 32:
                    labels[neighbour] = component
                    pending.append(neighbour)

    selected = []
    for column in range(8):
        counts = [0] * (component + 1)
        for y in range(height):
            for x in range(column * 192, (column + 1) * 192):
                counts[labels[y * width + x]] += 1
        counts[0] = 0
        selected.append(max(range(1, component + 1), key=counts.__getitem__))

    # Assign each original translucent fringe pixel to its nearest visible core.
    core_labels = array("I", labels)
    distance = bytearray(len(alpha))
    fringe = deque(index for index, label in enumerate(labels) if label)
    while fringe:
        index = fringe.popleft()
        if distance[index] >= 12:
            continue
        x, y = index % width, index // width
        neighbours = []
        if x: neighbours.append(index - 1)
        if x + 1 < width: neighbours.append(index + 1)
        if y: neighbours.append(index - width)
        if y + 1 < height: neighbours.append(index + width)
        for neighbour in neighbours:
            if alpha[neighbour] and not labels[neighbour]:
                labels[neighbour] = labels[index]
                distance[neighbour] = distance[index] + 1
                fringe.append(neighbour)

    frames = []
    for selected_label in selected:
        core = Image.frombytes("L", strip.size, bytes(255 if label == selected_label else 0 for label in core_labels))
        left, top, right, bottom = core.getbbox()
        leg_top = top + round((bottom - top) * 0.7)
        legs = core.crop((0, leg_top, width, bottom)).getbbox()
        center_x = (legs[0] + legs[2]) / 2
        pose = strip.copy()
        pose.putalpha(Image.frombytes("L", strip.size, bytes(value if label == selected_label else 0 for value, label in zip(alpha, labels))))
        bounds = pose.getbbox()
        pose = pose.crop(bounds)
        pose = pose.resize((round(pose.width * 0.5), round(pose.height * 0.5)), Image.Resampling.LANCZOS)
        frame = Image.new("RGBA", CELL)
        frame.alpha_composite(pose, (round(64 + (bounds[0] - center_x) * 0.5), round(152 + (bounds[1] - bottom) * 0.5)))
        frames.append(frame)
    return frames


for name in ["raven", "shadepi"]:
    source = Image.open(ROOT / "tools/hero_sources" / f"{name}-keyframes.png").convert("RGBA")
    if source.size != (1536, 1024):
        raise ValueError("The keyframe grid must have eight 192x256 cells per row.")
    poses = [extract_row(source, row) for row in range(4)]
    sequences = {
        "idle": [0] * 8,
        "walk": [0, 1, 1, 0, 0, 2, 2, 0],
        "attack": [3, 3, 3, 3, 3, 0, 0, 0] if name == "raven" else [0, 0, 3, 3, 3, 2, 0, 0],
        "hurt": [0] * 8,
    }
    sheet = Image.new("RGBA", (CELL[0] * 8, CELL[1] * 32))
    for state, sequence in enumerate(sequences.values()):
        for direction in range(8):
            for frame, source_row in enumerate(sequence):
                sheet.alpha_composite(poses[source_row][direction], (frame * CELL[0], (state * 8 + direction) * CELL[1]))
    out = ROOT / "assets/sprites/heroes" / f"{name}.png"
    temporary = out.with_suffix(".tmp.png")
    sheet.save(temporary, optimize=True)
    temporary.replace(out)
    print(out)
