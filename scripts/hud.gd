extends CanvasLayer

const StartMenuBackdrop = preload("res://scripts/start_menu_backdrop.gd")

const UiSkin = preload("res://scripts/ui_skin.gd")
var world: Node2D
var root: Control
var vitals: Label
var objective: Label
var combat_hint: Label
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
var start_backdrop: Control
var menu_chrome: Control
var menu_emblem: TextureRect
var menu_tagline: Label
var menu_skin := "raven"
var menu_buttons: Array[Button] = []
var display_button: Button
var display_panel: Control
var game_hud_nodes: Array[CanvasItem] = []
var menu_button_tweens: Dictionary = {}
var visual_button: Button
var mode_button: Button
var requested_coop: = false
var controls: Label
var raven_vitals: Label
var raven_health: ColorRect
var raven_energy: ColorRect
var vital_tracks: Array[ColorRect] = []
var message_time: = 0.0
var dialogue_next: Label
var admin_panel: Panel
var admin_close_button: Button
var admin_chapter_picker: OptionButton
var admin_chapter_button: Button
var admin_checks: Dictionary = {}
var admin_title_clicks := 0

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
	start_backdrop = StartMenuBackdrop.new()
	root.add_child(start_backdrop)
	var top: = panel(Rect2(12, 10, 184, 53))
	game_hud_nodes.append(top)
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
	game_hud_nodes.append(mission)
	mission_title = label_at("ECHOS IN NEON / SPÄTERE SZENE", Vector2(10, 4), Vector2(218, 14), mission, 10, Color("65d4df"))
	objective = label_at("Sprich mit Raven", Vector2(10, 22), Vector2(214, 28), mission, 11)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_hint = label_at("", Vector2(14, 65), Vector2(360, 28), root, 10, Color("aeeaf2"))
	combat_hint.add_theme_color_override("font_shadow_color", Color.BLACK)
	combat_hint.add_theme_constant_override("shadow_offset_x", 1)
	combat_hint.add_theme_constant_override("shadow_offset_y", 1)
	game_hud_nodes.append(combat_hint)
	boss_panel = panel(Rect2(204, 10, 182, 54))
	game_hud_nodes.append(boss_panel)
	boss = label_at("", Vector2(5, 7), Vector2(172, 35), boss_panel, 10, Color("f18aaa"))
	boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var bar: = panel(Rect2(0, 334, 640, 26))
	game_hud_nodes.append(bar)
	controls = label_at("WASD  Bewegen     J / Maus  Katana     Leertaste  Ausweichen     Esc  Menü", Vector2(12, 5), Vector2(616, 18), bar, 10)
	abilities = label_at("", Vector2(12, 307), Vector2(615, 22), root, 10, Color("91c5d9"))
	prompt = label_at("", Vector2(30, 270), Vector2(580, 34), root, 12, Color("e1f5ff"))
	game_hud_nodes.append(abilities)
	game_hud_nodes.append(prompt)
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var shadow: = StyleBoxFlat.new()
	shadow.bg_color = Color(0.03, 0.05, 0.09, 0.9)
	prompt.add_theme_stylebox_override("normal", shadow)
	notice = label_at("", Vector2(100, 100), Vector2(440, 44), root, 11, Color("b5e9f0"))
	game_hud_nodes.append(notice)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	dialogue_next = label_at("E / Enter / A · Weiter", Vector2(360, 74), Vector2(218, 14), dialogue_panel, 9, Color("9eb2c7"))
	dialogue_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dialogue_panel.hide()
	# Pixel-art menu: steel frame, title plate and buttons from assets/ui/<theme>
	# (tools/ui_pixel), Silkscreen / Shadepi Pixel fonts at whole-pixel sizes.
	menu = panel(Rect2(350, 14, 276, 332))
	menu.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	menu_chrome = preload("res://scripts/menu_chrome.gd").new()
	menu_chrome.size = menu.size
	menu.add_child(menu_chrome)
	start_backdrop.quality_changed.connect(func(value): menu_chrome.strength = [0.0, 0.55, 1.0][value])
	menu_emblem = TextureRect.new()
	menu_emblem.position = Vector2(238, 14)
	menu.add_child(menu_emblem)
	menu_title = label_at("SHADEPI", Vector2(14, 7), Vector2(222, 36), menu)
	menu_title.clip_text = true
	menu_tagline = label_at("ECHOS IN NEON", Vector2(15, 40), Vector2(244, 20), menu)
	menu_description = label_at("IM SCHATTEN DES RABEN\nEine Cyberpunk-Saga", Vector2(15, 60), Vector2(246, 32), menu)
	mode_button = button_at("Modus · Einzelspieler", 94, _switch_mode)
	resume_button = button_at("Testszene starten", 124, start_selected)
	load_button = button_at("Spielstand laden", 154, func(): world.load_game(requested_coop))
	restart_button = button_at("Testszene neu starten", 184, _start_new)
	var audio_button := button_at("Ton An/Aus", 214, func(): world.toggle_audio())
	audio_button.size.x = 116
	audio_button.tooltip_text = "Musik und Spielgeräusche ein- oder ausschalten."
	display_button = button_at("Anzeige", 214, _open_display_panel)
	display_button.position.x = 144
	display_button.set_meta("home_x", 144.0)
	display_button.size.x = 116
	display_button.tooltip_text = "Vollbild, Fenstergröße und Skalierung · F11 / Alt+Enter"
	visual_button = button_at("Bildstil: " + world.VISUAL_PRESETS[world.visual_quality], 244, func(): world.cycle_visual_quality())
	menu_help = label_at("Controller · Stick wählen, A bestätigen\nF11 Vollbild · F5 Speichern · F9 Laden", Vector2(16, 279), Vector2(246, 37), menu)
	display_panel = preload("res://scripts/display_panel.gd").new()
	root.add_child(display_panel)
	display_panel.closed.connect(func(): display_button.grab_focus())

	_build_admin_panel()
	_build_feedback()
	menu_title.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_title.gui_input.connect(_secret_title_click)

func button_at(text: String, y: float, callback: Callable) -> Button:
	var button: = Button.new()
	button.text = text
	button.position = Vector2(16, y)
	button.size = Vector2(244, 26)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	UiSkin.apply_button(button, menu_skin)
	menu_buttons.append(button)
	button.pressed.connect(callback)
	menu.add_child(button)
	button.set_meta("home_x", button.position.x)
	button.mouse_entered.connect(_animate_menu_button.bind(button))
	button.mouse_exited.connect(_animate_menu_button.bind(button))
	button.focus_entered.connect(_animate_menu_button.bind(button))
	button.focus_exited.connect(_animate_menu_button.bind(button))
	return button

func _animate_menu_button(button: Button) -> void:
	var active := not button.disabled and (button.is_hovered() or button.has_focus())
	if menu_button_tweens.has(button):
		menu_button_tweens[button].kill()
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Whole-pixel slide instead of scaling, so the pixel art never resamples.
	tween.tween_property(button, "position:x", float(button.get_meta("home_x", 16.0)) + (3.0 if active else 0.0), 0.1)
	menu_button_tweens[button] = tween
	if active and start_backdrop.visible:
		start_backdrop.pulse_at(button.global_position + button.size * 0.5)

## Scene look of the pause menu; chapter scripts override it.
func menu_theme() -> String:
	return "raven"

func apply_menu_skin(theme: String) -> void:
	menu_skin = theme
	var c := UiSkin.colors(theme)
	menu.add_theme_stylebox_override("panel", UiSkin.panel(theme))
	menu_emblem.texture = UiSkin.emblem(theme)
	UiSkin.style_label(menu_title, c.text, "title", 32)
	UiSkin.style_label(menu_tagline, c.primary, "title")
	UiSkin.style_label(menu_description, c.muted)
	UiSkin.style_label(menu_help, c.muted)
	menu_chrome.primary = c.primary
	menu_chrome.accent = c.accent
	for button in menu_buttons:
		if is_instance_valid(button):
			UiSkin.apply_button(button, theme)

func show_menu(title: String = "ECHOS IN NEON") -> void :
	requested_coop = world.coop
	_show_menu_shell(title)

func _show_menu_shell(title: String) -> void:
	if admin_panel != null:
		admin_panel.hide()
	var opening: bool = not world.started
	# Draw HQ menu PNGs and fonts at window resolution, retaining the game's
	# original viewport rendering as soon as play starts or the game is paused.
	get_node("/root/DisplaySettings").set_menu_context(opening)
	start_backdrop.visible = opening
	start_backdrop.set_quality(world.visual_quality)
	menu_chrome.strength = [0.0, 0.55, 1.0][world.visual_quality]
	menu.position = Vector2(350, 14) if opening else Vector2(182, 14)
	apply_menu_skin("raven" if opening else menu_theme())
	menu_title.text = "SHADEPI" if opening else title
	menu_title.add_theme_font_size_override("font_size", 32 if opening else (16 if title.length() <= 18 else 8))
	menu_description.text = "IM SCHATTEN DES RABEN\nEine Cyberpunk-Saga" if opening else "Pause · Einsatzstatus und Optionen"
	if opening:
		world.set_music_section("menu")
		for node in game_hud_nodes:
			node.hide()
	_update_mode_buttons()
	menu.show()
	resume_button.grab_focus()

func hide_menu() -> void:
	get_node("/root/DisplaySettings").set_menu_context(false)
	if display_panel != null and display_panel.visible:
		display_panel.dismiss()
	menu.hide()
	start_backdrop.hide()
	for node in game_hud_nodes:
		node.show()

func _open_display_panel() -> void:
	display_panel.present("raven" if not world.started else menu_theme())

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

# Intentional QA-only entry: Ctrl+Shift+F10 or five title clicks in the main menu.
func _input(event: InputEvent) -> void:
	if world == null or not world.menu_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_F10:
			_toggle_admin_panel()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and admin_panel != null and admin_panel.visible:
			_close_admin_panel()
			get_viewport().set_input_as_handled()

func _secret_title_click(event: InputEvent) -> void:
	if not world.menu_open or admin_panel.visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		admin_title_clicks += 1
		if admin_title_clicks >= 5:
			admin_title_clicks = 0
			_toggle_admin_panel()

func _build_admin_panel() -> void:
	admin_panel = panel(Rect2(72, 10, 496, 339))
	admin_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	label_at("DEV // TESTLAB", Vector2(18, 9), Vector2(355, 24), admin_panel, 19, Color("79e7f0"))
	label_at("Testwerkzeuge · separate Kontrollpunkte", Vector2(19, 32), Vector2(385, 14), admin_panel, 10, Color("b8c1d8"))
	admin_close_button = Button.new()
	admin_close_button.text = "X"
	admin_close_button.position = Vector2(454, 10)
	admin_close_button.size = Vector2(27, 27)
	admin_close_button.pressed.connect(_close_admin_panel)
	admin_panel.add_child(admin_close_button)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(15, 54)
	scroll.size = Vector2(466, 267)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	admin_panel.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 4)
	scroll.add_child(content)

	var settings := [
		["unlock_all", "Alle Kapitel (1–7) freischalten"],
		["god_mode", "Unendlich Leben · auch im Fahrzeug"],
		["one_hit", "Ein Treffer = K.O. (Story-Schutz bleibt)"],
		["infinite_energy", "Unendliche Energie"],
		["no_cooldowns", "Keine Wartezeiten bei Fähigkeiten"],
		["freeze_timer", "60-Sekunden-Fluchttimer anhalten"],
	]
	for entry in settings:
		var option := str(entry[0])
		var checkbox := CheckBox.new()
		checkbox.text = str(entry[1])
		checkbox.button_pressed = world.admin_enabled(option)
		checkbox.add_theme_font_size_override("font_size", 12)
		checkbox.toggled.connect(_set_admin_checkbox.bind(option))
		content.add_child(checkbox)
		admin_checks[option] = checkbox

	var chapter_heading := Label.new()
	chapter_heading.text = "KAPITEL-WAHL · separater Test-Spielstand"
	chapter_heading.add_theme_font_size_override("font_size", 11)
	chapter_heading.add_theme_color_override("font_color", Color("79e7f0"))
	content.add_child(chapter_heading)
	var row := HBoxContainer.new()
	content.add_child(row)
	admin_chapter_picker = OptionButton.new()
	admin_chapter_picker.custom_minimum_size = Vector2(269, 29)
	admin_chapter_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for entry in [
		[1, "Kapitel 1 · Raven / Jackal"],
		[2, "Kapitel 2 · Deep Dive"],
		[3, "Kapitel 3 · Pakt"],
		[4, "Kapitel 4 · Hangar"],
		[5, "Kapitel 5 · Heiligtum"],
		[6, "Kapitel 6 · Tower / Kenzō"],
		[7, "Kapitel 7 · See / Finale"],
	]:
		admin_chapter_picker.add_item(str(entry[1]), int(entry[0]))
	row.add_child(admin_chapter_picker)
	admin_chapter_button = Button.new()
	admin_chapter_button.text = "Test starten"
	admin_chapter_button.pressed.connect(_admin_start_chapter)
	row.add_child(admin_chapter_button)
	_refresh_admin_controls()

	var actions := HBoxContainer.new()
	content.add_child(actions)
	var heal := Button.new()
	heal.text = "Leben / Energie auffüllen"
	heal.pressed.connect(func(): world.admin_heal())
	actions.add_child(heal)
	var defeat := Button.new()
	defeat.text = "Aktuelle Gegner besiegen"
	defeat.pressed.connect(_admin_defeat_enemies)
	actions.add_child(defeat)
	var reset := Button.new()
	reset.text = "Alle Cheats AUS"
	reset.pressed.connect(_admin_reset)
	content.add_child(reset)
	var note := Label.new()
	note.text = "Test-Kontrollpunkte getrennt von normalen Spielständen.\nEsc schließt das Fenster."
	note.add_theme_font_size_override("font_size", 10)
	note.add_theme_color_override("font_color", Color("aab8c8"))
	content.add_child(note)
	admin_panel.hide()

func _refresh_admin_controls() -> void:
	if admin_chapter_picker == null:
		return
	var unlocked: bool = world.admin_enabled("unlock_all")
	admin_chapter_picker.disabled = not unlocked
	admin_chapter_button.disabled = not unlocked

func _set_admin_checkbox(checked: bool, option: String) -> void:
	if not world.set_admin_option(option, checked):
		world.toast("Test-Einstellung konnte nicht gespeichert werden.")
	_refresh_admin_controls()

func _toggle_admin_panel() -> void:
	if admin_panel.visible:
		_close_admin_panel()
	else:
		world.begin_admin_test_session()
		for option in admin_checks:
			var checkbox: CheckBox = admin_checks[option]
			checkbox.set_pressed_no_signal(world.admin_enabled(option))
		_refresh_admin_controls()
		admin_panel.show()
		admin_close_button.grab_focus()

func _close_admin_panel() -> void:
	admin_panel.hide()
	resume_button.grab_focus()

func _admin_start_chapter() -> void:
	if world.admin_enabled("unlock_all"):
		world.admin_jump_to_chapter(admin_chapter_picker.get_selected_id())

func _admin_defeat_enemies() -> void:
	_close_admin_panel()
	world.close_menu()
	var amount: int = world.admin_defeat_enemies()
	world.toast("Test: %d Gegner besiegt." % amount if amount > 0 else "Keine frei besiegbaren Gegner im Abschnitt.")

func _admin_reset() -> void:
	for option in admin_checks:
		var checkbox: CheckBox = admin_checks[option]
		checkbox.set_pressed_no_signal(false)
		world.set_admin_option(option, false)
	_refresh_admin_controls()
	world.toast("Alle Test-Cheats deaktiviert.")

var combo_label: Label
var hurt_overlay: ColorRect
var shown_combo := 0

func _build_feedback() -> void:
	hurt_overlay = ColorRect.new()
	hurt_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hurt_overlay.color = Color(0.85, 0.05, 0.12, 0.0)
	hurt_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hurt_overlay)
	root.move_child(hurt_overlay, 1)
	combo_label = label_at("", Vector2(470, 72), Vector2(160, 30), root, 20, Color("ffe08a"))
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_color_override("font_outline_color", Color("1a0d16"))
	combo_label.add_theme_constant_override("outline_size", 5)
	combo_label.pivot_offset = Vector2(140, 15)
	game_hud_nodes.append(combo_label)

func hurt_flash() -> void:
	if hurt_overlay != null:
		hurt_overlay.color.a = 0.32

func _update_feedback(delta: float) -> void:
	if combo_label == null:
		return
	hurt_overlay.color.a = maxf(0.0, hurt_overlay.color.a - delta * 1.4)
	var hits: int = world.combo_hits
	combo_label.visible = hits >= 2 and not world.is_busy()
	if hits != shown_combo:
		shown_combo = hits
		if hits >= 2:
			combo_label.text = "%d TREFFER" % hits
			combo_label.scale = Vector2.ONE * 1.45
			combo_label.modulate = Color("ffe08a") if hits < 6 else (Color("ff9b5e") if hits < 10 else Color("ff5f86"))
	combo_label.scale = combo_label.scale.move_toward(Vector2.ONE, delta * 4.0)
	combo_label.modulate.a = clampf(world.combo_time / 0.5, 0.0, 1.0)

func clear_toast() -> void:
	message_time = 0.0
	notice.visible = false

func toast(text: String) -> void :
	notice.text = text
	message_time = maxf(3.2, text.length() * 0.055)

func dialogue(lines: Array, done: Callable = Callable()) -> void :
	dialogue_lines.clear()
	for line: Array in lines:
		var pages := dialogue_pages(str(line[1]))
		for page in pages:
			var entry := line.duplicate()
			entry[1] = page
			dialogue_lines.append(entry)
	dialogue_done = done
	dialogue_open = true
	dialogue_panel.show()
	advance_dialogue()

func dialogue_pages(text: String) -> Array[String]:
	var pages: Array[String] = []
	var current := ""
	var font := dialogue_text.get_theme_font("font")
	for word in text.split(" "):
		var candidate := word if current.is_empty() else current + " " + word
		if not current.is_empty() and font.get_multiline_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, 562, 12).y > 44:
			pages.append(current)
			current = word
		else:
			current = candidate
	pages.append(current)
	return pages

func fit_hud_text() -> void:
	# Fixed widths prevent Label's minimum size from expanding beyond its panel.
	for entry in [[mission_title, 218, 10], [comic_caption, 219, 9], [controls, 616, 10], [abilities, 615, 10]]:
		var label: Label = entry[0]
		label.clip_text = true
		var font := label.get_theme_font("font")
		var font_size: int = entry[2]
		while font_size > 9 and font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > entry[1]:
			font_size -= 1
		label.add_theme_font_size_override("font_size", font_size)
		label.size.x = entry[1]

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
	dialogue_next.text = "E / Enter / A · " + ("Zurück zum Spiel" if dialogue_lines.is_empty() else "Weiter")
	_set_comic(comic_texture(str(line[2])) if line.size() > 2 else null)

func _process(delta: float) -> void :
	if world == null or world.player == null:
		return
	dialogue_panel.visible = dialogue_open and not world.menu_open
	comic_panel.visible = dialogue_panel.visible and comic_art.texture != null
	controls.visible = not dialogue_open and not world.menu_open
	fit_hud_text.call_deferred()
	message_time = maxf(0.0, message_time - delta)
	notice.visible = message_time > 0.0
	vitals.text = "SHADEPI / %03d   EN %03d" % [world.player.health, roundi(world.player.energy)]
	var coop: bool = world.coop
	var lead = world.raven if world.raven_leads() else world.player
	combat_hint.visible = not world.is_busy() and world.actor_is_playable(lead) and world.combat_ready()
	combat_hint.text = "K / RT halten · Kraftschuss" if lead.second_player else "K / RT halten · Kraftschlag    L / LT · Kick"
	if coop:
		combat_hint.text += "\nRaven: I / RT halten · Kraftschuss"
	for actor in [world.player, world.raven]:
		if actor.charging:
			combat_hint.text = ("RAVEN" if actor.second_player else "SHADEPI") + (" · BEREIT – loslassen!" if actor.charge_ready else " · Lädt … %d %%" % roundi(actor.charge_time / actor.CHARGE_SECONDS * 100))
			break
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
	_update_feedback(delta)
	if start_backdrop.visible:
		for node in game_hud_nodes:
			node.hide()
