extends Node2D

const PlayerScript = preload("res://scripts/player.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const HudScript = preload("res://scripts/hud.gd")
const EffectsScript = preload("res://scripts/effects.gd")
var player
var enemy
var raven: PixelActor
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

func _ready() -> void:
	_bind_inputs()
	_build_world()
	_build_audio()
	ui = HudScript.new()
	ui.world = self
	add_child(ui)
	ui.show_menu()
	if "--capture" in OS.get_cmdline_user_args():
		screenshot_mode = true
		close_menu()
		stage = 2
		set_gate(true)
		player.position = Vector2(674, 362)
		raven.position = Vector2(587, 394)
		enemy.active = true
		enemy.position = Vector2(770, 323)
		_capture.call_deferred()

func _bind_inputs() -> void:
	var bindings := {
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN],
		"attack": [KEY_J], "dash": [KEY_SPACE, KEY_SHIFT], "cloak": [KEY_C],
		"hack": [KEY_Q], "interact": [KEY_E, KEY_ENTER], "pause_game": [KEY_ESCAPE],
		"save_game": [KEY_F5], "load_game": [KEY_F9], "help_game": [KEY_H], "mute_game": [KEY_M]
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

func _build_world() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ground := Sprite2D.new()
	ground.texture = preload("res://assets/world/alley.png")
	ground.centered = false
	ground.z_index = -10
	add_child(ground)
	for wall in WorldData.WALLS:
		_collider(wall)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	for prop in WorldData.PROPS:
		_collider(prop.collision)
		var sprite := Sprite2D.new()
		var atlas := AtlasTexture.new()
		atlas.atlas = preload("res://assets/world/props.png")
		atlas.region = [Rect2(0, 0, 64, 48), Rect2(64, 0, 32, 32), Rect2(96, 0, 32, 48)][prop.kind]
		sprite.texture = atlas
		sprite.position = prop.position
		sprite.offset = Vector2(0, -atlas.region.size.y * 0.5 + 4)
		actors.add_child(sprite)
	gate_body = _collider(WorldData.GATE)
	player = PlayerScript.new()
	player.name = "Shadepi"
	player.setup(preload("res://assets/sprites/shadepi.png"), self)
	player.position = WorldData.START
	actors.add_child(player)
	raven = PixelActor.new()
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
	ambient.color = Color(0.78, 0.82, 0.95)
	add_child(ambient)
	_light(Vector2(77, 244), Color("fb71b5"), 1.9, 0.9)
	_light(Vector2(640, 264), Color("65d9e5"), 3.0, 1.25)
	_light(Vector2(900, 264), Color("df78be"), 2.5, 1.0)
	_light(Vector2(454, 337), Color("5be1e5"), 1.0, 0.9)
	_light(Vector2(11, -18), Color("f55078"), 0.7, 0.6, player)
	_light(Vector2(0, -24), Color("50cbe8"), 0.6, 0.45, raven)
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

func _collider(rect: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	return body

func _light(point: Vector2, color: Color, radius: float, strength: float, parent: Node = null) -> void:
	if parent == null:
		parent = self
	var light := PointLight2D.new()
	light.position = point
	light.texture = light_texture
	light.texture_scale = radius
	light.color = color
	light.energy = strength
	parent.add_child(light)

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
		raven.animate("attack" if enemy.exposed > 0.0 else "idle", delta)
		if stage >= 2:
			var target: Vector2 = player.position + Vector2(-52, 26)
			if raven.position.distance_to(target) > 35 and WorldData.walkable(target, gate_open):
				raven.facing = (target - raven.position).normalized()
				raven.velocity = raven.facing * 75
				raven.move_and_slide()
				raven.animate("walk", delta)
			if stage == 2 and player.position.x > 548:
				enemy.active = true
	else:
		raven.animate("idle", delta)
	camera.position = player.position + Vector2(0, -28) + player.facing * 8
	shake = maxf(0, shake - delta * 20)
	camera.offset = Vector2(sin(Time.get_ticks_msec() * 0.1), cos(Time.get_ticks_msec() * 0.15)) * shake
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("pause_game") or event.is_action_pressed("help_game"):
		if menu_open:
			close_menu()
		else:
			menu_open = true
			ui.show_menu()
		get_viewport().set_input_as_handled()
		return
	if menu_open:
		return
	if ui.dialogue_open:
		if event.is_action_pressed("interact"):
			ui.advance_dialogue()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("interact"):
		interact()
	elif event.is_action_pressed("hack"):
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
		return "E · Mit Raven sprechen"
	if stage == 1 and player.position.distance_to(WorldData.TERMINAL) < 54:
		return "E · Sicherheitssperre hacken"
	if stage == 3 and player.position.distance_to(WorldData.EXIT) < 54:
		return "E · Daten sichern"
	return ""

func interact() -> void:
	if stage == 0 and player.position.distance_to(raven.position) < 62:
		ui.dialogue([
			["Raven", "Chrome Jackal bewacht den Ausgang. Ich kann seine Implantate stören. Du kümmerst dich um den Rest."],
			["Shadepi", "Einverstanden. Zuerst brauchen wir einen Weg durch die Sperre."],
			["Raven", "Das Terminal rechts. Danach Q für meinen Hack. Wenn er rot ausholt: ausweichen!"]
		], func():
			stage = 1
			autosave()
		)
	elif stage == 1 and player.position.distance_to(WorldData.TERMINAL) < 54:
		set_gate(true)
		stage = 2
		sound("hack")
		effects.burst(WorldData.TERMINAL, Color("61e0ec"), 22)
		toast("Raven: Sperre offen. Seine Panzerung schwäche ich mit Q.")
		autosave()
	elif stage == 3 and player.position.distance_to(WorldData.EXIT) < 54:
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

func raven_hack() -> bool:
	if stage != 2 or enemy.health <= 0:
		toast("Raven: Hier ist gerade kein aktives Ziel.")
		return false
	if hack_cooldown > 0:
		toast("Raven: Mein Deck lädt noch.")
		return false
	if player.position.distance_to(enemy.position) > 240 or not _line_clear(player.position, enemy.position):
		toast("Raven: Näher ran. Ich brauche eine freie Verbindung.")
		return false
	hack_cooldown = 11.0
	enemy.hack()
	effects.burst(enemy.position, Color("4de2ef"), 28)
	sound("hack")
	toast("Raven: Implantate gestört. Jetzt!")
	return true

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

func enemy_defeated() -> void:
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
	enemy.position = WorldData.JACKAL
	enemy.reset_fight()
	enemy.active = stage == 2

func snapshot() -> Dictionary:
	return {"version": 1, "stage": stage, "health": player.health, "energy": player.energy, "x": player.position.x, "y": player.position.y, "enemy_health": enemy.health}

func autosave() -> void:
	if not SaveService.write(snapshot()):
		toast("Der Kontrollpunkt konnte nicht gespeichert werden. F5 erneut versuchen.")

func save_game() -> bool:
	var success := SaveService.write(snapshot())
	toast("Spielstand gespeichert" if success else "Speichern fehlgeschlagen")
	return success

func load_game() -> bool:
	var data := SaveService.read()
	if data.is_empty():
		toast("Kein gültiger Spielstand vorhanden")
		return false
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
	raven.position = WorldData.RAVEN if stage < 2 else player.position + Vector2(-44, 24)
	if not WorldData.walkable(raven.position, gate_open):
		raven.position = WorldData.RAVEN
	hack_cooldown = 0.0
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
	toast("Spielstand geladen")
	return true

func new_game() -> void:
	stage = 0
	set_gate(false)
	player.position = WorldData.START
	player.health = 100
	player.energy = 100
	player.reset_transients()
	enemy.position = WorldData.JACKAL
	enemy.reset_fight()
	enemy.active = false
	raven.position = WorldData.RAVEN
	hack_cooldown = 0.0
	ui.dialogue_open = false
	ui.dialogue_panel.hide()
	close_menu()
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
	var marker := WorldData.RAVEN if stage == 0 else WorldData.TERMINAL if stage == 1 else WorldData.JACKAL if stage == 2 else WorldData.EXIT
	if stage < 4:
		var bounce := sin(Time.get_ticks_msec() * 0.004) * 2
		draw_polyline(PackedVector2Array([marker + Vector2(-5, -72 + bounce), marker + Vector2(0, -67 + bounce), marker + Vector2(5, -72 + bounce)]), Color("8aebf0"), 2)
	if stage >= 3:
		draw_arc(WorldData.EXIT, 18, 0.0, TAU, 24, Color(0.4, 0.9, 0.85, 0.6), 1)

func _capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/screenshot.png")
	get_tree().quit()
