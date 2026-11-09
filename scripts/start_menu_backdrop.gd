extends Control
signal quality_changed(value: int)

const CITY := preload("res://assets/menu/start-city.png")
const HEROES := preload("res://assets/menu/start-heroes-hq.png")
const CITY_FX := preload("res://shaders/menu_city.gdshader")
const WIND := preload("res://shaders/menu_wind.gdshader")
const ATMOSPHERE := preload("res://shaders/menu_atmosphere.gdshader")
const VIEW := Vector2(640, 360)
# Fixed illustration and fixed roof: pointer/focus must never slide the feet.
const HERO_RECT := Rect2(10, 64, 260, 260)
const RAVEN_SCALE := 0.92
const RAVEN_PIVOT := Vector2(0.81, 0.95)
const RAVEN_OFFSET := Vector2(-5, -9)
# The cut follows the transparent gap between the two reference figures.
const SEAM := [Vector2(0.60, 0), Vector2(0.60, 0.30), Vector2(0.594, 0.35), Vector2(0.603, 0.40), Vector2(0.615, 0.45), Vector2(0.615, 0.62), Vector2(0.635, 0.71), Vector2(0.62, 0.80), Vector2(0.62, 1)]

var elapsed := 0.0
var quality := 2
var pulse := 0.0
var pulse_position := Vector2(240, 210)
var city: TextureRect
var city_material: ShaderMaterial
var heroes: Node2D
var wind_material: ShaderMaterial
var ground_contacts: ColorRect
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
	city_material = ShaderMaterial.new()
	city_material.shader = CITY_FX
	city.material = city_material
	add_child(city)
	ground_contacts = ColorRect.new()
	ground_contacts.size = VIEW
	var contact_material := ShaderMaterial.new()
	contact_material.shader = preload("res://shaders/menu_contacts.gdshader")
	var contacts := PackedVector4Array()
	for foot in boot_contacts(): contacts.append(Vector4(foot.x,foot.y,foot.z,foot.w))
	contact_material.set_shader_parameter("feet",contacts)
	city_material.set_shader_parameter("boot_contacts",contacts)
	ground_contacts.material = contact_material
	ground_contacts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ground_contacts)
	heroes = Node2D.new()
	heroes.position = HERO_RECT.position
	add_child(heroes)
	wind_material = ShaderMaterial.new()
	wind_material.shader = WIND
	for is_raven in [false, true]:
		var figure := MeshInstance2D.new()
		figure.texture = HEROES
		figure.mesh = _figure_mesh(is_raven)
		figure.material = wind_material
		if is_raven:
			figure.scale = Vector2.ONE * RAVEN_SCALE
			figure.position = RAVEN_PIVOT * HERO_RECT.size * (1.0 - RAVEN_SCALE) + RAVEN_OFFSET
		heroes.add_child(figure)
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
	var signature := Label.new()
	signature.text = "IM SCHATTEN DES RABEN  ·  V" + str(ProjectSettings.get_setting("application/config/version"))
	signature.position = Vector2(14, 345)
	signature.add_theme_font_override("font", preload("res://scripts/ui_skin.gd").font("title"))
	signature.add_theme_font_size_override("font_size", 8)
	signature.add_theme_color_override("font_color", Color("aac9d9"))
	signature.add_theme_color_override("font_shadow_color", Color.BLACK)
	signature.add_theme_constant_override("shadow_offset_y", 1)
	signature.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(signature)
	set_quality(quality)
	_sync_activity()

static func seam_at(y: float) -> float:
	for i in range(1, SEAM.size()):
		if y <= SEAM[i].y:
			return lerpf(SEAM[i - 1].x, SEAM[i].x, inverse_lerp(SEAM[i - 1].y, SEAM[i].y, y))
	return SEAM.back().x

static func wind_weights(uv: Vector2, is_raven: bool) -> Vector2:
	# Weights are zero at roots, body, hands, weapons and boots. Feathered
	# silhouette-only regions avoid the old whole-character rubber motion.
	if is_raven:
		var hair := smoothstep(0.27, 0.38, uv.y) * (1.0 - smoothstep(0.425, 0.45, uv.y))
		hair *= smoothstep(0.59, 0.61, uv.x) * (1.0 - smoothstep(0.63, 0.654, uv.x))
		return Vector2(hair, 0)
	var tips := smoothstep(0.58, 0.68, uv.y) * (1.0 - smoothstep(0.745, 0.78, uv.y))
	var left_edge := smoothstep(0.21, 0.23, uv.x) * (1.0 - smoothstep(0.27, 0.30, uv.x))
	var right_edge := smoothstep(0.53, 0.568, uv.x) * (1.0 - smoothstep(0.62, 0.64, uv.x))
	return Vector2(0, tips * maxf(left_edge, right_edge))

func _figure_mesh(is_raven: bool) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var weights := PackedColorArray()
	var indices := PackedInt32Array()
	const ROWS := 160
	const COLS := 80
	for row in ROWS + 1:
		var y := float(row) / ROWS
		var seam := seam_at(y)
		for column in COLS + 1:
			var x := lerpf(seam if is_raven else 0.0, 1.0 if is_raven else seam, float(column) / COLS)
			var uv := Vector2(x, y)
			vertices.append(Vector3(x * HERO_RECT.size.x, y * HERO_RECT.size.y, 0))
			uvs.append(uv)
			var weight := wind_weights(uv, is_raven)
			weights.append(Color(weight.x, weight.y, 0, 1))
	for row in ROWS:
		for column in COLS:
			var index := row * (COLS + 1) + column
			indices.append_array([index, index + 1, index + COLS + 1, index + 1, index + COLS + 2, index + COLS + 1])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = weights
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

static func foot_position(uv: Vector2, is_raven: bool) -> Vector2:
	var point := uv * HERO_RECT.size
	if is_raven:
		point = (point - RAVEN_PIVOT * HERO_RECT.size) * RAVEN_SCALE + RAVEN_PIVOT * HERO_RECT.size + RAVEN_OFFSET
	return HERO_RECT.position + point

static func boot_contacts() -> Array[Vector4]:
	# Source sole baselines, including Raven's existing separate scale/offset.
	var contacts: Array[Vector4] = []
	for foot in [[Vector2(0.309,0.958),false,15.0,2.3],[Vector2(0.545,0.963),false,11.2,2.1],[Vector2(0.732,0.963),true,9.0,1.8],[Vector2(0.856,0.951),true,10.0,1.8]]:
		var point := foot_position(foot[0],foot[1])
		contacts.append(Vector4(point.x,point.y,foot[2],foot[3]))
	return contacts

func _sync_activity() -> void:
	var active := is_visible_in_tree()
	set_process(active)
	set_process_input(active)

func set_quality(value: int) -> void:
	quality = clampi(value, 0, 2)
	if city_material != null:
		city_material.set_shader_parameter("strength", [0.0, 0.55, 1.0][quality])
	if wind_material != null:
		wind_material.set_shader_parameter("strength", [0.0, 0.55, 1.0][quality])
	if atmosphere_material != null:
		atmosphere_material.set_shader_parameter("strength", [0.0, 0.55, 1.0][quality])
		atmosphere.visible = quality > 0
	quality_changed.emit(quality)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pulse_at(get_local_mouse_position())

func pulse_at(point: Vector2) -> void:
	pulse_position = point.clamp(Vector2.ZERO, VIEW)
	pulse = 1.0

func _process(delta: float) -> void:
	elapsed += delta
	city_material.set_shader_parameter("clock", elapsed)
	wind_material.set_shader_parameter("clock", elapsed)
	pulse = maxf(0.0, pulse - delta * 1.4)
	atmosphere_material.set_shader_parameter("clock", elapsed)
	atmosphere_material.set_shader_parameter("focus", pulse_position / VIEW)
	atmosphere_material.set_shader_parameter("pulse", pulse)
	weather.queue_redraw()

func _draw_weather() -> void:
	# Different depths and speeds make the downpour read as a volume.
	var counts := [35, 150, 260]
	for i in int(counts[quality]):
		var depth := float(i % 3 + 1) / 3.0
		var speed := 105.0 + depth * 190.0
		var wind := 25.0 + sin(elapsed * 0.45) * 8.0
		var p := Vector2(fposmod(i * 87.3 - elapsed * wind * depth, 690.0) - 25.0,
			fposmod(i * 53.7 + elapsed * speed, 400.0) - 20.0)
		var length := 4.0 + depth * 13.0
		var alpha := (0.07 + depth * 0.19) * (0.6 if p.x > 350 else 1.0)
		weather.draw_line(p, p + Vector2(-length * 0.28, length), Color(0.57, 0.82, 0.94, alpha), 0.55 + depth * 0.5, true)
		if quality == 2 and i % 7 == 0:
			weather.draw_line(p, p + Vector2(-length * 0.28, length), Color(0.42, 0.76, 1.0, alpha * 0.12), 2.5, true)
	# Flying traffic passes across the skyline, behind the menu text area.
	for i in 6:
		var x := fposmod(i * 111.0 + elapsed * (12.0 + i * 3.0), 760.0) - 60.0
		var y := 165.0 + float((i * 31) % 117)
		var color := Color(0.3, 0.85, 1.0, 0.65) if i % 2 == 0 else Color(1.0, 0.19, 0.49, 0.55)
		weather.draw_line(Vector2(x - 15, y), Vector2(x, y), Color(color, 0.18), 1.0, true)
		weather.draw_line(Vector2(x, y), Vector2(x + 4, y), color, 1.5, true)
	# Small ground rings and neon reflections, clipped to the rooftop.
	if quality > 0:
		for i in 32:
			var life := fposmod(elapsed * 0.8 + float(i) * 0.137, 1.0)
			var p := Vector2(18 + (i * 29) % 250, 304 + (i * 7) % 21)
			# Match the sloping foreground roof; no rings floating over the edge.
			if p.y > 350 - p.x * 0.15:
				continue
			weather.draw_set_transform(p, 0, Vector2(1, 0.32))
			weather.draw_arc(Vector2.ZERO, 1 + life * 7, 0, TAU, 16, Color(0.39, 0.81, 0.93, (1 - life) * 0.23), 0.6, true)
		weather.draw_set_transform(Vector2.ZERO)
		# Windblown spray catches the roof's pink and cyan neon.
		for i in (24 if quality == 2 else 10):
			var life := fposmod(elapsed * 0.6 + i * 0.171, 1.0)
			var p := Vector2(20 + (i * 47) % 262 - life * 12, 306 - sin(life * PI) * 7)
			weather.draw_circle(p, 0.35 + life * 0.4, Color(0.4, 0.85, 1, sin(life * PI) * 0.32))
	if pulse > 0.0:
		weather.draw_arc(pulse_position, (1 - pulse) * 38 + 3, 0, TAU, 40, Color(0.4, 0.9, 1, pulse * 0.32), 0.8, true)
