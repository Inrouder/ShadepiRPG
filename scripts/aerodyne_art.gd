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

static func draw(canvas: CanvasItem, destination: Rect2, clock: float, power: float, tint: Color = Color.WHITE, bank: float = 0.0, braking: float = 0.0) -> void:
	for entry in layers(bank,braking):
		if entry[1]<=0.001: continue
		var frame: int = frame_for(clock,power) if entry[0]<0 else entry[0]
		var anchor: Vector2 = ANCHORS[frame] if entry[0]<0 else BANK_ANCHORS[frame]
		var offset := (CELL*0.5-anchor)*destination.size/CELL
		var color := tint
		color.a *= entry[1]
		canvas.draw_texture_rect_region(ATLAS if entry[0]<0 else BANKS,Rect2(destination.position+offset,destination.size),region(frame),color)

# v0.40.0 · CodexAI. Real bank views; the mechanical atlas remains the level/door source.
const BANKS = preload("res://assets/vehicles/aerodyne/banks.png")
const BANK_ANCHORS: Array[Vector2] = [Vector2(266,256),Vector2(249,256),Vector2(228,256),Vector2(265,256),Vector2(240,256),Vector2(228,256)]
const BANK_NOZZLES := [
	[Vector2(290,418),Vector2(365,445)],
	[Vector2(211,441),Vector2(337,446)],
	[Vector2(151,442),Vector2(302,442)],
	[Vector2(184,445),Vector2(332,431)],
	[Vector2(164,445),Vector2(237,419)],
	[Vector2(151,442),Vector2(302,442)],
]
# -1 denotes the existing mechanical hull. Discrete pixel phases retain solid opacity.
static func layers(bank: float, braking: float = 0.0) -> Array:
	var strength := clampf(absf(bank),0,1)
	if strength<0.18: return [[5 if braking>0.55 else -1,1.0]]
	var soft := 1 if bank<0 else 3
	var hard := 0 if bank<0 else 4
	return [[hard if strength>0.65 else soft,1.0]]

static func nozzles(bank: float, braking: float = 0.0) -> Array[Vector2]:
	var result: Array[Vector2] = [Vector2.ZERO,Vector2.ZERO]
	for entry in layers(bank,braking):
		for i in 2:
			var contact: Vector2 = NOZZLES[i] if entry[0]<0 else (BANK_NOZZLES[entry[0]][i]-BANK_ANCHORS[entry[0]])*240.0/512.0
			result[i] += contact*entry[1]
	return result
