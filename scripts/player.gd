extends PixelActor

const SPEED := 94.0
var health := 100
var energy := 100.0
var attack_time := 0.0
var attack_cooldown := 0.0
var dash_time := 0.0
var dash_cooldown := 0.0
var cloak_time := 0.0
var cloak_cooldown := 0.0
var invulnerable := 0.0
var hit_pending := false
var combo := 0
var combo_window := 0.0
var knockback := Vector2.ZERO
var last_aim_mouse := Vector2.ZERO

func _physics_process(delta: float) -> void:
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
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.length() > 0.1 and attack_time <= 0.0 and dash_time <= 0.0:
		facing = direction.normalized()
	if Input.is_action_just_pressed("attack"):
		try_attack()
	if Input.is_action_just_pressed("dash"):
		try_dash(direction)
	if Input.is_action_just_pressed("cloak"):
		try_cloak()
	set_cloaked(cloak_time > 0.0)
	var state := "idle"
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
	move_and_slide()
	animate(state, delta)

func try_attack() -> bool:
	if attack_cooldown > 0.0 or dash_time > 0.0 or energy < 5.0:
		return false
	if Input.is_action_just_pressed("mouse_attack"):
		var aim := get_global_mouse_position() - global_position
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

func take_damage(amount: int, source: Vector2) -> void:
	if invulnerable > 0.0 or health <= 0:
		return
	health = maxi(0, health - amount)
	invulnerable = 0.8
	cloak_time = 0.0
	flash_time = 0.18
	knockback = (global_position - source).normalized() * 130.0
	world.impact(global_position, false)
	if health == 0:
		world.player_defeated()

func reset_transients() -> void:
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
