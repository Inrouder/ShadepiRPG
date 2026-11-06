extends Control
## Draw connected pipes over native, focusable buttons.
var puzzle: RefCounted

func _draw() -> void:
	if puzzle == null:
		return
	var flow: Array = puzzle.connected() if puzzle.powered else []
	for i in 16:
		var center := Vector2(23 + i % 4 * 52, 16 + i / 4 * 37)
		var color := Color("ff627c") if i in puzzle.infected else (Color("66edf2") if i in flow else Color("7895a5"))
		for d in 4:
			if not (puzzle.masks[i] & (1 << d)):
				continue
			var offset := Vector2(puzzle.DIRECTIONS[d]) * Vector2(26, 18.5)
			draw_line(center, center + offset, Color(color, 0.18), 7, true)
			draw_line(center, center + offset, color, 3, true)
			if i in flow:
				draw_circle(center + offset * fposmod(puzzle.clock * 1.5, 1.0), 2, Color.WHITE)
		draw_circle(center, 3, color)
		if i == 10:
			draw_rect(Rect2(center - Vector2(9, 7), Vector2(18, 14)), Color("102332"))
			draw_string(ThemeDB.fallback_font, center + Vector2(-6, 4), "10", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, color)
