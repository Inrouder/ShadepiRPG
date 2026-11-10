#!/usr/bin/env python3
"""v0.52.0 · ClaudeHelper: find pose rectangles that show a neighbour or cut their own pose.

For every rectangle the game cuts out, connected opaque shapes that touch the rectangle
edge are classified:
  intruder – most of the shape lies outside: a piece of the NEIGHBOUR pose is visible
  cut      – most of the shape lies inside: the pose itself is clipped at the edge
Read-only. Needs Pillow, numpy, scipy.   python3 tools/sprites/audit_atlases.py [-v]
"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage
from atlas_regions import ROOT, catalog

ALPHA = 24

def audit(path, rects):
    alpha = np.array(Image.open(ROOT / path).convert("RGBA"))[..., 3]
    labels, count = ndimage.label(alpha > ALPHA, structure=np.ones((3, 3)))
    sizes = ndimage.sum(np.ones_like(labels), labels, index=np.arange(count + 1))
    findings = []
    for (x, y, w, h) in rects:
        inside = labels[y:y + h, x:x + w]
        edge = np.concatenate([inside[0], inside[-1], inside[:, 0], inside[:, -1]])
        for label in np.unique(edge):
            if label == 0:
                continue
            within = int((inside == label).sum())
            total = int(sizes[label])
            if total < 6 or min(within, total - within) < 8 and within != total:
                continue   # stray specks of a few pixels are invisible at game scale
            kind = "cut" if within * 2 >= total else "intruder"
            if within == total:
                kind = "touch"   # complete, but without a clear pixel of margin
            findings.append(((x, y, w, h), kind, within, total))
    return findings

def main():
    verbose = "-v" in sys.argv
    bad = 0
    for path, rects in sorted(catalog().items()):
        found = audit(path, rects)
        hard = [f for f in found if f[1] != "touch"]
        bad += len(hard)
        print(f"{'FAIL' if hard else 'ok  '} {path}: {len(rects)} poses, {sum(f[1]=='intruder' for f in found)} intruders, {sum(f[1]=='cut' for f in found)} cut, {sum(f[1]=='touch' for f in found)} touching")
        if verbose:
            for rect, kind, within, total in found:
                if kind != "touch":
                    print(f"      {kind:8} {rect} {within}/{total} px")
    print(f"ATLAS AUDIT: {bad} visible faults")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main())
