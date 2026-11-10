extends Node2D
## v0.49.0 · CodexAI. Eight registered contact frames; original heroes stay unchanged.
const ART = preload("res://assets/story/lake/poses-moon.png")
const CONTACT = preload("res://shaders/lake_contact.gdshader")
const CELL := Vector2(443.5,443.5)
const ANCHOR := Vector2(200,423)
const SCALE := 58.0/408.0
const RAVEN_OFFSET := Vector2(20,0)
const KEY_FRAMES := [0,3,4,7]
var sprite: Sprite2D
var atlas: AtlasTexture
var material_pose: ShaderMaterial
var pose := 0
var target_pose := 0
var source_frame := 0
var transitioning := false
var hold_clock := 0.0

static func region(frame: int) -> Rect2:
	var x0 := roundi((frame%4)*1774.0/4.0)
	var x1 := roundi((frame%4+1)*1774.0/4.0)
	var y0 := 0 if frame<4 else 444
	return Rect2(x0,y0,x1-x0,444 if frame<4 else 443)

func _ready() -> void:
	sprite = Sprite2D.new()
	atlas = AtlasTexture.new()
	atlas.atlas = ART
	atlas.filter_clip = true
	sprite.texture = atlas
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE*SCALE
	material_pose = ShaderMaterial.new()
	material_pose.shader = CONTACT
	sprite.material = material_pose
	add_child(sprite)
	set_pose(0)
	hide()

func _frame(value: int) -> void:
	source_frame = clampi(value,0,7)
	atlas.region = region(source_frame)
	sprite.position = (atlas.region.size*0.5-ANCHOR)*SCALE

func set_pose(index: int) -> void:
	pose = clampi(index,0,3)
	target_pose = pose
	transitioning = false
	hold_clock = 0
	_frame(KEY_FRAMES[pose])
	queue_redraw()

func _process(delta: float) -> void:
	if not is_visible_in_tree() or transitioning or pose!=2:return
	var parent := get_parent()
	if parent.has_method("paused") and parent.paused():return
	hold_clock += delta
	_frame(4+posmod(int(hold_clock*2.0),2))

func transition(cs, index: int, seconds: float = 0.5) -> void:
	var ticket: int = cs.generation
	target_pose = clampi(index,0,3)
	var first := source_frame
	var last: int = KEY_FRAMES[target_pose]
	transitioning = true
	await cs.animate(func(p: float):
		_frame(first+roundi((last-first)*p))
	,seconds)
	transitioning = false
	if not cs.alive(ticket):return
	set_pose(target_pose)

func _draw() -> void:
	for foot in [Vector2.ZERO,RAVEN_OFFSET]:
		draw_set_transform(foot+Vector2(0,1),0,Vector2(1,0.25))
		draw_circle(Vector2.ZERO,10,Color(0,0,0,0.3))
	draw_set_transform(Vector2.ZERO)
