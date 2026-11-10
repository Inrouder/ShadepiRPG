extends Node
## v0.51.0 · CodexAI. Full-HD-capped HQ, classic fallback, shared chapter/input policy.

signal changed

enum Mode { WINDOWED, BORDERLESS, FULLSCREEN }
const SETTINGS_PATH := "user://shadepi-display.cfg"
const HQRenderer = preload("res://scripts/hq_renderer.gd")
const BASE_SIZE := Vector2i(640, 360)
const RESOLUTIONS: Array[Vector2i] = [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]
const MODE_NAMES := ["Fenster", "Fenstervollbild", "Vollbild"]
var mode: int = Mode.BORDERLESS
var last_fullscreen: int = Mode.BORDERLESS
var resolution_index := 0
var integer_scaling := false
var hq_enabled := true
var menu_context := false
var renderer: Node
var save_error: Error = OK
var preferences_path := SETTINGS_PATH

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_preferences()
	renderer = HQRenderer.new()
	add_child(renderer)
	set_menu_context(false)
	get_window().size_changed.connect(func(): changed.emit())
	_bootstrap.call_deferred()

func _bootstrap() -> void:
	# SceneTree test/gallery tools own their window; normal launches have a scene.
	if get_tree().current_scene != null:
		apply_window_mode()

func load_preferences(path: String = "") -> void:
	mode = Mode.BORDERLESS
	last_fullscreen = Mode.BORDERLESS
	resolution_index = 0
	integer_scaling = false
	hq_enabled = true
	var config := ConfigFile.new()
	if config.load(preferences_path if path.is_empty() else path) != OK:
		return
	var stored_mode: Variant = config.get_value("display", "mode", mode)
	if stored_mode is int and stored_mode >= Mode.WINDOWED and stored_mode <= Mode.FULLSCREEN:
		mode = stored_mode
	var stored_last: Variant = config.get_value("display", "last_fullscreen", last_fullscreen)
	if stored_last is int and stored_last in [Mode.BORDERLESS, Mode.FULLSCREEN]:
		last_fullscreen = stored_last
	var stored_resolution: Variant = config.get_value("display", "resolution", resolution_index)
	if stored_resolution is int and stored_resolution >= 0 and stored_resolution < RESOLUTIONS.size():
		resolution_index = stored_resolution
	var stored_scaling: Variant = config.get_value("display", "integer_scaling", false)
	if stored_scaling is bool:
		integer_scaling = stored_scaling
	var stored_hq: Variant = config.get_value("display", "hq_enabled", true)
	if stored_hq is bool: hq_enabled = stored_hq

func save_preferences(path: String = "") -> Error:
	var config := ConfigFile.new()
	config.set_value("display", "mode", mode)
	config.set_value("display", "last_fullscreen", last_fullscreen)
	config.set_value("display", "resolution", resolution_index)
	config.set_value("display", "integer_scaling", integer_scaling)
	config.set_value("display", "hq_enabled", hq_enabled)
	save_error = config.save(preferences_path if path.is_empty() else path)
	return save_error

func set_menu_context(opening: bool) -> void:
	menu_context = opening
	var window := get_window()
	window.content_scale_size = BASE_SIZE
	window.content_scale_factor = 1.0
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS if opening or hq_enabled else Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER if integer_scaling else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	if renderer != null: renderer.set_enabled(hq_enabled)

func set_hq(enabled: bool) -> void:
	hq_enabled = enabled
	set_menu_context(menu_context)
	save_preferences()
	changed.emit()

func game_render_size() -> Vector2i:
	return HQRenderer.target_size(get_window().size,integer_scaling) if hq_enabled else BASE_SIZE

func game_render_scale() -> float:
	return float(game_render_size().y)/BASE_SIZE.y

func set_mode(value: int) -> void:
	if value < Mode.WINDOWED or value > Mode.FULLSCREEN:
		return
	mode = value
	if mode != Mode.WINDOWED:
		last_fullscreen = mode
	apply_window_mode()
	save_preferences()
	changed.emit()

func set_resolution(index: int) -> void:
	if index < 0 or index >= RESOLUTIONS.size():
		return
	resolution_index = index
	if mode == Mode.WINDOWED:
		apply_window_mode()
	save_preferences()
	changed.emit()

func set_integer_scaling(enabled: bool) -> void:
	integer_scaling = enabled
	get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER if enabled else Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	save_preferences()
	changed.emit()

static func fit_window(requested: Vector2i, usable: Vector2i) -> Vector2i:
	# Reserve decorations/taskbar space, retaining 16:9 even on small monitors.
	var unit := mini(requested.x / 16, requested.y / 9)
	unit = mini(unit, mini(maxi(16, usable.x - 48) / 16, maxi(9, usable.y - 80) / 9))
	return Vector2i(maxi(1, unit) * 16, maxi(1, unit) * 9)

func apply_window_mode() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var window := get_window()
	window.min_size = BASE_SIZE
	match mode:
		Mode.BORDERLESS:
			# Godot fullscreen covers the desktop without exclusive display ownership.
			window.mode = Window.MODE_FULLSCREEN
		Mode.FULLSCREEN:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		Mode.WINDOWED:
			window.mode = Window.MODE_WINDOWED
			window.borderless = false
			var area := DisplayServer.screen_get_usable_rect(window.current_screen)
			window.size = fit_window(RESOLUTIONS[resolution_index], area.size)
			window.position = area.position + (area.size - window.size) / 2

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F11 or (event.alt_pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]):
		set_mode(last_fullscreen if mode == Mode.WINDOWED else Mode.WINDOWED)
		get_viewport().set_input_as_handled()
