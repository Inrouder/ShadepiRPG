extends RefCounted
## v0.41.0 · CodexAI. Registered rear axle, steering, road travel and turret recoil.
const ATLAS = preload("res://assets/vehicles/pursuit/car.png")
const CELL := Vector2(418,418)
const SIZE := Vector2(112,96)
const SCALE := SIZE/CELL
const ANCHORS: Array[Vector2] = [Vector2(225,236),Vector2(207,236),Vector2(191,236),Vector2(225,221),Vector2(207,218),Vector2(191,218),Vector2(225,230),Vector2(207,230),Vector2(191,230)]
const MUZZLES: Array[Vector2] = [Vector2(225,153),Vector2(207,153),Vector2(191,153),Vector2(225,147),Vector2(207,134),Vector2(191,132),Vector2(225,191),Vector2(207,173),Vector2(191,164)]
const REAR_AXLES: Array[Vector2] = [Vector2(225,290),Vector2(207,290),Vector2(191,290),Vector2(225,275),Vector2(207,272),Vector2(191,272),Vector2(225,284),Vector2(207,284),Vector2(191,284)]

static func region(frame: int) -> Rect2: return Rect2(Vector2(frame%3,frame/3)*CELL,CELL)

static func frame_for(steering: float,recoil: float,warning: float,recovery: float,clock: float) -> int:
	if recoil>0.16: return 6
	if recoil>0: return 7
	if recovery>0.52: return 8
	if warning>0: return 5
	if absf(steering)>35: return 1 if steering<0 else 2
	var road := fposmod(clock*1.5,1.0)
	return 3 if road<0.15 else 4 if road>0.5 and road<0.65 else 0

static func muzzle(center: Vector2,frame: int) -> Vector2:
	return center+(MUZZLES[frame]-ANCHORS[frame])*SCALE

static func draw(canvas: CanvasItem,center: Vector2,frame: int):
	canvas.draw_texture_rect_region(ATLAS,Rect2(center-ANCHORS[frame]*SCALE,SIZE),region(frame))
