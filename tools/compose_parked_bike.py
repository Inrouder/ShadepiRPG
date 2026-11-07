"""Builds assets/world/hq/bike-parked.png (the motorcycle without riders) from the
existing HQ vehicle atlas: front fairing and rear section are cut from the ridden
bike, the middle (where Shadepi and Raven sit) becomes tank, seat and engine.
Run from the project root: python3 tools/compose_parked_bike.py"""
from PIL import Image, ImageDraw

src = Image.open("assets/world/hq/vehicles.png").convert("RGBA").crop((0, 627, 627, 1254))


def feather(im, top=0, bottom=0, left=0, right=0):
    im = im.copy()
    alpha = im.split()[3]
    px = alpha.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            f = 1.0
            if top and y < top:
                f = min(f, y / top)
            if bottom and y > h - 1 - bottom:
                f = min(f, (h - 1 - y) / bottom)
            if left and x < left:
                f = min(f, x / left)
            if right and x > w - 1 - right:
                f = min(f, (w - 1 - x) / right)
            px[x, y] = int(px[x, y] * f)
    im.putalpha(alpha)
    return im


front = src.crop((230, 28, 400, 152))
rear = src.crop((190, 410, 440, 605))
mid_h = 104
out = Image.new("RGBA", (260, front.height + mid_h + rear.height - 20), (0, 0, 0, 0))
d = ImageDraw.Draw(out)
cx, y0 = 130, front.height - 8
d.rounded_rectangle((cx - 46, y0 - 10, cx + 46, y0 + mid_h + 14), radius=30, fill=(26, 26, 30, 255))
engine = feather(src.crop((198, 412, 252, 470)), 4, 4, 4, 4)
out.alpha_composite(engine.resize((44, 64)), (cx - 80, y0 + 30))
out.alpha_composite(engine.transpose(Image.FLIP_LEFT_RIGHT).resize((44, 64)), (cx + 36, y0 + 30))
d.rounded_rectangle((cx - 34, y0 - 4, cx + 34, y0 + 44), radius=22, fill=(150, 32, 30, 255), outline=(70, 14, 14, 255), width=3)
d.ellipse((cx - 16, y0 + 4, cx + 10, y0 + 20), fill=(205, 80, 70, 255))
d.rounded_rectangle((cx - 30, y0 + 44, cx + 30, y0 + mid_h + 6), radius=24, fill=(20, 18, 22, 255), outline=(68, 58, 62, 255), width=3)
d.line((cx, y0 + 52, cx, y0 + mid_h), fill=(52, 46, 50, 255), width=2)
out.alpha_composite(front, (cx - 85, 0))
out.alpha_composite(feather(rear, top=14), (cx - 125, y0 + mid_h - 6))
out.crop(out.getbbox()).save("assets/world/hq/bike-parked.png")
