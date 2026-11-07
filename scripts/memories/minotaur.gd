extends PixelActor
## Atlas scale remains constant when the mech collapses; the wreck persists.
const ART = preload("res://assets/memories/sacrifice/minotaur.png")
const FOOTPRINT := Rect2(-53,-14,106,28)
static var frames: Array = []
var atlas: AtlasTexture
var destroyed := false
var frame_index := 0
var identity := "minotaur"
func prepare(game: Node2D) -> void:
	if frames.is_empty(): frames=JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/sacrifice/actors.json")).minotaur
	setup(preload("res://assets/sprites/heroes/shadepi.png"),game)
	var shape := RectangleShape2D.new()
	shape.size=FOOTPRINT.size
	get_child(0).shape=shape
	collision_layer=1
	collision_mask=1
	atlas=AtlasTexture.new()
	set_physics_process(false)
	facing=Vector2.LEFT
	animate("idle",0)
func animate(state: String,delta: float) -> void:
	if destroyed: state="wreck"
	if animation_name!=state: animation_time=0
	animation_name=state
	animation_time+=delta
	frame_index = {"idle":0,"guard":0,"hurt":4,"critical":5,"collapse":6,"wreck":7}.get(state,0)
	if state=="walk": frame_index=1+int(animation_time*5)%2
	if state=="fire": frame_index=3 if animation_time<0.12 else 0
	var pose: Dictionary=frames[frame_index]
	var rect: Array=pose.region
	atlas.atlas=ART
	atlas.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	visual.texture=atlas
	visual.hframes=1
	visual.vframes=1
	visual.frame=0
	visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	visual.scale=Vector2.ONE*float(pose.scale)
	visual.position=(Vector2(rect[2],rect[3])*0.5-Vector2(pose.anchor[0],pose.anchor[1]))*float(pose.scale)
	standing_visual_position=visual.position
	cast_shadow.texture=atlas
	cast_shadow.hframes=1
	cast_shadow.vframes=1
	cast_shadow.frame=0
	cast_shadow.scale=Vector2(1.05,0.25)*float(pose.scale)
	cast_shadow.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()
func weak_point() -> Vector2: return position+Vector2(30,-34)
func muzzle() -> Vector2: return position+Vector2(-66,-81)
func disable() -> void:
	destroyed=true
	collision_layer=0
	collision_mask=0
	animate("wreck",0)
