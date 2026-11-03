class_name PixelActor
extends CharacterBody2D

var visual: Sprite2D
var facing := Vector2.DOWN
var animation_time := 0.0
var animation_name := "idle"
var flash_time := 0.0
var body_material: ShaderMaterial
var world: Node2D

func setup(texture: Texture2D, game: Node2D) -> void:
	world = game
	collision_layer = 2
	collision_mask = 1
	var collider := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 7.0
	collider.shape = shape
	add_child(collider)
	visual = Sprite2D.new()
	visual.texture = texture
	visual.hframes = 8
	visual.vframes = 16
	visual.position = Vector2(0, -26)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body_material = ShaderMaterial.new()
	body_material.shader = preload("res://shaders/cloak.gdshader")
	visual.material = body_material
	add_child(visual)

func animate(state: String, delta: float) -> void:
	if state != animation_name:
		animation_time = 0.0
		animation_name = state
	animation_time += delta
	flash_time = maxf(0.0, flash_time - delta)
	body_material.set_shader_parameter("flash", clampf(flash_time * 6.0, 0.0, 1.0))
	var direction := 0
	if absf(facing.x) > absf(facing.y):
		direction = 2 if facing.x > 0 else 1
	elif facing.y < 0:
		direction = 3
	var row: int = {"idle": 0, "walk": 1, "attack": 2, "hurt": 3}.get(state, 0)
	var speed := 18.0 if state == "attack" else 9.0
	var frame := mini(7, int(animation_time * speed)) if state == "attack" else int(animation_time * speed) % 8
	visual.frame = (row * 4 + direction) * 8 + frame
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()

func draw_ellipse_shadow() -> void:
	draw_style_box(_shadow_style(), Rect2(-10, -2, 20, 5))

func _shadow_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.06, 0.55)
	style.set_corner_radius_all(4)
	return style
