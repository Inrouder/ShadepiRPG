"""v0.63.0 CodexAI: register generated pixel HUD sprites; never draw replacement art."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[2]
im=Image.open(Path(__file__).with_name('source.png')).convert('RGBA')
# Actual 1254-square output; source rectangles retain each full independent silhouette.
regions={'ring':(8,15,400,399),'thumb':(480,75,754,355),'pistol':(832,105,1254,355),
 'katana':(12,422,403,812),'kick':(418,480,755,727),'dodge':(755,470,1230,780),
 'interact':(20,835,370,1254),'charge':(400,818,830,1254),'hack':(840,830,1220,1245)}
for name,box in regions.items():
    sprite=im.crop(box)
    bbox=sprite.getbbox()
    if not bbox:raise ValueError(name)
    sprite=sprite.crop(bbox)
    factor=min(352/sprite.width,352/sprite.height,1)
    sprite=sprite.resize((round(sprite.width*factor),round(sprite.height*factor)),Image.Resampling.NEAREST)
    out=Image.new('RGBA',(384,384))
    out.alpha_composite(sprite,((384-sprite.width)//2,(384-sprite.height)//2))
    out.save(root/'assets/ui/touch'/f'{name}.png',optimize=True)
Path(__file__).with_name('regions.json').write_text(json.dumps({'version':'0.63.0','author':'CodexAI','source_size':list(im.size),'regions':regions},indent=2)+'\n')
