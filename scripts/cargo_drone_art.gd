extends RefCounted
## v0.41.0 · CodexAI. Four blade phases, fixed rotor rings and cargo release point.
const ATLAS = preload("res://assets/vehicles/pursuit/drone.png")
const CELL := Vector2(627,627)
const CENTER := Vector2(316,304)
const HUBS: Array[Vector2] = [Vector2(134,134),Vector2(500,134),Vector2(134,464),Vector2(500,464)]
const RELEASE := Vector2(316,473)

static func frame_for(clock: float) -> int: return posmod(int(floor(clock*18.0)),4)
static func region(frame: int) -> Rect2: return Rect2(Vector2(frame%2,frame/2)*CELL,CELL)
static func release_point(center: Vector2,size: Vector2,tilt: float = 0.0) -> Vector2:
	return center+((RELEASE-CENTER)*size/CELL).rotated(tilt)
static func draw(canvas: CanvasItem,center: Vector2,size: Vector2,clock: float,tilt: float = 0.0,tint: Color = Color.WHITE):
	canvas.draw_set_transform(center,tilt)
	canvas.draw_texture_rect_region(ATLAS,Rect2(-CENTER*size/CELL,size),region(frame_for(clock)),tint)
	canvas.draw_set_transform(Vector2.ZERO)
