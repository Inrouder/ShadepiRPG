"""Read original atlas alpha; record cell regions and foot anchors. No image edits."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]
FOLDER=ROOT/'assets/memories/attack'
def measure(name,rows,target_height):
 im=Image.open(FOLDER/name).convert('RGBA');w,h=im.size;out=[]
 for row in range(rows):
  cells=[]
  for col in range(8):
   l,t,r,b=[round(v) for v in [col*w/8,row*h/rows,(col+1)*w/8,(row+1)*h/rows]]
   cell=im.crop((l,t,r,b));a=cell.getchannel('A');box=a.point(lambda v:255 if v>110 else 0).getbbox()
   if box is None:raise ValueError((name,row,col))
   pixels=a.load();valid=[]
   for y in range(round(cell.height*.6),cell.height):
    xs=[x for x in range(round(cell.width*.2),round(cell.width*.8)) if pixels[x,y]>160]
    if len(xs)>=5:valid.append((y,xs))
   foot=valid[-1][0]+1 if valid else box[3]
   xs=[x for y,values in valid if y>=foot-10 for x in values]
   anchor_x=(min(xs)+max(xs))/2 if xs else (box[0]+box[2])/2
   scale=target_height/(foot-box[1])
   cells.append({'region':[l,t,r-l,b-t],'anchor':[anchor_x,foot],'scale':round(scale,6)})
  out.append(cells)
 return out
ready=measure('warriors-ready.png',4,64)
run=measure('warriors-run.png',8,59)
residents=measure('residents.png',4,57)
data={}
for i,name in enumerate(['oni','robot','ly','heavy']):data[name]={'idle':ready[i],'run_a':run[i*2],'run_b':run[i*2+1]}
for i,name in enumerate(['elder','monk','resident','caretaker']):data[name]={'civilian':residents[i]}
bots=measure('bots.png',4,65)
data['bot']={'idle':bots[0],'run_a':bots[1],'run_b':bots[2],'attack':bots[3]}
walking=measure('residents-walk.png',8,57)
for i,name in enumerate(['elder','monk','resident','caretaker']):
 # DOWN, LEFT, RIGHT, UP; four distinct steps each. Keep one scale per person
 # so bent legs and flying hems do not make the body inflate each frame.
 frames=walking[i*2+1][4:]+walking[i*2][:4]+walking[i*2+1][:4]+walking[i*2][4:]
 scale=sorted(p['scale'] for p in frames)[len(frames)//2]
 for pose in frames:pose['scale']=scale
 data[name]['walk_cycle']=frames
combat=measure('combat.png',5,64)
for i,name in enumerate(['oni','robot','ly','heavy','bot']):
 # Same size through windup, contact, recoil and collapse. Fallen bodies use
 # their floor contact, not a fictional upright foot/height normalization.
 scale=combat[i][0]['scale']
 for pose in combat[i]:pose['scale']=scale
 data[name]['combat']=combat[i]
(FOLDER/'actors.json').write_text(json.dumps(data,indent=2)+'\n')
print('Measured 264 nonempty actor cells; source pixels preserved.')
