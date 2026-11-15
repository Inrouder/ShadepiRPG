#!/usr/bin/env python3
"""v0.61.0 · CodexAI. Register generated artwork; never paint replacement sprites.

Only crops, uniform per-character resampling and transparent atlas placement.
Sources remain intact. Run deliberately from repository root, not during setup.
"""
import json
from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = Path(__file__).parent / 'sources'
IDS = ['shadepi', 'raven', 'jackal', 'kenzo', 'punk-1', 'punk-2',
       'punk-3', 'punk-4', 'shooter-violet', 'shooter-visor']
POSES = ['ready', 'breath', 'walk_a', 'walk_b', 'jump', 'block', 'hurt', 'ko',
         'punch_start', 'punch_hit', 'kick_start', 'kick_hit',
         'special_start', 'special_hit', 'victory', 'land']

def split(name):
    im = Image.open(SRC / (name + '.png')).convert('RGBA')
    alpha = np.array(im)[..., 3] > 24
    h, w = alpha.shape
    def cut(hist, n, index):
        lo, hi = int(n * (index / 4 - .055)), int(n * (index / 4 + .055))
        at = min(range(lo, hi), key=lambda p: (hist[p], abs(p - n * index / 4)))
        if hist[at] != 0:
            raise ValueError(f'{name}: no empty separator for {index}: {hist[at]}')
        return at
    ys = [0] + [cut(alpha.sum(axis=1), h, i) for i in range(1, 4)] + [h]
    cells, regions = [], []
    for r in range(4):
        hist = alpha[ys[r]:ys[r+1]].sum(axis=0)
        xs = [0] + [cut(hist, w, i) for i in range(1, 4)] + [w]
        for c in range(4):
            rect = (xs[c], ys[r], xs[c+1], ys[r+1])
            cell = im.crop(rect)
            # Ignore isolated invisible fringe pixels only for measuring, retain RGBA content.
            a = cell.getchannel('A').point(lambda v: 255 if v > 24 else 0)
            box = a.getbbox()
            if not box: raise ValueError(name + ': empty cell')
            regions.append([rect[0]+box[0], rect[1]+box[1], box[2]-box[0], box[3]-box[1]])
            cells.append(cell.crop(box))
    return cells, regions

def save(im, path):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, optimize=True)

def fighters():
    meta = {'version': '0.61.0', 'author': 'CodexAI', 'cell': [512, 320],
            'anchor': [224, 288], 'scale': .5, 'poses': POSES, 'fighters': {}}
    for identity in IDS:
        cells, regions = split(identity)
        body = 232 if identity != 'raven' else 220
        if identity == 'jackal': body = 248
        ratio = body / np.median([cells[i].height for i in range(4)])
        atlas = Image.new('RGBA', (2048, 1280))
        records = []
        for i, cell in enumerate(cells):
            a = np.array(cell)[..., 3] > 24
            feet = np.where(a[max(0, cell.height-12):])[1]
            anchor_x = float(np.median(feet)) if i not in [4, 7] else cell.width/2
            out = cell.resize((round(cell.width*ratio), round(cell.height*ratio)), Image.Resampling.LANCZOS)
            dx, dy = round(224-anchor_x*ratio), 288-out.height
            if min(dx, dy) < 4 or dx+out.width > 508:
                raise ValueError(f'{identity} {POSES[i]}: needs wider atlas, not clipping')
            atlas.paste(out, ((i%4)*512+dx, (i//4)*320+dy))
            records.append({'source_region': regions[i], 'placement': [dx, dy],
                            'size': list(out.size), 'source_anchor_x': round(anchor_x, 2)})
        save(atlas, f'assets/arcade/fighters/{identity}.png')
        meta['fighters'][identity] = {'ratio': round(ratio, 6), 'frames': records,
                                     'emitter': {'raven': [30, -158], 'punk-2': [52, -172], 'punk-3': [46, -158], 'shooter-violet': [126, -172], 'shooter-visor': [50, -160]}.get(identity, [78, -158])}
    (ROOT/'assets/arcade/fighters/atlas.json').write_text(json.dumps(meta, indent=2)+'\n')

def companions():
    cells, _ = split('companions')
    drone = Image.new('RGBA', (640, 320))
    ratio = 128 / np.median([c.width for c in cells[:8]])
    for i, c in enumerate(cells[:8]):
        out = c.resize((round(c.width*ratio), round(c.height*ratio)), Image.Resampling.LANCZOS)
        drone.paste(out, ((i%4)*160+(160-out.width)//2, (i//4)*160+16))
    save(drone, 'assets/sprites/companions/drone-hq.png')
    nanites = Image.new('RGBA', (256, 128))
    for i, c in enumerate(cells[8:]):
        c.thumbnail((52, 52), Image.Resampling.LANCZOS)
        nanites.paste(c, ((i%4)*64+(64-c.width)//2, (i//4)*64+(64-c.height)//2))
    save(nanites, 'assets/sprites/companions/nanites-hq.png')

def props():
    cells, _ = split('props')
    atlas = Image.new('RGBA', (1024, 1024))
    for i, c in enumerate(cells):
        # Animation phases share scale, retaining their expansion and dispersal.
        group = cells[8:12] if i in range(8,12) else cells[12:16] if i>=12 else [c]
        ratio = 224/max(max(p.size) for p in group)
        c = c.resize((round(c.width*ratio), round(c.height*ratio)), Image.Resampling.LANCZOS)
        atlas.paste(c, ((i%4)*256+(256-c.width)//2, (i//4)*256+(256-c.height)//2))
    save(atlas, 'assets/arcade/props-fx-hq.png')
    im = Image.open(SRC/'cabinet.png').convert('RGBA')
    im = im.crop(im.getchannel('A').point(lambda v:255 if v>24 else 0).getbbox())
    im.thumbnail((500, 780), Image.Resampling.LANCZOS)
    cabinet = Image.new('RGBA', (528, 816))
    cabinet.paste(im, ((528-im.width)//2, 800-im.height))
    save(cabinet, 'assets/arcade/cabinet-hq.png')

if __name__ == '__main__':
    fighters(); companions(); props()
    print('v0.61.0 CodexAI: registered 160 fighter poses, 16 companions and 16 props/FX')
