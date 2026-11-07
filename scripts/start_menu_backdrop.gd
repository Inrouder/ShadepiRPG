extends Control

const CITY := preload("res://assets/menu/start-city.png")
const HEROES := preload("res://assets/menu/start-heroes.png")
const ATMOSPHERE := preload("res://shaders/menu_atmosphere.gdshader")
const VIEW := Vector2(640, 360)
# Fixed illustration and fixed roof: pointer/focus must never slide the feet.
const HERO_RECT := Rect2(0, 6, 310, 310)

var elapsed := 0.0
var quality := 2
var pulse := 0.0
var pulse_position := Vector2(240, 210)
var city: TextureRect
var heroes: TextureRect
var weather: Control
var atmosphere: ColorRect
var atmosphere_material: ShaderMaterial

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	city = TextureRect.new()
	city.texture = CITY
	city.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	city.size = VIEW + Vector2(20, 12)
	city.position = Vector2(-10, -6)
	city.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(city)
	heroes = TextureRect.new()
	heroes.texture = HEROES
	heroes.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	heroes.size = HERO_RECT.size
	heroes.position = HERO_RECT.position
	heroes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(heroes)
	weather = Control.new()
	weather.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weather.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	weather.draw.connect(_draw_weather)
	add_child(weather)
	atmosphere = ColorRect.new()
	atmosphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere_material = ShaderMaterial.new()
	atmosphere_material.shader = ATMOSPHERE
	atmosphere.material = atmosphere_material
	add_child(atmosphere)
	visibility_changed.connect(_sync_activity)
	set_quality(quality)
	_sync_activity()

func _sync_activity() -> void:
	var active := is_visible_in_tree()
	set_process(active)
	set_process_input(active)

func set_quality(value: int) -> void:
	quality = clampi(value, 0, 2)
	if atmosphere_material != null:
		atmosphere_material.set_shader_parameter("strength", [0.0, 0.55, 1.0][quality])
		atmosphere.visible = quality > 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pulse_at(get_local_mouse_position())

func pulse_at(point: Vector2) -> void:
	pulse_position = point.clamp(Vector2.ZERO, VIEW)
	pulse = 1.0

func _process(delta: float) -> void:
	elapsed += delta
	pulse = maxf(0.0, pulse - delta * 1.4)
	atmosphere_material.set_shader_parameter("clock", elapsed)
	atmosphere_material.set_shader_parameter("focus", pulse_position / VIEW)
	atmosphere_material.set_shader_parameter("pulse", pulse)
	weather.queue_redraw()

func _draw_weather() -> void:
	# Different depths and speeds make the downpour read as a volume.
	var counts := [35, 105, 180]
	for i in int(counts[quality]):
		var depth := float(i % 3 + 1) / 3.0
		var speed := 105.0 + depth * 190.0
		var wind := 25.0
		var p := Vector2(fposmod(i * 87.3 - elapsed * wind * depth, 690.0) - 25.0,
			fposmod(i * 53.7 + elapsed * speed, 400.0) - 20.0)
		var length := 4.0 + depth * 13.0
		var alpha := (0.07 + depth * 0.19) * (0.6 if p.x > 350 else 1.0)
		weather.draw_line(p, p + Vector2(-length * 0.28, length), Color(0.57, 0.82, 0.94, alpha), 0.55 + depth * 0.5, true)
	# Flying traffic passes across the skyline, behind the menu text area.
	for i in 6:
		var x := fposmod(i * 111.0 + elapsed * (12.0 + i * 3.0), 760.0) - 60.0
		var y := 165.0 + float((i * 31) % 117)
		var color := Color(0.3, 0.85, 1.0, 0.65) if i % 2 == 0 else Color(1.0, 0.19, 0.49, 0.55)
		weather.draw_line(Vector2(x - 15, y), Vector2(x, y), Color(color, 0.18), 1.0, true)
		weather.draw_line(Vector2(x, y), Vector2(x + 4, y), color, 1.5, true)
	# Small ground rings and neon reflections, clipped to the rooftop.
	if quality > 0:
		for i in 16:
			var life := fposmod(elapsed * 0.8 + float(i) * 0.137, 1.0)
			var p := Vector2(18 + (i * 29) % 292, 303 + (i * 7) % 28)
			weather.draw_set_transform(p, 0, Vector2(1, 0.32))
			weather.draw_arc(Vector2.ZERO, 1 + life * 7, 0, TAU, 16, Color(0.39, 0.81, 0.93, (1 - life) * 0.23), 0.6, true)
		weather.draw_set_transform(Vector2.ZERO)
	if pulse > 0.0:
		weather.draw_arc(pulse_position, (1 - pulse) * 38 + 3, 0, TAU, 40, Color(0.4, 0.9, 1, pulse * 0.32), 0.8, true)
