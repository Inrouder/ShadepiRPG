extends Node2D
## v0.37.0 · CodexAI. Registered hull frames and exhaust share one transform.
const Art = preload("res://scripts/aerodyne_art.gd")
const FLAMES = preload("res://assets/memories/attack/props-fx.png")
const EXHAUST = preload("res://shaders/cinematic_exhaust.gdshader")
const NOZZLES = Art.NOZZLES
var pivot: Node2D
var hull: Sprite2D
var plumes: Array[Sprite2D] = []
var power := 0.0
var roll := 0.0
var door := 0.0
var clock := 0.0

func _ready() -> void:
	pivot = Node2D.new()
	add_child(pivot)
	for i in 2:
		var plume := Sprite2D.new()
		plume.texture = FLAMES
		plume.centered = false
		plume.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var shader := ShaderMaterial.new()
		shader.shader = EXHAUST
		shader.set_shader_parameter("flame_atlas", FLAMES)
		shader.set_shader_parameter("seed", i*0.47)
		plume.material = shader
		pivot.add_child(plume)
		plumes.append(plume)
	hull = Sprite2D.new()
	hull.texture = Art.ATLAS
	hull.hframes = 3
	hull.vframes = 2
	hull.scale = Vector2.ONE*(240.0/512.0)
	hull.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pivot.add_child(hull)
	set_pose(Vector2.ZERO,1,0,0,0)

func set_door(amount: float) -> void:
	door = clampf(amount,0,1)
	_update_hull()

func _update_hull() -> void:
	if hull==null: return
	hull.frame = Art.frame_for(clock,power,door)
	hull.position = (Art.CELL*0.5-Art.ANCHORS[hull.frame])*(240.0/512.0)

func set_pose(center: Vector2, grow: float, tilt: float, thrust: float, scene_clock: float) -> void:
	position = center
	scale = Vector2.ONE*grow
	roll = tilt
	power = clampf(thrust,0,1)
	clock = scene_clock
	if pivot == null: return
	_update_hull()
	pivot.transform = Transform2D(0.0,Vector2(1.0,0.6),0.0,Vector2.ZERO)*Transform2D(tilt,Vector2.ZERO)
	for i in plumes.size():
		var length := lerpf(30,82,power)*(1.0+0.035*sin(clock*9+i))
		plumes[i].position = NOZZLES[i]+Vector2(-17,-3)
		plumes[i].scale = Vector2(34,length)/Vector2(FLAMES.get_size())
		plumes[i].visible = power>0.001
		plumes[i].material.set_shader_parameter("clock",clock)
		plumes[i].material.set_shader_parameter("strength",power)
