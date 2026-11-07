extends Control
## Oscilloscope of the signal deck, drawn in whole pixels: grid dots, the gold
## target wave as 2 px blocks and the player's wave as a 1 px trace.
var puzzle: RefCounted
var target_color := Color("ffcc77")
var signal_color := Color("58edf5")
var grid_color := Color("183342")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("070c14"))
	for x in range(0, int(size.x), 10):
		for y in range(0, int(size.y), 10):
			var major := x % 40 == 0 or y % 40 == 0
			draw_rect(Rect2(x, y, 1, 1), grid_color.lightened(0.25) if major and x % 40 == 0 and y % 40 == 0 else grid_color)
	draw_rect(Rect2(0, int(size.y / 2), int(size.x), 1), Color(grid_color, 0.8))
	if puzzle == null:
		return
	for target in [true, false]:
		var values: Array = puzzle.signal_target if target else puzzle.signal_values
		var previous := -1
		for x in range(0, int(size.x)):
			var wave := sin(float(x) / size.x * TAU * values[0] + values[2] * TAU / 8.0)
			var interference := sin(x * 1.7 + puzzle.clock * 20) * 5 if target and puzzle.noise else 0.0
			var y := int(round(size.y / 2 + wave * values[1] * 10 + interference))
			var top := y if previous < 0 else mini(y, previous)
			var bottom := y if previous < 0 else maxi(y, previous)
			if target:
				draw_rect(Rect2(x, top - 1, 1, bottom - top + 2), target_color)
			else:
				draw_rect(Rect2(x, top, 1, bottom - top + 1), signal_color)
			previous = y
