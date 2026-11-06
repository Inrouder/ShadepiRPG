extends CanvasLayer
## Modal, controller-friendly Raven deck. Only explicit acceptance commits a result.
signal finished(success: bool)
signal alarm
const Puzzle = preload("res://scripts/terminal_puzzle.gd")
const Scope = preload("res://scripts/terminal_scope.gd")
const CYAN := Color("66edf2")
var puzzle: RefCounted
var context := "jackal"
var root: Control
var feedback: Label
var details: Label
var glitch: Label
var apply_button: Button
var pause_button: Button
var controls: Array[Control] = []
var cells: Array[Button] = []
var helper_buttons: Array[Button] = []
var pin_labels: Array[Label] = []
var scope: Control
var circuit: Control
var sparks: Node2D
var previous_attempts := 4
var previous_failure := false
var paused := false
var closed := false
var completion_focused := false

func _ready() -> void:
	layer = 100
	_build()

func _label(text: String, rect: Rect2, font_size: int = 12, color: Color = CYAN) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)
	return label

func _style(color: Color, fill: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = color
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	return style

func _button(text: String, rect: Rect2, callback: Callable, interactive: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_disabled_color", Color("9cafba"))
	button.add_theme_stylebox_override("normal", _style(Color("315667"), Color("102332")))
	button.add_theme_stylebox_override("focus", _style(CYAN, Color(0.1, 0.6, 0.7, 0.25)))
	button.pressed.connect(callback)
	root.add_child(button)
	if interactive:
		controls.append(button)
	return button

func _slider(text: String, rect: Rect2, maximum: int, initial: int, callback: Callable, minimum: int = 0) -> HSlider:
	_label(text, Rect2(rect.position - Vector2(0, 20), Vector2(rect.size.x, 18)))
	var slider := HSlider.new()
	slider.position = rect.position
	slider.size = rect.size
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 1
	slider.value = initial
	slider.value_changed.connect(callback)
	root.add_child(slider)
	controls.append(slider)
	return slider

func _option(items: Array, rect: Rect2, callback: Callable) -> OptionButton:
	var option := OptionButton.new()
	option.position = rect.position
	option.size = rect.size
	option.add_theme_font_size_override("font_size", 12)
	for item in items:
		option.add_item(str(item))
	option.item_selected.connect(callback)
	root.add_child(option)
	controls.append(option)
	return option

func _build() -> void:
	completion_focused = false
	puzzle = Puzzle.new(context)
	previous_attempts = puzzle.attempts
	previous_failure = false
	controls.clear()
	cells.clear()
	helper_buttons.clear()
	pin_labels.clear()
	scope = null
	circuit = null
	details = null
	glitch = null
	if root != null:
		remove_child(root)
		root.queue_free()
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var background := Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_theme_stylebox_override("panel", _style(Color("315667"), Color("080f19")))
	root.add_child(background)
	_label("RAVEN / NIGHTWING", Rect2(24, 10, 450, 22), 18)
	_label("Tab / Pfeile · Enter / A · Esc / B zurück", Rect2(403, 15, 215, 16), 10, Color("a7beca"))
	_label(puzzle.title, Rect2(24, 33, 570, 20), 13, Color("ffcc77"))
	var instructions := {
		"matrix": "Obere Zeile zuerst. Dann abwechselnd gleiche Spalte / Zeile.\nJede Zelle nur einmal. Zielsequenzen zusammenhängend in den Puffer laden.",
		"decoder": "Rauschfilter einstellen, bis die Wörter lesbar sind. Passwort auswählen.\nÄhnlichkeit zählt Buchstaben an gleicher Stelle. Klammerpaare helfen einmalig.",
		"routing": "Leitungen drehen: IN → Logik-Knoten 10 → OUT. Rot = Active ICE.\nA/B setzen, Datenfluss einschalten. ICE abtrennen; Knoten 10 verträgt nur 1×.",
		"signal": "Cyan auf Gold abstimmen: Frequenz, Amplitude und Phase einstellen.\nDeckung kurz halten. Bei Störimpulsen warten; gesicherter Kanal bleibt offen.",
		"jumper": "Ravens Wartungsdeck / Steckplätze verbinden und Widerstände wählen.\nErst prüfen, dann Neustart übernehmen. Fehler lösen die Schutzschaltung aus.",
	}
	_label(instructions[puzzle.kind], Rect2(24, 57, 592, 36), 11, Color("a7beca"))
	match puzzle.kind:
		"matrix": _matrix()
		"decoder": _decoder()
		"routing": _routing()
		"signal": _signal()
		"jumper": _jumper()
	feedback = _label("", Rect2(24, 273, 592, 37), 12)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button("Abbrechen", Rect2(24, 316, 105, 27), func(): finish(false), false)
	_button("Neu versuchen", Rect2(137, 316, 119, 27), func():
		paused = false
		_build(), false)
	pause_button = _button("Pause", Rect2(264, 316, 87, 27), _toggle_pause, false)
	apply_button = _button("Übernehmen", Rect2(488, 316, 128, 27), func(): finish(true), false)
	sparks = preload("res://scripts/terminal_sparks.gd").new()
	sparks.puzzle = puzzle
	root.add_child(sparks)
	_refresh()
	_focus_available()

func _focus_available() -> void:
	if puzzle.solved and not paused:
		apply_button.grab_focus()
		return
	for control in controls:
		if control is BaseButton and not control.disabled:
			control.grab_focus()
			return
		if control is Slider and control.editable:
			control.grab_focus()
			return
	pause_button.grab_focus()

func _matrix() -> void:
	for i in 25:
		cells.append(_button(puzzle.cells[i], Rect2(24 + (i % 5) * 51, 102 + (i / 5) * 31, 46, 27), func(): puzzle.select_hex(i)))
	details = _label("", Rect2(306, 104, 310, 158), 14)

func _decoder() -> void:
	for i in 6:
		cells.append(_button("", Rect2(24 + i % 2 * 128, 108 + i / 2 * 38, 120, 30), func(): puzzle.guess(i)))
	helper_buttons.append(_button("[A7.DUD.3F]", Rect2(24, 230, 120, 28), func(): puzzle.helper("dud")))
	helper_buttons.append(_button("<FF.RESET>", Rect2(152, 230, 120, 28), func(): puzzle.helper("reset")))
	glitch = _label("", Rect2(311, 99, 298, 25), 15)
	_slider("Rauschfilter-Frequenz", Rect2(312, 153, 290, 18), 100, 0, func(v): puzzle.filter = int(v))
	details = _label("", Rect2(312, 179, 290, 88), 12)

func _routing() -> void:
	for i in 16:
		cells.append(_button("", Rect2(46 + i % 4 * 52, 102 + i / 4 * 37, 47, 32), func(): puzzle.rotate(i)))
	_label("IN", Rect2(22, 142, 24, 20), 10)
	_label("OUT", Rect2(253, 142, 30, 20), 10)
	_option(["A = 0", "A = 1"], Rect2(306, 104, 111, 27), func(i): puzzle.input_a = i == 1)
	_option(["B = 0", "B = 1"], Rect2(432, 104, 111, 27), func(i): puzzle.input_b = i == 1)
	_option(["1× Datenrate", "2× Datenrate"], Rect2(306, 142, 237, 27), func(i): puzzle.rate = i + 1)
	_button("Datenfluss AN / AUS", Rect2(306, 180, 237, 29), func():
		puzzle.powered = not puzzle.powered
		puzzle.stability = 0.0)
	details = _label("", Rect2(306, 217, 300, 48), 12)
	circuit = preload("res://scripts/terminal_circuit.gd").new()
	circuit.puzzle = puzzle
	circuit.position = Vector2(46, 102)
	circuit.size = Vector2(208, 148)
	circuit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(circuit)

func _signal() -> void:
	scope = Scope.new()
	scope.puzzle = puzzle
	scope.position = Vector2(24, 105)
	scope.size = Vector2(330, 145)
	scope.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(scope)
	_label("GOLD: Ziel   /   CYAN: Dein Signal", Rect2(24, 251, 335, 18), 10)
	for i in 3:
		_slider(["Frequenz", "Amplitude", "Phase"][i], Rect2(382, 126 + i * 55, 220, 20), [6, 5, 7][i], puzzle.signal_values[i], func(v):
			puzzle.signal_values[i] = int(v)
			puzzle.stability = 0.0, 0 if i == 2 else 1)

func _jumper() -> void:
	for i in 5:
		pin_labels.append(_label("", Rect2(24, 101 + i * 32, 124, 24), 12))
		_option(Puzzle.SOCKETS, Rect2(159, 101 + i * 32, 110, 27), func(v):
			puzzle.wiring[i] = v
			puzzle.leds[i] = false)
	_label("WARTUNGSLOG / ARTOS\nPin 3 → GND. Pin 4 → VCC.\nTX / RX kreuzen; nie an VCC.\nDATA bleibt DATA.\nKette Alpha: zusammen 120 Ω.", Rect2(306, 101, 304, 99), 12)
	_option(Puzzle.RESISTORS, Rect2(306, 202, 101, 27), func(i): puzzle.resistors[0] = i)
	_option(Puzzle.RESISTORS, Rect2(418, 202, 101, 27), func(i): puzzle.resistors[1] = i)
	_button("Verbindungen prüfen", Rect2(306, 237, 237, 27), func(): puzzle.check_wiring())

func _process(delta: float) -> void:
	if closed:
		return
	if not paused:
		puzzle.tick(delta)
	if puzzle.attempts < previous_attempts or (puzzle.failed and not previous_failure):
		alarm.emit()
	previous_attempts = puzzle.attempts
	previous_failure = puzzle.failed
	_refresh()

func _refresh() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	feedback.text = "PAUSE · Weiter mit Start oder Fortsetzen." if paused else puzzle.status
	feedback.add_theme_color_override("font_color", Color("ff697c") if puzzle.flash > 0 or puzzle.failed else CYAN)
	sparks.queue_redraw()
	apply_button.disabled = not puzzle.solved or paused
	pause_button.text = "Fortsetzen" if paused else "Pause"
	for control in controls:
		if control is BaseButton:
			control.disabled = paused or not puzzle.available()
		elif control is Slider:
			control.editable = not paused and puzzle.available()
	match puzzle.kind:
		"matrix":
			for i in cells.size():
				cells[i].disabled = paused or not puzzle.legal(i)
				cells[i].modulate = Color("527686") if i in puzzle.used else Color.WHITE
			details.text = "PUFFER %d / %d\n%s\n\nDAEMONS" % [puzzle.buffer.size(), puzzle.capacity, " · ".join(puzzle.buffer)]
			for goal in puzzle.goals:
				details.text += "\n%s  %s" % ["✓" if puzzle.has_sequence(goal) else "○", " → ".join(goal)]
		"decoder":
			controls[8].set_value_no_signal(puzzle.filter)
			for i in cells.size():
				cells[i].text = "......" if i in puzzle.removed else (Puzzle.WORDS[i] if puzzle.filter_locked() else _scramble(Puzzle.WORDS[i], i))
				cells[i].disabled = paused or not puzzle.available() or not puzzle.filter_locked() or i in puzzle.removed or i in puzzle.guessed
			glitch.text = "SIGNAL STABIL" if puzzle.filter_locked() else "↓ " + _scramble("SPEICHERDUMP", 3) + " ↓"
			glitch.position.y = 99 if puzzle.filter_locked() else 99 + sin(puzzle.clock * 4) * 5
			details.text = "%d Versuche · Filter %d\n%s" % [puzzle.attempts, puzzle.filter, puzzle.history.left(114)]
			for i in 2:
				helper_buttons[i].disabled = paused or not puzzle.available() or ["dud", "reset"][i] in puzzle.helpers
		"routing":
			for i in cells.size():
				cells[i].text = ""
				cells[i].disabled = paused or not puzzle.available() or i in puzzle.infected
			circuit.queue_redraw()
			details.text = "Knoten 10: %s → %d\nBus %s · ICE: %d Knoten" % [puzzle.gate, int(Puzzle.gate_output(puzzle.gate, puzzle.input_a, puzzle.input_b)), "AN" if puzzle.powered else "AUS", puzzle.infected.size()]
		"signal":
			for i in 3:
				controls[i].set_value_no_signal(puzzle.signal_values[i])
			scope.queue_redraw()
		"jumper":
			for i in 5:
				controls[i].selected = puzzle.wiring[i]
				pin_labels[i].text = "%s %d · %s →" % ["●" if puzzle.leds[i] else "○", i + 1, Puzzle.PINS[i]]
				pin_labels[i].modulate = Color("7dffaa") if puzzle.leds[i] else Color.WHITE
			for i in 2:
				controls[i + 5].selected = puzzle.resistors[i]
	if puzzle.solved and not paused and not completion_focused:
		completion_focused = true
		apply_button.grab_focus()
	elif focus != null and focus is BaseButton and focus.disabled:
		_focus_available()

func _scramble(word: String, salt: int) -> String:
	var result := ""
	var proximity := absi(puzzle.filter - puzzle.filter_target)
	for i in word.length():
		var tick := int(puzzle.clock * 10) + i * 7 + salt
		result += word[i] if tick % 60 > proximity else "#%/?@$"[tick % 6]
	return result

func _toggle_pause() -> void:
	paused = not paused
	for control in controls:
		if control is OptionButton:
			control.get_popup().hide()

func _input(event: InputEvent) -> void:
	if closed:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B):
		get_viewport().set_input_as_handled()
		finish(false)
	elif event.is_action_pressed("pause_game") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P):
		get_viewport().set_input_as_handled()
		_toggle_pause()

func finish(success: bool) -> void:
	if closed or (success and (not puzzle.solved or paused)):
		return
	closed = true
	finished.emit(success)
