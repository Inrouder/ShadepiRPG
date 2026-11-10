class_name PixelActor
extends CharacterBody2D

const OCTANT_ROWS := [2, 7, 0, 6, 1, 4, 3, 5]
const TURN_STEP_TIME := 0.06

var external_pose := false
var reaction: Node2D
var visual: Sprite2D
var facing := Vector2.DOWN
var animation_time := 0.0
var animation_name := "idle"
var flash_time := 0.0
var body_material: ShaderMaterial
var world: Node2D
var cast_shadow: Sprite2D
var shadow_material: ShaderMaterial
var light_occluder: LightOccluder2D
var cloaked := false
var directions := 4
var visual_octant := 2
var turn_time := 0.0
var standing_visual_position := Vector2(0, -26)

func setup(texture: Texture2D, game: Node2D) -> void:
	world = game
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	collider.shape = shape
	add_child(collider)
	var sheet := SpriteAssets.resolve(texture)
	var frame_size := SpriteAssets.frame_size(sheet)
	var display_scale := SpriteAssets.display_scale(sheet)
	directions = int(sheet.get_height() / float(frame_size.y * 4))
	cast_shadow = Sprite2D.new()
	cast_shadow.texture = sheet
	cast_shadow.hframes = 8
	cast_shadow.vframes = directions * 4
	cast_shadow.position = Vector2(8, -5)
	cast_shadow.scale = Vector2(1.05, 0.3) * display_scale
	cast_shadow.skew = -0.65
	shadow_material = ShaderMaterial.new()
	shadow_material.shader = preload("res://shaders/shadow.gdshader")
	cast_shadow.material = shadow_material
	add_child(cast_shadow)
	light_occluder = LightOccluder2D.new()
	light_occluder.sdf_collision = false
	var polygon := OccluderPolygon2D.new()
	polygon.polygon = PackedVector2Array([Vector2(-7, -3), Vector2(-8, -20), Vector2(-4, -35), Vector2(6, -35), Vector2(9, -18), Vector2(7, -3)])
	light_occluder.occluder = polygon
	add_child(light_occluder)
	visual = Sprite2D.new()
	visual.texture = sheet
	visual.hframes = 8
	visual.vframes = directions * 4
	standing_visual_position = Vector2(0, (frame_size.y * 0.5 - SpriteAssets.foot_baseline(sheet)) * display_scale)
	visual.position = standing_visual_position
	visual.scale = Vector2.ONE * display_scale
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if display_scale < 1.0 else CanvasItem.TEXTURE_FILTER_NEAREST
	cast_shadow.texture_filter = visual.texture_filter
	body_material = ShaderMaterial.new()
	body_material.shader = preload("res://shaders/cloak.gdshader")
	visual.material = body_material
	add_child(visual)

func reset_visual_pose() -> void:
	clear_reaction()
	visual.rotation = 0.0
	visual.position = standing_visual_position

func animate(state: String, delta: float) -> void:
	var continuing_walk := state == "walk" and animation_name == "walk"
	if state != animation_name:
		animation_time = 0.0
		animation_name = state
	animation_time += delta
	flash_time = maxf(0.0, flash_time - delta)
	body_material.set_shader_parameter("flash", clampf(flash_time * 6.0, 0.0, 1.0))
	var direction := _direction_row(continuing_walk, delta)
	var row: int = {"idle": 0, "walk": 1, "attack": 2, "hurt": 3}.get(state, 0)
	var speed := 18.0 if state == "attack" else 9.0
	var frame := mini(7, int(animation_time * speed)) if state == "attack" else int(animation_time * speed) % 8
	visual.frame = (row * directions + direction) * 8 + frame
	cast_shadow.frame = visual.frame
	queue_redraw()

func _direction_row(continuing_walk: bool, delta: float) -> int:
	if directions == 4:
		if absf(facing.x) > absf(facing.y):
			return 2 if facing.x > 0.0 else 1
		return 3 if facing.y < 0.0 else 0
	var target := posmod(roundi(facing.angle() / (PI / 4.0)), 8)
	if not continuing_walk:
		visual_octant = target
		turn_time = 0.0
	else:
		turn_time = maxf(0.0, turn_time - delta)
		if turn_time == 0.0 and target != visual_octant:
			var clockwise := posmod(target - visual_octant, 8)
			visual_octant = posmod(visual_octant + (1 if clockwise <= 4 else -1), 8)
			if visual_octant != target:
				turn_time = TURN_STEP_TIME
	return OCTANT_ROWS[visual_octant]

func set_cloaked(value: bool) -> void:
	if value == cloaked:
		return
	cloaked = value
	body_material.set_shader_parameter("cloak", 1.0 if cloaked else 0.0)
	shadow_material.set_shader_parameter("opacity", 0.08 if cloaked else 0.45)
	light_occluder.visible = not cloaked

func show_reaction(index: int, mode: String = "") -> void:
	clear_reaction()
	reaction=preload("res://scripts/actor_reaction.gd").new()
	reaction.actor=self
	reaction.frame=index
	reaction.mode=mode
	add_child(reaction)

func clear_reaction() -> void:
	if is_instance_valid(reaction):
		reaction.release()
		reaction.queue_free()
	reaction=null
	external_pose=false

func _draw() -> void:
	if not external_pose: draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	var opacity := 0.2 if cloaked else 1.0
	draw_texture_rect(preload("res://assets/world/light.png"),Rect2(-11,-2,22,7),false,Color(0.01,0.02,0.04,0.50*opacity))
