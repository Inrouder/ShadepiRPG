extends PixelActor

const SPEED: = 94.0
const CHARGE_SECONDS := 1.1
const HAND_CAST = preload("res://assets/sprites/heroes/raven-hand-cast.png")
static var hand_cast_data: Array = []
var hand_pose_index := -1
const COMBAT_POSES := preload("res://assets/sprites/heroes/combat-poses.png")
var charging := false
var charge_time := 0.0
var charge_ready := false
var attack_kind := "normal"
var kick_pending := false
var combat_generation := 0
var normal_texture: Texture2D
var special_pose := false
var health: = 100
var health_floor: = 0
var energy: = 100.0
var attack_time: = 0.0
var attack_cooldown: = 0.0
var dash_time: = 0.0
var dash_cooldown: = 0.0
var cloak_time: = 0.0
var cloak_cooldown: = 0.0
var invulnerable: = 0.0
var hit_pending: = false
var combo: = 0
var combo_window: = 0.0
var knockback: = Vector2.ZERO
var second_player: = false
var aim_stick: = Vector2.ZERO

func _physics_process(delta: float) -> void :
	if not world.actor_is_playable(self):
		return
	if world.is_busy():
		cancel_charge()
		if not (world.in_cinematic() and (world.cutscene.walkers.has(self) or world.cutscene.poses.has(self))):
			animate("idle", delta)
		return
	if world.admin_enabled("infinite_energy"):
		energy = 100.0
	if world.admin_enabled("no_cooldowns"):
		attack_cooldown = 0.0
		dash_cooldown = 0.0
		cloak_cooldown = 0.0
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	cloak_cooldown = maxf(0.0, cloak_cooldown - delta)
	invulnerable = maxf(0.0, invulnerable - delta)
	combo_window = maxf(0.0, combo_window - delta)
	if combo_window <= 0.0:
		combo = 0
	if cloak_time > 0.0:
		cloak_time = maxf(0.0, cloak_time - delta)
		energy = maxf(0.0, energy - delta * 9.0)
		if energy <= 0.0:
			cloak_time = 0.0
	else:
		energy = minf(100.0, energy + delta * 15.0)
	var prefix: String = world.actor_input_prefix(self)
	var direction: = Input.get_vector(prefix + "move_left", prefix + "move_right", prefix + "move_up", prefix + "move_down")
	if direction.length() > 0.1 and attack_time <= 0.0 and dash_time <= 0.0:
		facing = direction.normalized()
	var mouse_shot: = second_player and Input.is_action_just_pressed("mouse_attack" if prefix.is_empty() else "raven_mouse_attack")
	aim_stick = Vector2.ZERO
	if second_player:
		var device: int = world.gamepads.shadepi_device if prefix.is_empty() else world.gamepads.raven_device
		if device >= 0:
			aim_stick = Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y))
		if aim_stick.length() > 0.25 and dash_time <= 0.0:
			facing = aim_stick.normalized()
	if Input.is_action_just_pressed(prefix + "charge"):
		start_charge()
	if charging:
		update_charge(delta)
		if not Input.is_action_pressed(prefix + "charge"):
			release_charge()
	if not second_player and Input.is_action_just_pressed(prefix + "kick"):
		try_kick()
	if mouse_shot or Input.is_action_just_pressed(prefix + "attack"):
		if mouse_shot:
			var aim: = get_global_mouse_position() - global_position + Vector2(0, 24)
			if aim.length_squared() > 1.0:
				facing = aim.normalized()
		try_attack()
	if Input.is_action_just_pressed(prefix + "dash"):
		try_dash(direction)
	if not second_player and Input.is_action_just_pressed("cloak"):
		try_cloak()
	set_cloaked(cloak_time > 0.0)
	var state: = "idle"
	if charging:
		velocity = direction * SPEED * 0.3
		state = "charge"
	elif attack_time > 0.0:
		attack_time = maxf(0.0, attack_time - delta)
		velocity = direction * SPEED * 0.25
		state = "kick" if attack_kind == "kick" else "attack"
		if kick_pending and attack_time <= 0.29:
			kick_pending = false
			world.player_kick(self)
		if hit_pending and attack_time < 0.26:
			hit_pending = false
			world.player_strike([22, 25, 32][combo])
	elif dash_time > 0.0:
		dash_time -= delta
		velocity = facing * 330.0
		state = "walk"
		world.spawn_trail(global_position, Color(0.35, 0.85, 1.0, 0.4))
	else:
		velocity = direction * SPEED
		state = "walk" if direction.length() > 0.1 else "idle"
	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 700.0 * delta)
	velocity = world.limit_coop_motion(self, velocity, delta)
	move_and_slide()
	animate(state, delta)

# Attachment coordinates are authored in the original 128×160 attack frames.
# Conversion through the sprite transform keeps scaled/custom actors supported.
const MUZZLE_POINTS := [Vector2(64,71),Vector2(24,57),Vector2(105,58),Vector2(62,36),Vector2(26,46),Vector2(100,46),Vector2(34,65),Vector2(99,64)]
const HAND_POINTS := [Vector2(64,73),Vector2(34,59),Vector2(94,59),Vector2(62,43),Vector2(35,50),Vector2(93,50),Vector2(42,67),Vector2(91,67)]
func attack_attachment(hand: bool = false) -> Vector2:
	if hand and visual.texture == HAND_CAST and hand_pose_index >= 0:
		var data: Dictionary = hand_cast_data[hand_pose_index/8][hand_pose_index%8]
		return visual.to_global(Vector2(data.palm[0],data.palm[1]) - Vector2(visual.texture.get_size())/Vector2(16,8))
	var row := _direction_row(false, 0.0)
	if not hand and HeroArt.supports(visual.texture):return HeroArt.attachment(self,row)
	if directions == 4:
		row = [0,1,2,3][row]
	var point: Vector2 = (HAND_POINTS if hand else MUZZLE_POINTS)[row]
	var frame_size := Vector2(visual.texture.get_size()) / Vector2(visual.hframes, visual.vframes)
	return visual.to_global((point / Vector2(128,160) - Vector2(0.5,0.5)) * frame_size)

func try_attack() -> bool:
	if charging or attack_cooldown > 0.0 or dash_time > 0.0 or energy < 5.0:
		return false
	attack_kind = "normal"
	if second_player:
		energy -= 5.0
		attack_time = 0.22
		attack_cooldown = 0.42
		world.raven_shot()
		return true
	if Input.is_action_just_pressed("mouse_attack"):
		var aim: = get_global_mouse_position() - global_position
		if aim.length() > 4.0:
			facing = aim.normalized()
	combo = (combo + 1) % 3 if combo_window > 0.0 else 0
	combo_window = 0.9
	world.melee_assist(self)
	# A short step into the swing sells the weight of the blade.
	knockback = facing * (150.0 if combo == 2 else 95.0)
	energy -= 5.0
	attack_time = 0.38
	attack_cooldown = 0.4
	cloak_time = 0.0
	hit_pending = true
	world.sound("slash")
	world.spawn_slash(global_position, facing)
	return true

func charge_cost() -> float:
	return 25.0 if second_player else 30.0

func start_charge() -> bool:
	if charging or world.is_busy() or not world.actor_is_playable(self) or attack_time > 0 or attack_cooldown > 0 or dash_time > 0 or energy < charge_cost():
		return false
	charging = true
	charge_time = 0
	charge_ready = false
	cloak_time = 0
	combo_window = 0
	return true

func update_charge(delta: float) -> void:
	if not charging or world.is_busy():
		return
	charge_time = minf(CHARGE_SECONDS, charge_time + delta)
	if charge_time >= CHARGE_SECONDS and not charge_ready:
		charge_ready = true
		world.effects.charge_ready(position, second_player)
		world.sound("hack")
	queue_redraw()

func cancel_charge() -> void:
	charging = false
	charge_time = 0
	charge_ready = false
	queue_redraw()

func release_charge() -> bool:
	if not charging:
		return false
	var ready := charge_ready
	cancel_charge()
	if world.is_busy() or not world.actor_is_playable(self):
		return false
	if not ready:
		return try_attack()
	if energy < charge_cost():
		return false
	energy -= charge_cost()
	attack_time = 0.48
	attack_cooldown = 0.8
	attack_kind = "power"
	hit_pending = false
	kick_pending = false
	world.power_attack(self)
	return true

func try_kick() -> bool:
	if second_player or world.is_busy() or not world.actor_is_playable(self) or charging or attack_time > 0 or attack_cooldown > 0 or dash_time > 0 or energy < 12:
		return false
	energy -= 12
	cloak_time = 0
	attack_kind = "kick"
	attack_time = 0.48
	attack_cooldown = 0.65
	kick_pending = true
	hit_pending = false
	combo_window = 0
	world.sound("slash")
	return true

func try_dash(direction: Vector2) -> bool:
	if dash_cooldown > 0.0 or energy < 22.0 or attack_time > 0.0:
		return false
	cancel_charge()
	if direction.length() > 0.1:
		facing = direction.normalized()
	energy -= 22.0
	dash_time = 0.16
	dash_cooldown = 0.65
	invulnerable = 0.24
	return true

func try_cloak() -> bool:
	if cloak_time > 0.0:
		cloak_time = 0.0
		return true
	if charging or cloak_cooldown > 0.0 or energy < 20.0 or attack_time > 0.0:
		return false
	cloak_time = 10.0
	cloak_cooldown = 18.0
	world.toast("Tarnfeld aktiv · Angreifen beendet die Tarnung")
	return true

func take_damage(amount: int, source: Vector2) -> void :
	if world.admin_enabled("god_mode"):
		return
	if invulnerable > 0.0 or health <= 0:
		return
	cancel_charge()
	health = maxi(health_floor, health - amount)
	invulnerable = 0.8
	cloak_time = 0.0
	flash_time = 0.18
	knockback = (global_position - source).normalized() * 130.0
	world.impact(global_position, false)
	if world.has_method("hero_damaged"):
		world.hero_damaged(self,amount)
	if health == 0:
		world.player_defeated()

func reset_transients() -> void :
	combat_generation += 1
	cancel_charge()
	kick_pending = false
	attack_kind = "normal"
	if special_pose:
		animate("idle", 0)
	velocity = Vector2.ZERO
	attack_time = 0.0
	attack_cooldown = 0.0
	dash_time = 0.0
	dash_cooldown = 0.0
	cloak_time = 0.0
	cloak_cooldown = 0.0
	invulnerable = 0.0
	knockback = Vector2.ZERO
	hit_pending = false
	combo_window = 0.0
	set_cloaked(false)

func animate(state: String, delta: float) -> void:
	if normal_texture == null:
		normal_texture = hero_sheet if hero_sheet!=null else visual.texture
	if special_pose:
		visual.texture = normal_texture
		visual.hframes = 8
		visual.vframes = directions * 4
		visual.scale = Vector2.ONE * SpriteAssets.display_scale(normal_texture)
		visual.position = standing_visual_position
		cast_shadow.texture = normal_texture
		cast_shadow.hframes = 8
		cast_shadow.vframes = directions * 4
		cast_shadow.scale = Vector2(1.05, 0.3) * SpriteAssets.display_scale(normal_texture)
		special_pose = false
	super.animate("idle" if state == "charge" else "attack" if state == "kick" else state, delta)
	if state=="attack" and attack_kind=="power" and HeroArt.supports(visual.texture):
		HeroArt.apply(self,"attack",_direction_row(false,delta),0.2)
	if state == "attack" and attack_kind == "power" and not HeroArt.supports(visual.texture):
		# The charge already supplied the windup; show the cut/discharge on release.
		var release_frame := (0 if second_player else 2) if attack_time > 0.22 else 6
		visual.frame = (2 * directions + _direction_row(false, delta)) * 8 + release_frame
		cast_shadow.frame = visual.frame
	# Custom replacement heroes keep their own identity and use the same effects.
	if normal_texture.resource_path.begins_with("res://assets/custom/") or (state not in ["charge", "kick"] and not (second_player and world.raven_energy_attack() and state == "attack")):
		return
	if second_player and world.raven_energy_attack() and state in ["charge","attack"]:
		_show_hand_cast(state)
		return
	var row := 3 if second_player else 0
	if state == "kick":
		row = 2 if attack_time <= 0.29 and attack_time > 0.1 else 1
	var direction := _direction_row(false, delta)
	visual.frame = 0
	cast_shadow.frame = 0
	visual.texture = COMBAT_POSES
	visual.hframes = 8
	visual.vframes = 4
	visual.scale = Vector2.ONE * 0.25
	visual.position = Vector2(0, -30.5)
	visual.frame = row * 8 + direction
	cast_shadow.texture = COMBAT_POSES
	cast_shadow.hframes = 8
	cast_shadow.vframes = 4
	cast_shadow.scale = Vector2(1.05, 0.3) * 0.25
	cast_shadow.frame = visual.frame
	special_pose = true

func _show_hand_cast(state: String) -> void:
	if hand_cast_data.is_empty():
		hand_cast_data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites/heroes/raven-hand-cast.json"))
	var row := 0 if state == "charge" else 1 if attack_time > 0.1 else 2
	var direction := _direction_row(false,0)
	hand_pose_index = row*8+direction
	var pose: Dictionary = hand_cast_data[row][direction]
	var cell_size := Vector2(HAND_CAST.get_size()) / Vector2(8,4)
	visual.texture = HAND_CAST
	visual.hframes = 8
	visual.vframes = 4
	visual.frame = hand_pose_index
	visual.scale = Vector2.ONE * float(pose.scale)
	visual.position = (cell_size*0.5 - Vector2(pose.anchor[0],pose.anchor[1])) * float(pose.scale)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cast_shadow.texture = HAND_CAST
	cast_shadow.hframes = 8
	cast_shadow.vframes = 4
	cast_shadow.frame = hand_pose_index
	cast_shadow.scale = Vector2(1.05,0.3) * float(pose.scale)
	special_pose = true

func _draw() -> void :
	super._draw()
	if charging and not world.is_busy():
		var progress := charge_time / CHARGE_SECONDS
		var color := Color("66eaff") if second_player else Color("ff4f70")
		draw_arc(Vector2(0, -22), 15, -PI / 2, -PI / 2 + TAU * progress, 32, color, 2)
		if charge_ready:
			draw_circle(attack_attachment(world.raven_energy_attack()) - global_position if second_player else Vector2(0,-24)+facing*19, 3.5 + sin(Time.get_ticks_msec() * 0.015), Color(color, 0.75))
	if second_player and health > 0 and world.actor_is_playable(self) and not world.is_busy() and aim_stick.length() > 0.25:
		var tip: = Vector2(0, -24) + facing * 64.0
		draw_line(Vector2(0, -24) + facing * 12.0, tip, Color(0.38, 0.9, 1.0, 0.55))
		draw_arc(tip, 3.0, 0.0, TAU, 8, Color("9de6f2"))
