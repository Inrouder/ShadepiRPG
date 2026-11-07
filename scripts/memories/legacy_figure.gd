extends Node2D
## Source atlas tableau: supporting the master, receiving, resting, collapse.
const ART = preload("res://assets/memories/legacy/characters.png")
static var frames: Array = []
var sprite: Sprite2D
var frame_index := 2
func _ready() -> void:
	if frames.is_empty(): frames=JSON.parse_string(FileAccess.get_file_as_string("res://assets/memories/legacy/actors.json")).figures
	sprite=Sprite2D.new()
	sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	set_frame(frame_index)
func set_frame(index: int) -> void:
	frame_index=index
	var data: Dictionary=frames[index]
	var rect: Array=data.region
	var texture:=AtlasTexture.new()
	texture.atlas=ART
	texture.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	sprite.texture=texture
	sprite.scale=Vector2.ONE*float(data.scale)
	sprite.position=(Vector2(rect[2],rect[3])*0.5-Vector2(data.anchor[0],data.anchor[1]))*float(data.scale)
