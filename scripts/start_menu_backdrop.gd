extends Control

const CITY := preload("res://assets/menu/start-city.png")
const HEROES := preload("res://assets/menu/start-heroes.png")
const WIND := preload("res://shaders/menu_wind.gdshader")
const ATMOSPHERE := preload("res://shaders/menu_atmosphere.gdshader")
const VIEW := Vector2(640, 360)
# Leave roof clearance below both pairs of boots, including full parallax travel.
const HERO_RECT := Rect2(0, 6, 310, 310)

var elapsed := 0.0
var quality := 2
var pointer := Vector2.ZERO
var target_pointer := Vector2.ZERO
var pulse := 0.0
var pulse_position := Vector2(240, 210)
var city: TextureRect
var heroes: MeshInstance2D
var weather: Control
var atmosphere: ColorRect
var wind_material: ShaderMaterial
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
	heroes = MeshInstance2D.new()
	heroes.texture = HEROES
	heroes.mesh = _hero_mesh()
	heroes.position = HERO_RECT.position
	wind_material = ShaderMaterial.new()
	wind_material.shader = WIND
	heroes.material = wind_material
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

func _hero_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	const GRID := 48
	for y in GRID + 1:
		for x in GRID + 1:
			var uv := Vector2(x, y) / float(GRID)
			vertices.append(Vector3(uv.x * HERO_RECT.size.x, uv.y * HERO_RECT.size.y, 0))
			uvs.append(uv)
	for y in GRID:
		for x in GRID:
			var i := y * (GRID + 1) + x
			indices.append_array([i, i + 1, i + GRID + 1, i + 1, i + GRID + 2, i + GRID + 1])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

func _sync_activity() -> void:
	var active := is_visible_in_tree()
	set_process(active)
	set_process_input(active)

func set_quality(value: int) -> void:
	quality = clampi(value, 0, 2)
	if wind_material != null:
		wind_material.set_shader_parameter("strength", [0.25, 0.7, 1.0][quality])
		atmosphere_material.set_shader_parameter("strength", [0.0, 0.55, 1.0][quality])
		atmosphere.visible = quality > 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		aim_at(get_local_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pulse_at(get_local_mouse_position())

func aim_at(point: Vector2) -> void:
	target_pointer = ((point / VIEW - Vector2(0.5, 0.5)) * 2.0).clamp(Vector2(-1, -1), Vector2.ONE)

func pulse_at(point: Vector2) -> void:
	pulse_position = point.clamp(Vector2.ZERO, VIEW)
	pulse = 1.0
	aim_at(point)

func _process(delta: float) -> void:
	elapsed += delta
	pointer = pointer.lerp(target_pointer, 1.0 - exp(-delta * 5.0))
	pulse = maxf(0.0, pulse - delta * 1.4)
	var motion := [0.2, 0.65, 1.0][quality] as float
	city.position = Vector2(-10, -6) - pointer * Vector2(4, 2) * motion
	city.position += Vector2(sin(elapsed * 0.15), cos(elapsed * 0.12)) * motion
	heroes.position = HERO_RECT.position + pointer * Vector2(5.0, 2.0) * motion
	wind_material.set_shader_parameter("clock", elapsed)
	wind_material.set_shader_parameter("gust", pointer.x + pulse)
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
		var wind := 25.0 + pointer.x * 14.0
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
