extends CanvasLayer

var world: Node2D
var root: Control
var vitals: Label
var objective: Label
var abilities: Label
var prompt: Label
var notice: Label
var boss: Label
var boss_panel: Panel
var health_bar: ColorRect
var energy_bar: ColorRect
var dialogue_panel: Panel
var speaker: Label
var dialogue_text: Label
var dialogue_open := false
var dialogue_lines: Array = []
var dialogue_done: Callable
var menu: Panel
var menu_title: Label
var resume_button: Button
var load_button: Button
var visual_button: Button
var message_time := 0.0

func panel(rect: Rect2, parent: Node = null) -> Panel:
	if parent == null:
		parent = root
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.095, 0.94)
	style.border_color = Color("314257")
	style.set_border_width_all(1)
	node.add_theme_stylebox_override("panel", style)
	parent.add_child(node)
	return node

func label_at(text: String, point: Vector2, size: Vector2, parent: Node = null, font_size: int = 10, color: Color = Color("dce8ef")) -> Label:
	if parent == null:
		parent = root
	var node := Label.new()
	node.text = text
	node.position = point
	node.size = size
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

func _ready() -> void:
	layer = 10
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top := panel(Rect2(12, 10, 184, 53))
	vitals = label_at("SHADEPI / 100", Vector2(10, 4), Vector2(160, 14), top)
	for y in [25, 37]:
		var bar := ColorRect.new()
		bar.position = Vector2(10, y)
		bar.size = Vector2(164, 5)
		bar.color = Color("1d2c3e")
		top.add_child(bar)
	health_bar = ColorRect.new()
	health_bar.position = Vector2(10, 25)
	health_bar.size = Vector2(164, 5)
	health_bar.color = Color("ee597f")
	top.add_child(health_bar)
	energy_bar = ColorRect.new()
	energy_bar.position = Vector2(10, 37)
	energy_bar.size = Vector2(164, 5)
	energy_bar.color = Color("58d4e5")
	top.add_child(energy_bar)
	var mission := panel(Rect2(394, 10, 234, 54))
	label_at("ECHOS IN NEON / SPÄTERE SZENE", Vector2(10, 4), Vector2(218, 14), mission, 10, Color("65d4df"))
	objective = label_at("Sprich mit Raven", Vector2(10, 22), Vector2(214, 28), mission, 11)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boss_panel = panel(Rect2(204, 10, 182, 54))
	boss = label_at("", Vector2(5, 7), Vector2(172, 35), boss_panel, 10, Color("f18aaa"))
	boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar := panel(Rect2(0, 334, 640, 26))
	label_at("WASD  Bewegen     J / Maus  Katana     Leertaste  Ausweichen     Esc  Menü", Vector2(12, 5), Vector2(616, 18), bar, 10)
	abilities = label_at("", Vector2(12, 307), Vector2(615, 22), root, 10, Color("91c5d9"))
	prompt = label_at("", Vector2(120, 278), Vector2(400, 23), root, 12, Color("e1f5ff"))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Color(0.03, 0.05, 0.09, 0.9)
	prompt.add_theme_stylebox_override("normal", shadow)
	notice = label_at("", Vector2(100, 73), Vector2(440, 25), root, 11, Color("b5e9f0"))
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue_panel = panel(Rect2(64, 228, 512, 101))
	speaker = label_at("", Vector2(12, 7), Vector2(470, 18), dialogue_panel, 12, Color("66d7e3"))
	dialogue_text = label_at("", Vector2(12, 29), Vector2(484, 48), dialogue_panel, 12)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_at("E / Enter · Weiter", Vector2(372, 80), Vector2(130, 16), dialogue_panel, 9, Color("93a7ba"))
	dialogue_panel.hide()
	menu = panel(Rect2(145, 27, 350, 304))
	menu_title = label_at("ECHOS IN NEON", Vector2(20, 12), Vector2(310, 26), menu, 19)
	label_at("Shadepi · Im Schatten des Raben", Vector2(20, 40), Vector2(310, 22), menu, 11, Color("7cc4d4"))
	label_at("Späterer Testabschnitt\nRaven und Shadepi kennen sich bereits.", Vector2(20, 62), Vector2(310, 28), menu, 10, Color("9db0c4"))
	resume_button = button_at("Testszene starten", 96, func(): world.close_menu())
	load_button = button_at("Spielstand laden", 128, func(): world.load_game())
	button_at("Testszene neu starten", 160, func(): world.new_game())
	button_at("Musik / Ton umschalten", 192, func(): world.toggle_audio())
	visual_button = button_at("Bildstil: " + world.VISUAL_PRESETS[world.visual_quality], 224, func(): world.cycle_visual_quality())
	label_at("E  Interagieren   Q  Raven-Hack   C  Tarnung\nF5  Speichern   F9  Laden   V  Bildstil", Vector2(20, 263), Vector2(310, 35), menu, 10, Color("9db0c4"))

func button_at(text: String, y: float, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = Vector2(20, y)
	button.size = Vector2(310, 27)
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(callback)
	menu.add_child(button)
	return button

func show_menu(title: String = "ECHOS IN NEON") -> void:
	menu_title.text = title
	resume_button.text = "Fortsetzen" if world.started else "Testszene starten"
	load_button.disabled = SaveService.read().is_empty()
	menu.show()
	resume_button.grab_focus()

func toast(text: String) -> void:
	notice.text = text
	message_time = 3.2

func dialogue(lines: Array, done: Callable = Callable()) -> void:
	dialogue_lines = lines.duplicate()
	dialogue_done = done
	dialogue_open = true
	dialogue_panel.show()
	advance_dialogue()

func advance_dialogue() -> void:
	if dialogue_lines.is_empty():
		dialogue_open = false
		dialogue_panel.hide()
		if dialogue_done.is_valid():
			dialogue_done.call()
		return
	var line: Array = dialogue_lines.pop_front()
	speaker.text = line[0]
	dialogue_text.text = line[1]

func _process(delta: float) -> void:
	if world == null or world.player == null:
		return
	message_time = maxf(0.0, message_time - delta)
	notice.visible = message_time > 0.0
	vitals.text = "SHADEPI / %03d   EN %03d" % [world.player.health, roundi(world.player.energy)]
	health_bar.size.x = 164 * world.player.health / 100.0
	energy_bar.size.x = 164 * world.player.energy / 100.0
	objective.text = ["Sprich mit Raven", "Öffne die Sperre am Terminal", "Besiege Chrome Jackal", "Sichere die Daten am Ausgang", "Test abgeschlossen · frei erkunden"][world.stage]
	var cloak: String = ("%.0fs" % world.player.cloak_time) if world.player.cloak_time > 0 else (("%.0fs" % world.player.cloak_cooldown) if world.player.cloak_cooldown > 0 else "bereit")
	var hack: String = ("%.0fs" % world.hack_cooldown) if world.hack_cooldown > 0 else "bereit"
	abilities.text = "C  Tarnfeld: %s     Q  Raven-Hack: %s     F5  Speichern / F9  Laden     V  Bildstil" % [cloak, hack]
	prompt.text = world.interaction_prompt()
	prompt.visible = not prompt.text.is_empty() and not world.is_busy()
	abilities.visible = not dialogue_open and not world.menu_open
	boss.text = "CHROME JACKAL\n" + ("IMPLANTATE GESTÖRT" if world.enemy.exposed > 0 else "Panzerung aktiv") if world.stage == 2 else ""
	boss_panel.visible = world.stage == 2
