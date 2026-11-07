extends Control
## Small animated light accents; draw behind interactive menu contents.
var elapsed := 0.0
var strength := 1.0
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(func(): set_process(is_visible_in_tree()))
func _process(delta: float) -> void:
	if not is_visible_in_tree() or strength == 0: return
	elapsed += delta * strength
	queue_redraw()
func _draw() -> void:
	var cyan := Color("62dde8")
	var pink := Color("ee648f")
	# Architectural corners echo the terminals and armor panels.
	for point in [Vector2(0, 0), Vector2(size.x, size.y)]:
		var sign_dir := 1.0 if point == Vector2.ZERO else -1.0
		draw_line(point, point + Vector2(24, 0) * sign_dir, cyan, 1.5, true)
		draw_line(point, point + Vector2(0, 18) * sign_dir, cyan, 1.5, true)
	draw_line(Vector2(16, 91), Vector2(size.x - 16, 91), Color(cyan, 0.22), 0.7, true)
	for i in 17:
		var alpha := 0.12 + 0.45 * pow(maxf(0, sin(elapsed * 0.8 - i * 0.24)), 6)
		draw_line(Vector2(18+i*4, 91), Vector2(20+i*4, 91), Color(cyan, alpha), 1, true)
	draw_line(Vector2(size.x - 22, 12), Vector2(size.x - 10, 12), pink, 2, true)
