extends Node2D

signal completed
var world: Node2D
var elapsed: = 0.0
var mode: = 0
var positions: = [0.5, 0.5]
var scores: = [0.0, 0.0]
var done: = false

func _process(delta: float) -> void :
	if world.is_busy() or done:
		return
	if mode == 0:
		if Input.is_action_just_pressed("attack"):
			mode = 1
		elif Input.is_action_just_pressed("dash"):
			mode = 2
			world.gamepads.assign(Input.get_connected_joypads(), true)
		return
	elapsed += delta
	var wave: = mini(2, int(elapsed / 4.0))
	for i in mode:
		var action: = "attack" if i == 0 else "raven_attack"
		positions[i] = clampf(positions[i] - delta * (0.19 + wave * 0.12), 0.0, 1.0)
		if Input.is_action_just_pressed(action):
			positions[i] = clampf(positions[i] + 0.14, 0.0, 1.0)
		if elapsed < 12.0 and absf(positions[i] - 0.5) <= 0.11:
			scores[i] += delta
	queue_redraw()
	if elapsed >= 15.0:
		done = true
		completed.emit()

func _draw() -> void :
	var font: = ThemeDB.fallback_font
	var cyan: = Color("78e5e7")
	draw_rect(Rect2(0, 0, 640, 360), Color("171323"))
	draw_string(font, Vector2(100, 107), "HEILIGTUM / EINDÄMMUNG 96 %", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, cyan)
	if mode == 0:
		draw_string(font, Vector2(100, 166), "J / X  Solo starten     Leertaste / B  Duell starten", HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
		draw_string(font, Vector2(100, 198), "Tippe in kurzen Serien. Halte den Zeiger im Cyan-Fenster.", HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
		return
	draw_string(font, Vector2(100, 139), "Welle %d / 3   ·   %.1f s" % [mini(3, int(elapsed / 4.0) + 1), maxf(0.0, 12.0 - elapsed)], HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	for i in mode:
		var y: = 181 + i * 61
		draw_string(font, Vector2(100, y - 7), "%s · %.1f s im Fenster" % ["Shadepi  J / X" if i == 0 else "Raven  U / X", scores[i]], HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
		draw_rect(Rect2(100, y, 440, 12), Color("372d47"))
		draw_rect(Rect2(272, y, 96, 12), cyan.darkened(0.3))
		draw_rect(Rect2(99 + positions[i] * 440, y - 3, 3, 18), Color.WHITE)
	if elapsed >= 12.0:
		var result: = "Runde abgeschlossen"
		if mode == 2:
			result = "Gleichstand" if absf(scores[0] - scores[1]) < 0.08 else ("Shadepi gewinnt" if scores[0] > scores[1] else "Raven gewinnt")
		draw_string(font, Vector2(100, 305), result, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, cyan)
