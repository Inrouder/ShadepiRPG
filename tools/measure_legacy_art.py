"""Measure source pixel regions only. No edits to original PNGs."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]
folder=ROOT/'assets/memories/legacy'
image=Image.open(folder/'characters.png').convert('RGBA')
frames=[]
for i in range(8):
 x,y=(i%4)*384,(i//4)*512
 alpha=image.crop((x,y,x+384,y+512)).getchannel('A')
 box=alpha.point(lambda a:255 if a>120 else 0).getbbox()
 if not box:raise ValueError(i)
 pix=alpha.load();valid=[]
 for row in range(300,512):
  xs=[col for col in range(384) if pix[col,row]>160]
  if len(xs)>7:valid.append((row,xs))
 floor=valid[-1][0]+1 if valid else box[3]
 feet=[col for row,xs in valid if row>=floor-7 for col in xs]
 anchor=(min(feet)+max(feet))/2 if feet else (box[0]+box[2])/2
 frames.append({'region':[x,y,384,512],'anchor':[anchor,floor],'bounds':list(box)})
scale=round(64/(frames[0]['anchor'][1]-frames[0]['bounds'][1]),6)
for frame in frames:frame['scale']=scale
(folder/'actors.json').write_text(json.dumps({'figures':frames,'transfer_grid':[4,2]},indent=2)+'\n')
print('8 figure regions measured; constant body scale and original source pixels preserved.')
