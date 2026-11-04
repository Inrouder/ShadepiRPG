extends PixelActor

const SPEED: = 94.0
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
		animate("idle", delta)
		return
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
	if attack_time > 0.0:
		attack_time = maxf(0.0, attack_time - delta)
		velocity = direction * SPEED * 0.25
		state = "attack"
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

func try_attack() -> bool:
	if attack_cooldown > 0.0 or dash_time > 0.0 or energy < 5.0:
		return false
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
	energy -= 5.0
	attack_time = 0.38
	attack_cooldown = 0.4
	cloak_time = 0.0
	hit_pending = true
	world.sound("slash")
	world.spawn_slash(global_position, facing)
	return true

func try_dash(direction: Vector2) -> bool:
	if dash_cooldown > 0.0 or energy < 22.0 or attack_time > 0.0:
		return false
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
	if cloak_cooldown > 0.0 or energy < 20.0 or attack_time > 0.0:
		return false
	cloak_time = 10.0
	cloak_cooldown = 18.0
	world.toast("Tarnfeld aktiv · Angreifen beendet die Tarnung")
	return true

func take_damage(amount: int, source: Vector2) -> void :
	if invulnerable > 0.0 or health <= 0:
		return
	health = maxi(health_floor, health - amount)
	invulnerable = 0.8
	cloak_time = 0.0
	flash_time = 0.18
	knockback = (global_position - source).normalized() * 130.0
	world.impact(global_position, false)
	if health == 0:
		world.player_defeated()

func reset_transients() -> void :
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

func _draw() -> void :
	super._draw()
	if second_player and health > 0 and world.actor_is_playable(self) and not world.is_busy() and aim_stick.length() > 0.25:
		var tip: = Vector2(0, -24) + facing * 64.0
		draw_line(Vector2(0, -24) + facing * 12.0, tip, Color(0.38, 0.9, 1.0, 0.55))
		draw_arc(tip, 3.0, 0.0, TAU, 8, Color("9de6f2"))
