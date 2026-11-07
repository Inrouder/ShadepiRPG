"""Read PNG alpha/color data; save atlas regions and foot/palm anchors. Does not edit art."""
from PIL import Image
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def measure(source,rows,names):
 im=Image.open(ROOT/source).convert('RGBA');w,h=im.size;out={}
 for row,name in enumerate(names):
  frames=[]
  old=Image.open(ROOT/('assets/sprites/heroes/raven.png' if name.startswith('cast') else 'assets/sprites/npcs/'+name+'.png'))
  height=old.crop((0,320,128,480)).getbbox();display_height=(height[3]-height[1])*.5
  for col in range(8):
   rect=(round(col*w/8),round(row*h/rows),round((col+1)*w/8),round((row+1)*h/rows));cell=im.crop(rect);a=cell.getchannel('A');box=a.point(lambda p:255 if p>100 else 0).getbbox()
   if not box:raise ValueError((name,col))
   l,t,r,b=box;legs=a.crop((0,t+(b-t)*2//3,cell.width,b)).point(lambda p:255 if p>100 else 0).getbbox();anchor=(legs[0]+legs[2])/2
   data={'region':[rect[0],rect[1],cell.width,cell.height],'anchor':[anchor,b],'scale':display_height/(b-t)}
   if name.startswith('cast'):
    points=[]
    for y in range(int(cell.height*.12),int(cell.height*.6)):
     for x in range(cell.width):
      red,green,blue,alpha=cell.getpixel((x,y))
      if alpha>180 and green>220 and blue>225 and red>175:points.append((x,y))
    data['palm']=[sum(x for x,y in points)/len(points),sum(y for x,y in points)/len(points)] if points else [cell.width*.5,cell.height*.5]
   frames.append(data)
  out[name]=frames
 return out
p=ROOT/'assets/sprites/npcs/contact-poses.json'
p.write_text(json.dumps(measure('assets/sprites/npcs/contact-poses.png',8,['punk-1','punk-2','punk-3','punk-4','shooter-visor','shooter-violet','jackal','kenzo']),indent=2)+'\n')
p=ROOT/'assets/sprites/heroes/raven-hand-cast.json'
p.write_text(json.dumps(list(measure('assets/sprites/heroes/raven-hand-cast.png',4,['cast0','cast1','cast2','cast3']).values()),indent=2)+'\n')
