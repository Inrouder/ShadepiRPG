extends Node2D
## v0.30.0 · CodexAI: an anchored UI bubble identifies off-screen speakers.
var label: Label
var tip := Vector2.ZERO
var box := Rect2(0, 0, 190, 66)
func _ready() -> void:
	z_index = 100
	label = Label.new()
	label.position = Vector2(9, 5)
	label.size = Vector2(172, 56)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color("e7f7fa"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	hide()
func speak(text: String, source: Vector2) -> void:
	global_position = Vector2(clampf(source.x - 170, 250, 590), source.y - 80)
	tip = source - global_position
	label.text = text
	show()
	queue_redraw()
func _draw() -> void:
	draw_rect(box, Color("101b25"))
	draw_rect(box, Color("73cad5"), false, 1)
	var edge := Vector2(clampf(tip.x - 8, 12, 178), box.end.y)
	draw_colored_polygon(PackedVector2Array([edge - Vector2(7, 0), tip, edge + Vector2(7, 0)]), Color("101b25"))
	draw_polyline(PackedVector2Array([edge - Vector2(7, 0), tip, edge + Vector2(7, 0)]), Color("73cad5"), 1)
