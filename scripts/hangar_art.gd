extends RefCounted
## v0.39.0 · CodexAI. Shared registered floor, closed roof and existing HQ craft.
const DECK = preload("res://assets/story/hangar-discovery/platform.png")
const SHAFT = preload("res://assets/story/hangar-discovery/shaft.png")
const SWITCH = preload("res://assets/story/hangar-discovery/switch.png")
const ROOM = preload("res://assets/story/departure/hangar-empty.png")
const ROOF = preload("res://assets/world/painted/hangar.png")
const BIKE = preload("res://assets/world/hq/bike-parked.png")
const GARAGE_DECK := Rect2(740,320,270,185)
const SHIFT := Vector2(-578,24)
const DOCK := Rect2(GARAGE_DECK.position+SHIFT,GARAGE_DECK.size)
const GARAGE_CAMERA := Vector2(870,410)
const HANGAR_CAMERA := GARAGE_CAMERA+SHIFT
const MOUNTS: Array[Vector2] = [Vector2(810,420),Vector2(843,440)]
const ARRIVALS: Array[Vector2] = [MOUNTS[0]+SHIFT,MOUNTS[1]+SHIFT]
const BIKE_SPOT := Vector2(902,386)+SHIFT
const CRAFT := Vector2(884,306)
const SWITCH_FEET := Vector2(720,296)
const SWITCH_TARGET := Vector2(738.875,246)
const SOURCE_FINGER := Vector2(531,88)
const SWITCH_ANCHOR := Vector2(380,488)

static func floor(canvas: CanvasItem, dock: bool, frame: int) -> void:
	frame = clampi(frame,0,5)
	var source := Rect2(Vector2(frame%3,frame/3)*512+Vector2(16,80),Vector2(480,350))
	canvas.draw_texture_rect_region(DECK,DOCK if dock else GARAGE_DECK,source)

static func room(canvas: CanvasItem) -> void:
	canvas.draw_texture_rect(ROOM,Rect2(0,0,1024,640),false)
	# The open roof belongs to the later departure, not this underground arrival.
	var roof := Rect2(782,0,242,205)
	canvas.draw_texture_rect_region(ROOF,roof,Rect2(roof.position/Vector2(1024,640)*ROOF.get_size(),roof.size/Vector2(1024,640)*ROOF.get_size()))
	preload("res://scripts/painted_world.gd").draw_hangar_brand(canvas)

static func bike_sprite() -> Sprite2D:
	var bike := Sprite2D.new()
	bike.texture = BIKE
	bike.scale = Vector2.ONE*72.0/BIKE.get_height()
	bike.position = BIKE_SPOT+Vector2(3,4)
	bike.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	return bike

static func shadow(canvas: CanvasItem, matrix: Transform2D = Transform2D.IDENTITY) -> void:
	canvas.draw_set_transform_matrix(matrix*Transform2D(0,Vector2(1,0.3),0,CRAFT+Vector2(0,28)))
	canvas.draw_circle(Vector2.ZERO,52,Color(0,0,0,0.32))
	canvas.draw_set_transform_matrix(matrix)
