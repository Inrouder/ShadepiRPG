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
print('8 figure regions measured; constant body scale and original source pixels preserved.')
# The new master's corpse is measured by body length, not lying height.
# This also keeps the two supporting poses at the existing kneeling scale.
death_image=Image.open(folder/'master-death.png').convert('RGBA')
death=[]
for i in range(4):
 x,y=(i%2)*768,(i//2)*512
 alpha=death_image.crop((x,y,x+768,y+512)).getchannel('A')
 box=alpha.point(lambda a:255 if a>120 else 0).getbbox()
 if not box:raise ValueError(('death',i))
 pix=alpha.load();floor=box[3]
 xs=[col for row in range(max(box[1],floor-8),floor) for col in range(box[0],box[2]) if pix[col,row]>160]
 death.append({'region':[x,y,768,512],'anchor':[(min(xs)+max(xs))/2,floor],'bounds':list(box)})
body=death[2]['bounds']
corpse_scale=round(64/(body[2]-body[0]),6)
for frame in death:frame['scale']=corpse_scale
(folder/'actors.json').write_text(json.dumps({'figures':frames,'master_death':death,'transfer_grid':[4,2],'aura_grid':[4,4]},indent=2)+'\n')
print('4 death/support poses added at shared body scale; original PNG pixels preserved.')
