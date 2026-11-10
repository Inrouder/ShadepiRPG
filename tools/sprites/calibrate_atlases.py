#!/usr/bin/env python3
"""v0.52.0 · ClaudeHelper: give every pose its own clean, padded cell.

No pixel is redrawn. Each connected shape is assigned to the pose rectangle that holds
most of it; a pose is then copied WHOLE (including the part that used to hang into the
neighbouring rectangle) into a larger cell with a transparent margin. Neighbour remains
disappear, clipped limbs and weapons become complete.

  grid atlases  – all cells grow by the same padding, the grid stays uniform; sprites are
                  drawn centred, so the game code and on-screen position stay identical.
  JSON atlases  – regions are repacked row by row; `region` is rewritten and `anchor` /
                  `bounds` move by the padding, so the on-screen position stays identical.

Shapes that genuinely join two poses (drawn overlapping) are left split at the old edge.
Writes the PNG (and JSON) in place. The untouched originals are the v0.51.1 files in Git.
Run it only on uncalibrated sheets; a clean sheet is reported and left alone.
  python3 tools/sprites/calibrate_atlases.py            # all atlases listed in JOBS
"""
import json
import sys
import numpy as np
from PIL import Image
from scipy import ndimage
from atlas_regions import ROOT, _json_regions

ALPHA = 24
MARGIN = 3

def owners(alpha, rects):
    labels, count = ndimage.label(alpha > ALPHA, structure=np.ones((3, 3)))
    share = np.zeros((count + 1, len(rects)), dtype=np.int64)
    for i, (x, y, w, h) in enumerate(rects):
        ids, n = np.unique(labels[y:y + h, x:x + w], return_counts=True)
        share[ids, i] += n
    total = np.bincount(labels.ravel(), minlength=count + 1)
    owner = share.argmax(axis=1)
    owner[share.max(axis=1) == 0] = -1          # outside every rectangle
    ordered = np.sort(share, axis=1)
    second = ordered[:, -2] if len(rects) > 1 else np.zeros(count + 1, dtype=np.int64)
    # Two poses drawn into each other: keep the old split instead of gifting a body away.
    merged = (second > 400) & (second * 4 > total)
    owner[merged] = -2
    owner[0] = -1
    return labels, owner, int(merged.sum())

def pose_images(image, rects):
    alpha = image[..., 3]
    labels, owner, merged = owners(alpha, rects)
    own = owner[labels]
    boxes = []
    for i, (x, y, w, h) in enumerate(rects):
        mine = own == i
        inside = np.zeros_like(mine)
        inside[y:y + h, x:x + w] = True
        # Own shapes everywhere, joined shapes only inside the old edge, plus the soft
        # anti-aliased fringe (alpha below the threshold) right around the own shapes.
        fringe = (alpha > 0) & (labels == 0) & ndimage.binary_dilation(mine, iterations=2)
        keep = mine | (inside & (own == -2)) | fringe
        ys, xs = np.nonzero(mine)
        if len(ys):
            over = max(x - xs.min(), xs.max() - (x + w - 1), y - ys.min(), ys.max() - (y + h - 1), 0)
        else:
            over = 0
        boxes.append((keep, over))
    return boxes, merged

def extract(image, keep, rect, pad):
    x, y, w, h = rect
    H, W = keep.shape
    cell = np.zeros((h + 2 * pad, w + 2 * pad, 4), dtype=np.uint8)
    sx0, sy0, sx1, sy1 = max(0, x - pad), max(0, y - pad), min(W, x + w + pad), min(H, y + h + pad)
    part = image[sy0:sy1, sx0:sx1].copy()
    part[~keep[sy0:sy1, sx0:sx1]] = 0
    cell[sy0 - (y - pad):sy1 - (y - pad), sx0 - (x - pad):sx1 - (x - pad)] = part
    return cell

def calibrate_grid(png, cols, rows):
    path = ROOT / png
    image = np.array(Image.open(path).convert("RGBA"))
    H, W = image.shape[:2]
    cw, ch = W // cols, H // rows
    assert cw * cols == W and ch * rows == H, "grid atlas needs whole-pixel cells"
    rects = [(c * cw, r * ch, cw, ch) for r in range(rows) for c in range(cols)]
    boxes, merged = pose_images(image, rects)
    pad = max(over for _, over in boxes)
    if pad == 0:
        print(f"clean   {png}")
        return
    pad += MARGIN
    out = np.zeros(((ch + 2 * pad) * rows, (cw + 2 * pad) * cols, 4), dtype=np.uint8)
    for i, (keep, _) in enumerate(boxes):
        r, c = divmod(i, cols)
        out[r * (ch + 2 * pad):(r + 1) * (ch + 2 * pad), c * (cw + 2 * pad):(c + 1) * (cw + 2 * pad)] = extract(image, keep, rects[i], pad)
    Image.fromarray(out).save(path, optimize=True)
    print(f"grid    {png}: cells {cw}x{ch} -> {cw + 2 * pad}x{ch + 2 * pad}, {merged} joined shapes kept")

def calibrate_json(png_regions, json_path):
    """png_regions: {png: [region dicts that live on this png]}; all dicts belong to json_path."""
    for png, entries in png_regions.items():
        path = ROOT / png
        image = np.array(Image.open(path).convert("RGBA"))
        rects = sorted({tuple(int(v) for v in e["region"]) for e in entries}, key=lambda r: (r[1], r[0]))
        boxes, merged = pose_images(image, rects)
        pad = max(over for _, over in boxes)
        if pad == 0:
            print(f"clean   {png}")
            continue
        pad += MARGIN
        # Shelf packing in the original reading order: same rows, wider cells.
        moved, cells = {}, []
        row_y, cursor_y, cursor_x, row_h, width = None, 0, 0, 0, 0
        for i, rect in enumerate(rects):
            if rect[1] != row_y:
                cursor_y += row_h
                row_y, cursor_x, row_h = rect[1], 0, 0
            cell = extract(image, boxes[i][0], rect, pad)
            moved[rect] = (int(cursor_x), int(cursor_y), int(cell.shape[1]), int(cell.shape[0]))
            cells.append((cursor_x, cursor_y, cell))
            cursor_x += cell.shape[1]
            row_h = max(row_h, cell.shape[0])
            width = max(width, cursor_x)
        out = np.zeros((cursor_y + row_h, width, 4), dtype=np.uint8)
        for x, y, cell in cells:
            out[y:y + cell.shape[0], x:x + cell.shape[1]] = cell
        Image.fromarray(out).save(path, optimize=True)
        for e in entries:
            old = tuple(int(v) for v in e["region"])
            e["region"] = list(moved[old])
            e["anchor"] = [e["anchor"][0] + int(pad), e["anchor"][1] + int(pad)]
            if "bounds" in e:
                e["bounds"] = [v + int(pad) for v in e["bounds"]]
        print(f"json    {png}: {len(rects)} poses, padding {pad}px, atlas {image.shape[1]}x{image.shape[0]} -> {out.shape[1]}x{out.shape[0]}, {merged} joined shapes kept")

def dicts(node, out):
    if isinstance(node, dict):
        if "region" in node:
            out.append(node)
        else:
            for v in node.values():
                dicts(v, out)
    elif isinstance(node, list):
        for v in node:
            dicts(v, out)
    return out

def main():
    calibrate_grid("assets/sprites/heroes/combat-poses.png", 8, 4)
    # Enemy contact poses.
    p = ROOT / "assets/sprites/npcs/contact-poses.json"
    data = json.loads(p.read_text())
    calibrate_json({"assets/sprites/npcs/contact-poses.png": dicts(data, [])}, p)
    p.write_text(json.dumps(data, indent=1) + "\n")
    # Monastery memories: several sheets share one catalog.
    mem = "assets/memories/"
    p = ROOT / mem / "attack/actors.json"
    data = json.loads(p.read_text())
    sheet_for = {"idle": "warriors-ready", "run_a": "warriors-run", "run_b": "warriors-run", "combat": "combat",
                 "civilian": "residents", "walk_cycle": "residents-walk", "attack": "bots"}
    groups = {}
    for identity, poses in data.items():
        for key, frames in poses.items():
            sheet = "bots" if identity == "bot" and key != "combat" else sheet_for[key]
            groups.setdefault(mem + "attack/" + sheet + ".png", []).extend(dicts(frames, []))
    calibrate_json(groups, p)
    p.write_text(json.dumps(data, indent=1) + "\n")
    for folder, mapping in [("sacrifice", {"minotaur": "minotaur", "ly": "ly-charge"}), ("legacy", {"figures": "characters", "master_death": "master-death"})]:
        p = ROOT / mem / folder / "actors.json"
            data = json.loads(p.read_text())
        calibrate_json({mem + folder + "/" + sheet + ".png": dicts(data[key], []) for key, sheet in mapping.items()}, p)
        p.write_text(json.dumps(data, indent=1) + "\n")

if __name__ == "__main__":
    main()
