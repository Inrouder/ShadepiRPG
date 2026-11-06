extends Node2D
var puzzle: RefCounted

func _draw() -> void:
	if puzzle == null or puzzle.flash <= 0:
		return
	var origin := Vector2(283, 182) if puzzle.kind == "jumper" else Vector2(602, 281)
	var age: float = 0.7 - puzzle.flash
	for i in 12:
		var direction := Vector2.from_angle(i * 2.4)
		var start := origin + direction * age * (35 + i * 3)
		draw_line(start, start + direction * 5, Color(1, 0.65, 0.2, puzzle.flash / 0.7), 1.5, true)
