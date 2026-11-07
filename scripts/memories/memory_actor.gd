extends PixelActor
## Reference-based atlas cells are displayed without rewriting or smoothing pixels.
const READY = preload("res://assets/memories/attack/warriors-ready.png")
const RUN = preload("res://assets/memories/attack/warriors-run.png")
const PEOPLE = preload("res://assets/memories/attack/residents.png")
const BOT = preload("res://assets/memories/attack/bots.png")
const WALK = preload("res://assets/memories/attack/residents-walk.png")
const COMBAT = preload("res://assets/memories/attack/combat.png")
const COMBAT_COLUMNS := {"guard":0,"windup":1,"strike":2,"shoot":2,"recover":3,"hurt":4,"kneel":5,"fall":6,"dead":7}
static var catalog: Dictionary = {}
var identity := "oni"
var frame_key := ""
var image_region: AtlasTexture
var last_foot := Vector2.ZERO
var fallen := false
var gait_offset := 0

func prepare(id: String, game: Node2D) -> void:
	identity = id
	gait_offset = get_index()%4
	setup(preload("res://assets/sprites/heroes/shadepi.png"),game)
	set_physics_process(false)
	if id == "shadepi":
		visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		return
	if catalog.is_empty():
		catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/attack/actors.json"))
	image_region = AtlasTexture.new()
	animate("idle",0)

func animate(state: String, delta: float) -> void:
	if fallen: state = "dead"
	if identity == "shadepi":
		super.animate(state,delta)
		return
	if state != animation_name: animation_time = 0.0
	animation_time += delta
	animation_name = state
	var data: Dictionary = catalog[identity]
	var pose: Dictionary
	var texture: Texture2D
	var flip := false
	if COMBAT_COLUMNS.has(state) and data.has("combat"):
		var column: int = COMBAT_COLUMNS[state]
		if state=="shoot": column = 2 if animation_time<0.08 else 3 if animation_time<0.22 else 0
		if state=="recover" and animation_time>0.22: column = 0
		pose = data.combat[column]
		texture = COMBAT
		flip = facing.x < 0
		frame_key = "combat_%d"%column
	elif data.has("civilian"):
		var column := (2 if facing.x>0 else 1) if absf(facing.x)>absf(facing.y) else (3 if facing.y<0 else 0)
		if state == "walk":
			column = column*4 + (int(animation_time*9)+gait_offset)%4
			pose = data.walk_cycle[column]
			texture = WALK
			frame_key = "walk_cycle_%d"%column
		else:
			pose = data.civilian[column]
			texture = PEOPLE
			frame_key = "civilian_%d"%column
	else:
		var octant := posmod(roundi(facing.angle()/(PI/4)),8)
		var direction: int = OCTANT_ROWS[octant]
		var key := "idle"
		if state == "walk": key = ["run_a","run_b"][int(animation_time*8)%2]
		if state == "attack" and data.has("attack"): key = "attack"
		pose = data[key][direction]
		texture = BOT if identity=="bot" else READY if key=="idle" else RUN
		frame_key = "%s_%d"%[key,direction]
	apply_pose(pose,texture,flip)

func apply_pose(pose: Dictionary, texture: Texture2D, flip: bool = false) -> void:
	var rect: Array = pose.region
	image_region.atlas = texture
	image_region.region = Rect2(rect[0],rect[1],rect[2],rect[3])
	visual.texture = image_region
	visual.hframes = 1
	visual.vframes = 1
	visual.frame = 0
	visual.scale = Vector2.ONE * float(pose.scale)
	visual.flip_h = flip
	var offset := Vector2(rect[2],rect[3])*0.5 - Vector2(pose.anchor[0],pose.anchor[1])
	if flip: offset.x = -offset.x
	visual.position = offset * float(pose.scale)
	standing_visual_position = visual.position
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.modulate = Color(0.65,0.68,0.7) if fallen and identity=="bot" else Color.WHITE
	cast_shadow.texture = image_region
	cast_shadow.hframes = 1
	cast_shadow.vframes = 1
	cast_shadow.frame = 0
	cast_shadow.flip_h = flip
	cast_shadow.scale = Vector2(1.05,0.3) * float(pose.scale)
	last_foot = visual.position + Vector2(-offset.x,-offset.y)*float(pose.scale)
	queue_redraw()
