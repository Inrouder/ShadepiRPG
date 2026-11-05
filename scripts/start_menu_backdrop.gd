extends Control

const CITY := preload("res://assets/menu/start-city.png")

var elapsed := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	queue_redraw()

func _draw() -> void:
	var drift := sin(elapsed * 0.075) * 4.0
	var lift := cos(elapsed * 0.06) * 2.0
	draw_texture_rect(CITY, Rect2(-7.0 + drift, -4.0 + lift, 654.0, 368.0), false)

	# Moving fog and distant traffic keep the title screen alive without hiding the artwork.
	for i in 5:
		var fog_x := fposmod(elapsed * (4.0 + i) + i * 151.0, 780.0) - 100.0
		var fog_y := 171.0 + i * 25.0 + sin(elapsed * 0.21 + i) * 7.0
		draw_circle(Vector2(fog_x, fog_y), 42.0 + i * 7.0, Color(0.34, 0.56, 0.68, 0.018))
	for i in 7:
		var car_x := fposmod(elapsed * (18.0 + i * 2.0) + i * 103.0, 720.0) - 40.0
		var car_y := 214.0 + float((i * 29) % 103)
		var color := Color(0.30, 0.88, 1.0, 0.36) if i % 2 == 0 else Color(1.0, 0.22, 0.65, 0.34)
		draw_line(Vector2(car_x, car_y), Vector2(car_x + 11.0, car_y - 1.0), color, 1.0)

	# Fine rain falls at different speeds; each streak wraps deterministically.
	for i in 72:
		var rain_x := fposmod(i * 83.0 + elapsed * (72.0 + float(i % 5) * 13.0), 690.0) - 25.0
		var rain_y := fposmod(i * 47.0 + elapsed * (125.0 + float(i % 7) * 9.0), 405.0) - 25.0
		var rain_alpha := 0.06 + float(i % 4) * 0.018
		draw_line(Vector2(rain_x, rain_y), Vector2(rain_x - 2.5, rain_y + 10.0), Color(0.61, 0.84, 0.95, rain_alpha), 1.0)

	var dragon_pulse := 0.025 + (sin(elapsed * 1.25) + 1.0) * 0.012
	draw_circle(Vector2(261.0 + drift, 73.0 + lift), 52.0, Color(0.76, 0.93, 1.0, dragon_pulse))
	for x in range(372, 640, 8):
		var alpha := 0.12 * float(x - 372) / 268.0
		draw_rect(Rect2(x, 0, 9, 360), Color(0.015, 0.028, 0.052, alpha))
	for y in range(0, 360, 3):
		draw_line(Vector2(0, y), Vector2(640, y), Color(0.02, 0.05, 0.08, 0.035), 1.0)

