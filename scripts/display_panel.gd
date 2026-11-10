extends Control
## v0.34.0 · CodexAI. Shared main/pause display options, keyboard and controller.

signal closed
const UiSkin = preload("res://scripts/ui_skin.gd")
const Settings = preload("res://scripts/display_settings.gd")
var settings: Node
var mode_select: OptionButton
var resolution_select: OptionButton
var quality_select: OptionButton
var scaling_select: OptionButton
var output_label: Label
var status_label: Label
var close_button: Button
var sheet: Panel

func _ready() -> void:
	settings = get_node("/root/DisplaySettings")
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.04, 0.9)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	sheet = Panel.new()
	sheet.position = Vector2(150, 8)
	sheet.size = Vector2(340, 344)
	sheet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sheet)
	_text("ANZEIGE", Vector2(18, 10), Vector2(304, 28), 32)
	_text("16:9 · Auflösung und Bildschirmmodus", Vector2(18, 39), Vector2(304, 19))
	_text("Darstellung", Vector2(18, 59), Vector2(304, 20))
	quality_select = _select(78)
	quality_select.add_item("HQ · bis 1920 × 1080 nativ")
	quality_select.add_item("Klassisch · 640 × 360")
	quality_select.item_selected.connect(func(index): settings.set_hq(index == 0))
	_text("Bildschirmmodus", Vector2(18, 109), Vector2(304, 20))
	mode_select = _select(128)
	for title in Settings.MODE_NAMES:
		mode_select.add_item(title)
	mode_select.item_selected.connect(func(index): settings.set_mode(index))
	_text("Fenstergröße (Vollbild nutzt den Desktop)", Vector2(18, 159), Vector2(304, 20))
	resolution_select = _select(178)
	for resolution in Settings.RESOLUTIONS:
		resolution_select.add_item("%d × %d" % [resolution.x, resolution.y])
	resolution_select.item_selected.connect(func(index): settings.set_resolution(index))
	_text("Skalierung", Vector2(18, 209), Vector2(304, 20))
	scaling_select = _select(228)
	scaling_select.add_item("Bildschirmfüllend · empfohlen")
	scaling_select.add_item("Pixelgenau · nur ganze Stufen")
	scaling_select.item_selected.connect(func(index): settings.set_integer_scaling(index == 1))
	output_label = _text("", Vector2(18, 261), Vector2(304, 14), 14)
	status_label = _text("", Vector2(18, 279), Vector2(304, 29), 13)
	close_button = Button.new()
	close_button.position = Vector2(18, 311)
	close_button.size = Vector2(304, 27)
	close_button.text = "Zurück · Esc / B"
	close_button.pressed.connect(dismiss)
	sheet.add_child(close_button)
	settings.changed.connect(_sync)
	hide()

func _text(value: String, at: Vector2, extent: Vector2, font_size: int = 20) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.size = extent
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", UiSkin.font())
	label.add_theme_font_size_override("font_size", font_size)
	sheet.add_child(label)
	return label

func _select(y: int) -> OptionButton:
	var select := OptionButton.new()
	select.position = Vector2(18, y)
	select.size = Vector2(304, 27)
	sheet.add_child(select)
	return select

func present(theme: String) -> void:
	sheet.add_theme_stylebox_override("panel", UiSkin.panel(theme))
	var colors := UiSkin.colors(theme)
	for child in sheet.get_children():
		if child is Label:
			UiSkin.style_label(child, colors.text)
	for button in [quality_select, mode_select, resolution_select, scaling_select, close_button]:
		UiSkin.apply_button(button, theme)
		if button is OptionButton:
			var popup: PopupMenu = button.get_popup()
			popup.add_theme_stylebox_override("panel", UiSkin.panel(theme))
			popup.add_theme_stylebox_override("hover", UiSkin.button(theme, "hover"))
			popup.add_theme_font_override("font", UiSkin.font())
			popup.add_theme_font_size_override("font_size", 20)
			popup.add_theme_color_override("font_color", colors.text)
	_sync()
	show()
	mode_select.grab_focus()

func _sync() -> void:
	quality_select.select(0 if settings.hq_enabled else 1)
	mode_select.select(settings.mode)
	resolution_select.select(settings.resolution_index)
	var resolution_had_focus := resolution_select.has_focus()
	resolution_select.disabled = settings.mode != Settings.Mode.WINDOWED
	if resolution_had_focus and resolution_select.disabled:
		mode_select.grab_focus()
	scaling_select.select(1 if settings.integer_scaling else 0)
	var extent := get_window().size
	var render_size: Vector2i = settings.game_render_size()
	output_label.text = "%d × %d intern → %d × %d Ausgabe" % [render_size.x,render_size.y,extent.x,extent.y]
	status_label.text = "HQ zeichnet bis Full HD; größere Ausgaben\nvergrößern dieses Bild. F11 · Vollbild" if settings.hq_enabled else "Klassisches Pixelbild · F11 / Alt+Enter\nwechselt den Bildschirmmodus."
	if settings.integer_scaling:
		status_label.text = "Pixelstufen können breite Ränder erzeugen.\nF11 / Alt+Enter · Vollbild umschalten"
	if settings.save_error != OK:
		status_label.text = "Aktiv; Einstellungen konnten nicht gespeichert werden."
	var controls: Array[Control] = [quality_select, mode_select, scaling_select, close_button]
	if not resolution_select.disabled:
		controls.insert(2, resolution_select)
	for i in controls.size():
		var previous := controls[(i - 1 + controls.size()) % controls.size()]
		var next := controls[(i + 1) % controls.size()]
		controls[i].focus_neighbor_top = controls[i].get_path_to(previous)
		controls[i].focus_previous = controls[i].get_path_to(previous)
		controls[i].focus_neighbor_bottom = controls[i].get_path_to(next)
		controls[i].focus_next = controls[i].get_path_to(next)
		controls[i].focus_neighbor_left = NodePath(".")
		controls[i].focus_neighbor_right = NodePath(".")

func dismiss() -> void:
	for select in [quality_select, mode_select, resolution_select, scaling_select]:
		select.get_popup().hide()
	hide()
	closed.emit()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# Let a dropdown handle its own cancel before dismissing the options panel.
	for select in [quality_select, mode_select, resolution_select, scaling_select]:
		if select.get_popup().visible:
			return
	var cancel := event.is_action_pressed("ui_cancel")
	if event is InputEventJoypadButton:
		cancel = cancel or (event.pressed and event.button_index == JOY_BUTTON_B)
	if cancel:
		dismiss()
		get_viewport().set_input_as_handled()
