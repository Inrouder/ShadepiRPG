extends SceneTree

const MusicLibrary = preload("res://scripts/music_library.gd")

var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	check_admin_core()
	check(MusicLibrary.SLOTS.size() == 27, "every menu, combat and story section has an assigned music slot")
	check(MusicLibrary.candidates("chapter_2_dive")[0] == "res://assets/music/Fight.mp3", "regular fights use the shared Fight track")
	check(MusicLibrary.path_for("boss") == "res://assets/music/Boss.mp3", "boss encounters use the supplied boss track")
	check(MusicLibrary.path_for("menu") == MusicLibrary.path_for("chapter_7_finale"), "main menu uses the lake finale music")
	check(load("res://assets/menu/start-city.png").get_size() == Vector2(1280, 720), "start menu artwork keeps its 16:9 master resolution")
	check(CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(40, 0)), "frontal target can be hit")
	check(not CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(-40, 0)), "target behind player is safe")
	check(not CombatRules.can_strike(Vector2.ZERO, Vector2.RIGHT, Vector2(70, 0)), "target outside blade reach is safe")
	check(CombatRules.damage(25, true) > CombatRules.damage(25, false), "Raven creates a meaningful damage window")
	check(WorldData.walkable(WorldData.START, false), "spawn is walkable")
	check(not WorldData.walkable(Vector2(150, 200), true), "building is solid")
	check(not WorldData.walkable(Vector2(509, 380), false), "closed gate blocks its corridor")
	check(WorldData.walkable(Vector2(509, 380), true), "open gate unblocks its corridor")
	# Flood-fill both sides with the same clearance as the player: verify no gate bypass.
	check(not reachable(WorldData.START, WorldData.JACKAL, false), "boss cannot be reached around the closed gate")
	check(reachable(WorldData.START, WorldData.RAVEN, false), "Raven can be reached from spawn")
	check(reachable(WorldData.START, WorldData.TERMINAL + Vector2(-26, 25), false), "terminal can be approached")
	check(reachable(WorldData.START, WorldData.EXIT, true), "open map connects to exit")
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.ui.start_backdrop.visible and scene.music_section == "menu", "live city and menu music are active on startup")
	check(root.content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS, "HQ opening menu renders at window resolution")
	check(SpriteAssets.valid_sheet(scene.player.visual.texture), "selected player sprite fits a supported grid")
	var invalid_sprite := ImageTexture.create_from_image(Image.create_empty(48, 64, false, Image.FORMAT_RGBA8))
	check(not SpriteAssets.valid_sheet(invalid_sprite), "single-frame replacement is rejected")
	for dims in [Vector2i(384, 1024), Vector2i(384, 2048)]:
		var old_custom := ImageTexture.create_from_image(Image.create_empty(dims.x, dims.y, false, Image.FORMAT_RGBA8))
		check(SpriteAssets.valid_sheet(old_custom), "user-created classic custom atlas keeps working")
	for hero in ["shadepi.png", "raven.png"]:
		check(not FileAccess.file_exists("res://assets/sprites/" + hero), hero + " no longer needs a pixel proxy")
	if "--expect-custom-sprite" in OS.get_cmdline_user_args():
		check(scene.player.visual.texture.resource_path == "res://assets/custom/shadepi.png", "imported custom sheet takes precedence")
	check_hero_sprites(scene)
	check_npc_sprites(scene)
	check_admin_runtime(scene)
	scene.set_visual_quality(0)
	check(not scene.atmosphere_filter.visible and not scene.shadow_lights[0].shadow_enabled, "reduced mode removes screen processing and dynamic shadows")
	check(not scene.ui.start_backdrop.atmosphere.visible, "reduced mode also disables the menu post-processing pass")
	scene.set_visual_quality(2)
	check(scene.atmosphere_filter.visible and scene.shadow_lights[0].shadow_enabled, "atmospheric mode restores lighting and post filter")
	check(scene.ui.start_backdrop.atmosphere.visible, "atmospheric mode restores menu weather grading")
	var menu_backdrop = scene.ui.start_backdrop
	var shadepi_transform: Transform2D = menu_backdrop.heroes.get_child(0).transform
	var raven_transform: Transform2D = menu_backdrop.heroes.get_child(1).transform
	for quality in 3:
		menu_backdrop.set_quality(quality)
		check(is_zero_approx(menu_backdrop.city_material.get_shader_parameter("strength")) == (quality == 0) and is_zero_approx(scene.ui.menu_chrome.strength) == (quality == 0), "reduced style disables city FX and menu light animation")
		check(is_zero_approx(menu_backdrop.wind_material.get_shader_parameter("strength")) == (quality == 0), "reduced quality disables hair and cloth wind")
		for point in [Vector2.ZERO, Vector2(640, 0), Vector2(0, 360), Vector2(640, 360)]:
			var motion := InputEventMouseMotion.new()
			motion.position = point
			menu_backdrop._input(motion)
			menu_backdrop.pulse_at(point)
			menu_backdrop._process(0.5)
			check(menu_backdrop.heroes.position == menu_backdrop.HERO_RECT.position and menu_backdrop.city.position == Vector2(-10, -6) and menu_backdrop.heroes.get_child(0).transform == shadepi_transform and menu_backdrop.heroes.get_child(1).transform == raven_transform, "pointer and clicks keep figures and rooftop anchored at quality %d" % quality)
	# Sample protected landmarks in the source illustration, not just node origins.
	for uv in [Vector2(0.4, 0.13), Vector2(0.4, 0.30), Vector2(0.23, 0.52), Vector2(0.56, 0.55), Vector2(0.1, 0.7), Vector2(0.31, 0.947), Vector2(0.535, 0.953)]:
		check(menu_backdrop.wind_weights(uv, false).is_zero_approx(), "Shadepi mask, body, hands, sword and boots stay rigid")
	for uv in [Vector2(0.75, 0.18), Vector2(0.75, 0.4), Vector2(0.91, 0.35), Vector2(0.65, 0.55), Vector2(0.733, 0.95), Vector2(0.855, 0.94)]:
		check(menu_backdrop.wind_weights(uv, true).is_zero_approx(), "Raven face, body, hands, tablet and boots stay rigid")
	check(menu_backdrop.wind_weights(Vector2(0.62, 0.40), true).x > 0.9, "Raven free hair tips receive wind")
	check(menu_backdrop.wind_weights(Vector2(0.25, 0.71), false).y > 0.9 and menu_backdrop.wind_weights(Vector2(0.59, 0.71), false).y > 0.9, "both free cloak edges receive wind")
	var safe_roof := PackedVector2Array([Vector2(35, 299), Vector2(280, 299), Vector2(298, 305), Vector2(70, 344), Vector2(35, 334)])
	for foot in [[Vector2(0.31, 0.947), false], [Vector2(0.535, 0.953), false], [Vector2(0.733, 0.95), true], [Vector2(0.855, 0.94), true]]:
		check(Geometry2D.is_point_in_polygon(menu_backdrop.foot_position(foot[0], foot[1]), safe_roof), "each boot rests inside the foreground platform")
	menu_backdrop.pulse_at(Vector2(120, 240))
	check(menu_backdrop.pulse > 0.0 and menu_backdrop.pulse_position == Vector2(120, 240), "menu interaction produces feedback at the input point")
	scene.close_menu()
	check(root.content_scale_mode == Window.CONTENT_SCALE_MODE_VIEWPORT, "closing HQ menu restores original gameplay viewport")
	check(not scene.ui.start_backdrop.visible, "live start backdrop closes with the menu")
	check(not scene.ui.start_backdrop.is_processing() and not scene.ui.start_backdrop.is_processing_input(), "hidden menu stops animation and input work")
	check_npc_attack_animation(scene)
	var start: Vector2 = scene.player.position
	Input.action_press("move_right")
	for i in 15:
		await physics_frame
	Input.action_release("move_right")
	await physics_frame
	check(scene.player.position.x > start.x + 15, "keyboard input moves the actual player")
	scene.player.position = Vector2(120, 283)
	Input.action_press("move_up")
	for i in 20:
		await physics_frame
	Input.action_release("move_up")
	await physics_frame
	check(scene.player.position.y >= 278.0, "physics keeps player outside the north wall")
	scene.player.position = WorldData.RAVEN + Vector2(0, 40)
	scene.interact()
	check(scene.ui.dialogue_open, "Raven interaction opens the dialogue")
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 1, "finishing Raven dialogue advances objective")
	scene.player.position = WorldData.TERMINAL + Vector2(-26, 25)
	scene.interact()
	await physics_frame
	check(scene.stage == 2 and scene.gate_open, "terminal unlocks gate and combat")
	check(MusicLibrary.path_for(scene.music_section).ends_with("Boss.mp3"), "the demo Jackal fight switches to boss music")
	scene.player.position = Vector2(720, 350)
	scene.player.facing = (scene.enemy.position - scene.player.position).normalized()
	check(scene.raven_hack(), "Raven hack succeeds at valid range")
	check(scene.enemy.exposed > 0.0 and scene.enemy.stun > 0.0, "hack interrupts and exposes boss")
	check(not scene.raven_hack(), "hack cannot bypass cooldown")
	scene.player.energy = 0
	check(not scene.player.try_dash(Vector2.RIGHT), "dash cannot spend missing energy")
	check(not scene.player.try_cloak(), "cloak cannot activate with missing energy")
	scene.player.energy = 100
	check(scene.player.try_cloak(), "cloak activates with energy")
	check(scene.player.cloak_time == 10, "cloak has the promised ten second window")
	await physics_frame
	await physics_frame
	await process_frame
	await process_frame
	check(not scene.player.light_occluder.visible and not scene.blade_light.enabled, "cloaked player does not give away position with light and cast shadow")
	check(scene.player.try_attack(), "player can attack")
	check(scene.player.cloak_time == 0, "attack cancels stealth")
	check(not scene.player.try_attack(), "attack cooldown prevents repeated hits")
	scene.player.attack_time = 0
	scene.player.attack_cooldown = 0
	scene.player.position = scene.enemy.position + Vector2(-34, 0)
	scene.player.facing = Vector2.RIGHT
	var before: int = scene.enemy.health
	scene.player_strike(25)
	check(scene.enemy.health < before, "front-facing strike damages boss")
	before = scene.enemy.health
	scene.player.facing = Vector2.LEFT
	scene.player_strike(25)
	check(scene.enemy.health == before, "turning away prevents damage")
	scene.enemy.take_damage(1000)
	check(scene.stage == 3 and scene.enemy.health == 0, "boss defeat advances exactly to data objective")
	check(MusicLibrary.path_for(scene.music_section).ends_with("Level.mp3"), "boss defeat restores the level track")
	scene.player.position = WorldData.EXIT
	scene.interact()
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 4, "exit completes scene")
	var snapshot: Dictionary = scene.snapshot()
	var file := "user://test-validation-slot.json"
	check(SaveService.write(snapshot, file), "valid state can be saved")
	check(SaveService.read(file).stage == 4, "save round-trip preserves progress")
	var invalid := snapshot.duplicate()
	invalid.x = 10
	invalid.y = 10
	check(SaveService.validate(invalid).is_empty(), "save cannot place player inside geometry")
	invalid = snapshot.duplicate()
	invalid.stage = 2.5
	check(SaveService.validate(invalid).is_empty(), "fractional quest stage is rejected")
	invalid = snapshot.duplicate()
	invalid.health = INF
	check(SaveService.validate(invalid).is_empty(), "non-finite values are rejected")
	invalid = snapshot.duplicate()
	invalid.enemy_health = 180
	check(SaveService.validate(invalid).is_empty(), "inconsistent quest and boss states are rejected")
	check(SaveService.write(snapshot, file), "second save creates recovery backup")
	var broken := FileAccess.open(file, FileAccess.WRITE)
	broken.store_string("{broken"); broken.close()
	check(SaveService.read(file).stage == 4, "corrupted slot recovers from validated backup")
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(file + suffix):
			DirAccess.remove_absolute(file + suffix)
	scene.new_game()
	check(scene.stage == 0 and scene.enemy.health == 180 and not scene.gate_open, "restart resets combat, quest and gate")
	await check_coop(scene)
	await check_gamepads(scene)
	check_directional_animation(scene)
	scene.queue_free()
	await process_frame
	await check_chapter()
	await check_chapter_two()
	await check_campaign()
	await check_feedback()
	print("SHADEPI TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func check_coop(scene: Node2D) -> void:
	# Use the menu entry point, then send real keyboard events.
	scene.menu_open = true
	scene.ui.show_menu()
	scene.ui.mode_button.pressed.emit()
	scene.ui.resume_button.pressed.emit()
	check(scene.coop and not scene.menu_open, "menu starts local co-op")
	check(scene.save_path() == SaveService.COOP_PATH, "co-op selects its own save slot")
	var shadepi_start: Vector2 = scene.player.position
	var raven_start: Vector2 = scene.raven.position
	key(KEY_D, true)
	key(KEY_LEFT, true)
	for i in 15:
		await physics_frame
	key(KEY_D, false)
	key(KEY_LEFT, false)
	await physics_frame
	check(scene.player.position.x > shadepi_start.x + 15, "WASD controls Shadepi during simultaneous input")
	check(scene.raven.position.x < raven_start.x - 15, "arrows independently control Raven")
	check(absf(scene.player.position.y - shadepi_start.y) < 0.1, "Raven input does not steer Shadepi")
	var offset: Vector2 = scene.camera.position - scene.player.position.lerp(scene.raven.position, 0.5)
	check(offset.distance_to(Vector2(0, -27)) < 3.0, "shared camera tracks both players")
	scene.player.position = scene.raven.position + Vector2(-448, 0)
	check(scene.limit_coop_motion(scene.player, Vector2(-100, 0), 0.016).x == 0.0, "camera boundary prevents walking farther away")
	check(scene.limit_coop_motion(scene.player, Vector2(100, 0), 0.016).x > 0.0, "camera boundary allows regrouping")
	scene.player.position = WorldData.RAVEN + Vector2(0, 28)
	scene.raven.position = WorldData.RAVEN
	scene.interact(scene.raven)
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 1, "Raven can start the team dialogue")
	scene.raven.position = WorldData.TERMINAL + Vector2(-26, 25)
	scene.interact(scene.raven)
	await physics_frame
	check(scene.stage == 2 and scene.gate_open, "Raven can operate the mission terminal")
	scene.player.position = Vector2(350, 380)
	scene.raven.position = Vector2(710, 323)
	scene.raven.facing = Vector2.RIGHT
	check(scene.combat_target(scene.enemy.position) == scene.raven, "Jackal can target Raven")
	key(KEY_O, true)
	await physics_frame
	key(KEY_O, false)
	check(scene.enemy.exposed > 0.0, "Raven's hack uses her own range and key")
	var enemy_health: int = scene.enemy.health
	key(KEY_U, true)
	for i in 4:
		await physics_frame
	key(KEY_U, false)
	check(scene.enemy.health < enemy_health, "Raven's pulse shot damages Jackal")
	scene.raven.health = 63
	var saved_raven: Vector2 = scene.raven.position
	check(scene.save_game(), "co-op checkpoint saves both players")
	scene.raven.position = WorldData.RAVEN
	scene.raven.health = 100
	check(scene.load_game() and scene.raven.position == saved_raven and scene.raven.health == 63, "co-op load restores Raven's position and health")
	scene.raven.take_damage(100, scene.enemy.position)
	check(scene.menu_open and scene.raven.health == 100 and scene.player.health == 100, "Raven defeat resets the team checkpoint")
	scene.close_menu()
	scene.enemy.take_damage(1000)
	scene.raven.position = WorldData.EXIT
	scene.interact(scene.raven)
	for i in 3:
		scene.ui.advance_dialogue()
	check(scene.stage == 4, "Raven can complete the shared mission")
	scene.set_coop(false)
	check(InputMap.action_has_event("move_left", arrow_left()), "solo arrow shortcuts are restored")

func check_gamepads(scene: Node2D) -> void:
	var both: Array[int] = [0, 1]
	var one: Array[int] = [0]
	var none: Array[int] = []
	scene.set_coop(true)
	scene.new_game(false)
	scene.gamepads.assign(both, true)
	var shadepi_start: Vector2 = scene.player.position
	var raven_start: Vector2 = scene.raven.position
	stick(0, 1.0)
	stick(1, -1.0)
	for i in 15:
		await physics_frame
	stick(0, 0.0)
	stick(1, 0.0)
	await physics_frame
	check(scene.player.position.x > shadepi_start.x + 15.0 and scene.raven.position.x < raven_start.x - 15.0, "two analog sticks control distinct actors")
	pad_button(1, JOY_BUTTON_START)
	await process_frame
	check(scene.menu_open, "Raven controller opens pause menu")
	var mode_before: bool = scene.ui.requested_coop
	scene.ui.mode_button.grab_focus()
	stick(0, 1.0, JOY_AXIS_LEFT_Y)
	await process_frame
	check(root.gui_get_focus_owner() == scene.ui.resume_button, "left stick moves menu focus")
	stick(0, 0.0, JOY_AXIS_LEFT_Y)
	scene.ui.mode_button.grab_focus()
	pad_button(0, JOY_BUTTON_A)
	await process_frame
	check(scene.ui.requested_coop != mode_before, "controller A activates the focused menu button")
	scene.close_menu()
	scene.player.position = WorldData.RAVEN + Vector2(0, 28)
	scene.raven.position = WorldData.RAVEN
	pad_button(1, JOY_BUTTON_A)
	await process_frame
	check(scene.ui.dialogue_open, "Raven controller starts dialogue")
	for i in 3:
		pad_button(1, JOY_BUTTON_A)
		await process_frame
	check(scene.stage == 1, "Raven controller advances and closes dialogue")
	scene.raven.position = WorldData.TERMINAL + Vector2(-26, 25)
	pad_button(1, JOY_BUTTON_A)
	await physics_frame
	check(scene.stage == 2, "Raven controller operates the terminal")
	scene.raven.position = Vector2(710, 323)
	scene.raven.facing = Vector2.RIGHT
	pad_button(1, JOY_BUTTON_Y)
	await process_frame
	check(scene.enemy.exposed > 0.0 and scene.player.cloak_time == 0.0, "Raven Y hacks without triggering Shadepi's cloak")
	var hp: int = scene.enemy.health
	pad_button(1, JOY_BUTTON_X)
	for i in 3:
		await physics_frame
	check(scene.enemy.health < hp and scene.player.attack_time == 0.0, "Raven X fires without swinging Shadepi's katana")
	pad_button(0, JOY_BUTTON_Y)
	await physics_frame
	await physics_frame
	check(scene.player.cloak_time > 0.0, "Shadepi Y activates cloak")
	scene.gamepads.assign(one, true)
	check(scene.gamepads.shadepi_device == -1 and scene.gamepads.raven_device == 0, "one co-op controller is assigned to Raven")
	var shadepi_position: Vector2 = scene.player.position
	stick(0, -1.0)
	for i in 8:
		await physics_frame
	stick(0, 0.0)
	check(scene.player.position.distance_to(shadepi_position) < 0.1, "reassignment removes old Shadepi bindings")
	scene.set_coop(false)
	scene.new_game(false)
	scene.gamepads.assign(one, false)
	pad_button(0, JOY_BUTTON_Y)
	await physics_frame
	await physics_frame
	check(scene.player.cloak_time > 0.0, "the first controller controls Shadepi in solo")
	scene.stage = 2
	scene.set_gate(true)
	scene.player.position = Vector2(710, 323)
	await physics_frame
	pad_button(0, JOY_BUTTON_RIGHT_SHOULDER)
	await process_frame
	check(scene.enemy.exposed > 0.0, "solo controller can call Raven's hack")
	stick(0, -1.0)
	await physics_frame
	check(Input.is_action_pressed("move_left"), "analog input is held before disconnect")
	scene.gamepads.assign(none, false)
	check(not Input.is_action_pressed("move_left"), "disconnect clears held controller input")

func stick(device: int, value: float, axis: JoyAxis = JOY_AXIS_LEFT_X) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = value
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func pad_button(device: int, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	var release := event.duplicate() as InputEventJoypadButton
	release.pressed = false
	Input.parse_input_event(release)
	Input.flush_buffered_events()

func check_admin_core() -> void:
	check(AdminTools.scene_for_chapter(1) == "res://scenes/chapter_one.tscn", "admin chapter 1 scene")
	check(AdminTools.scene_for_chapter(2) == "res://scenes/chapter_two.tscn", "admin chapter 2 scene")
	for chapter in range(3, 8):
		check(AdminTools.scene_for_chapter(chapter) == "res://scenes/campaign.tscn", "admin chapter campaign scene")
	check(AdminTools.scene_for_chapter(0).is_empty() and AdminTools.scene_for_chapter(8).is_empty(), "admin rejects invalid chapter ids")
	for pair in [[3, 0], [4, 3], [5, 5], [6, 6], [7, 10]]:
		check(AdminTools.first_beat(pair[0]) == pair[1], "admin chapter maps to the right story beat")
	check(not AdminTools.is_test_session(self), "test runner starts without active admin mode")
	var standard := "user://shadepi-campaign.cfg"
	check(AdminTools.checkpoint_path(standard, self) == standard, "normal saves keep original file")
	set_meta(AdminTools.SESSION_KEY, true)
	check(AdminTools.checkpoint_path(standard, self) == "user://shadepi-admin-campaign.cfg", "admin saves use another file")
	remove_meta(AdminTools.SESSION_KEY)
	check(AdminTools.read_flags().size() == AdminTools.OPTIONS.size(), "admin settings define all switches")

func check_admin_runtime(scene: Node2D) -> void:
	check(scene.ui.admin_panel != null and not scene.ui.admin_panel.visible, "dev panel stays hidden initially")
	check(scene.ui.admin_chapter_picker.get_item_count() == 7, "chapter selector offers seven chapters")
	check(scene.ui.admin_chapter_picker.disabled == not scene.admin_enabled("unlock_all"), "chapter selection gated by unlock toggle")
	var standard_path: String = scene.save_path()
	scene.ui._toggle_admin_panel()
	check(scene.ui.admin_panel.visible, "secret developer overlay opens when requested")
	check(AdminTools.is_test_session(self) and scene.save_path() != standard_path, "opening developer tools isolates checkpoint storage")
	scene.ui._close_admin_panel()
	check(not scene.ui.admin_panel.visible and scene.menu_open, "closing admin overlay leaves game menu intact")
	remove_meta(AdminTools.SESSION_KEY)
	var previous_flags: Dictionary = scene.admin_flags.duplicate()
	scene.admin_flags["unlock_all"] = true
	scene.ui._refresh_admin_controls()
	check(not scene.ui.admin_chapter_picker.disabled, "unlock setting enables full chapter selection")
	scene.admin_flags = previous_flags.duplicate()
	scene.ui._refresh_admin_controls()
	var health_before: int = scene.player.health
	scene.admin_flags["god_mode"] = true
	scene.player.take_damage(33, scene.player.global_position + Vector2.RIGHT)
	check(scene.player.health == health_before, "god mode prevents player damage")
	scene.admin_flags["god_mode"] = false
	var foe = scene.enemy
	var previous_health: int = foe.health
	var previous_minimum: int = foe.min_health
	var previous_armour: bool = foe.armoured
	foe.armoured = false
	foe.min_health = 1
	foe.health = 60
	scene.admin_flags["one_hit"] = true
	foe.take_damage(1)
	check(foe.health == 1, "one hit honors the minimum HP on scripted enemies")
	foe.health = previous_health
	foe.min_health = previous_minimum
	foe.armoured = previous_armour
	foe.reset_visual_pose()
	scene.admin_flags = previous_flags

func check_hero_sprites(scene: Node2D) -> void:
	for actor in [scene.player, scene.raven]:
		var texture: Texture2D = actor.visual.texture
		if texture.resource_path.begins_with("res://assets/custom/"):
			continue
		check(texture.resource_path.begins_with("res://assets/sprites/heroes/"), "hero uses the generated illustrated artwork")
		check(actor.directions == 8 and actor.visual.hframes == 8 and actor.visual.vframes == 32, "HQ atlas retains all eight directions and animation states")
		check(actor.visual.scale == Vector2(0.5, 0.5) and actor.visual.texture_filter == CanvasItem.TEXTURE_FILTER_LINEAR, "HQ pixels render smoothly at the intended world size")
		var feet: float = actor.visual.position.y + (152.0 - 80.0) * actor.visual.scale.y
		check(is_zero_approx(feet), "HQ feet meet the collision origin")
		actor.visual.rotation = PI * 0.5
		actor.visual.position.y = -9
		actor.reset_visual_pose()
		check(actor.visual.rotation == 0.0 and actor.visual.position.y == -36.0, "revival restores the HQ foot alignment")
		actor.facing = Vector2.DOWN
		actor.animate("attack", 0.18)
		check(actor.visual.frame_coords.y == 16 and actor.cast_shadow.frame == actor.visual.frame, "attack uses its own pose and matching shadow")
		actor.set_cloaked(true)
		check(not actor.light_occluder.visible, "HQ hero preserves stealth visibility")
		actor.set_cloaked(false)
	if not scene.enemy.visual.texture.resource_path.begins_with("res://assets/custom/"):
		check(scene.enemy.visual.texture.resource_path == "res://assets/sprites/npcs/jackal.png", "live Jackal uses his HQ replacement")

func check_npc_sprites(scene: Node2D) -> void:
	# Die Kapitel verwenden die HQ-Atlanten direkt, ohne alte Pixel-Proxys.
	var filenames := ["jackal.png", "kenzo.png", "punk-1.png", "punk-2.png", "punk-3.png", "punk-4.png", "shooter-visor.png", "shooter-violet.png"]
	var facing_rows := [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
	var states := ["idle", "walk", "attack", "hurt"]
	for filename in filenames:
		check(not FileAccess.file_exists("res://assets/sprites/" + filename), filename + " no longer needs a pixel proxy")
		var atlas := load("res://assets/sprites/npcs/" + filename) as Texture2D
		check(atlas != null and Vector2i(atlas.get_size()) == Vector2i(1024, 5120), filename + " has the full HQ atlas")
		if atlas == null:
			continue
		var pixels := atlas.get_image()
		if pixels.is_compressed():
			pixels.decompress()
		check(pixels.detect_alpha() != Image.ALPHA_NONE, filename + " retains transparent artwork")
		var all_cells_populated := true
		for row in 32:
			for column in 8:
				if not pixels.get_region(Rect2i(column * 128, row * 160, 128, 160)).get_used_rect().has_area():
					all_cells_populated = false
		check(all_cells_populated, filename + " has artwork in every animation cell")
		var actor := PixelActor.new()
		scene.add_child(actor)
		actor.setup(atlas, scene)
		if actor.visual.texture.resource_path.begins_with("res://assets/custom/"):
			check(SpriteAssets.valid_sheet(actor.visual.texture), filename + " keeps a valid custom override")
			actor.free()
			continue
		check(actor.visual.texture == atlas and actor.cast_shadow.texture == atlas, filename + " resolves its artwork and shadow through actor setup")
		check(actor.directions == 8 and actor.visual.hframes == 8 and actor.visual.vframes == 32, filename + " supports eight directions and four states")
		check(is_zero_approx(actor.visual.position.y + (152.0 - 80.0) * actor.visual.scale.y), filename + " feet align with the collision origin")
		var animation_rows_ok := true
		for state_index in 4:
			for direction_index in 8:
				actor.facing = facing_rows[direction_index]
				# A new state avoids the deliberate gradual turning of a continuing walk.
				actor.animate("hurt" if states[state_index] == "walk" else "idle", 0.0)
				actor.animate(states[state_index], 0.0)
				if actor.visual.frame_coords.y != state_index * 8 + direction_index or actor.cast_shadow.frame != actor.visual.frame:
					animation_rows_ok = false
		check(animation_rows_ok, filename + " selects each state/direction with a matching shadow")
		actor.free()

func check_npc_attack_animation(scene: Node2D) -> void:
	var foe = load("res://scripts/enemy.gd").new()
	foe.set_physics_process(false)
	scene.add_child(foe)
	foe.position = Vector2(1100, 700)
	foe.setup(preload("res://assets/sprites/npcs/shooter-visor.png"), scene)
	foe.attack_direction = Vector2.RIGHT
	foe.facing = Vector2.RIGHT
	foe.shot_range = 80.0
	foe.windup = 0.001
	foe._physics_process(0.016)
	check(foe.animation_name == "attack" and foe.attack_visual_time > 0.0, "ranged shot displays its attack pose after windup")
	check(is_equal_approx(foe.cooldown, foe.attack_recovery) and foe.lunge == 0.0, "shot pose preserves ranged recovery and does not add a lunge")
	foe._physics_process(0.5)
	check(foe.animation_name == "idle" and foe.attack_visual_time == 0.0, "ranged attack pose finishes without restarting the shot")
	foe.shot_range = 0.0
	foe.sweeping = true
	foe.windup = 0.001
	foe._physics_process(0.016)
	check(foe.animation_name == "attack" and is_equal_approx(foe.cooldown, foe.attack_recovery), "sweep displays its pose while retaining recovery timing")
	foe.hack()
	foe._physics_process(0.016)
	check(foe.animation_name == "hurt" and foe.attack_visual_time == 0.0, "hack interrupts the visual attack cycle")
	foe.attack_visual_time = 0.2
	foe.reset_fight()
	check(foe.attack_visual_time == 0.0, "checkpoint reset clears pending attack artwork")
	foe.free()

func check_directional_animation(scene: Node2D) -> void:
	for actor in [scene.player, scene.raven]:
		if actor.directions == 4:
			# Existing custom four-direction sheets still use their own layout.
			continue
		actor.facing = Vector2.UP
		actor.animate("idle", 0.0)
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 11, "north uses the rear walk cycle")
		actor.facing = Vector2.RIGHT
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 13, "north to east turns through the northeast pose")
		actor.animate("walk", 0.07)
		check(actor.visual.frame_coords.y == 10, "east uses the side walk cycle")
		actor.facing = Vector2.UP
		actor.animate("idle", 0.0)
		actor.animate("walk", 0.02)
		actor.facing = Vector2.LEFT
		actor.animate("walk", 0.02)
		check(actor.visual.frame_coords.y == 12, "north to west turns through the northwest pose")
		actor.animate("walk", 0.07)
		check(actor.visual.frame_coords.y == 9 and actor.cast_shadow.frame == actor.visual.frame, "west uses its own walk cycle and matching shadow")

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func arrow_left() -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_LEFT
	return event

func reachable(from: Vector2, to: Vector2, gate: bool) -> bool:
	var start := Vector2i(from / 8)
	var goal := Vector2i(to / 8)
	var queue: Array[Vector2i] = [start]
	var visited := {start: true}
	var index := 0
	while index < queue.size():
		var cell := queue[index]
		index += 1
		if cell.distance_to(goal) < 3:
			return true
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = cell + offset
			if not visited.has(next) and WorldData.walkable(Vector2(next) * 8 + Vector2(4, 4), gate):
				visited[next] = true
				queue.append(next)
	return false

func check_chapter() -> void:
	var chapter = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(chapter)
	await process_frame
	check(chapter.ui.menu_title.text == "SHADEPI" and chapter.ui.start_backdrop.visible, "the actual chapter-one entry uses the shared opening menu")
	check(not chapter.ui.vitals.is_visible_in_tree(), "opening menu hides chapter HUD panels immediately")
	chapter.ui.mode_button.pressed.emit()
	chapter.ui.resume_button.pressed.emit()
	check(chapter.chapter_coop and not chapter.coop, "chapter defers co-op until the team fight")
	chapter.menu_open = true
	chapter.ui.show_menu()
	check(chapter.ui.requested_coop and not chapter.ui.start_backdrop.visible, "chapter pause preserves pending co-op and keeps the opening art hidden")
	chapter.close_menu()
	check(chapter.in_cinematic() and not chapter.ui.dialogue_open and chapter.ui.comic_art.texture == null, "chapter opens with an in-engine scene instead of comic pages")
	check(chapter.raven.position.x < -100 and chapter.phase == chapter.Phase.APARTMENT, "Raven gets the lead in her apartment")
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.HUNT and chapter.actor_is_playable(chapter.raven) and not chapter.actor_is_playable(chapter.player), "the hunt gives primary controls to Raven")
	check(MusicLibrary.path_for(chapter.music_section).ends_with("Fight.mp3"), "street combat uses the regular fight track")
	check(chapter.saved_checkpoint(true) == chapter.Phase.HUNT, "the hunt is saved in the co-op slot")
	check(chapter.patrol.size() == 2 and not chapter.gate_open, "the hunt begins with the first arcade wave")
	check(chapter.patrol[1].shot_range > 0.0, "carbine-equipped gang member uses ranged attacks")
	var first_guard = chapter.patrol[0]
	chapter.raven.facing = (first_guard.position - chapter.raven.position).normalized()
	await physics_frame
	var hp: int = first_guard.health
	var direct_aim: Vector2 = chapter.raven.facing
	chapter.raven.facing = direct_aim.rotated(0.3)
	chapter.raven_shot()
	check(first_guard.health == hp, "off-axis shots miss even inside the old aim cone")
	chapter.raven.facing = direct_aim
	chapter.raven_shot()
	check(first_guard.health < hp, "Raven can shoot a street punk with her pistol")
	for guard in chapter.patrol:
		guard.take_damage(100)
	finish_arcade(chapter)
	var sprites := {}
	for guard in chapter.patrol:
		sprites[guard.visual.texture.resource_path] = true
	check(sprites.size() == 4, "hunt waves use four distinct sprites")
	chapter.raven.position = chapter.APARTMENT_EXIT
	check(not chapter.gate_open, "clearing the gang still requires following the trail")
	var route := [
		Vector2(-543, 448), Vector2(-297, 448), Vector2(-297, 346), Vector2(-158, 346),
		Vector2(-158, 451), Vector2(-60, 451), Vector2(308, 452), Vector2(319, 343),
		Vector2(392, 343), Vector2(480, 365), Vector2(580, 361),
	]
	for point in route:
		if point == Vector2(308, 452):
			await walk_to(chapter.raven, Vector2(125, 451))
		await walk_to(chapter.raven, point)
		check(chapter.raven.position.distance_to(point) < 20.0, "Raven can walk to %s through chapter geometry" % point)
		if point == Vector2(480, 365):
			chapter.interact()
			check(preload("res://tests/terminal_solver.gd").complete(chapter), "Raven solves Jackal's matrix before entering")
	check(chapter.phase == chapter.Phase.DUEL and chapter.enemy.active, "the trail opens the gate and starts the first Jackal fight")
	check(MusicLibrary.path_for(chapter.music_section).ends_with("Boss.mp3"), "the first Jackal duel uses boss music")
	finish_dialogue(chapter)
	chapter.enemy.take_damage(1000)
	check(chapter.enemy.health == 360 and not chapter.raven_hack(), "Jackal blocks all damage and early hacks during the first duel")
	chapter.raven.take_damage(500, chapter.enemy.position)
	check(chapter.raven.health == 1 and chapter.phase == chapter.Phase.DUEL, "early damage cannot end Raven's duel")
	chapter.duel_time = 0.0
	chapter._process(29.9)
	check(chapter.phase == chapter.Phase.DUEL and chapter.counter_warning, "the duel is still active just before 30 seconds")
	chapter._process(0.11)
	check(chapter.phase == chapter.Phase.ROOFTOP and chapter.raven.health == 0 and not chapter.effects.links.is_empty(), "the scripted counterhack knocks Raven down after 30 seconds")
	chapter._process(1.0)
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.RESCUE and chapter.actor_is_playable(chapter.player), "Shadepi takes over in the rescue")
	check(chapter.patrol.size() == 3 and not chapter.gate_open, "the patrol guards the way to Raven")
	for guard in chapter.patrol:
		guard.take_damage(100)
	finish_arcade(chapter)
	check(chapter.gate_open, "the patrol's defeat opens the rescue gate")
	chapter.player.position = chapter.raven.position + Vector2(-20, 0)
	chapter.interact()
	check(chapter.phase == chapter.Phase.REVIVE, "interacting with Raven starts the rescue dialogue")
	finish_dialogue(chapter)
	check(chapter.phase == chapter.Phase.TEAM and not chapter.coop and chapter.raven.health == 0, "Shadepi starts the 360 HP fight alone")
	check(MusicLibrary.path_for(chapter.music_section).ends_with("Boss.mp3"), "the team fight against Jackal keeps boss music")
	chapter.enemy.take_damage(1000)
	check(chapter.enemy.health == 180 and not chapter.raven_joined, "damage stops at exactly half health for the handoff")
	chapter._process(0.01)
	check(chapter.coop and chapter.raven_joined and chapter.raven.health == 100, "Raven stands up and the second player takes control")
	check(chapter.actor_input_prefix(chapter.raven) == "raven_", "co-op Raven has her own input bindings")
	chapter.player.position = Vector2(690, 330)
	chapter.raven.position = Vector2(678, 323)
	await physics_frame
	check(chapter.raven_hack() and chapter.enemy.exposed > 0.0, "Raven hacks Jackal during the team fight")
	chapter.enemy.take_damage(200)
	check(chapter.phase == chapter.Phase.EPILOGUE and chapter.in_cinematic(), "winning starts the closing scene")
	finish_dialogue(chapter)
	check(not chapter.raven.visible and chapter.player.position.y == 223.0, "Raven leaves through the door and Shadepi leaps onto the roof")
	check(chapter.phase == chapter.Phase.COMPLETE and not chapter.in_cinematic(), "the rooftop jump completes the chapter")
	check(is_equal_approx(chapter.player.visual.position.y, chapter.player.standing_visual_position.y), "rooftop landing restores the HQ sprite foot position")
	check(chapter.load_game(true) and chapter.phase == chapter.Phase.COMPLETE and not chapter.enemy.visible, "the completed co-op checkpoint can be reloaded")
	chapter.chapter_coop = false
	chapter._enter_checkpoint(chapter.Phase.TEAM)
	chapter.player.position = Vector2(710, 323)
	chapter.enemy.position = WorldData.JACKAL
	chapter.enemy.take_damage(1000)
	chapter._process(0.01)
	chapter.raven.position = Vector2(681, 323)
	await physics_frame
	await process_frame
	await process_frame
	check(not chapter.coop and chapter.raven_joined and chapter.enemy.health < 180, "solo Raven assists with aimed shots after the handoff")
	chapter.queue_free()
	await process_frame

func finish_arcade(scene: Node2D) -> void:
	var encounter = scene.encounter
	for step in 40:
		if encounter.finished:
			return
		if encounter.waiting:
			encounter.leader().position = encounter.sections[encounter.section_index].start
		for foe in encounter.fighters:
			foe.hack()
			foe.take_damage(1000)
		encounter._process(0.0)
		encounter._process(encounter.WAVE_BREAK)
	check(false, "arcade encounter completes within its finite wave plan")

func finish_dialogue(chapter: Node2D) -> void:
	for _round in 4:
		if chapter.in_cinematic():
			chapter.cutscene.skip()
		_finish_dialogue_once(chapter)
	if chapter.in_cinematic():
		chapter.cutscene.skip()

func _finish_dialogue_once(chapter: Node2D) -> void:
	for _line in 16:
		if not chapter.ui.dialogue_open:
			break
		chapter.ui.advance_dialogue()

func walk_to(actor: PixelActor, point: Vector2) -> void:
	var actions := ["move_left", "move_right", "move_up", "move_down"]
	for frame in 210:
		var offset := point - actor.position
		var held := [offset.x < -3.0, offset.x > 3.0, offset.y < -3.0, offset.y > 3.0]
		for index in actions.size():
			if held[index]:
				Input.action_press(actions[index])
			else:
				Input.action_release(actions[index])
		if offset.length() < 5.0:
			break
		await physics_frame
	for action in actions:
		Input.action_release(action)

func check_chapter_two() -> void:
	var chapter = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(chapter)
	chapter.new_game()
	finish_dialogue(chapter)
	for scan in chapter.SCANS:
		chapter.player.position = scan
		chapter.interact()
	check(chapter.scan_index == 3, "chapter two scans all approaches before entry")
	chapter.player.position = chapter.DOOR
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.HIDEOUT, "steel door leads to Raven")
	chapter.player.position = chapter.WORKBENCH
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.COOLING, "Raven must be connected to the cooling system before diving")
	chapter.player.position = chapter.BATH
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.raven_leads() and chapter.actor_is_playable(chapter.raven), "deep dive switches control to Raven")
	check(MusicLibrary.path_for(chapter.music_section).ends_with("Fight.mp3"), "Deep Dive combat uses the fight track")
	chapter.raven.position = chapter.RELAYS[0]
	chapter.ice_cycle = 1.5
	chapter.interact()
	check(chapter.relay_index == 0, "red ICE window blocks access")
	chapter.ice_cycle = 1.2
	chapter.interact()
	check(chapter.relay_index == 1 and chapter.threats.size() == 1, "first hack opens the virus encounter")
	check(chapter.load_game() and chapter.relay_index == 1 and chapter.threats.size() == 1, "the saved data node reloads its encounter")
	for expected in [1, 2, 1, 2, 1]:
		check(chapter.threats.size() == expected, "ICE encounter spawns the expected group")
		var target: Node2D = chapter.threats[0]
		target.elapsed = 1.6
		chapter.raven.position = target.position - Vector2(0, 25)
		chapter.raven.facing = Vector2.DOWN
		chapter.raven_shot()
		if chapter.relay_index == 1 and chapter.threats.is_empty():
			chapter.raven.position = chapter.RELAYS[1]
			chapter.ice_cycle = 0.0
			chapter.interact()
	chapter.raven.position = chapter.RELAYS[2]
	chapter.ice_cycle = 0.0
	chapter.interact()
	check(chapter.dive_hold > 0.0 and chapter.raven_leads(), "countertrace waits for the final download")
	chapter._process(0.6)
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.RECOVERY and chapter.actor_is_playable(chapter.player), "countertrace returns control to Shadepi")
	chapter.player.position = chapter.SPRAY
	chapter.interact()
	chapter.player.position = chapter.BATH
	chapter.interact()
	finish_dialogue(chapter)
	check(chapter.section == chapter.Section.END and chapter.saved_checkpoint() == chapter.Section.END, "the vow closes and saves chapter two")
	chapter.queue_free()
	await process_frame

func check_campaign() -> void:
	var scene = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(scene)
	scene.new_game()
	finish_dialogue(scene)
	for i in 3:
		scene.player.position = scene._target()
		scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.AMBUSH and scene._living() == 2, "pact leads to the two-shooter ambush")
	check(MusicLibrary.path_for(scene.music_section).ends_with("Fight.mp3"), "the ambush uses the regular fight track")
	finish_arcade(scene)
	scene.player.position = scene._target()
	scene.interact()
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.CHASE and scene.drive != null, "ambush opens the motorcycle chase")
	var drive = scene.drive
	Input.action_press("hack")
	Input.action_press("attack")
	Input.action_press("dash")
	drive._process(0.01)
	Input.action_release("hack")
	Input.action_release("attack")
	Input.action_release("dash")
	check(drive.hack > 0 and drive.grenade != Vector2.ZERO and not drive.bullets.is_empty(), "bike supports shooting, hacking and grenades")
	drive._process(0.6)
	check(drive.armour < 100, "aligned shots and grenade damage the pursuing car")
	drive.health = 0
	drive._process(0.01)
	check(scene.beat == scene.Beat.CHASE and scene.menu_open and scene.drive.health == 100, "crashing restarts the chase checkpoint")
	scene.close_menu()
	finish_dialogue(scene)
	scene.drive.armour = 0
	scene.drive._process(0.01)
	scene.drive._process(1.2)
	check(scene.beat == scene.Beat.GARAGE, "defeating the car opens chapter four")
	finish_dialogue(scene)
	check(scene.bike_mode == "parked" and scene.bike_pos == scene.BIKE_PARK and scene.garage_door == 0.0, "the bike rides in, stays parked on the platform and the door closes again")
	check(scene.player.visible and scene.raven.visible and not scene.player.position.distance_to(scene.BIKE_PARK) < 20.0, "both heroes dismount beside the bike")
	check(scene.Painted.SOLIDS["garage"][0].has_point(scene.BIKE_PARK) and scene.Story.POINTS[scene.Beat.GARAGE][1].distance_to(scene.BIKE_PARK) > 50.0, "the parked bike is solid and leaves the lift terminal free")
	scene.player.position = scene._target()
	scene.interact()
	scene.player.position = scene._target()
	scene.interact()
	check(scene.beat == scene.Beat.GARAGE, "lift waits for Raven")
	scene.raven.position = scene._target()
	scene.interact()
	check(preload("res://tests/terminal_solver.gd").complete(scene), "garage decoder opens the lift")
	finish_dialogue(scene)
	for i in 3:
		scene.clock = 0
		scene.raven.position = scene._target()
		scene.interact()
		if scene.terminal != null:
			check(preload("res://tests/terminal_solver.gd").complete(scene), "hangar routing restores power")
	check(scene.beat == scene.Beat.HANGAR and scene.point_index == 3, "transponder preparation opens the matrix")
	scene.raven.position = scene._target()
	scene.interact()
	check(preload("res://tests/terminal_solver.gd").complete(scene), "overlapping daemons unlock transponder")
	finish_dialogue(scene)
	scene.player.position = scene._target()
	scene.interact()
	check(scene.timing != null, "the sanctuary timing game opens before the memories")
	var timing = scene.timing
	await process_frame
	await process_frame
	timing.mode = 2
	timing._process(0.1)
	check(timing.scores[0] > 0 and timing.scores[1] > 0, "both players receive independent time scores")
	timing.elapsed = 15.0
	timing._process(0.01)
	finish_dialogue(scene)
	for i in 3:
		scene.raven.position = scene._target()
		scene.interact()
		if i in [0,1,2]:
			await process_frame
			check(scene.memory_scene != null and scene.point_index == i, "memory anchor opens its historical scene before advancing")
			scene.memory_scene.cutscene.skip()
			await process_frame
			check(scene.memory_legacy_complete and scene.point_index==2 if i==2 else scene.point_index==i+1 and (scene.memory_attack_complete if i==0 else scene.memory_sacrifice_complete), "finishing historical scene commits its node before returning to the campaign")
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.FLIGHT and scene.drive.flight and scene.drive.phase == "canyon", "chapter five leads to the Aerodyne flight")
	scene.drive.start_engine_failure()
	check(preload("res://tests/terminal_solver.gd").complete(scene), "wiring repairs Aerodyne")
	scene.drive.health = 0
	scene.drive._process(0.01)
	check(scene.beat == scene.Beat.FLIGHT and scene.menu_open, "a wrecked Aerodyne restarts the flight checkpoint")
	scene.close_menu()
	finish_dialogue(scene)
	check(scene.drive.engine_repaired and not scene.drive.engine_failed, "after a crash the repaired engine does not fail again")
	await process_frame
	scene.drive.elapsed = scene.drive.SCAN_AT
	scene.drive._process(0.01)
	scene.drive._process(0.01)
	check(scene.drive.phase == "scan", "the tower scanner starts Raven's sequence calibration")
	var calib = scene.drive.calibration
	var guard := 0
	while calib.state == "run" and guard < 4000:
		guard += 1
		if calib.in_window():
			scene.drive.calibration_input(int(calib.current().dir))
		else:
			scene.drive._process(1.0 / 120.0)
	check(scene.drive.transponder_sent, "Raven calibrates Kenzō's glider ID at the scanner")
	scene.drive.approach_left = 0.0
	scene.drive._process(0.01)
	check(scene.drive.phase == "landing", "accepted ID leads to the landing approach")
	scene.drive.shadow = scene.drive.pad_screen()
	scene.drive.altitude = 0.001
	scene.drive.descent = 0.1
	scene.drive._process(0.01)
	scene.drive._process(2.0)
	check(scene.beat == scene.Beat.ROOF and scene.parked_aerodyne != null, "the Aerodyne lands on the tower pad and stays parked")
	check(scene.parked_aerodyne.spot.distance_to(scene.drive.PAD_WORLD if scene.drive != null else Vector2(222, 326)) < 40.0, "parked Aerodyne stands where it touched down")
	finish_dialogue(scene)
	for i in 2:
		scene.clock = 0
		scene.raven.position = scene._target()
		scene.interact()
		check(preload("res://tests/terminal_solver.gd").complete(scene), "Raven solves roof terminal")
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.BOSS and scene._living() == 1, "the penthouse door leads straight to Kenzō without guards before him")
	check(MusicLibrary.path_for(scene.music_section).ends_with("Boss.mp3"), "Kenzō's encounter uses boss music")
	check(not scene.in_cinematic() and scene.foes.back().health == 360 and scene.player.cloak_time == 0.0, "penthouse scene ends with Shadepi revealed and Kenzō ready to fight")
	scene.foes.back().take_damage(1000)
	await process_frame
	await process_frame
	check(scene.beat == scene.Beat.ESCAPE and scene.in_cinematic(), "Kenzō's fall plays as a scripted scene")
	check(scene.encounter == null and not scene.escape_guards_cleared, "lift guards are not called before Kenzō has fallen")
	finish_dialogue(scene)
	check(scene.encounter != null and scene._living() == 2, "the dead-man switch brings the lift guards after Kenzō's defeat")
	check(scene.kenzo_body != null and scene.kenzo_body.health <= 0 and scene.kenzo_body.visual.rotation > 1.0, "Kenzō remains lying in the penthouse")
	check(MusicLibrary.path_for(scene.music_section).ends_with("Fight.mp3"), "lift guards use fight music")
	var timer_before: float = scene.countdown
	scene._process(5.0)
	check(scene.countdown == timer_before, "escape timer waits until the lift guards are down")
	scene.save_game()
	check(scene.load_game() and scene.encounter != null and not scene.escape_guards_cleared and not scene.in_cinematic(), "loading during the lift fight resumes the guards without replaying the kill scene")
	finish_dialogue(scene)
	finish_arcade(scene)
	await process_frame
	await process_frame
	check(scene.escape_guards_cleared and scene.in_cinematic(), "alarm briefing follows the last lift wave")
	finish_dialogue(scene)
	check(scene.beat == scene.Beat.ESCAPE, "boss defeat starts the sixty-second escape")
	for i in 4:
		scene.clock = 0
		scene.player.position = scene._target()
		scene.interact()
		if scene.terminal != null:
			check(preload("res://tests/terminal_solver.gd").complete(scene), "Raven synchronizes elevator charge")
	finish_dialogue(scene)
	for i in 4:
		scene.player.position = scene._target()
		scene.interact()
		finish_dialogue(scene)
	check(scene.beat == scene.Beat.END and scene.saved_checkpoint() == scene.Beat.END, "consent and three ritual steps reach and save the ending")
	scene.queue_free()
	await process_frame

func check_feedback() -> void:
	# v0.19.0: apartment scale, chapter-two positions, net walls/hitboxes, hit feedback.
	var one = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(one)
	await process_frame
	check(is_equal_approx(one.APARTMENT_RECT.size.x / one.APARTMENT_RECT.size.y, 1.6), "apartment art keeps its 16:10 aspect instead of a squeezed 640 x 640 square")
	var door_height: float = 145.0 * one.APARTMENT_SCALE
	check(door_height > 52.0 and door_height < 80.0, "apartment door is about 1.25 times Raven's sprite height")
	one.queue_free()
	await process_frame
	var two = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(two)
	await process_frame
	two.close_menu()
	two._enter(two.Section.HIDEOUT)
	finish_dialogue(two)
	two.player.position = two.WORKBENCH
	two.interact()
	finish_dialogue(two)
	check(two.section == two.Section.COOLING and two.player.position.distance_to(two.WORKBENCH) < 60.0, "Shadepi stays at the workbench instead of snapping back to the entrance")
	var cooling_spot: Vector2 = two.player.position
	two.player.position = two.BATH
	two.interact()
	finish_dialogue(two)
	check(two.section == two.Section.DIVE and two.player.position == two.BATH, "Shadepi waits at the ice bath during the dive")
	# Viruses slide along data walls instead of passing through them.
	var wall: Rect2 = two.Painted.SOLIDS["dive"][0]
	for threat in two.threats:
		threat.queue_free()
	two.threats.clear()
	var virus = load("res://scripts/dive_threat.gd").new()
	virus.world = two
	virus.position = Vector2(wall.position.x - 30, wall.get_center().y)
	two.actors.add_child(virus)
	two.threats.append(virus)
	two.raven.position = Vector2(wall.end.x + 40, wall.get_center().y)
	var entered := false
	for i in 120:
		virus._process(1.0 / 60.0)
		if wall.has_point(virus.position):
			entered = true
	check(not entered, "net enemies no longer move through data walls")
	# Shell crack: a protected virus can be shot, cracks open and dies on the follow-up.
	virus.position = two.raven.position + Vector2(60, 12)
	virus.elapsed = 0.2
	two.raven.facing = Vector2.RIGHT
	check(not virus.vulnerable(), "virus starts protected")
	two.raven_shot()
	check(virus.vulnerable() and virus.cracked > 0.0 and virus in two.threats, "an off-axis shot still locks on and cracks the shell")
	two.raven_shot()
	check(virus not in two.threats, "the follow-up shot deletes the cracked virus")
	two.queue_free()
	await process_frame
	var camp = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(camp)
	await process_frame
	camp._enter(camp.Beat.AMBUSH)
	finish_dialogue(camp)
	var foe = camp.foes[0]
	foe.position = Vector2(480, 420)
	for other in camp.foes:
		if other != foe:
			other.position = Vector2(900, 300)
	camp.player.position = Vector2(450, 420)
	camp.player.facing = Vector2.RIGHT
	var hits_before: int = camp.combo_hits
	foe.take_damage(10, camp.player.position)
	check(foe.knock_velocity.x > 0.0 and foe.stun > 0.0, "regular enemies are knocked back and flinch on every hit")
	check(camp.combo_hits == hits_before + 1 and camp.combo_time > 0.0, "hits build the combo counter")
	camp.player.facing = Vector2(0.6, 0.8).normalized()
	camp.melee_assist(camp.player)
	check(camp.player.facing.dot((foe.position - camp.player.position).normalized()) > 0.99, "melee aim assist turns toward a nearby enemy")
	camp._enter(camp.Beat.BOSS)
	finish_dialogue(camp)
	var kenzo = camp.foes.back()
	kenzo.stun = 0.0
	kenzo.take_damage(10, kenzo.position + Vector2(-20, 0))
	check(kenzo.stun == 0.0 and kenzo.knock_velocity.length() > 0.0, "bosses only budge slightly on light hits")
	kenzo.take_damage(1000, kenzo.position + Vector2(-20, 0))
	check(kenzo.health <= 0 and kenzo.death_tween != null, "defeated enemies fall with a knockback animation")
	camp.queue_free()
	await process_frame
