extends Sprite2D
## v0.66.0 · CodexAI. A continuously moving bike behind the garage facade, never spawned inside it.
var world: Node2D
func _ready():
	texture=world.VEHICLES
	region_enabled=true; region_rect=Rect2(0,627,627,627)
	scale=Vector2.ONE*(78.0/627.0)
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	var clip:=ShaderMaterial.new(); clip.shader=preload("res://shaders/garage_arrival.gdshader")
	material=clip
	sync()
func _process(_delta: float): sync()
func sync():
	visible=world.beat==world.Beat.GARAGE and world.bike_mode in ["approach","ride"]
	position=world.bike_pos; rotation=world.bike_rot
	material.set_shader_parameter("opening_top",world.GARAGE_DOOR.end.y-world.GARAGE_DOOR.size.y*world.garage_door)

	material.set_shader_parameter("outside_only",world.bike_mode=="approach")
