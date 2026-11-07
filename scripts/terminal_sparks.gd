extends Node2D
## Failure sparks as single pixel squares.
var puzzle: RefCounted

func _draw() -> void:
	if puzzle == null or puzzle.flash <= 0:
		return
	var origin := Vector2(283, 182) if puzzle.kind == "jumper" else Vector2(602, 281)
	var age: float = 0.7 - puzzle.flash
	for i in 12:
		var direction := Vector2.from_angle(i * 2.4)
		var start := (origin + direction * age * (35 + i * 3)).floor()
		var color := Color(1, 0.65, 0.2, puzzle.flash / 0.7)
		draw_rect(Rect2(start, Vector2(2, 2)), color)
		draw_rect(Rect2((start + direction * 4).floor(), Vector2(1, 1)), Color(1, 0.9, 0.6, puzzle.flash / 0.7))
