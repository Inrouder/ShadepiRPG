extends Node2D

const GamepadBindings = preload("res://scripts/gamepad_bindings.gd")
const Admin = preload("res://scripts/admin_tools.gd")
const ChapterFlow = preload("res://scripts/chapter_flow.gd")
const PixelMarker = preload("res://scripts/pixel_marker.gd")
const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const HudScript = preload("res://scripts/hud.gd")
const EffectsScript = preload("res://scripts/effects.gd")
const PropScript = preload("res://scripts/world_prop.gd")
const Painted = preload("res://scripts/painted_world.gd")
const Dressing = preload("res://scripts/world_dressing.gd")
const SceneAtmosphereScript = preload("res://scripts/scene_atmosphere.gd")
const GroundAtmosphereScript = preload("res://scripts/ground_atmosphere.gd")
const MusicLibrary = preload("res://scripts/music_library.gd")
const CutsceneScript = preload("res://scripts/cutscene.gd")
const VISUAL_PRESETS: = ["Reduziert", "Ausgewogen", "Atmosphärisch"]
const VISUAL_SETTINGS: = "user://shadepi-graphics.cfg"
var player
var enemy
var raven
var coop: = false
var gamepads: = GamepadBindings.new()
const COOP_REACH: = Vector2(448, 166)
var ui
var effects
var blood_effects
var camera: Camera2D
var actors: Node2D
var gate_body: StaticBody2D
var stage: = 0
var menu_open: = true
var started: = false
var admin_flags: Dictionary = {}
var hack_cooldown: = 0.0
var shake: = 0.0
var gate_open: = false
var terminal: CanvasLayer

var audio_on: = true
var sfx: Array[AudioStreamPlayer] = []
var combat_audio: Node
var music: AudioStreamPlayer
var music_section := ""
var music_fade: Tween
var light_texture: = preload("res://assets/world/light.png")
var screenshot_mode: = false
var visual_quality: = 2
var scene_atmosphere: Node2D
var ground_atmosphere: Node2D
var atmosphere_filter: ColorRect
var filter_material: ShaderMaterial
var shadow_lights: Array[PointLight2D] = []
var world_lights: Array[PointLight2D] = []
var ambient: CanvasModulate
var neon_halos: Array[Sprite2D] = []
var blade_light: PointLight2D
var next_step_ripple: = 0.0
var destructibles: Array[WorldProp] = []
var prop_states: Dictionary = {}
var dressing_layout: = ""
var dressing_generation: = 0
var terminal_devices: Array[WorldProp] = []
var painted_solids: Array[StaticBody2D] = []
var painted_masks: Array[Polygon2D] = []
var painted_layout: = ""
var cutscene: CanvasLayer
## Combat feedback: consecutive hits, short freeze frames and camera punch.
var combo_hits := 0
var combo_time := 0.0
var best_combo := 0
var hitstop_left := 0.0
var camera_punch := Vector2.ZERO

func open_terminal(context: String, on_success: Callable) -> void:
	if terminal != null or is_busy():
		return
	player.cancel_charge()
	raven.cancel_charge()
	player.velocity = Vector2.ZERO
	raven.velocity = Vector2.ZERO
	var panel = preload("res://scripts/terminal_ui.gd").new()
	panel.context = context
	terminal = panel
	var device_generation := dressing_generation
	var devices: Array[WorldProp] = _begin_technology_access(context)
	add_child(panel)
	panel.alarm.connect(func():
		sound("hit")
		if terminal==panel and dressing_generation==device_generation:
			for device in devices:
				if is_instance_valid(device): device.finish_access("fault")
	)
	panel.finished.connect(func(success: bool):
		if terminal != panel:
			return
		var failed: bool = panel.puzzle.failed
		cancel_terminal()
		if dressing_generation==device_generation:
			for device in devices:
				if is_instance_valid(device): device.finish_access("success" if success else "fault" if failed else "idle")
		if success and on_success.is_valid():
			sound("hack")
			on_success.call()
	)

func _begin_technology_access(context: String) -> Array[WorldProp]:
	terminal_devices.clear()
	var ids: Array = preload("res://scripts/technology_art.gd").LINKS.get(dressing_layout,{}).get(context,[])
	for device in destructibles:
		if device.prop_id in ids and device.begin_access(): terminal_devices.append(device)
	return terminal_devices.duplicate()

func cancel_terminal() -> void:
	for device in terminal_devices:
		if is_instance_valid(device): device.finish_access("idle")
	terminal_devices.clear()
	if is_instance_valid(terminal):
		terminal.closed = true
		terminal.hide()
		terminal.queue_free()
	terminal = null

func _ready() -> void :
	Engine.time_scale = 1.0
	admin_flags = Admin.read_flags()
	_bind_inputs()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	gamepads.assign(Input.get_connected_joypads(), coop)
	_build_world()
	ground_atmosphere.hide()
	for halo in neon_halos:
		halo.hide()
	set_dressing("demo")
	_build_atmosphere_filter()
	_load_visual_quality()
	_build_audio()
	ui = create_hud()
	ui.world = self
	add_child(ui)
	cutscene = CutsceneScript.new()
	cutscene.world = self
	add_child(cutscene)
	ui.show_menu()
	var args: = OS.get_cmdline_user_args()
	if "--capture" in args or "--capture-reduced" in args:
		screenshot_mode = true
		set_visual_quality(0 if "--capture-reduced" in args else 2)
		close_menu()
		stage = 2
		set_gate(true)
		player.position = Vector2(674, 362)
		raven.position = Vector2(587, 394)
		enemy.active = true
		enemy.position = Vector2(770, 323)
		_capture.call_deferred("res://docs/screenshot.png" if visual_quality == 2 else "res://docs/screenshot-reduced.png")

func create_hud() -> CanvasLayer:
	return HudScript.new()

func actor_is_playable(actor: PixelActor) -> bool:
	return actor == player or (coop and actor == raven)

func actor_input_prefix(actor: PixelActor) -> String:
	return "raven_" if actor == raven else ""

func _bind_inputs() -> void :
	if not InputMap.has_action("raven_mouse_attack"):
		InputMap.add_action("raven_mouse_attack")
		var mouse: = InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("raven_mouse_attack", mouse)
	var bindings: = {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], 
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN], 
		"attack": [KEY_J], "dash": [KEY_SPACE, KEY_SHIFT], "cloak": [KEY_C], 
		"charge": [KEY_K], "kick": [KEY_L],
		"hack": [KEY_Q], "interact": [KEY_E, KEY_ENTER], "pause_game": [KEY_ESCAPE], 
		"save_game": [KEY_F5], "load_game": [KEY_F9], "help_game": [KEY_H], "mute_game": [KEY_M], 
		"graphics_game": [KEY_V], 
		"raven_move_left": [KEY_LEFT], "raven_move_right": [KEY_RIGHT], 
		"raven_move_up": [KEY_UP], "raven_move_down": [KEY_DOWN], 
		"raven_attack": [KEY_U], "raven_hack": [KEY_O], 
		"raven_charge": [KEY_I], "raven_kick": [],
		"raven_dash": [KEY_P], "raven_interact": [KEY_ENTER]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event: = InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for action in ["attack", "mouse_attack"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var mouse: = InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event(action, mouse)

func set_coop(enabled: bool) -> void :
	coop = enabled
	gamepads.assign(Input.get_connected_joypads(), coop)
	camera.limit_left = -18 if coop else 0
	camera.limit_right = 1042 if coop else 1024

	var arrows: = [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
	var actions: = ["move_left", "move_right", "move_up", "move_down"]
	for i in arrows.size():
		var event: = InputEventKey.new()
		event.physical_keycode = arrows[i]
		Input.action_release(actions[i])
		Input.action_release("raven_" + actions[i])
		if coop:
			InputMap.action_erase_event(actions[i], event)
		elif not InputMap.action_has_event(actions[i], event):
			InputMap.action_add_event(actions[i], event)

func _on_joy_connection_changed(_device: int, _connected: bool) -> void :
	player.cancel_charge()
	raven.cancel_charge()
	gamepads.assign(Input.get_connected_joypads(), coop)

func hack_input_hint() -> String:
	if coop:
		return "O / Y" if gamepads.raven_device >= 0 else "O"
	return "Q / RB" if gamepads.shadepi_device >= 0 else "Q"

func save_path() -> String:
	return Admin.checkpoint_path(SaveService.COOP_PATH if coop else SaveService.PATH, get_tree())

func admin_enabled(option: String) -> bool:
	return bool(admin_flags.get(option, false))

func set_admin_option(option: String, enabled: bool) -> bool:
	if not option in Admin.OPTIONS:
		return false
	admin_flags[option] = enabled
	return Admin.save_flags(admin_flags)

func admin_jump_to_chapter(chapter: int) -> bool:
	if not admin_enabled("unlock_all"):
		toast("Zuerst im Admin-Menü alle Kapitel freischalten.")
		return false
	var error := Admin.request_chapter(get_tree(), chapter)
	if error != OK:
		toast("Kapitel konnte nicht geladen werden (%d)." % error)
		return false
	return true

func admin_jump_to_checkpoint(id: String) -> bool:
	if not admin_enabled("unlock_all"):
		toast("Im Testmenü zuerst alle Kapitel freischalten.")
		return false
	var error := preload("res://scripts/test_checkpoints.gd").request(get_tree(),id)
	if error!=OK: toast("Test-Kontrollpunkt konnte nicht geöffnet werden (%d)."%error)
	return error==OK

func begin_admin_test_session() -> void:
	get_tree().set_meta(Admin.SESSION_KEY, true)

func admin_heal() -> void:
	for character in [player, raven]:
		if character != null:
			# Story-driven incapacitation remains under chapter control.
			if character.health > 0:
				character.health = 100
			character.energy = 100.0
	toast("Test: Gesundheit und Energie aufgefüllt.")

func admin_defeat_enemies() -> int:
	var defeated := 0
	for node in actors.get_children():
		if node is PixelActor and node != player and node != raven and node.visible and node.health > 0 and node.active:
			node.armoured = false
			node.front_shield = false
			node.min_health = 0
			node.take_damage(node.health + 10000)
			defeated += 1
	return defeated


func limit_coop_motion(actor: PixelActor, motion: Vector2, delta: float) -> Vector2:
	if not coop:
		return motion
	var partner: PixelActor = raven if actor == player else player
	var offset: = actor.position - partner.position
	var step: = motion * delta

	step.x = clampf(step.x, minf(0.0, - COOP_REACH.x - offset.x), maxf(0.0, COOP_REACH.x - offset.x))
	step.y = clampf(step.y, minf(0.0, - COOP_REACH.y - offset.y), maxf(0.0, COOP_REACH.y - offset.y))
	return step / delta

func combat_target(origin: Vector2, include_cloaked: bool = false) -> PixelActor:
	var target: PixelActor
	if include_cloaked or player.cloak_time <= 0.0:
		target = player
	if coop and (target == null or origin.distance_squared_to(raven.position) < origin.distance_squared_to(target.position)):
		target = raven
	return target

func world_walls() -> Array[Rect2]:
	return WorldData.WALLS

func world_props() -> Array[Dictionary]:
	return WorldData.PROPS

func _build_world() -> void :
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var backdrop_material: = CanvasItemMaterial.new()
	backdrop_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material = backdrop_material
	var ground: = Sprite2D.new()
	ground.name = "PaintedAlley"
	ground.texture = Painted.ART.alley
	ground.material = material
	ground.scale = Vector2(1024, 640) / ground.texture.get_size()
	ground.centered = false
	ground.z_index = -10
	add_child(ground)
	ground_atmosphere = GroundAtmosphereScript.new()
	add_child(ground_atmosphere)
	scene_atmosphere = SceneAtmosphereScript.new()
	scene_atmosphere.world = self
	add_child(scene_atmosphere)
	for wall in world_walls():
		_collider(wall)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for prop in world_props():
		_collider(prop.collision)
		var sprite: = Sprite2D.new()
		var column: int = [4, 0, 5][prop.kind]
		preload("res://scripts/prop_art.gd").apply(sprite, column)
		var height: float = sprite.position.y
		sprite.position = prop.position + Vector2(0, height)
		actors.add_child(sprite)
	gate_body = _collider(WorldData.GATE, false)
	player = PlayerScript.new()
	player.name = "Shadepi"
	player.setup(preload("res://assets/sprites/heroes/shadepi.png"), self)
	player.position = WorldData.START
	actors.add_child(player)
	raven = PlayerScript.new()
	raven.second_player = true
	raven.name = "Raven"
	raven.setup(preload("res://assets/sprites/heroes/raven.png"), self)
	raven.position = WorldData.RAVEN
	actors.add_child(raven)
	enemy = EnemyScript.new()
	enemy.name = "ChromeJackal"
	enemy.setup(preload("res://assets/sprites/npcs/jackal.png"), self)
	enemy.position = WorldData.JACKAL
	actors.add_child(enemy)
	ambient = CanvasModulate.new()
	ambient.color = Color(0.72, 0.77, 0.92)
	add_child(ambient)
	world_lights = [
		_light(Vector2(77, 282), Color("fb71b5"), 2.5, 1.25), 
		_light(Vector2(640, 270), Color("65e8fa"), 3.5, 1.65), 
		_light(Vector2(900, 272), Color("f37ac1"), 3.0, 1.45), 
		_light(Vector2(454, 337), Color("5be1e5"), 1.2, 1.1), 
	]
	shadow_lights.append(world_lights[1])
	shadow_lights.append(world_lights[2])
	blade_light = _light(Vector2(11, -18), Color("f55078"), 0.9, 0.75, player)
	_light(Vector2(0, -24), Color("50cbe8"), 0.6, 0.45, raven)
	_halo(Vector2(78, 226), Color(1.0, 0.23, 0.55, 0.38), 1.2)
	_halo(Vector2(638, 227), Color(0.12, 0.75, 1.0, 0.4), 1.42)
	_halo(Vector2(899, 225), Color(0.95, 0.23, 0.65, 0.35), 1.28)
	effects = EffectsScript.new()
	effects.world = self
	effects.ambient_steam_enabled = false
	add_child(effects)
	blood_effects = preload("res://scripts/blood_fx.gd").new()
	blood_effects.world = self
	add_child(blood_effects)
	camera = Camera2D.new()
	camera.position = player.position
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1024
	camera.limit_bottom = 640
	add_child(camera)
	camera.make_current()

func atmosphere_profile() -> String:
	return painted_layout if not painted_layout.is_empty() else "alley"

func atmosphere_rect() -> Rect2:
	return Rect2(0,0,1024,640)

func set_painted_solids(key: String) -> void :
	for body in painted_solids:
		body.collision_layer = 0
		body.queue_free()
	painted_solids.clear()
	for mask in painted_masks:
		mask.hide()
		mask.queue_free()
	painted_masks.clear()
	painted_layout = key
	for box in Painted.walls(key):
		painted_solids.append(_collider(box, false))
	if key == "lakeside":
		var body: = StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var collision: = CollisionPolygon2D.new()
		collision.polygon = PackedVector2Array(Painted.WATER_EDGE)
		body.add_child(collision)
		add_child(body)
		painted_solids.append(body)
	add_painted_masks(key)

func add_painted_masks(key: String, offset: Vector2 = Vector2.ZERO, size: Vector2 = Vector2(1024, 640)) -> void :
	for entry: Array in Painted.OCCLUDERS.get(key, []):
		var mask: = Polygon2D.new()
		mask.position = offset + Vector2(0, entry[0])
		var polygon: = PackedVector2Array()
		var uv: = PackedVector2Array()
		var texture: Texture2D = Painted.ART[key]
		for point: Vector2 in entry[1]:
			polygon.append(point - Vector2(0, entry[0]))
			uv.append(point / size * texture.get_size())
		mask.polygon = polygon
		mask.uv = uv
		mask.texture = texture
		mask.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var unshaded: = CanvasItemMaterial.new()
		unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		mask.material = unshaded
		actors.add_child(mask)
		painted_masks.append(mask)

func set_dressing(layout: String) -> void :
	if is_instance_valid(blood_effects):blood_effects.clear()
	for device in terminal_devices:
		if is_instance_valid(device): device.finish_access("idle")
	terminal_devices.clear()
	dressing_generation += 1
	if is_instance_valid(effects):
		effects.fragments.clear()
		effects.smoke.clear()
		effects.blasts.clear()
	for prop in destructibles:
		prop.collision_layer = 0
		prop.hide()
		prop.set_process(false)
		prop.queue_free()
	destructibles.clear()
	dressing_layout = layout
	for item: Array in Dressing.items(layout):
		var prop: = PropScript.new()
		prop.setup(self, item[0], item[1], item[2])
		actors.add_child(prop)
		prop.restore_health(int(prop_states.get(layout, {}).get(prop.prop_id, prop.max_health)))
		destructibles.append(prop)

func dressing_state() -> Dictionary:
	return prop_states.duplicate(true)

func restore_dressing_state(value: Variant) -> void :
	if is_instance_valid(blood_effects):blood_effects.clear()
	prop_states.clear()
	if value is Dictionary:
		for layout: String in Dressing.LAYOUTS:
			var saved: Variant = value.get(layout)
			if not saved is Dictionary:
				continue
			var states: = {}
			for item: Array in Dressing.items(layout):
				var hp: Variant = saved.get(item[0])
				var limit: int = PropScript.TYPES[item[1]].hp
				if (hp is int or hp is float) and is_finite(float(hp)) and hp == floor(float(hp)) and hp >= 0 and hp < limit:
					states[item[0]] = int(hp)
			if not states.is_empty():
				prop_states[layout] = states
	for prop in destructibles:
		prop.restore_health(int(prop_states.get(dressing_layout, {}).get(prop.prop_id, prop.max_health)))

func free_saved_position(point: Vector2) -> Vector2:
	for ring in range(0, 97, 12):
		for direction in (1 if ring == 0 else 16):
			var candidate: = point + Vector2.from_angle(float(direction) * TAU / 16.0) * ring
			if not WorldData.walkable(candidate, gate_open):
				continue
			var blocked: = false
			for prop in destructibles:
				if prop.health > 0 and prop.footprint().grow(8).has_point(candidate):
					blocked = true
					break
			if not blocked:
				return candidate
	return WorldData.START

func prop_prompt() -> String:
	var actor: PixelActor = raven if raven_leads() else player
	if not actor_is_playable(actor):
		return ""
	for prop in destructibles:
		if prop.health > 0 and CombatRules.can_strike(actor.position, actor.facing, prop.nearest_point(actor.position), 40.0):
			return "J / X · " + str(PropScript.TYPES[prop.kind].label)
	return ""

func raven_leads() -> bool:
	return false

func trace_scenery(from: Vector2, to: Vector2) -> Dictionary:
	var query: = PhysicsRayQueryParameters2D.create(from, to, 1)


	var excluded: Array[RID] = []
	for prop in destructibles:
		if prop.health == 0:
			excluded.append(prop.get_rid())
	query.exclude = excluded
	return get_world_2d().direct_space_state.intersect_ray(query)

func strike_scenery(origin: Vector2, direction: Vector2, amount: int) -> int:
	var hits: = 0
	for prop in destructibles:
		if prop.health <= 0:
			continue
		var point: = prop.nearest_point(origin)
		if not CombatRules.can_strike(origin, direction, point):
			continue
		var obstruction: = trace_scenery(origin, point)
		if obstruction.is_empty() or obstruction.collider == prop:
			prop.take_damage(amount)
			hits += 1
	return hits

func prop_damaged(prop: WorldProp, amount: int) -> void :
	if not prop_states.has(dressing_layout):
		prop_states[dressing_layout] = {}
	prop_states[dressing_layout][prop.prop_id] = prop.health
	var tint: = Color(PropScript.TYPES[prop.kind].color)
	effects.prop_impact(prop.position, tint, prop.health == 0, prop.kind)
	if prop.health > 0:
		sound("prop_hit")
	else:
		shake = maxf(shake, 2.0 if prop.kind != "car" else 4.0)
		sound("prop_wood" if prop.kind == "crate" else "prop_metal")
		if prop.kind == "barrel":
			_explode_prop.call_deferred(prop.position, dressing_generation)
	damage_number(prop.position + Vector2(0, -50), str(mini(amount, prop.max_health)))

func _explode_prop(point: Vector2, generation: int) -> void :
	if generation != dressing_generation:
		return
	effects.prop_explosion(point)
	sound("prop_blast")
	shake = maxf(shake, 5.0)
	for prop in destructibles.duplicate():
		if generation != dressing_generation:
			return
		if prop.health <= 0 or prop.nearest_point(point).distance_to(point) > 78.0:
			continue
		var obstruction: = trace_scenery(point, prop.nearest_point(point))
		if obstruction.is_empty() or obstruction.collider == prop:
			prop.take_damage(46)

	var targets: Array = []
	for node in actors.get_children():
		if node is PixelActor and node.health > 0 and node.visible:
			if node in [player, raven]:
				if actor_is_playable(node):
					targets.append(node)
			elif node.active:
				targets.append(node)
	for target in targets:
		if generation != dressing_generation:
			return
		if target.position.distance_to(point) <= 78.0 and _line_clear(point, target.position):
			if target in [player, raven]:
				target.take_damage(24, point)
			else:
				target.take_damage(36)

func _collider(rect: Rect2, casts_shadow: bool = true) -> StaticBody2D:
	var body: = StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collider: = CollisionShape2D.new()
	var shape: = RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	if casts_shadow:
		var shadow: = LightOccluder2D.new()
		shadow.sdf_collision = false
		var silhouette: = OccluderPolygon2D.new()
		var corner: = rect.size * 0.5
		silhouette.polygon = PackedVector2Array([ - corner, Vector2(corner.x, - corner.y), corner, Vector2( - corner.x, corner.y)])
		shadow.occluder = silhouette
		body.add_child(shadow)
	add_child(body)
	return body

func _light(point: Vector2, color: Color, radius: float, strength: float, parent: Node = null) -> PointLight2D:
	if parent == null:
		parent = self
	var light: = PointLight2D.new()
	light.position = point
	light.texture = light_texture
	light.texture_scale = radius
	light.color = color
	light.energy = strength
	parent.add_child(light)
	return light

func set_scene_lighting(tint: Color, lamps: Array) -> void :
	ambient.color = tint
	for i in world_lights.size():
		var light: = world_lights[i]
		light.enabled = i < lamps.size()
		if light.enabled:
			var lamp: Array = lamps[i]
			light.position = lamp[0]
			light.color = Color(lamp[1])
			light.texture_scale = lamp[2]
			light.energy = lamp[3]

func _halo(point: Vector2, color: Color, radius: float) -> void :
	var halo: = Sprite2D.new()
	halo.texture = light_texture
	halo.position = point
	halo.scale = Vector2.ONE * radius
	halo.modulate = color
	halo.z_index = -2
	var material: = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = material
	add_child(halo)
	neon_halos.append(halo)

func _build_atmosphere_filter() -> void :
	var layer: = CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	atmosphere_filter = ColorRect.new()
	atmosphere_filter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filter_material = ShaderMaterial.new()
	filter_material.shader = preload("res://shaders/atmosphere.gdshader")
	atmosphere_filter.material = filter_material
	layer.add_child(atmosphere_filter)

func _load_visual_quality() -> void :
	var config: = ConfigFile.new()
	var saved: Variant = 2
	if config.load(VISUAL_SETTINGS) == OK:
		saved = config.get_value("video", "preset", 2)
	set_visual_quality(int(saved) if saved is int else 2)

func set_visual_quality(level: int) -> void :
	visual_quality = clampi(level, 0, 2)
	ground_atmosphere.quality = visual_quality
	effects.quality = visual_quality
	atmosphere_filter.visible = visual_quality > 0
	filter_material.set_shader_parameter("strength", 1.0 if visual_quality == 2 else 0.55)
	filter_material.set_shader_parameter("bloom", 0.32 if visual_quality == 2 else 0.15)
	filter_material.set_shader_parameter("detailed", visual_quality == 2)
	if scene_atmosphere != null: scene_atmosphere.set_quality(visual_quality)
	for light in shadow_lights:
		light.shadow_enabled = visual_quality > 0
		light.shadow_filter = Light2D.SHADOW_FILTER_PCF5 if visual_quality == 2 else Light2D.SHADOW_FILTER_NONE
		light.shadow_filter_smooth = 2.0
	for halo in neon_halos:
		halo.visible = visual_quality > 0
	if ui != null:
		ui.visual_button.text = "Bildstil: " + VISUAL_PRESETS[visual_quality]
		ui.start_backdrop.set_quality(visual_quality)

func cycle_visual_quality() -> void :
	set_visual_quality((visual_quality + 1) % VISUAL_PRESETS.size())
	var config: = ConfigFile.new()
	config.set_value("video", "preset", visual_quality)
	if config.save(VISUAL_SETTINGS) != OK:
		toast("Bildstil geändert · Einstellung konnte nicht gespeichert werden")
	else:
		toast("Bildstil: " + VISUAL_PRESETS[visual_quality])

func _build_audio() -> void :
	combat_audio = preload("res://scripts/combat_audio.gd").new()
	add_child(combat_audio)
	music = AudioStreamPlayer.new()
	music.volume_db = -12
	add_child(music)
	set_music_section("menu", true)
	for i in 8:
		var channel: = AudioStreamPlayer.new()
		channel.volume_db = -8
		add_child(channel)
		sfx.append(channel)

func set_music_section(section: String, restart: bool = false) -> void:
	if not restart and music_section == section and music.stream != null:
		return
	music_section = section
	if music_fade != null:
		music_fade.kill()
	music.stop()
	music.stream = MusicLibrary.stream_for(section)
	music.stream_paused = not audio_on
	music.volume_db = -28.0
	if audio_on and DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy":
		music.play()
		music_fade = create_tween()
		music_fade.tween_property(music, "volume_db", -12.0, 0.65)
	else:
		music.volume_db = -12.0

func _process(delta: float) -> void :
	if admin_enabled("no_cooldowns"):
		hack_cooldown = 0.0
	if not is_busy():
		hack_cooldown = maxf(0, hack_cooldown - delta)
		next_step_ripple = maxf(0.0, next_step_ripple - delta)
		if effects.rain and player.velocity.length() > 45.0 and next_step_ripple <= 0.0:
			effects.water_step(player.position)
			next_step_ripple = 0.13
		if not coop:
			_update_raven_follower(delta)
		var lead_x: float = maxf(player.position.x, raven.position.x) if coop else player.position.x
		if stage == 2 and lead_x > 548:
			enemy.active = true
	blade_light.enabled = player.cloak_time <= 0.0
	blade_light.position = Vector2(5, -18) + player.facing * 9.0
	blade_light.energy = 1.6 if player.attack_time > 0.12 else 0.8
	if in_cinematic():
		pass
	elif coop:
		camera.position = player.position.lerp(raven.position, 0.5) + Vector2(0, -27)
	else:
		camera.position = player.position + Vector2(0, -60) + player.facing * 8
	shake = maxf(0, shake - delta * 20)
	camera_punch = camera_punch.move_toward(Vector2.ZERO, delta * 60.0)
	combo_time = maxf(0.0, combo_time - delta)
	if combo_time == 0.0:
		combo_hits = 0
	camera.offset = Vector2(sin(Time.get_ticks_msec() * 0.1), cos(Time.get_ticks_msec() * 0.15)) * shake + camera_punch
	queue_redraw()

func _update_raven_follower(delta: float) -> void :
	raven.animate("attack" if enemy.exposed > 0.0 else "idle", delta)
	if stage >= 2:
		var target: Vector2 = player.position + Vector2(-52, 26)
		if raven.position.distance_to(target) > 35 and WorldData.walkable(target, gate_open):
			raven.facing = (target - raven.position).normalized()
			raven.velocity = raven.facing * 75
			raven.move_and_slide()
			raven.animate("walk", delta)

func _unhandled_input(event: InputEvent) -> void :
	if terminal != null:
		return
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("graphics_game"):
		cycle_visual_quality()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause_game") or event.is_action_pressed("help_game"):
		if menu_open:
			if started:
				close_menu()
			else:
				ui.start_selected()
		else:
			menu_open = true
			ui.show_menu()
		get_viewport().set_input_as_handled()
		return
	if menu_open:
		return
	if in_cinematic():
		if event.is_action_pressed("interact") or (coop and event.is_action_pressed("raven_interact")):
			cutscene.advance()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("dash") or event.is_action_pressed("raven_dash"):
			cutscene.skip()
			get_viewport().set_input_as_handled()
		return
	if ui.dialogue_open:
		if event.is_action_pressed("interact") or (coop and event.is_action_pressed("raven_interact")):
			ui.advance_dialogue()
			get_viewport().set_input_as_handled()
		return
	if coop and event.is_action_pressed("raven_interact"):
		interact(raven)
	elif event.is_action_pressed("interact"):
		interact()
	elif (coop and event.is_action_pressed("raven_hack")) or ( not coop and event.is_action_pressed("hack")):
		raven_hack()
	elif event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
	elif event.is_action_pressed("mute_game"):
		toggle_audio()

func is_busy() -> bool:
	return terminal != null or menu_open or (ui != null and ui.dialogue_open) or player.health <= 0 or in_cinematic()

## Where the gameplay camera rests; cutscenes blend back to it when they end.
func camera_home() -> Vector2:
	if coop:
		return player.position.lerp(raven.position, 0.5) + Vector2(0, -27)
	return player.position + Vector2(0, -60) + player.facing * 8

## Plays plain spoken lines as an in-engine scene (no comic page).
func play_lines(entries: Array, done: Callable = Callable()) -> void:
	var cs = begin_cutscene()
	await cs.lines(entries)
	cs.end(done)

## Hides combat hints in calm story moments; chapters narrow this down.
func combat_ready() -> bool:
	return true

func in_cinematic() -> bool:
	return cutscene != null and cutscene.running

## Starts a scripted scene; returns the director. Aborts any running scene.
func begin_cutscene() -> CanvasLayer:
	ui.clear_dialogue()
	cutscene.begin()
	return cutscene

func close_menu() -> void :
	menu_open = false
	started = true
	ui.hide_menu()
	if ui.admin_panel != null:
		ui.admin_panel.hide()

func interaction_prompt() -> String:
	if stage == 0 and player.position.distance_to(raven.position) < 62:
		return "E / Enter / A · Einsatz besprechen" if coop else "E / A · Mit Raven sprechen"
	var point: Vector2
	var action: String
	if stage == 1:
		point = WorldData.TERMINAL
		action = "Sicherheitssperre hacken"
	elif stage == 3:
		point = WorldData.EXIT
		action = "Daten sichern"
	else:
		return ""
	if player.position.distance_to(point) < 54:
		return ("E / A · " if gamepads.shadepi_device >= 0 else "E · ") + action
	if coop and raven.position.distance_to(point) < 54:
		return ("Enter / A · " if gamepads.raven_device >= 0 else "Enter · ") + action
	return ""

func interact(actor: PixelActor = null) -> void :
	if actor == null:
		actor = player
	if stage == 0 and player.position.distance_to(raven.position) < 62:
		ui.dialogue([
			["Raven", "Chrome Jackal bewacht den Ausgang. Ich kann seine Implantate stören. Du kümmerst dich um den Rest."], 
			["Shadepi", "Einverstanden. Zuerst brauchen wir einen Weg durch die Sperre."], 
			["Raven", "Das Terminal rechts. Danach %s für meinen Hack. Wenn er rot ausholt: ausweichen!" % hack_input_hint()]
		], func():
			stage = 1
			autosave()
		)
	elif stage == 1 and actor.position.distance_to(WorldData.TERMINAL) < 54:
		set_gate(true)
		stage = 2
		set_music_section("boss")
		sound("hack")
		effects.burst(WorldData.TERMINAL, Color("61e0ec"), 22)
		toast("Raven: Sperre offen. Seine Panzerung schwäche ich mit %s." % hack_input_hint())
		autosave()
	elif stage == 3 and actor.position.distance_to(WorldData.EXIT) < 54:
		ui.dialogue([
			["Shadepi", "Die Daten sind gesichert. Vielleicht führen sie uns zu den Minotauren."], 
			["Raven", "Dann verschwinden wir. Und vergiss nicht: Wir sind noch lange keine Freunde."], 
			["Testszene abgeschlossen", "Du kannst die Gasse weiter erkunden. Über Esc lässt sich die Szene neu starten."]
		], func():
			stage = 4
			autosave()
		)

func set_gate(open: bool) -> void :
	gate_open = open
	gate_body.get_child(0).set_deferred("disabled", open)
	queue_redraw()

func hack_origin() -> Vector2:
	return raven.position if coop else player.position

func raven_hack() -> bool:
	if stage != 2 or enemy.health <= 0:
		toast("Raven: Hier ist gerade kein aktives Ziel.")
		return false
	if hack_cooldown > 0:
		toast("Raven: Mein Deck lädt noch.")
		return false
	var origin: = hack_origin()
	if origin.distance_to(enemy.position) > 240 or not _line_clear(origin, enemy.position):
		toast("Raven: Näher ran. Ich brauche eine freie Verbindung.")
		return false
	hack_cooldown = 11.0
	enemy.hack()
	effects.burst(enemy.position, Color("4de2ef"), 28)
	effects.hack_arc(raven.position, enemy.position)
	sound("hack")
	toast("Raven: Implantate gestört. Jetzt!")
	return true

func raven_energy_attack() -> bool:
	return false

func raven_attack_fx(endpoint: Vector2, electric: bool) -> void:
	raven.animate("attack",0.0)
	effects.weapon_trace(raven.attack_attachment(electric), endpoint + Vector2(0,-28), electric)
	sound("electric" if electric else "pistol", 0.05)

func raven_shot() -> void :
	var origin: Vector2 = raven.position
	var endpoint: Vector2 = origin + raven.facing * 152.0
	var wall: = trace_scenery(origin, endpoint)
	if not wall.is_empty():
		endpoint = wall.position
	var target: = raven_shot_target(origin)
	if target != null:
		endpoint = target.position
		target.take_damage(17, origin)
	elif not wall.is_empty() and wall.collider is WorldProp:
		wall.collider.take_damage(17)
	raven_attack_fx(endpoint, false)

func raven_shot_target(origin: Vector2) -> PixelActor:
	return enemy if stage == 2 and raven_can_hit(enemy, origin) else null

## Pistol shots forgive slightly off-axis aim: a cone that widens with distance
## (aim assist) instead of an eight-pixel line.
func raven_can_hit(target: PixelActor, origin: Vector2) -> bool:
	var offset: = target.position - origin
	var depth: float = offset.dot(raven.facing)
	return depth >= 0.0 and depth <= 160.0 and absf(offset.cross(raven.facing)) <= 14.0 + depth * 0.12 and _line_clear(origin, target.position)

func _line_clear(from: Vector2, to: Vector2) -> bool:
	return trace_scenery(from, to).is_empty()

func player_strike(amount: int) -> void :
	strike_scenery(player.position, player.facing, amount)
	if stage == 2 and CombatRules.can_strike(player.position, player.facing, enemy.position) and _line_clear(player.position, enemy.position):
		enemy.take_damage(amount, player.position)

func special_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	for node in actors.get_children():
		if node is EnemyScript and node.active and node.visible and node.health > 0:
			targets.append(node)
	return targets

func special_hit(target: Node2D, amount: int, source: PixelActor, kick: bool) -> void:
	var before: int = target.health
	target.take_damage(amount, source.position)
	if kick and target.health > 0 and target.health < before:
		target.hack_interrupt(0.5)
		target.move_and_collide(source.facing * 22)

func power_attack(source: PixelActor) -> void:
	var projectile := preload("res://scripts/power_projectile.gd").new()
	projectile.world = self
	projectile.source = source
	projectile.generation = source.combat_generation
	projectile.ranged = source.second_player
	projectile.remaining = 300.0 if projectile.ranged else 240.0
	projectile.direction = source.facing.normalized()
	projectile.position = source.position
	if source.second_player:
		source.animate("attack", 0.0)
		projectile.electric = raven_energy_attack()
		projectile.visual_offset = source.attack_attachment(projectile.electric) - source.position
		effects.weapon_trace(source.attack_attachment(projectile.electric), source.attack_attachment(projectile.electric) + source.facing * 14, projectile.electric)
	projectile.z_index = 45
	add_child(projectile)
	sound(("electric" if projectile.electric else "pistol") if source.second_player else "slash")

func player_kick(source: PixelActor) -> void:
	strike_scenery(source.position, source.facing, 28)
	for target in special_targets():
		var offset: Vector2 = target.position - source.position
		if offset.length() <= 46 and offset.normalized().dot(source.facing) > 0.5 and _line_clear(source.position, target.position):
			special_hit(target, 28, source, true)

func spawn_slash(point: Vector2, direction: Vector2) -> void :
	effects.slash(point, direction)

func spawn_trail(point: Vector2, color: Color) -> void :
	effects.trail(point, color)

func impact(point: Vector2, foe: bool) -> void :
	effects.burst(point, Color("ff648a") if foe else Color("a6d6ea"))
	shake = maxf(shake, 2.2 if foe else 4.5)
	sound("hit", 0.12)
	if not foe and ui != null and ui.has_method("hurt_flash"):
		ui.hurt_flash()
		hitstop(0.05)

## One place for hit feedback: freeze frame, camera punch, sparks, combo count.
func register_hit(target: Node2D, amount: int, direction: Vector2, killed: bool) -> void:
	if amount > 0 and target is EnemyScript and is_instance_valid(blood_effects):
		blood_effects.hit(target,direction,amount,killed)
	var heavy: = amount >= 30
	combo_hits += 1
	best_combo = maxi(best_combo, combo_hits)
	combo_time = 1.4
	hitstop(0.11 if killed else (0.075 if heavy else 0.045))
	shake = maxf(shake, 6.0 if killed else (4.0 if heavy else 2.6))
	camera_punch = direction.normalized() * (5.0 if heavy or killed else 2.5)
	var point: Vector2 = target.global_position
	effects.slash(point + direction.normalized() * 6.0, direction)
	effects.burst(point, Color("ffe0a8") if heavy else Color("ff648a"), 22 if killed else (14 if heavy else 9))
	if killed:
		effects.burst(point, Color("9fe8ff"), 18)

## Brief freeze frame on impact. Skipped in headless runs so tests keep timing.
func hitstop(seconds: float) -> void:
	if DisplayServer.get_name() == "headless" or seconds <= 0.0:
		return
	if hitstop_left > 0.0:
		hitstop_left = maxf(hitstop_left, seconds)
		return
	hitstop_left = seconds
	Engine.time_scale = 0.06
	while hitstop_left > 0.0:
		var started := Time.get_ticks_usec()
		await get_tree().create_timer(0.016, true, false, true).timeout
		if not is_inside_tree():
			return
		hitstop_left -= (Time.get_ticks_usec() - started) / 1000000.0
	Engine.time_scale = 1.0

## Melee aim assist: turn toward the closest enemy just outside the blade cone.
func melee_assist(actor: PixelActor) -> void:
	var best: Node2D
	var best_distance := 66.0
	for target in special_targets():
		var offset: Vector2 = target.global_position - actor.position
		var distance := offset.length()
		if distance < best_distance and distance > 4.0 and offset.normalized().dot(actor.facing) > 0.2 and _line_clear(actor.position, target.global_position):
			best = target
			best_distance = distance
	if best != null:
		actor.facing = (best.global_position - actor.position).normalized()


func damage_number(point: Vector2, text: String, big: bool = false) -> void :
	var label: = Label.new()
	label.text = text
	var heavy: = big or (text.is_valid_int() and int(text) >= 30)
	point += Vector2(randf_range(-8, 8), 0)
	label.position = point
	label.z_index = 80
	label.add_theme_font_size_override("font_size", 15 if heavy else 12)
	label.add_theme_color_override("font_outline_color", Color("1a0d16"))
	label.add_theme_constant_override("outline_size", 4)
	label.modulate = Color("ffe08a") if heavy else (Color("aab6c4") if text == "BLOCK" else Color("ffd4de"))
	label.pivot_offset = Vector2(12, 8)
	label.scale = Vector2.ONE * (1.7 if heavy else 1.35)
	add_child(label)
	var tween: = create_tween().set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", point.y - 26, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0, 0.25).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)

func enemy_defeated(_foe: PixelActor = null) -> void :
	stage = 3
	set_music_section("demo")
	toast("Raven: Der Weg ist frei. Sichere die Daten am Ausgang im Nordosten.")
	autosave()

func player_defeated() -> void :
	if is_instance_valid(blood_effects):blood_effects.clear()
	menu_open = true
	ui.show_menu("SYSTEM GESTÖRT")
	ui.resume_button.text = "Am Kontrollpunkt fortsetzen"

	player.health = 100
	player.energy = 100
	player.position = Vector2(562, 386) if stage == 2 else WorldData.START
	player.reset_transients()
	reset_raven(Vector2(586, 405) if stage == 2 else WorldData.RAVEN)
	enemy.position = WorldData.JACKAL
	enemy.reset_fight()
	enemy.active = stage == 2

func snapshot() -> Dictionary:
	var state: = {"version": 1, "stage": stage, "health": player.health, "energy": player.energy, "x": player.position.x, "y": player.position.y, "enemy_health": enemy.health}
	state.props = dressing_state()
	if coop:
		state.raven = {"x": raven.position.x, "y": raven.position.y, "health": raven.health, "energy": raven.energy}
	return state

func autosave() -> void :
	if not SaveService.write(snapshot(), save_path()):
		toast("Der Kontrollpunkt konnte nicht gespeichert werden. F5 erneut versuchen.")

func save_game() -> bool:
	var success: = SaveService.write(snapshot(), save_path())
	toast("Spielstand gespeichert" if success else "Speichern fehlgeschlagen")
	return success

func load_game(requested_mode: Variant = null) -> bool:
	var requested_coop: bool = coop if requested_mode == null else bool(requested_mode)
	var path: = SaveService.COOP_PATH if requested_coop else SaveService.PATH
	var data: = SaveService.read(path)
	if data.is_empty():
		toast("Kein gültiger Spielstand vorhanden")
		return false
	set_coop(requested_coop)
	restore_dressing_state(data.get("props", {}))
	stage = int(data.stage)
	set_gate(stage >= 2)
	player.position = free_saved_position(Vector2(data.x, data.y))
	player.health = int(data.health)
	player.energy = float(data.energy)
	player.reset_transients()
	enemy.position = WorldData.JACKAL
	enemy.reset_fight(int(data.enemy_health))
	enemy.active = stage == 2
	if enemy.health == 0:
		enemy.visual.rotation = PI * 0.5
		enemy.visual.position.y = -10
		enemy.visual.modulate = Color(0.45, 0.5, 0.6, 0.7)
	if coop:
		reset_raven(free_saved_position(Vector2(data.raven.x, data.raven.y)))
		raven.health = int(data.raven.health)
		raven.energy = float(data.raven.energy)
	else:
		var follow_position: Vector2 = player.position + Vector2(-44, 24)
		reset_raven(free_saved_position(follow_position if stage >= 2 and WorldData.walkable(follow_position, gate_open) else WorldData.RAVEN))
	hack_cooldown = 0.0
	set_music_section("boss" if stage == 2 else "demo")
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	toast("Spielstand geladen")
	return true

func reset_raven(point: Vector2) -> void :
	raven.position = point
	raven.health = 100
	raven.energy = 100.0
	raven.reset_transients()

func new_game(save_checkpoint: bool = true) -> void :
	cancel_terminal()
	restore_dressing_state({})
	stage = 0
	set_gate(false)
	player.position = WorldData.START
	player.health = 100
	player.energy = 100
	player.reset_transients()
	enemy.position = WorldData.JACKAL
	enemy.reset_fight()
	enemy.active = false
	reset_raven(WorldData.RAVEN)
	hack_cooldown = 0.0
	set_music_section("demo")
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	if save_checkpoint:
		autosave()

func toast(text: String) -> void :
	if ui != null:
		ui.toast(text)

func sound(kind: String, pitch_variance: float = 0.0) -> void :
	if not audio_on or DisplayServer.get_name() == "headless" or AudioServer.get_driver_name() == "Dummy":
		return
	for channel in sfx:
		if not channel.playing:
			channel.stream = load("res://assets/audio/" + kind + ".wav")
			channel.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
			channel.play()
			return

func toggle_audio() -> void :
	audio_on = not audio_on
	music.stream_paused = not audio_on
	if not audio_on and combat_audio != null: combat_audio.stop()
	if audio_on and not music.playing and DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy":
		music.play()
	for channel in sfx:
		if not audio_on:
			channel.stop()
	toast("Ton an" if audio_on else "Ton aus")

func _exit_tree() -> void :
	# A freeze frame must never outlive its scene (chapter change mid-hit).
	hitstop_left = 0.0
	Engine.time_scale = 1.0
	gamepads.clear()
	if is_instance_valid(music):
		music.stop()
		music.stream = null
	for channel in sfx:
		channel.stop()
		channel.stream = null

func _draw() -> void :
	if not gate_open:
		for y in range(164, 496, 8):
			draw_line(Vector2(509, y), Vector2(509, y + 5), Color(0.28, 0.8, 0.95, 0.75), 3)
		draw_line(Vector2(504, 164), Vector2(504, 496), Color(0.2, 0.6, 0.8, 0.3))
		for y in [176, 480]:
			draw_rect(Rect2(499, y, 21, 12), Color("2e4355"))
			draw_rect(Rect2(504, y + 3, 11, 3), Color("76dfec"))
	var marker: Vector2 = WorldData.RAVEN if stage == 0 else WorldData.TERMINAL if stage == 1 else enemy.position if stage == 2 else WorldData.EXIT
	if stage < 4:
		PixelMarker.draw(self, marker, player.position.distance_to(marker) <= 40.0, false, 72.0)
	if stage >= 3:
		PixelMarker.draw(self, WorldData.EXIT, true)

func _capture(path: String) -> void :
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
