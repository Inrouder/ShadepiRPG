extends Node2D
## v0.35.0 · CodexAI. Hull and exhaust share the exact source-pixel transform.
const HULL = preload("res://assets/world/hq/vehicles.png")
const FLAMES = preload("res://assets/memories/attack/props-fx.png")
const EXHAUST = preload("res://shaders/cinematic_exhaust.gdshader")
# Source nozzle centers (214,550), (421,550) in the 627×627 vehicle cell.
const NOZZLES: Array[Vector2] = [Vector2(-38.1,90.5),Vector2(41.1,90.5)]
var pivot: Node2D
var plumes: Array[Sprite2D] = []
var power := 0.0
var roll := 0.0

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
	var hull := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = HULL
	atlas.region = Rect2(0,0,627,627)
	atlas.filter_clip = true
	hull.texture = atlas
	hull.scale = Vector2.ONE*(240.0/627.0)
	hull.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pivot.add_child(hull)
	set_pose(Vector2.ZERO,1,0,0,0)

func set_pose(center: Vector2, grow: float, tilt: float, thrust: float, clock: float) -> void:
	position = center
	scale = Vector2.ONE*grow
	roll = tilt
	power = clampf(thrust,0,1)
	if pivot == null: return
	pivot.transform = Transform2D(0.0,Vector2(1.0,0.6),0.0,Vector2.ZERO)*Transform2D(tilt,Vector2.ZERO)
	for i in plumes.size():
		var length := lerpf(30,82,power)*(1.0+0.035*sin(clock*9+i))
		plumes[i].position = NOZZLES[i]+Vector2(-17,-3)
		plumes[i].scale = Vector2(34,length)/Vector2(FLAMES.get_size())
		plumes[i].visible = power>0.001
		plumes[i].material.set_shader_parameter("clock",clock)
		plumes[i].material.set_shader_parameter("strength",power)
