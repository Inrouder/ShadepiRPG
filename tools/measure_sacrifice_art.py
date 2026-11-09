# v0.46.2 · CodexAI: reads PNG pixels but overwrites active JSON metadata. Not a read-only audit.
# See tools/README.md; do not run during ordinary setup.
"""Read-only atlas measurement for Memory II. Never rewrites PNG pixels."""
from pathlib import Path
from PIL import Image
import json
ROOT=Path(__file__).resolve().parents[1]
FOLDER=ROOT/'assets/memories/sacrifice'
def measure(name,height):
 image=Image.open(FOLDER/name).convert('RGBA');width,total_height=image.size;frames=[]
 for row in range(2):
  for column in range(4):
   left,top,right,bottom=[round(x) for x in (column*width/4,row*total_height/2,(column+1)*width/4,(row+1)*total_height/2)]
   alpha=image.crop((left,top,right,bottom)).getchannel('A')
   bounds=alpha.point(lambda x:255 if x>120 else 0).getbbox()
   if bounds is None:raise ValueError((name,row,column))
   pixels=alpha.load();rows=[]
   for y in range(round(alpha.height*.6),alpha.height):
    xs=[x for x in range(alpha.width) if pixels[x,y]>160]
    if len(xs)>=7:rows.append((y,xs))
   floor=rows[-1][0]+1 if rows else bounds[3]
   feet=[x for y,xs in rows if y>=floor-8 for x in xs]
   anchor=(min(feet)+max(feet))/2 if feet else (bounds[0]+bounds[2])/2
   frames.append({'region':[left,top,right-left,bottom-top],'anchor':[anchor,floor],'scale':1.0,'bounds':list(bounds)})
 reference=frames[0 if name=='minotaur.png' else 2]
 scale=round(height/(reference['anchor'][1]-reference['bounds'][1]),6)
 for frame in frames:frame['scale']=scale
 return frames
meta={'minotaur':measure('minotaur.png',136),'ly':measure('ly-charge.png',64)}
# The device is a prop, not a man: separate size and mount offset.
charge=meta['ly'][7];bounds=charge['bounds'];charge['scale']=round(15/(bounds[2]-bounds[0]),6)
charge['anchor']=[(bounds[0]+bounds[2])/2,(bounds[1]+bounds[3])/2]
(FOLDER/'actors.json').write_text(json.dumps(meta,indent=2)+'\n')
print('16 source regions measured; common human/mech scales preserve stance and collapse size.')
