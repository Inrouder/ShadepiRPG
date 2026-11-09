extends Node2D
## v0.32.0 · CodexAI: game-matched materials, stable chair and mattress anchors.
const ART = preload("res://assets/story/sanctuary/poses-game.png")
const ROOM = preload("res://assets/world/painted/compensator-clear.png")
const FLOW = preload("res://assets/memories/legacy/transfer.png")
const SEAT := Vector2(514, 320)
const BEDSIDE := Vector2(604, 322)
const DOOR := Vector2(750, 316)
const APPROACH := Vector2(549, 319)
const ENTRY := Vector2(727, 356)
const RAVEN_EYE := Vector2(18.5, -54)
const ANCHORS := [Vector2(242, 506), Vector2(187, 506), Vector2(180, 506), Vector2(218, 468), Vector2(230, 353), Vector2(245, 358)]
const REGIONS := [Rect2(0, 0, 512, 512), Rect2(512, 0, 512, 512), Rect2(1024, 0, 512, 512), Rect2(0, 512, 410, 512), Rect2(472, 512, 552, 512), Rect2(1024, 512, 512, 512)]
var sprite: Sprite2D
var flow: Sprite2D
var door: Node2D
var speech: Node2D
var frame_index := 0
var transfer_power := 0.0

func _ready() -> void:
	sprite = Sprite2D.new()
	# The regular heroes use the same sampling when reduced below native size.
	# This source has genuine transparency; do not force edge pixels opaque.
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	flow = Sprite2D.new()
	flow.texture = FLOW
	flow.hframes = 4
	flow.vframes = 2
	flow.scale = Vector2(0.22, 0.12)
	flow.position = Vector2(14, -42)
	flow.hide()
	add_child(flow)
	# A location marker only: the doorway is painted into the room itself.
	door = Node2D.new()
	door.position = DOOR - SEAT
	add_child(door)
	speech = preload("res://scripts/world_speech.gd").new()
	add_child(speech)
	set_pose(0)

func set_pose(index: int) -> void:
	frame_index = index
	var texture := AtlasTexture.new()
	texture.atlas = ART
	texture.region = REGIONS[index]
	sprite.texture = texture
	var factor := 0.115 if index >= 3 else 0.145
	sprite.scale = Vector2.ONE * factor
	sprite.modulate = Color.WHITE
	sprite.position = (REGIONS[index].size * 0.5 - ANCHORS[index]) * factor
	position = SEAT
	if index >= 3: sprite.position += Vector2(604, 269 if index == 3 else 246) - SEAT
	flow.hide()
	transfer_power = 0.0
	queue_redraw()

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
		draw_circle(RAVEN_EYE, 1.4, Color(1, 1, 1, transfer_power))
