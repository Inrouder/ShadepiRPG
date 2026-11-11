extends StaticBody2D
## v0.57.0 · ClaudeHelper: Arcade-Automat „NEON KOMBAT“ in der Halle des Ordens.
## Steht auf seinem Fußpunkt (y-sortiert), blockiert den Weg und flimmert leicht.
const ART = preload("res://assets/arcade/cabinet.png")
const USE_POINT := Vector2(0, 16)        # Standpunkt davor, relativ zum Fußpunkt
var clock := 0.0
var world: Node

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(36, 12)
	shape.shape = box
	shape.position = Vector2(0, -6)
	add_child(shape)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	clock += delta
	# Während der Enthüllungsszene der Halle zeigt das Spiel ein eigenes Bild.
	if is_instance_valid(world): visible = not is_instance_valid(world.get("hangar_discovery"))
	queue_redraw()

func _draw() -> void:
	# Bodenschatten und Bildschirmschein auf dem Hallenboden.
	draw_rect(Rect2(-20, -4, 42, 7), Color(0, 0, 0, 0.4))
	var glow := 0.5 + 0.5 * sin(clock * 5.0) * sin(clock * 1.7)
	for i in 3:
		draw_rect(Rect2(-14 + i * 2, 3 + i * 4, 28 - i * 4, 4), Color(1.0, 0.25, 0.6, (0.16 - i * 0.045) * (0.7 + 0.3 * glow)))
	draw_texture_rect(ART, Rect2(-22, -66, 44, 68), false)
	# Laufzeile im Leuchtschild und flackernder Bildschirm.
	draw_rect(Rect2(-10, -48, 26, 18), Color(0.4, 0.9, 1.0, 0.07 + 0.05 * glow))
	draw_rect(Rect2(-11.0 + fposmod(clock * 9.0, 26.0), -59, 2, 6), Color(1, 1, 1, 0.5))
