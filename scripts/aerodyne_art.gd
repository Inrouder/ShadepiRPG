extends RefCounted
## v0.37.0 · CodexAI. Registered mechanical frames, shared by flight and cinematics.
const ATLAS = preload("res://assets/vehicles/aerodyne/airframe.png")
const CELL := Vector2(512,512)
# Measured hull registration: the generated cells have different transparent gutters.
# Nose/cockpit and nozzle positions stay fixed after this correction, without painting pixels.
const ANCHORS: Array[Vector2] = [Vector2(268,256),Vector2(256,256),Vector2(244,256),Vector2(268,258),Vector2(256,258),Vector2(244,258)]
const NOZZLES: Array[Vector2] = [Vector2(-82,186)*240.0/512.0,Vector2(82,186)*240.0/512.0]
const CYCLE := [4,5,4,0]

static func frame_for(clock: float, power: float, door: float = 0.0) -> int:
	if door>0.001: return clampi(roundi(door*3),0,3)
	if power<=0.001: return 0
	return CYCLE[posmod(int(floor(clock*8)),CYCLE.size())]

static func region(frame: int) -> Rect2:
	return Rect2(Vector2(frame%3,frame/3)*CELL,CELL)

static func draw(canvas: CanvasItem, destination: Rect2, clock: float, power: float, tint: Color = Color.WHITE) -> void:
	var frame := frame_for(clock,power)
	var offset := (CELL*0.5-ANCHORS[frame])*destination.size/CELL
	canvas.draw_texture_rect_region(ATLAS,Rect2(destination.position+offset,destination.size),region(frame),tint)
