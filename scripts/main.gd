extends Node2D

const GamepadBindings = preload("res://scripts/gamepad_bindings.gd")
const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const HudScript = preload("res://scripts/hud.gd")
const EffectsScript = preload("res://scripts/effects.gd")
const GroundAtmosphereScript = preload("res://scripts/ground_atmosphere.gd")
const VISUAL_PRESETS := ["Reduziert", "Ausgewogen", "Atmosphärisch"]
const VISUAL_SETTINGS := "user://shadepi-graphics.cfg"
var player
var enemy
var raven
var coop := false
var gamepads := GamepadBindings.new()
const COOP_REACH := Vector2(448, 166)
var ui
var effects
var camera: Camera2D
var actors: Node2D
var gate_body: StaticBody2D
var stage := 0
var menu_open := true
var started := false
var hack_cooldown := 0.0
var shake := 0.0
var gate_open := false
var audio_on := true
var sfx: Array[AudioStreamPlayer] = []
var music: AudioStreamPlayer
var light_texture := preload("res://assets/world/light.png")
var screenshot_mode := false
var visual_quality := 2
var ground_atmosphere: Node2D
var atmosphere_filter: ColorRect
var filter_material: ShaderMaterial
var shadow_lights: Array[PointLight2D] = []
var neon_halos: Array[Sprite2D] = []
var blade_light: PointLight2D
var next_step_ripple := 0.0

func _ready() -> void:
	_bind_inputs()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	gamepads.assign(Input.get_connected_joypads(), coop)
	_build_world()
	_build_atmosphere_filter()
	_load_visual_quality()
	_build_audio()
	ui = create_hud()
	ui.world = self
	add_child(ui)
	ui.show_menu()
	var args := OS.get_cmdline_user_args()
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

func _bind_inputs() -> void:
	if not InputMap.has_action("raven_mouse_attack"):
		InputMap.add_action("raven_mouse_attack")
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("raven_mouse_attack", mouse)
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"attack": [KEY_J], "dash": [KEY_SPACE, KEY_SHIFT], "cloak": [KEY_C],
		"hack": [KEY_Q], "interact": [KEY_E, KEY_ENTER], "pause_game": [KEY_ESCAPE],
		"save_game": [KEY_F5], "load_game": [KEY_F9], "help_game": [KEY_H], "mute_game": [KEY_M],
		"graphics_game": [KEY_V],
		"raven_move_left": [KEY_LEFT], "raven_move_right": [KEY_RIGHT],
		"raven_move_up": [KEY_UP], "raven_move_down": [KEY_DOWN],
		"raven_attack": [KEY_U], "raven_hack": [KEY_O],
		"raven_dash": [KEY_P], "raven_interact": [KEY_ENTER]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for action in ["attack", "mouse_attack"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event(action, mouse)

func set_coop(enabled: bool) -> void:
	coop = enabled
	gamepads.assign(Input.get_connected_joypads(), coop)
	camera.limit_left = -18 if coop else 0
	camera.limit_right = 1042 if coop else 1024
	# Solo keeps the arrow-key shortcuts. In co-op each direction has one owner.
	var arrows := [KEY_LEFT, KEY_RIGHT, KEY_UP, KEY_DOWN]
	var actions := ["move_left", "move_right", "move_up", "move_down"]
	for i in arrows.size():
		var event := InputEventKey.new()
		event.physical_keycode = arrows[i]
		Input.action_release(actions[i])
		Input.action_release("raven_" + actions[i])
		if coop:
			InputMap.action_erase_event(actions[i], event)
		elif not InputMap.action_has_event(actions[i], event):
			InputMap.action_add_event(actions[i], event)

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	gamepads.assign(Input.get_connected_joypads(), coop)

func hack_input_hint() -> String:
	if coop:
		return "O / Y" if gamepads.raven_device >= 0 else "O"
	return "Q / RB" if gamepads.shadepi_device >= 0 else "Q"

func save_path() -> String:
	return SaveService.COOP_PATH if coop else SaveService.PATH

func limit_coop_motion(actor: PixelActor, motion: Vector2, delta: float) -> Vector2:
	if not coop:
		return motion
	var partner: PixelActor = raven if actor == player else player
	var offset := actor.position - partner.position
	var step := motion * delta
	# If a collision displaced either actor, allow motion back toward the group.
	step.x = clampf(step.x, minf(0.0, -COOP_REACH.x - offset.x), maxf(0.0, COOP_REACH.x - offset.x))
	step.y = clampf(step.y, minf(0.0, -COOP_REACH.y - offset.y), maxf(0.0, COOP_REACH.y - offset.y))
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

func _build_world() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ground := Sprite2D.new()
	ground.texture = preload("res://assets/world/alley.png")
	ground.centered = false
	ground.z_index = -10
	add_child(ground)
	ground_atmosphere = GroundAtmosphereScript.new()
	add_child(ground_atmosphere)
	for wall in world_walls():
		_collider(wall)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for prop in world_props():
		_collider(prop.collision)
		var sprite := Sprite2D.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://assets/world/props.png")
		atlas.region = [Rect2(0, 0, 64, 48), Rect2(64, 0, 32, 32), Rect2(96, 0, 32, 48)][prop.kind]
		sprite.texture = atlas
		sprite.position = prop.position
		sprite.offset = Vector2(0, -atlas.region.size.y * 0.5 + 4)
		actors.add_child(sprite)
	gate_body = _collider(WorldData.GATE, false)
	player = PlayerScript.new()
	player.name = "Shadepi"
	player.setup(preload("res://assets/sprites/shadepi.png"), self)
	player.position = WorldData.START
	actors.add_child(player)
	raven = PlayerScript.new()
	raven.second_player = true
	raven.name = "Raven"
	raven.setup(preload("res://assets/sprites/raven.png"), self)
	raven.position = WorldData.RAVEN
	actors.add_child(raven)
	enemy = EnemyScript.new()
	enemy.name = "ChromeJackal"
	enemy.setup(preload("res://assets/sprites/jackal.png"), self)
	enemy.position = WorldData.JACKAL
	actors.add_child(enemy)
	var ambient := CanvasModulate.new()
	ambient.color = Color(0.72, 0.77, 0.92)
	add_child(ambient)
	_light(Vector2(77, 282), Color("fb71b5"), 2.5, 1.25)
	shadow_lights.append(_light(Vector2(640, 270), Color("65e8fa"), 3.5, 1.65))
	shadow_lights.append(_light(Vector2(900, 272), Color("f37ac1"), 3.0, 1.45))
	_light(Vector2(454, 337), Color("5be1e5"), 1.2, 1.1)
	blade_light = _light(Vector2(11, -18), Color("f55078"), 0.9, 0.75, player)
	_light(Vector2(0, -24), Color("50cbe8"), 0.6, 0.45, raven)
	_halo(Vector2(78, 226), Color(1.0, 0.23, 0.55, 0.38), 1.2)
	_halo(Vector2(638, 227), Color(0.12, 0.75, 1.0, 0.4), 1.42)
	_halo(Vector2(899, 225), Color(0.95, 0.23, 0.65, 0.35), 1.28)
	effects = EffectsScript.new()
	effects.world = self
	add_child(effects)
	camera = Camera2D.new()
	camera.position = player.position
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1024
	camera.limit_bottom = 640
	add_child(camera)
	camera.make_current()

func _collider(rect: Rect2, casts_shadow: bool = true) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	if casts_shadow:
		var shadow := LightOccluder2D.new()
		shadow.sdf_collision = false
		var silhouette := OccluderPolygon2D.new()
		var corner := rect.size * 0.5
		silhouette.polygon = PackedVector2Array([-corner, Vector2(corner.x, -corner.y), corner, Vector2(-corner.x, corner.y)])
		shadow.occluder = silhouette
		body.add_child(shadow)
	add_child(body)
	return body

func _light(point: Vector2, color: Color, radius: float, strength: float, parent: Node = null) -> PointLight2D:
	if parent == null:
		parent = self
	var light := PointLight2D.new()
	light.position = point
	light.texture = light_texture
	light.texture_scale = radius
	light.color = color
	light.energy = strength
	parent.add_child(light)
	return light

func _halo(point: Vector2, color: Color, radius: float) -> void:
	var halo := Sprite2D.new()
	halo.texture = light_texture
	halo.position = point
	halo.scale = Vector2.ONE * radius
	halo.modulate = color
	halo.z_index = -2
	var material := CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = material
	add_child(halo)
	neon_halos.append(halo)

func _build_atmosphere_filter() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	atmosphere_filter = ColorRect.new()
	atmosphere_filter.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	filter_material = ShaderMaterial.new()
	filter_material.shader = preload("res://shaders/atmosphere.gdshader")
	atmosphere_filter.material = filter_material
	layer.add_child(atmosphere_filter)

func _load_visual_quality() -> void:
	var config := ConfigFile.new()
	var saved: Variant = 2
	if config.load(VISUAL_SETTINGS) == OK:
		saved = config.get_value("video", "preset", 2)
	set_visual_quality(int(saved) if saved is int else 2)

func set_visual_quality(level: int) -> void:
	visual_quality = clampi(level, 0, 2)
	ground_atmosphere.quality = visual_quality
	effects.quality = visual_quality
	atmosphere_filter.visible = visual_quality > 0
	filter_material.set_shader_parameter("strength", 1.0 if visual_quality == 2 else 0.55)
	filter_material.set_shader_parameter("bloom", 0.32 if visual_quality == 2 else 0.15)
	filter_material.set_shader_parameter("detailed", visual_quality == 2)
	for light in shadow_lights:
		light.shadow_enabled = visual_quality > 0
		light.shadow_filter = Light2D.SHADOW_FILTER_PCF5 if visual_quality == 2 else Light2D.SHADOW_FILTER_NONE
		light.shadow_filter_smooth = 2.0
	for halo in neon_halos:
		halo.visible = visual_quality > 0
	if ui != null:
		ui.visual_button.text = "Bildstil: " + VISUAL_PRESETS[visual_quality]

func cycle_visual_quality() -> void:
	set_visual_quality((visual_quality + 1) % VISUAL_PRESETS.size())
	var config := ConfigFile.new()
	config.set_value("video", "preset", visual_quality)
	if config.save(VISUAL_SETTINGS) != OK:
		toast("Bildstil geändert · Einstellung konnte nicht gespeichert werden")
	else:
		toast("Bildstil: " + VISUAL_PRESETS[visual_quality])

func _build_audio() -> void:
	music = AudioStreamPlayer.new()
	var stream: AudioStreamWAV = preload("res://assets/audio/neon-loop.wav").duplicate()
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = stream.data.size() / 2
	music.stream = stream
	music.volume_db = -12
	add_child(music)
	if DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy":
		music.play()
	for i in 4:
		var channel := AudioStreamPlayer.new()
		channel.volume_db = -8
		add_child(channel)
		sfx.append(channel)

func _process(delta: float) -> void:
	if not is_busy():
		hack_cooldown = maxf(0, hack_cooldown - delta)
		next_step_ripple = maxf(0.0, next_step_ripple - delta)
		if player.velocity.length() > 45.0 and next_step_ripple <= 0.0:
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
	if coop:
		camera.position = player.position.lerp(raven.position, 0.5) + Vector2(0, -27)
	else:
		camera.position = player.position + Vector2(0, -60) + player.facing * 8
	shake = maxf(0, shake - delta * 20)
	camera.offset = Vector2(sin(Time.get_ticks_msec() * 0.1), cos(Time.get_ticks_msec() * 0.15)) * shake
	queue_redraw()

func _update_raven_follower(delta: float) -> void:
	raven.animate("attack" if enemy.exposed > 0.0 else "idle", delta)
	if stage >= 2:
		var target: Vector2 = player.position + Vector2(-52, 26)
		if raven.position.distance_to(target) > 35 and WorldData.walkable(target, gate_open):
			raven.facing = (target - raven.position).normalized()
			raven.velocity = raven.facing * 75
			raven.move_and_slide()
			raven.animate("walk", delta)

func _unhandled_input(event: InputEvent) -> void:
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
	if ui.dialogue_open:
		if event.is_action_pressed("interact") or (coop and event.is_action_pressed("raven_interact")):
			ui.advance_dialogue()
			get_viewport().set_input_as_handled()
		return
	if coop and event.is_action_pressed("raven_interact"):
		interact(raven)
	elif event.is_action_pressed("interact"):
		interact()
	elif (coop and event.is_action_pressed("raven_hack")) or (not coop and event.is_action_pressed("hack")):
		raven_hack()
	elif event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
	elif event.is_action_pressed("mute_game"):
		toggle_audio()

func is_busy() -> bool:
	return menu_open or (ui != null and ui.dialogue_open) or player.health <= 0

func close_menu() -> void:
	menu_open = false
	started = true
	ui.menu.hide()

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

func interact(actor: PixelActor = null) -> void:
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

func set_gate(open: bool) -> void:
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
	var origin := hack_origin()
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

func raven_shot() -> void:
	var origin: Vector2 = raven.position
	var endpoint: Vector2 = origin + raven.facing * 152.0
	var query := PhysicsRayQueryParameters2D.create(origin, endpoint, 1)
	var wall := get_world_2d().direct_space_state.intersect_ray(query)
	if not wall.is_empty():
		endpoint = wall.position
	var target := raven_shot_target(origin)
	if target != null:
		endpoint = origin + raven.facing * (target.position - origin).dot(raven.facing)
		target.take_damage(17)
	effects.pulse_trace(origin, endpoint)
	sound("hack")

func raven_shot_target(origin: Vector2) -> PixelActor:
	return enemy if stage == 2 and raven_can_hit(enemy, origin) else null

func raven_can_hit(target: PixelActor, origin: Vector2) -> bool:
	var offset := target.position - origin
	var depth: float = offset.dot(raven.facing)
	return depth >= 0.0 and depth <= 152.0 and absf(offset.cross(raven.facing)) <= 8.0 and _line_clear(origin, origin + raven.facing * depth)

func _line_clear(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from, to, 1)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func player_strike(amount: int) -> void:
	if stage == 2 and CombatRules.can_strike(player.position, player.facing, enemy.position) and _line_clear(player.position, enemy.position):
		enemy.take_damage(amount)

func spawn_slash(point: Vector2, direction: Vector2) -> void:
	effects.slash(point, direction)

func spawn_trail(point: Vector2, color: Color) -> void:
	effects.trail(point, color)

func impact(point: Vector2, foe: bool) -> void:
	effects.burst(point, Color("ff648a") if foe else Color("a6d6ea"))
	shake = 2.2 if foe else 3.5
	sound("hit")

func damage_number(point: Vector2, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = point
	label.z_index = 80
	label.add_theme_font_size_override("font_size", 12)
	label.modulate = Color("ffd4de")
	add_child(label)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", point.y - 22, 0.55)
	tween.tween_property(label, "modulate:a", 0, 0.55)
	tween.chain().tween_callback(label.queue_free)

func enemy_defeated(_foe: PixelActor = null) -> void:
	stage = 3
	toast("Raven: Der Weg ist frei. Sichere die Daten am Ausgang im Nordosten.")
	autosave()

func player_defeated() -> void:
	menu_open = true
	ui.show_menu("SYSTEM GESTÖRT")
	ui.resume_button.text = "Am Kontrollpunkt fortsetzen"
	# Recover a playable checkpoint immediately; opening the menu keeps it frozen.
	player.health = 100
	player.energy = 100
	player.position = Vector2(562, 386) if stage == 2 else WorldData.START
	player.reset_transients()
	reset_raven(Vector2(586, 405) if stage == 2 else WorldData.RAVEN)
	enemy.position = WorldData.JACKAL
	enemy.reset_fight()
	enemy.active = stage == 2

func snapshot() -> Dictionary:
	var state := {"version": 1, "stage": stage, "health": player.health, "energy": player.energy, "x": player.position.x, "y": player.position.y, "enemy_health": enemy.health}
	if coop:
		state.raven = {"x": raven.position.x, "y": raven.position.y, "health": raven.health, "energy": raven.energy}
	return state

func autosave() -> void:
	if not SaveService.write(snapshot(), save_path()):
		toast("Der Kontrollpunkt konnte nicht gespeichert werden. F5 erneut versuchen.")

func save_game() -> bool:
	var success := SaveService.write(snapshot(), save_path())
	toast("Spielstand gespeichert" if success else "Speichern fehlgeschlagen")
	return success

func load_game(requested_mode: Variant = null) -> bool:
	var requested_coop: bool = coop if requested_mode == null else bool(requested_mode)
	var path := SaveService.COOP_PATH if requested_coop else SaveService.PATH
	var data := SaveService.read(path)
	if data.is_empty():
		toast("Kein gültiger Spielstand vorhanden")
		return false
	set_coop(requested_coop)
	stage = int(data.stage)
	set_gate(stage >= 2)
	player.position = Vector2(data.x, data.y)
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
		reset_raven(Vector2(data.raven.x, data.raven.y))
		raven.health = int(data.raven.health)
		raven.energy = float(data.raven.energy)
	else:
		var follow_position: Vector2 = player.position + Vector2(-44, 24)
		reset_raven(follow_position if stage >= 2 and WorldData.walkable(follow_position, gate_open) else WorldData.RAVEN)
	hack_cooldown = 0.0
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	toast("Spielstand geladen")
	return true

func reset_raven(point: Vector2) -> void:
	raven.position = point
	raven.health = 100
	raven.energy = 100.0
	raven.reset_transients()

func new_game(save_checkpoint: bool = true) -> void:
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
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	if save_checkpoint:
		autosave()

func toast(text: String) -> void:
	if ui != null:
		ui.toast(text)

func sound(kind: String) -> void:
	if not audio_on or DisplayServer.get_name() == "headless" or AudioServer.get_driver_name() == "Dummy":
		return
	for channel in sfx:
		if not channel.playing:
			channel.stream = load("res://assets/audio/" + kind + ".wav")
			channel.play()
			return

func toggle_audio() -> void:
	audio_on = not audio_on
	music.stream_paused = not audio_on
	for channel in sfx:
		if not audio_on:
			channel.stop()
	toast("Ton an" if audio_on else "Ton aus")

func _exit_tree() -> void:
	gamepads.clear()
	if is_instance_valid(music):
		music.stop()
		music.stream = null
	for channel in sfx:
		channel.stop()
		channel.stream = null

func _draw() -> void:
	if not gate_open:
		for y in range(164, 496, 8):
			draw_line(Vector2(509, y), Vector2(509, y + 5), Color(0.28, 0.8, 0.95, 0.75), 3)
		draw_line(Vector2(504, 164), Vector2(504, 496), Color(0.2, 0.6, 0.8, 0.3))
		for y in [176, 480]:
			draw_rect(Rect2(499, y, 21, 12), Color("2e4355"))
			draw_rect(Rect2(504, y + 3, 11, 3), Color("76dfec"))
	var marker: Vector2 = WorldData.RAVEN if stage == 0 else WorldData.TERMINAL if stage == 1 else enemy.position if stage == 2 else WorldData.EXIT
	if stage < 4:
		var bounce := sin(Time.get_ticks_msec() * 0.004) * 2
		draw_polyline(PackedVector2Array([marker + Vector2(-5, -72 + bounce), marker + Vector2(0, -67 + bounce), marker + Vector2(5, -72 + bounce)]), Color("8aebf0"), 2)
	if stage >= 3:
		draw_arc(WorldData.EXIT, 18, 0.0, TAU, 24, Color(0.4, 0.9, 0.85, 0.6), 1)

func _capture(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
