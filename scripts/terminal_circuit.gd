extends Control
## Draw connected pipes over native, focusable buttons, as solid pixel bars.
const UiSkin = preload("res://scripts/ui_skin.gd")
var puzzle: RefCounted
var flow_color := Color("66edf2")

func _draw() -> void:
	if puzzle == null:
		return
	var flow: Array = puzzle.connected() if puzzle.powered else []
	for i in 16:
		var center := Vector2(23 + i % 4 * 52, 16 + i / 4 * 37)
		var color := Color("ff627c") if i in puzzle.infected else (flow_color if i in flow else Color("7895a5"))
		for d in 4:
			if not (puzzle.masks[i] & (1 << d)):
				continue
			var offset := Vector2(puzzle.DIRECTIONS[d]) * Vector2(26, 19)
			var bar := Rect2(center, offset).abs()
			draw_rect(bar.grow(2), Color(color.darkened(0.7), 0.85))
			draw_rect(bar.grow(1), color)
			if i in flow:
				var dot := (center + offset * fposmod(puzzle.clock * 1.5, 1.0)).floor()
				draw_rect(Rect2(dot - Vector2(1, 1), Vector2(3, 3)), Color.WHITE)
		draw_rect(Rect2(center - Vector2(3, 3), Vector2(7, 7)), color.darkened(0.5))
		draw_rect(Rect2(center - Vector2(2, 2), Vector2(5, 5)), color)
		if i == 10:
			draw_rect(Rect2(center - Vector2(10, 7), Vector2(21, 14)), Color("102332"))
			draw_rect(Rect2(center - Vector2(10, 7), Vector2(21, 14)), color, false)
			draw_string(UiSkin.font("title"), center + Vector2(-7, 4), "10", HORIZONTAL_ALIGNMENT_LEFT, -1, UiSkin.SMALL_TITLE_SIZE, color)
