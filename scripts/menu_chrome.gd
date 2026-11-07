extends Control
## Animated pixel accents of the menu: a data bar under the title block and a
## blinking status block. Drawn in whole pixels behind the menu contents.
var elapsed := 0.0
var strength := 1.0
var primary := Color("62e3ee")
var accent := Color("ff7fc0")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(func(): set_process(is_visible_in_tree()))

func _process(delta: float) -> void:
	if not is_visible_in_tree() or strength == 0: return
	elapsed += delta * strength
	queue_redraw()

func _draw() -> void:
	# Segmented data bar: 2 px blocks with a light pulse running along it.
	var y := 91
	for i in 60:
		var x := 16 + i * 4
		if x > size.x - 20: break
		var pulse := pow(maxf(0.0, sin(elapsed * 1.6 - i * 0.22)), 8)
		var color := Color(primary, 0.22 + 0.7 * pulse)
		draw_rect(Rect2(x, y, 2, 1), color)
	# Blinking status block next to the emblem.
	if int(elapsed * 2.0) % 2 == 0:
		draw_rect(Rect2(size.x - 44, 40, 4, 2), accent)
