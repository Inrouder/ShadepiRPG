extends Node2D

const VIRUS_ART: Texture2D = preload("res://assets/sprites/npcs/dive-virus.png")
const GUARDIAN_ART: Texture2D = preload("res://assets/sprites/npcs/ice-guardian.png")

var world: Node2D
var guardian: = false
var elapsed: = 0.0
var direction: = Vector2.ZERO
var hit: = false
var age: = 0.0
var patrol_y: = 0.0
var visual: Sprite2D
var visual_elapsed := 0.0
var visual_scale := 1.0
## A charged shot cracks the shell: briefly vulnerable, knocked back, attack reset.
var cracked := 0.0
var knock := Vector2.ZERO
var flash := 0.0

func _ready() -> void:
	visual = Sprite2D.new()
	visual.texture = GUARDIAN_ART if guardian else VIRUS_ART
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	# Keep virus warning rings above the artwork; guardian overrides its phases.
	visual.show_behind_parent = true
	var diameter := 72.0 if guardian else 48.0
	visual_scale = diameter / float(maxi(visual.texture.get_width(), visual.texture.get_height()))
	visual.scale = Vector2.ONE * visual_scale
	add_child(visual)
	_update_visual()

func _update_visual() -> void:
	if visual == null:
		return
	visual.scale = Vector2.ONE * visual_scale * (1.0 + sin(visual_elapsed * 3.0) * 0.035)
	visual.rotation = sin(visual_elapsed * 1.7) * (0.035 if guardian else 0.09)
	visual.modulate = Color(2.2, 2.2, 2.2) if flash > 0.0 else (Color(0.74, 1.0, 1.0) if vulnerable() else Color.WHITE)

func _process(delta: float) -> void :
	if world.is_busy():
		return
	visual_elapsed += delta
	cracked = maxf(0.0, cracked - delta)
	flash = maxf(0.0, flash - delta)
	if knock.length() > 1.0:
		_move(knock * delta)
		knock = knock.move_toward(Vector2.ZERO, 520.0 * delta)
	elapsed += delta
	var target: Vector2 = world.raven.position
	if elapsed < 0.85:
		direction = position.direction_to(target)
		_move(position.direction_to(target) * minf(delta * 45.0, position.distance_to(target)))
	elif elapsed < 1.18:
		if not _move(direction * delta * 195.0):
			elapsed = 1.18
		if not hit and position.distance_to(target) < 18.0:
			hit = true
			world.raven.take_damage(22, position)
	elif elapsed >= 2.15:
		elapsed = 0.0
		hit = false
	_update_visual()
	queue_redraw()

## Moves while respecting the data-space walls; returns false when blocked.
func _move(step: Vector2) -> bool:
	var wanted := position + step
	var next := wanted.clamp(Vector2(25, 265), Vector2(998, 477))
	if not world.has_method("dive_blocked") or not world.dive_blocked(next, 12.0):
		position = next
		return next == wanted
	# Slide along the wall on the free axis instead of passing through it.
	for slide: Vector2 in [Vector2(step.x, 0), Vector2(0, step.y)]:
		var alt: Vector2 = (position + slide).clamp(Vector2(25, 265), Vector2(998, 477))
		if slide.length() > 0.01 and not world.dive_blocked(alt, 12.0):
			position = alt
			return false
	return false

func crack(from: Vector2) -> void:
	cracked = 1.6
	flash = 0.12
	knock = (position - from).normalized() * 160.0
	if not guardian:
		elapsed = 1.18
		hit = true

func vulnerable() -> bool:
	return cracked > 0.0 or elapsed >= 1.18

func _draw() -> void :
	var radius: = 17.0 if guardian else 10.0
	var glow: = Color("58eaff") if vulnerable() else Color("b992ff")
	draw_circle(Vector2.ZERO, radius + 5.0, Color(glow, 0.25))
	if cracked > 0.0:
		for i in 4:
			var a := i * PI * 0.5 + 0.4
			draw_line(Vector2.from_angle(a) * 4.0, Vector2.from_angle(a + 0.3) * (radius + 3.0), Color("e6fbff"), 1.5)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 22, glow, 2.0)
	if elapsed < 0.85:
		draw_line(Vector2.ZERO, direction * 28.0, Color(glow, 0.5))
