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
var dialogue_open: = false
var dialogue_lines: Array = []
var dialogue_done: Callable
var comic_panel: Panel
var comic_art: TextureRect
var comic_caption: Label
var comic_fade: Tween
var menu: Panel
var menu_title: Label
var menu_description: Label
var mission_title: Label
var resume_button: Button
var load_button: Button
var restart_button: Button
var menu_help: Label
var visual_button: Button
var mode_button: Button
var requested_coop: = false
var controls: Label
var raven_vitals: Label
var raven_health: ColorRect
var raven_energy: ColorRect
var vital_tracks: Array[ColorRect] = []
var message_time: = 0.0

func panel(rect: Rect2, parent: Node = null) -> Panel:
	if parent == null:
		parent = root
	var node: = Panel.new()
	node.position = rect.position
	node.size = rect.size
	var style: = StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.095, 0.94)
	style.border_color = Color("314257")
	style.set_border_width_all(1)
	node.add_theme_stylebox_override("panel", style)
	parent.add_child(node)
	return node

func label_at(text: String, point: Vector2, size: Vector2, parent: Node = null, font_size: int = 10, color: Color = Color("dce8ef")) -> Label:
	if parent == null:
		parent = root
	var node: = Label.new()
	node.text = text
	node.position = point
	node.size = size
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

func _ready() -> void :
	layer = 10
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top: = panel(Rect2(12, 10, 184, 53))
	vitals = label_at("SHADEPI / 100", Vector2(10, 4), Vector2(160, 14), top)
	for y in [25, 37]:
		var bar: = ColorRect.new()
		bar.position = Vector2(10, y)
		bar.size = Vector2(164, 5)
		bar.color = Color("1d2c3e")
		top.add_child(bar)
		vital_tracks.append(bar)
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
	raven_vitals = label_at("", Vector2(10, 25), Vector2(160, 14), top, 10, Color("91e7f4"))
	raven_health = ColorRect.new()
	raven_health.position = Vector2(10, 44)
	raven_health.color = health_bar.color
	top.add_child(raven_health)
	raven_energy = ColorRect.new()
	raven_energy.position = Vector2(94, 44)
	raven_energy.color = energy_bar.color
	top.add_child(raven_energy)
	var mission: = panel(Rect2(394, 10, 234, 54))
	mission_title = label_at("ECHOS IN NEON / SPÄTERE SZENE", Vector2(10, 4), Vector2(218, 14), mission, 10, Color("65d4df"))
	objective = label_at("Sprich mit Raven", Vector2(10, 22), Vector2(214, 28), mission, 11)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boss_panel = panel(Rect2(204, 10, 182, 54))
	boss = label_at("", Vector2(5, 7), Vector2(172, 35), boss_panel, 10, Color("f18aaa"))
	boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar: = panel(Rect2(0, 334, 640, 26))
	controls = label_at("WASD  Bewegen     J / Maus  Katana     Leertaste  Ausweichen     Esc  Menü", Vector2(12, 5), Vector2(616, 18), bar, 10)
	abilities = label_at("", Vector2(12, 307), Vector2(615, 22), root, 10, Color("91c5d9"))
	prompt = label_at("", Vector2(120, 278), Vector2(400, 23), root, 12, Color("e1f5ff"))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var shadow: = StyleBoxFlat.new()
	shadow.bg_color = Color(0.03, 0.05, 0.09, 0.9)
	prompt.add_theme_stylebox_override("normal", shadow)
	notice = label_at("", Vector2(100, 73), Vector2(440, 25), root, 11, Color("b5e9f0"))
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	comic_panel = panel(Rect2(0, 0, 640, 360))
	var page_style: = StyleBoxFlat.new()
	page_style.bg_color = Color("0c1321")
	comic_panel.add_theme_stylebox_override("panel", page_style)
	var page_title: = label_at("SHADEPI  /  IM SCHATTEN DES RABEN", Vector2(24, 8), Vector2(390, 18), comic_panel, 10, Color("e69c9f"))
	page_title.add_theme_color_override("font_shadow_color", Color("491e33"))
	page_title.add_theme_constant_override("shadow_offset_y", 1)
	comic_caption = label_at("", Vector2(397, 8), Vector2(219, 18), comic_panel, 9, Color("a4cbd7"))
	comic_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var frame: = panel(Rect2(24, 29, 592, 213), comic_panel)
	var frame_style: = StyleBoxFlat.new()
	frame_style.bg_color = Color("070d18")
	frame_style.set_border_width_all(1)
	frame_style.border_color = Color("536b83")
	frame.add_theme_stylebox_override("panel", frame_style)
	comic_art = TextureRect.new()
	comic_art.position = Vector2(3, 3)
	comic_art.size = Vector2(586, 207)
	comic_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	comic_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	comic_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	frame.add_child(comic_art)
	comic_panel.hide()
	dialogue_panel = panel(Rect2(24, 251, 592, 92))
	var caption_style: = StyleBoxFlat.new()
	caption_style.bg_color = Color("101c2a")
	caption_style.set_border_width_all(1)
	caption_style.border_width_left = 3
	caption_style.border_color = Color("587f89")
	dialogue_panel.add_theme_stylebox_override("panel", caption_style)
	speaker = label_at("", Vector2(15, 6), Vector2(560, 18), dialogue_panel, 12, Color("8be0e4"))
	dialogue_text = label_at("", Vector2(15, 26), Vector2(562, 44), dialogue_panel, 12)
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_at("E / Enter / A · Weiter", Vector2(444, 72), Vector2(134, 14), dialogue_panel, 9, Color("9eb2c7"))
	dialogue_panel.hide()
	menu = panel(Rect2(145, 19, 350, 321))
	menu_title = label_at("ECHOS IN NEON", Vector2(20, 12), Vector2(310, 26), menu, 19)
	label_at("Shadepi · Im Schatten des Raben", Vector2(20, 40), Vector2(310, 22), menu, 11, Color("7cc4d4"))
	menu_description = label_at("Späterer Testabschnitt\nRaven und Shadepi kennen sich bereits.", Vector2(20, 62), Vector2(310, 28), menu, 10, Color("9db0c4"))
	mode_button = button_at("Modus · Einzelspieler", 94, _switch_mode)
	resume_button = button_at("Testszene starten", 124, start_selected)
	load_button = button_at("Spielstand laden", 154, func(): world.load_game(requested_coop))
	restart_button = button_at("Testszene neu starten", 184, _start_new)
	button_at("Musik / Ton umschalten", 214, func(): world.toggle_audio())
	visual_button = button_at("Bildstil: " + world.VISUAL_PRESETS[world.visual_quality], 244, func(): world.cycle_visual_quality())
	menu_help = label_at("Controller · Stick / Steuerkreuz wählen, A bestätigen\nF5 / LB Speichern   F9 Laden   V Bildstil", Vector2(20, 279), Vector2(310, 35), menu, 10, Color("9db0c4"))

func button_at(text: String, y: float, callback: Callable) -> Button:
	var button: = Button.new()
	button.text = text
	button.position = Vector2(20, y)
	button.size = Vector2(310, 27)
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(callback)
	menu.add_child(button)
	return button

func show_menu(title: String = "ECHOS IN NEON") -> void :
	menu_title.text = title
	requested_coop = world.coop
	_update_mode_buttons()
	menu.show()
	resume_button.grab_focus()

func _switch_mode() -> void :
	requested_coop = not requested_coop
	_update_mode_buttons()

func _update_mode_buttons() -> void :
	var mode: = "Lokal-Koop" if requested_coop else "Einzelspieler"
	mode_button.text = "Modus · " + mode
	resume_button.text = "Fortsetzen" if world.started and world.coop == requested_coop else mode + " starten"
	load_button.disabled = SaveService.read(SaveService.COOP_PATH if requested_coop else SaveService.PATH).is_empty()

func _start_new() -> void :
	world.set_coop(requested_coop)
	world.new_game()

func start_selected() -> void :
	if world.started and world.coop == requested_coop:
		world.close_menu()
	else:
		world.set_coop(requested_coop)
		world.new_game(false)

func toast(text: String) -> void :
	notice.text = text
	message_time = 3.2

func dialogue(lines: Array, done: Callable = Callable()) -> void :
	dialogue_lines = lines.duplicate()
	dialogue_done = done
	dialogue_open = true
	dialogue_panel.show()
	advance_dialogue()

func comic_texture(_key: String) -> Texture2D:
	return null

func clear_dialogue() -> void :
	dialogue_lines.clear()
	dialogue_done = Callable()
	dialogue_open = false
	dialogue_panel.hide()
	_set_comic(null)

func comic_heading() -> String:
	return mission_title.text

func _set_comic(texture: Texture2D) -> void :
	if comic_art.texture != texture:
		if comic_fade != null:
			comic_fade.kill()
		comic_art.texture = texture
		if texture != null:
			comic_art.modulate.a = 0.55
			comic_fade = create_tween()
			comic_fade.tween_property(comic_art, "modulate:a", 1.0, 0.18)
	comic_caption.text = comic_heading()
	comic_panel.visible = texture != null and not world.menu_open
	dialogue_panel.position.y = 251 if texture != null else 236

func advance_dialogue() -> void :
	if dialogue_lines.is_empty():
		var done: = dialogue_done
		clear_dialogue()
		if done.is_valid():
			done.call()
		return
	var line: Array = dialogue_lines.pop_front()
	speaker.text = line[0]
	dialogue_text.text = line[1]
	_set_comic(comic_texture(str(line[2])) if line.size() > 2 else null)

func _process(delta: float) -> void :
	if world == null or world.player == null:
		return
	dialogue_panel.visible = dialogue_open and not world.menu_open
	comic_panel.visible = dialogue_panel.visible and comic_art.texture != null
	message_time = maxf(0.0, message_time - delta)
	notice.visible = message_time > 0.0
	vitals.text = "SHADEPI / %03d   EN %03d" % [world.player.health, roundi(world.player.energy)]
	var coop: bool = world.coop
	var width: = 78.0 if coop else 164.0
	health_bar.position = Vector2(10, 20 if coop else 25)
	energy_bar.position = Vector2(94, 20) if coop else Vector2(10, 37)
	health_bar.size.x = width * world.player.health / 100.0
	energy_bar.size.x = width * world.player.energy / 100.0
	for track in vital_tracks:
		track.visible = not coop
	raven_vitals.visible = coop
	raven_health.visible = coop
	raven_energy.visible = coop
	if coop:
		raven_vitals.text = "RAVEN / %03d   EN %03d" % [world.raven.health, roundi(world.raven.energy)]
		raven_health.size = Vector2(width * world.raven.health / 100.0, 5)
		raven_energy.size = Vector2(width * world.raven.energy / 100.0, 5)
	controls.text = "1 Shadepi · WASD / J / Leertaste / E     2 Raven · Pfeile / U / O / P / Enter" if coop else "WASD  Bewegen     J / Maus  Katana     Leertaste  Ausweichen     Esc  Menü"
	objective.text = ["Sprich mit Raven", "Öffne die Sperre am Terminal", "Besiege Chrome Jackal", "Sichere die Daten am Ausgang", "Test abgeschlossen · frei erkunden"][world.stage]
	if coop and world.stage == 0:
		objective.text = "Trefft euch zur Einsatzbesprechung"
	var cloak: String = ("%.0fs" % world.player.cloak_time) if world.player.cloak_time > 0 else (("%.0fs" % world.player.cloak_cooldown) if world.player.cloak_cooldown > 0 else "bereit")
	var hack: String = ("%.0fs" % world.hack_cooldown) if world.hack_cooldown > 0 else "bereit"
	var cloak_key: = "C / Y" if world.gamepads.shadepi_device >= 0 else "C"
	abilities.text = "%s  Tarnfeld: %s     %s  Raven-Hack: %s     F5  Speichern / F9  Laden     V  Bildstil" % [cloak_key, cloak, world.hack_input_hint(), hack]
	if coop and world.gamepads.raven_device >= 0 and world.gamepads.shadepi_device < 0:
		controls.text = "Shadepi · WASD / J / C / E     Raven · Stick / X Angriff / Y Hack / B Ausweichen / A"
	elif world.gamepads.shadepi_device >= 0:
		controls.text = "Stick / Steuerkreuz  Bewegen    X Angriff    B Ausweichen    A Interagieren    Start Menü"
	prompt.text = world.interaction_prompt()
	if prompt.text.is_empty() and not world.is_busy():
		prompt.text = world.prop_prompt()
	prompt.visible = not prompt.text.is_empty() and not world.is_busy()
	abilities.visible = not dialogue_open and not world.menu_open
	boss.text = "CHROME JACKAL\n" + ("IMPLANTATE GESTÖRT" if world.enemy.exposed > 0 else "Panzerung aktiv") if world.stage == 2 else ""
	boss_panel.visible = world.stage == 2
