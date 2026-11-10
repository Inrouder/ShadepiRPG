extends CanvasLayer
## Modal, controller-friendly Raven deck. Only explicit acceptance commits a result.
signal finished(success: bool)
signal alarm
const Puzzle = preload("res://scripts/terminal_puzzle.gd")
const Scope = preload("res://scripts/terminal_scope.gd")
const UiSkin = preload("res://scripts/ui_skin.gd")
## Scene theme of the target system (jackal, order, artos, tower or raven).
var skin := "raven"
var palette: Dictionary = UiSkin.THEMES.raven
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
var footer: Array[Control] = []
var value_labels: Array[Label] = []
var help_panel: Panel
var help_open := false
var help_focus: Control
var held_direction := Vector2.ZERO
var stick := Vector2.ZERO
var repeat_delay := 0.0
const GUIDES := {
 "matrix": "1  Beginne in der obersten Zeile. Wähle ein Byte mit A / Enter.
2  Danach darfst du nur in derselben Spalte wählen, dann in derselben
    Zeile. Helle Felder sind gültig; verbrauchte Felder sind gesperrt.
3  Lade jede rechts angezeigte Folge ohne Lücke in den Puffer.
    Bei zwei Folgen kann ein gemeinsames End-/Startbyte Platz sparen.
4  Puffer voll ohne alle Folgen? Wähle Neu versuchen.
5  Sind alle Folgen markiert, bestätige mit Übernehmen.",
 "decoder": "1  Wähle zuerst den Rauschfilter. Links / Rechts verändert seinen Wert.
    Je höher die Signalqualität, desto näher bist du an der Frequenz.
2  Sobald das Signal stabil ist, werden die Wörter auswählbar.
3  Wähle ein Passwort. 3/6 bedeutet: drei Buchstaben stehen an der
    richtigen Stelle. Vergleiche damit die übrigen Kandidaten.
4  [DUD] entfernt ein falsches Wort; <RESET> erneuert deine Versuche.
    Jede Hilfe ist einmal nutzbar. Danach Übernehmen wählen.",
 "routing": "1  A / Enter dreht eine Leitung um 90 Grad im Uhrzeigersinn.
2  Verbinde IN links über Knoten 10 mit OUT rechts.
3  Das AND-Gatter an Knoten 10 braucht A = 1 UND B = 1.
4  Nutze Datenrate 1×; 2× überlastet Knoten 10.
5  Trenne den roten ICE-Knoten vom Weg, bevor du den Bus einschaltest.
    ICE breitet sich alle 1,4 Sekunden über verbundene Leitungen aus.
6  Datenfluss einschalten, 3 Sekunden halten, dann Übernehmen.",
 "signal": "1  Gold zeigt die Zielwelle, Cyan dein Signal.
2  Frequenz verändert die Anzahl der Wellen, Amplitude ihre Höhe.
    Phase verschiebt die Welle seitlich. Werte mit Links / Rechts ändern.
3  Wechsle mit Oben / Unten zwischen den drei Reglern.
4  Bringe Cyan genau auf Gold und halte die Deckung 1,2 Sekunden.
5  Bei Rauschen warten. Bei der Sperrladung wandert die Zielphase
    alle 12 Sekunden weiter. Nach Phase Lock Übernehmen wählen.",
 "jumper": "1  Wähle für jeden Pin rechts einen Zielsteckplatz. Links / Rechts
    wechselt die Belegung; der Pinname links ist der Ausgang.
2  Kreuze TX und RX. GND bleibt GND, VCC bleibt VCC, DATA bleibt DATA.
3  Wähle zwei Widerstände, deren Summe 120 Ohm ergibt.
4  Verbindungen prüfen zeigt korrekte Pins als grüne LEDs.
    Auch die Widerstandssumme muss stimmen. Drei Fehlversuche
    sperren die Platine. Nach erfolgreicher Prüfung Übernehmen wählen."
}

func _ready() -> void:
	layer = 100
	skin = UiSkin.terminal_theme(context)
	palette = UiSkin.colors(skin)
	_build()

## Logical 640×360 deck; HQ presentation preserves the original control coordinates.
func _label(text: String, rect: Rect2, color: Color = Color.TRANSPARENT, kind: String = "ui", font_size: int = -1) -> Label:
	if color == Color.TRANSPARENT:
		color = palette.primary
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	UiSkin.style_label(label, color, kind, font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)
	return label

func _button(text: String, rect: Rect2, callback: Callable, interactive: bool = true) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	UiSkin.apply_button(button, skin)
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	root.add_child(button)
	if interactive:
		controls.append(button)
	return button

func _slider(text: String, rect: Rect2, maximum: int, initial: int, callback: Callable, minimum: int = 0) -> HSlider:
	var value_label := _label(text, Rect2(rect.position - Vector2(0, 21), Vector2(rect.size.x, 20)))
	value_labels.append(value_label)
	var slider := HSlider.new()
	slider.position = rect.position
	slider.size = rect.size
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 1
	slider.value = initial
	slider.value_changed.connect(callback)
	slider.value_changed.connect(func(v): value_label.text = "%s  [%d]" % [text, int(v)])
	value_label.text = "%s  [%d]" % [text, initial]
	slider.focus_mode = Control.FOCUS_ALL
	UiSkin.apply_slider(slider, skin)
	root.add_child(slider)
	controls.append(slider)
	return slider

func _option(items: Array, rect: Rect2, callback: Callable) -> OptionButton:
	var option := OptionButton.new()
	option.position = rect.position
	option.size = rect.size
	option.focus_mode = Control.FOCUS_ALL
	option.tooltip_text = "A / Enter · Liste öffnen und bestätigen. B / Esc · Liste schließen."
	UiSkin.apply_button(option, skin)
	option.add_theme_icon_override("arrow", UiSkin.chevron(skin))
	for item in items:
		option.add_item(str(item))
	option.item_selected.connect(callback)
	option.get_popup().about_to_popup.connect(func(): held_direction = Vector2.ZERO; stick = Vector2.ZERO)
	var popup := option.get_popup()
	popup.add_theme_stylebox_override("panel", UiSkin.panel(skin))
	popup.add_theme_stylebox_override("hover", UiSkin.button(skin, "hover"))
	popup.add_theme_font_override("font", option.get_theme_font("font"))
	popup.add_theme_font_size_override("font_size", option.get_theme_font_size("font_size"))
	popup.add_theme_color_override("font_color", option.get_theme_color("font_color"))
	root.add_child(option)
	controls.append(option)
	return option

func _build() -> void:
	completion_focused = false
	help_open = false
	help_panel = null
	held_direction = Vector2.ZERO
	stick = Vector2.ZERO
	footer.clear()
	value_labels.clear()
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
	root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(root)
	# The live scene stays visible behind the deck, pixelated and tinted in the
	# colours of the hacked system; frames and buttons come from assets/ui/<skin>.
	root.add_child(UiSkin.backdrop(skin, 0.72))
	var deck := _panel(Rect2(2, 2, 636, 356))
	var rim := UiSkin.panel(skin)
	rim.draw_center = false
	deck.add_theme_stylebox_override("panel", rim)
	_header(Rect2(10, 9, 584, 22))
	_emblem("raven", Rect2(14, 8, 24, 24))
	_emblem(skin, Rect2(602, 8, 24, 24))
	_panel(Rect2(16, 98, 348 if puzzle.kind == "signal" else 272, 169))
	_panel(Rect2(374, 98, 250, 169) if puzzle.kind == "signal" else Rect2(298, 98, 326, 169))
	_panel(Rect2(16, 270, 608, 40), true)
	_label("NIGHTWING / RAVENS DECK", Rect2(44, 12, 250, 10), UiSkin.THEMES.raven.primary, "title", UiSkin.SMALL_TITLE_SIZE)
	_label("SICHERE VERBINDUNG // " + puzzle.kind.to_upper(), Rect2(44, 21, 250, 10), palette.muted, "title", UiSkin.SMALL_TITLE_SIZE)
	var system := _label("ZIEL · " + palette.system, Rect2(250, 10, 300, 20), palette.accent)
	system.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var hint := _label("STICK/KREUZ WÄHLEN · A AKTION · LB/RB WEITER · Y HILFE · START PAUSE · B ZURÜCK", Rect2(20, 343, 600, 10), palette.muted, "title", UiSkin.SMALL_TITLE_SIZE)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(puzzle.title, Rect2(20, 36, 600, 18), palette.accent, "title")
	var instructions := {
		"matrix": "ZIEL: Alle Codefolgen rechts in den Puffer laden. Nur helle Felder sind erlaubt.\nStarte oben; danach wechseln Spalte und Zeile. Y / F1 erklärt die Schritte.",
		"decoder": "ZIEL: Das Türpasswort finden. Stelle zuerst den Rauschfilter auf ein stabiles Signal.\nDann Wörter vergleichen: Ähnlichkeit zählt Buchstaben an derselben Stelle.",
		"routing": "ZIEL: IN über Knoten 10 mit OUT verbinden. A dreht die markierte Leitung.\nAND braucht A=1 und B=1. Datenrate 1×; rotes ICE vom Datenweg abtrennen.",
		"signal": "ZIEL: Dein cyanfarbenes Signal auf die goldene Zielwelle abstimmen.\nRegler wählen, mit Links / Rechts ändern; Deckung 1,2 Sekunden halten.",
		"jumper": "ZIEL: Antrieb reparieren. Für jeden Pin den passenden Steckplatz wählen.\nWartungslog rechts beachten, Widerstände ergänzen, dann Verbindungen prüfen.",
	}
	_label(instructions[puzzle.kind], Rect2(22, 56, 598, 40), palette.text.darkened(0.08))
	match puzzle.kind:
		"matrix": _matrix()
		"decoder": _decoder()
		"routing": _routing()
		"signal": _signal()
		"jumper": _jumper()
	feedback = _label("", Rect2(28, 274, 584, 34))
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Footer: five buttons on one row without overlap (widths fit the pixel font).
	footer.append(_button("Abbrechen", Rect2(18, 315, 100, 24), func(): finish(false), false))
	footer.append(_button("Neu versuchen", Rect2(124, 315, 128, 24), func():
		paused = false
		_build(), false))
	pause_button = _button("Pause", Rect2(258, 315, 106, 24), _toggle_pause, false)
	apply_button = _button("Übernehmen", Rect2(492, 315, 130, 24), func(): finish(true), false)
	footer.append(pause_button)
	footer.append(_button("Hilfe Y / F1", Rect2(370, 315, 116, 24), _toggle_help, false))
	footer.append(apply_button)
	sparks = preload("res://scripts/terminal_sparks.gd").new()
	sparks.puzzle = puzzle
	root.add_child(sparks)
	_refresh()
	_focus_available()

func _focus_available() -> void:
	if puzzle.failed:
		footer[1].grab_focus()
		return
	if paused:
		pause_button.grab_focus()
		return
	if puzzle.kind == "decoder" and not puzzle.filter_locked() and puzzle.available():
		controls[8].grab_focus()
		return
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
		cells.append(_button(puzzle.cells[i], Rect2(26 + (i % 5) * 51, 106 + (i / 5) * 31, 46, 27), func(): puzzle.select_hex(i)))
		UiSkin.apply_cell(cells[i], skin)
	details = _label("", Rect2(310, 106, 304, 156))

func _decoder() -> void:
	for i in 6:
		cells.append(_button("", Rect2(24 + i % 2 * 128, 108 + i / 2 * 38, 120, 30), func(): puzzle.guess(i)))
	helper_buttons.append(_button("[A7.DUD.3F]", Rect2(24, 230, 120, 28), func(): puzzle.helper("dud")))
	helper_buttons.append(_button("<FF.RESET>", Rect2(152, 230, 120, 28), func(): puzzle.helper("reset")))
	glitch = _label("", Rect2(311, 103, 298, 20), palette.accent, "title")
	_slider("Rauschfilter-Frequenz", Rect2(312, 153, 290, 18), 100, 0, func(v): puzzle.filter = int(v))
	details = _label("", Rect2(312, 182, 290, 80))

func _routing() -> void:
	for i in 16:
		cells.append(_button("", Rect2(46 + i % 4 * 52, 102 + i / 4 * 37, 47, 32), func(): puzzle.rotate(i)))
		UiSkin.apply_cell(cells[i], skin)
	_label("IN", Rect2(24, 145, 24, 10), palette.accent, "title", UiSkin.SMALL_TITLE_SIZE)
	_label("OUT", Rect2(256, 145, 30, 10), palette.accent, "title", UiSkin.SMALL_TITLE_SIZE)
	_option(["A = 0", "A = 1"], Rect2(306, 104, 111, 27), func(i): puzzle.input_a = i == 1)
	_option(["B = 0", "B = 1"], Rect2(432, 104, 111, 27), func(i): puzzle.input_b = i == 1)
	_option(["1× Datenrate", "2× Datenrate"], Rect2(306, 142, 237, 27), func(i): puzzle.rate = i + 1)
	_button("Datenfluss AN / AUS", Rect2(306, 180, 237, 29), func():
		puzzle.powered = not puzzle.powered
		puzzle.stability = 0.0)
	details = _label("", Rect2(308, 216, 306, 46))
	circuit = preload("res://scripts/terminal_circuit.gd").new()
	circuit.puzzle = puzzle
	circuit.flow_color = palette.primary
	circuit.position = Vector2(46, 102)
	circuit.size = Vector2(208, 148)
	circuit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(circuit)

func _signal() -> void:
	scope = Scope.new()
	scope.puzzle = puzzle
	scope.grid_color = palette.primary.darkened(0.72)
	scope.position = Vector2(24, 105)
	scope.size = Vector2(330, 145)
	scope.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(scope)
	_label("GOLD: ZIEL  /  CYAN: DEIN SIGNAL", Rect2(24, 253, 330, 10), palette.muted, "title", UiSkin.SMALL_TITLE_SIZE)
	for i in 3:
		_slider(["Frequenz", "Amplitude", "Phase"][i], Rect2(382, 126 + i * 55, 220, 20), [6, 5, 7][i], puzzle.signal_values[i], func(v):
			puzzle.signal_values[i] = int(v)
			puzzle.stability = 0.0, 0 if i == 2 else 1)

func _jumper() -> void:
	for i in 5:
		pin_labels.append(_label("", Rect2(26, 104 + i * 32, 130, 22)))
		_option(Puzzle.SOCKETS, Rect2(159, 101 + i * 32, 110, 27), func(v):
			puzzle.wiring[i] = v
			puzzle.leds[i] = false)
	_label("WARTUNGSLOG / ARTOS", Rect2(310, 106, 300, 10), palette.accent, "title", UiSkin.SMALL_TITLE_SIZE)
	_label("Pin 3 → GND. Pin 4 → VCC.\nTX / RX kreuzen; nie an VCC.\nDATA bleibt DATA.\nKette Alpha: zusammen 120 Ω.", Rect2(310, 118, 300, 80))
	_option(Puzzle.RESISTORS, Rect2(306, 202, 101, 27), func(i): puzzle.resistors[0] = i)
	_option(Puzzle.RESISTORS, Rect2(418, 202, 101, 27), func(i): puzzle.resistors[1] = i)
	_button("Verbindungen prüfen", Rect2(306, 237, 237, 27), func(): puzzle.check_wiring())

func _process(delta: float) -> void:
	if closed:
		return
	if not help_open and held_direction != Vector2.ZERO:
		repeat_delay -= delta
		if repeat_delay <= 0:
			_navigate(held_direction)
			repeat_delay = 0.13
	if not paused and not help_open:
		puzzle.tick(delta)
	if puzzle.attempts < previous_attempts or (puzzle.failed and not previous_failure):
		alarm.emit()
	previous_attempts = puzzle.attempts
	previous_failure = puzzle.failed
	_refresh()

func _refresh() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	feedback.text = "PAUSE · Weiter mit Start oder Fortsetzen." if paused else puzzle.status
	if puzzle.status == "Verbindung bereit.":
		feedback.text = {"routing": "VORBEREITUNG · Leitungen drehen, A/B setzen, dann Datenfluss einschalten.", "signal": "ABGLEICH · Frequenz, Amplitude und Phase einstellen. Gold ist dein Ziel.", "jumper": "WARTUNG · Pins und Widerstände einstellen, dann Verbindungen prüfen."}.get(puzzle.kind, puzzle.status)
	if puzzle.solved:
		feedback.text = "ZUGRIFF FREI · Wähle Übernehmen, um die Aufgabe abzuschließen."
	elif puzzle.failed:
		feedback.text += "  Wähle Neu versuchen."
	elif puzzle.kind == "matrix" and puzzle.cursor < 0:
		feedback.text = "SCHRITT 1 · Wähle ein helles Byte in der obersten Zeile."
	elif puzzle.kind == "decoder" and not puzzle.filter_locked():
		feedback.text = "SCHRITT 1 · Rauschfilter mit Links / Rechts abstimmen."
	elif puzzle.kind == "decoder" and puzzle.history.is_empty():
		feedback.text = "SCHRITT 2 · Signal stabil. Wähle jetzt ein Passwort links."
	if paused:
		feedback.text = "PAUSE · Weiter mit Start oder Fortsetzen."
	feedback.add_theme_color_override("font_color", palette.warn if puzzle.flash > 0 or puzzle.failed else palette.primary)
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
				UiSkin.mark_used(cells[i], skin, i in puzzle.used)
			details.text = "PUFFER %d / %d\n%s\n\nDAEMONS" % [puzzle.buffer.size(), puzzle.capacity, " · ".join(puzzle.buffer) if not puzzle.buffer.is_empty() else "—"]
			for goal in puzzle.goals:
				details.text += "\n%s  %s" % ["✓" if puzzle.has_sequence(goal) else "○", " → ".join(goal)]
		"decoder":
			controls[8].set_value_no_signal(puzzle.filter)
			value_labels[0].text = "Rauschfilter-Frequenz  [%d]" % puzzle.filter
			for i in cells.size():
				cells[i].text = "......" if i in puzzle.removed else (Puzzle.WORDS[i] if puzzle.filter_locked() else _scramble(Puzzle.WORDS[i], i))
				cells[i].disabled = paused or not puzzle.available() or not puzzle.filter_locked() or i in puzzle.removed or i in puzzle.guessed
			glitch.text = "SIGNAL STABIL" if puzzle.filter_locked() else "↓ " + _scramble("SPEICHERDUMP", 3) + " ↓"
			glitch.position.y = 99 if puzzle.filter_locked() else 99 + sin(puzzle.clock * 4) * 5
			details.text = "Signalqualität: %d %% · Versuche: %d\n%s" % [100 - absi(puzzle.filter - puzzle.filter_target), puzzle.attempts, puzzle.history.left(114)]
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
				value_labels[i].text = "%s  [%d]" % [["Frequenz", "Amplitude", "Phase"][i], puzzle.signal_values[i]]
			scope.queue_redraw()
		"jumper":
			for i in 5:
				controls[i].selected = puzzle.wiring[i]
				pin_labels[i].text = "%s %d · %s →" % ["●" if puzzle.leds[i] else "○", i + 1, Puzzle.PINS[i]]
				pin_labels[i].add_theme_color_override("font_color", Color("7dffaa") if puzzle.leds[i] else palette.primary)
			for i in 2:
				controls[i + 5].selected = puzzle.resistors[i]
	if puzzle.solved and not paused and not help_open and not completion_focused:
		completion_focused = true
		apply_button.grab_focus()
	elif not help_open and focus != null and focus is BaseButton and focus.disabled:
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
	held_direction = Vector2.ZERO
	for control in controls:
		if control is OptionButton:
			control.get_popup().hide()
	_refresh()
	_focus_available()

func _input(event: InputEvent) -> void:
	# An open dropdown owns A/B, arrows and mouse, just like other game menus.
	# Do not abort the hack or cycle its underlying controls while choosing an item.
	for control in controls:
		if control is OptionButton and control.get_popup().visible: return
	if closed:
		return
	# Consume raw pad events here: gameplay bindings use these same buttons.
	if event is InputEventJoypadMotion:
		if event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y]:
			if event.axis == JOY_AXIS_LEFT_X: stick.x = event.axis_value
			else: stick.y = event.axis_value
			var direction := Vector2.ZERO
			if stick.length() > 0.55:
				direction = Vector2(signf(stick.x), 0) if absf(stick.x) > absf(stick.y) else Vector2(0, signf(stick.y))
			_hold(direction)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		var directions := {JOY_BUTTON_DPAD_LEFT: Vector2.LEFT, JOY_BUTTON_DPAD_RIGHT: Vector2.RIGHT, JOY_BUTTON_DPAD_UP: Vector2.UP, JOY_BUTTON_DPAD_DOWN: Vector2.DOWN}
		if event.button_index in directions:
			_hold(directions[event.button_index] if event.pressed else Vector2.ZERO)
		elif event.pressed:
			match event.button_index:
				JOY_BUTTON_Y: _toggle_help()
				JOY_BUTTON_B:
					if help_open: _toggle_help()
					else: finish(false)
				JOY_BUTTON_START:
					if not help_open: _toggle_pause()
				JOY_BUTTON_LEFT_SHOULDER: _cycle_focus(-1)
				JOY_BUTTON_RIGHT_SHOULDER: _cycle_focus(1)
				JOY_BUTTON_A: _activate()
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if help_open: _toggle_help()
		else: finish(false)
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F1:
		get_viewport().set_input_as_handled()
		_toggle_help()
	elif help_open:
		if event is InputEventKey: get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause_game") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P):
		get_viewport().set_input_as_handled()
		_toggle_pause()

func _hold(direction: Vector2) -> void:
	if direction == held_direction: return
	held_direction = direction
	repeat_delay = 0.32
	if direction != Vector2.ZERO and not help_open: _navigate(direction)

func _enabled_controls() -> Array[Control]:
	var result: Array[Control] = []
	for control in controls + footer:
		if control is BaseButton and not control.disabled or control is Slider and control.editable:
			result.append(control)
	return result

func _cycle_focus(step: int) -> void:
	if help_open: return
	var available := _enabled_controls()
	if available.is_empty(): return
	var index := available.find(get_viewport().gui_get_focus_owner())
	available[posmod(index + step, available.size())].grab_focus()

func _navigate(direction: Vector2) -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus == null:
		_focus_available()
		return
	if direction.x != 0:
		if focus is Slider and focus.editable:
			focus.value += direction.x * focus.step
			return
		if focus is OptionButton and not focus.disabled:
			focus.select(posmod(focus.selected + int(direction.x), focus.item_count))
			focus.item_selected.emit(focus.selected)
			return
	var best: Control
	var score := INF
	var center := focus.get_global_rect().get_center()
	for candidate in _enabled_controls():
		var offset := candidate.get_global_rect().get_center() - center
		var forward := offset.dot(direction)
		if forward <= 1: continue
		var sideways := absf(offset.cross(direction))
		var candidate_score := forward + sideways * 3
		if candidate_score < score:
			score = candidate_score
			best = candidate
	if best != null: best.grab_focus()

func _activate() -> void:
	if help_open:
		_toggle_help()
		return
	var focus := get_viewport().gui_get_focus_owner()
	if focus is OptionButton and not focus.disabled:
		held_direction = Vector2.ZERO
		focus.show_popup()
	elif focus is Button and not focus.disabled:
		focus.pressed.emit()
	_refresh()

func _panel(rect: Rect2, slim: bool = false) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiSkin.panel(skin, slim))
	root.add_child(panel)
	return panel

func _header(rect: Rect2) -> void:
	var plate := Panel.new()
	plate.position = rect.position
	plate.size = rect.size
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override("panel", UiSkin.header(skin))
	root.add_child(plate)

func _emblem(theme: String, rect: Rect2) -> void:
	var emblem := TextureRect.new()
	emblem.texture = UiSkin.emblem(theme)
	emblem.position = rect.position
	emblem.size = rect.size
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(emblem)

func _toggle_help() -> void:
	held_direction = Vector2.ZERO
	if help_open:
		help_open = false
		help_panel.queue_free()
		help_panel = null
		if is_instance_valid(help_focus) and not (help_focus is BaseButton and help_focus.disabled): help_focus.grab_focus()
		else: _focus_available()
		return
	help_focus = get_viewport().gui_get_focus_owner()
	help_open = true
	help_panel = _panel(Rect2(16, 8, 608, 338))
	help_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(palette.deep, 0.96)
	shade.position = Vector2(6, 6)
	shade.size = help_panel.size - Vector2(12, 12)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	help_panel.add_child(shade)
	var emblem := TextureRect.new()
	emblem.texture = UiSkin.emblem("raven")
	emblem.position = Vector2(16, 14)
	help_panel.add_child(emblem)
	var title := UiSkin.style_label(Label.new(), palette.accent, "title")
	title.text = "RAVENS HANDBUCH / " + puzzle.kind.to_upper()
	title.position = Vector2(48, 18)
	help_panel.add_child(title)
	var guide := UiSkin.style_label(Label.new(), palette.text)
	guide.text = GUIDES[puzzle.kind]
	guide.position = Vector2(20, 52)
	help_panel.add_child(guide)
	var close := Button.new()
	close.text = "Verstanden · A / B / Y / F1"
	close.position = Vector2(18, 298)
	close.size = Vector2(572, 26)
	UiSkin.apply_button(close, skin)
	close.pressed.connect(_toggle_help)
	help_panel.add_child(close)
	close.grab_focus()

func finish(success: bool) -> void:
	if closed or (success and (not puzzle.solved or paused)):
		return
	closed = true
	finished.emit(success)
