extends Node2D
## v0.65.1 · CodexAI. Real side-profile source, with horizontal registered exhaust.
const ATLAS = preload("res://assets/vehicles/aerodyne/side-flight.png")
const FLAMES = preload("res://assets/memories/attack/props-fx.png")
const EXHAUST = preload("res://shaders/cinematic_exhaust.gdshader")
const CELL := Vector2(768,512)
const ANCHORS: Array[Vector2] = [Vector2(384,256),Vector2(384,256),Vector2(384,256),Vector2(384,256)]
const NOZZLES: Array[Vector2] = [Vector2(89,207),Vector2(91,305)]
const UNIT := 240.0/768.0
var hull: Sprite2D
var plumes: Array[Sprite2D] = []
var frame := 0
func _ready():
	for i in 2:
		var plume:=Sprite2D.new()
		plume.texture=FLAMES; plume.centered=false
		plume.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
		var shader:=ShaderMaterial.new(); shader.shader=EXHAUST
		shader.set_shader_parameter("flame_atlas",FLAMES); shader.set_shader_parameter("seed",i*0.47)
		plume.material=shader; add_child(plume); plumes.append(plume)
	hull=Sprite2D.new(); hull.texture=ATLAS; hull.hframes=2; hull.vframes=2
	hull.scale=Vector2.ONE*UNIT; hull.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(hull)
func set_pose(power: float,clock: float):
	frame=posmod(int(clock*4),4) if power>0.001 else 0
	hull.frame=frame; hull.position=(CELL*0.5-ANCHORS[frame])*UNIT
	for i in plumes.size():
		var plume:=plumes[i]
		var width:=16.0
		plume.rotation=PI*0.5 # positive Y exhaust becomes negative X, behind the right-facing nose.
		plume.position=(NOZZLES[i]-ANCHORS[frame])*UNIT+Vector2(2,-width*0.5)
		plume.scale=Vector2(width,lerpf(22,60,power)*(1+0.035*sin(clock*9+i)))/Vector2(FLAMES.get_size())
		plume.visible=power>0.001
		plume.material.set_shader_parameter("clock",clock); plume.material.set_shader_parameter("strength",power)
