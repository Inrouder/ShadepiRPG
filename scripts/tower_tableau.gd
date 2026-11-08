extends Node2D
## v0.33.0 · CodexAI: source poses, calibrated to the normal 60 px heroes.
const ART = preload("res://assets/story/tower/kenzo-poses.png")
const REGIONS := [Rect2(0,0,768,512),Rect2(768,0,768,512),Rect2(0,512,768,512),Rect2(768,512,768,512)]
const ANCHORS := [Vector2(480,492),Vector2(384,494),Vector2(344,490),Vector2(390,406)]
const SCALES := [0.135,0.125,0.135,0.10]
const RAVEN_OFFSET := Vector2(-34,5)
var kenzo: Sprite2D
var raven: Sprite2D
var grip: Sprite2D
var mode := "kneel"

func _ready() -> void:
	kenzo = Sprite2D.new()
	raven = Sprite2D.new()
	grip = Sprite2D.new()
	for sprite in [kenzo,raven,grip]:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(sprite)
	_pose(raven,2)
	raven.position += RAVEN_OFFSET
	show_pose("kneel")

func _pose(sprite: Sprite2D, index: int) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = ART
	atlas.region = REGIONS[index]
	atlas.filter_clip = true
	sprite.texture = atlas
	sprite.scale = Vector2.ONE*SCALES[index]
	sprite.position = (REGIONS[index].size*0.5-ANCHORS[index])*SCALES[index]

func show_pose(value: String) -> void:
	mode = value
	grip.visible = value == "grip"
	kenzo.visible = value != "grip"
	raven.visible = value == "extract"
	_pose(grip,0)
	_pose(kenzo,3 if value=="dead" else 1)
	kenzo.modulate = Color(0.62,0.56,0.5) if value=="dead" else Color.WHITE
	raven.modulate = Color.WHITE
	grip.modulate = Color.WHITE
	queue_redraw()

func _draw() -> void:
	var feet: Array[Vector2] = [Vector2.ZERO]
	if mode=="grip": feet.append(Vector2(-30,0))
	if mode=="extract": feet.append(RAVEN_OFFSET)
	for point in feet:
		draw_set_transform(point,0,Vector2(1,0.28))
		draw_circle(Vector2.ZERO,12 if mode=="grip" else 15,Color(0,0,0,0.3))
	draw_set_transform(Vector2.ZERO)
