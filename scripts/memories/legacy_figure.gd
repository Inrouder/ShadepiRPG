extends Node2D
## Source atlas tableau: supporting the master, receiving, resting, collapse.
const ART = preload("res://assets/memories/legacy/characters.png")
const DEATH_ART = preload("res://assets/memories/legacy/master-death.png")
static var frames: Array = []
static var death_frames: Array = []
var sprite: Sprite2D
var frame_index := 2
var frame_source := "figures"
var master_deceased := false
var corpse_locked := false
func _ready() -> void:
	if frames.is_empty(): frames=JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/legacy/actors.json")).figures
	if death_frames.is_empty(): death_frames=JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/legacy/actors.json")).master_death
	sprite=Sprite2D.new()
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	set_frame(frame_index)
func set_frame(index: int) -> void:
	if corpse_locked: return
	frame_index=index
	frame_source="figures"
	master_deceased=false
	_display(frames[index],ART)
func set_death_frame(index: int) -> void:
	frame_index=index
	frame_source="master_death"
	master_deceased=true
	if index>=2: corpse_locked=true
	_display(death_frames[index],DEATH_ART)
func _display(data: Dictionary, art: Texture2D) -> void:
	var rect: Array=data.region
	var texture:=AtlasTexture.new()
	texture.atlas=art
	texture.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	sprite.texture=texture
	sprite.scale=Vector2.ONE*float(data.scale)
	sprite.position=(Vector2(rect[2],rect[3])*0.5-Vector2(data.anchor[0],data.anchor[1]))*float(data.scale)
