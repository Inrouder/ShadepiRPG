extends Node2D
## v0.29.0 · CodexAI: source-pixel tableaux anchored to chair / mattress.
const ART = preload("res://assets/story/sanctuary/poses.png")
const ROOM = preload("res://assets/world/painted/compensator.png")
const FLOW = preload("res://assets/memories/legacy/transfer.png")
const SEAT := Vector2(514, 320)
const BEDSIDE := Vector2(604, 322)
const DOOR := Vector2(735, 320)
const APPROACH := Vector2(550, 340)
const ENTRY := Vector2(727, 356)
const ANCHORS := [Vector2(421, 491), Vector2(330, 491), Vector2(330, 491), Vector2(372, 476)]
var sprite: Sprite2D
var flow: Sprite2D
var door: Sprite2D
var frame_index := 0
var transfer_power := 0.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	flow = Sprite2D.new()
	flow.texture = FLOW
	flow.hframes = 4
	flow.vframes = 2
	flow.scale = Vector2(0.22, 0.12)
	flow.position = Vector2(14, -42)
	flow.hide()
	add_child(flow)
	door = Sprite2D.new()
	var texture := AtlasTexture.new()
	texture.atlas = ROOM
	texture.region = Rect2(1230, 240, 285, 266)
	door.texture = texture
	door.scale = Vector2.ONE * 0.29
	door.position = DOOR + Vector2(0, -57) - SEAT
	add_child(door)
	set_pose(0)

func set_pose(index: int) -> void:
	frame_index = index
	var texture := AtlasTexture.new()
	texture.atlas = ART
	texture.region = Rect2((index % 2) * 768, (index / 2) * 512, 768, 512)
	sprite.texture = texture
	var factor := 0.105 if index == 3 else 0.14
	sprite.scale = Vector2.ONE * factor
	sprite.position = (Vector2(384, 256) - ANCHORS[index]) * factor
	position = SEAT
	if index == 3: sprite.position += Vector2(604, 269) - SEAT
	flow.hide()
	transfer_power = 0.0

func show_room(inside: bool) -> void:
	position = SEAT
	set_pose(0)
	sprite.visible = inside
	door.visible = not inside
	show()

func transfer_step(k: float) -> void:
	transfer_power = maxf(0.0, sin(clampf(k, 0.0, 1.0) * PI))
	flow.visible = k > 0.0 and k < 1.0
	flow.frame = mini(7, int(k * 8))
	flow.modulate = Color(1, 1, 1, transfer_power)
	sprite.modulate = Color(1 + transfer_power * 0.8, 1 + transfer_power * 0.8, 1 + transfer_power * 0.8)
	queue_redraw()

func _draw() -> void:
	# Brief white eye glimmer on Raven's position in the paired source pose.
	if transfer_power > 0.0:
		draw_circle(Vector2(29, -57), 1.4, Color(1, 1, 1, transfer_power))
