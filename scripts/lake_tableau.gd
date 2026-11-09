extends Node2D
## v0.36.0 · CodexAI. Contact poses preserve the original bodies and face privacy.
const ART = preload("res://assets/story/lake/poses.png")
const BLEND = preload("res://shaders/lake_pose_blend.gdshader")
const CELL := Vector2(768,512)
const ANCHOR := Vector2(300,488)
const SCALE := 0.125
const RAVEN_OFFSET := Vector2(20,0)
var sprite: Sprite2D
var material_pose: ShaderMaterial
var pose := 0
var target_pose := 0

func _ready() -> void:
	sprite = Sprite2D.new()
	var source := AtlasTexture.new()
	source.atlas = ART
	source.region = Rect2(Vector2.ZERO,CELL)
	source.filter_clip = true
	sprite.texture = source
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sprite.scale = Vector2.ONE*SCALE
	sprite.position = (CELL*0.5-ANCHOR)*SCALE
	material_pose = ShaderMaterial.new()
	material_pose.shader = BLEND
	material_pose.set_shader_parameter("sheet",ART)
	sprite.material = material_pose
	add_child(sprite)
	set_pose(0)
	hide()

func set_pose(index: int) -> void:
	pose = clampi(index,0,3)
	target_pose = pose
	var cell := Vector2(pose%2,pose/2)
	material_pose.set_shader_parameter("pose_a",cell)
	material_pose.set_shader_parameter("pose_b",cell)
	material_pose.set_shader_parameter("blend",0.0)
	queue_redraw()

func transition(cs, index: int, seconds: float = 0.5) -> void:
	var ticket: int = cs.generation
	target_pose = clampi(index,0,3)
	material_pose.set_shader_parameter("pose_b",Vector2(target_pose%2,target_pose/2))
	await cs.animate(func(p: float): material_pose.set_shader_parameter("blend",p),seconds)
	if not cs.alive(ticket): return
	set_pose(target_pose)

func _draw() -> void:
	for foot in [Vector2.ZERO,RAVEN_OFFSET]:
		draw_set_transform(foot+Vector2(0,1),0,Vector2(1,0.25))
		draw_circle(Vector2.ZERO,11,Color(0,0,0,0.25))
	draw_set_transform(Vector2.ZERO)
