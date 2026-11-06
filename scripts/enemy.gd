extends PixelActor

var health := 180
var max_health := 180
var min_health := 0
var hit_damage := 24
var move_speed := 46.0
var active := false
var armoured := false
var attack_recovery := 1.1
var windup_duration := 0.72
var lunge_speed := 220.0
var awareness := INF
var shot_range := 0.0
var sweep_enabled := false
var sweeping := false
var attack_index := 0
var front_shield := false
var exposed := 0.0
var stun := 0.0
var cooldown := 1.0
var windup := 0.0
var lunge := 0.0
var hit_done := false
var scenery_hit_done := false
var attack_direction := Vector2.DOWN
var attack_visual_time := 0.0
## Hit reaction: knockback impulse that slides with collision and decays.
var knock_velocity := Vector2.ZERO
var death_tween: Tween

func _physics_process(delta: float) -> void:
	if health <= 0 or world.is_busy():
		return
	exposed = maxf(0.0, exposed - delta)
	stun = maxf(0.0, stun - delta)
	cooldown = maxf(0.0, cooldown - delta)
	attack_visual_time = maxf(0.0, attack_visual_time - delta)
	velocity = Vector2.ZERO
	knock_velocity = knock_velocity.move_toward(Vector2.ZERO, 900.0 * delta)
	var state := "idle"
	var target = world.combat_target(global_position)
	var offset: Vector2 = target.global_position - global_position if target != null else Vector2.ZERO
	if stun > 0.0:
		state = "hurt"
	elif windup > 0.0:
		windup -= delta
		if windup <= 0.0:
			if shot_range > 0.0:
				attack_visual_time = 8.0 / 18.0
				var endpoint := global_position + attack_direction * shot_range
				var obstruction: Dictionary = world.trace_scenery(global_position, endpoint)
				if not obstruction.is_empty():
					endpoint = obstruction.position
				var target_exposed: bool = target != null and world._line_clear(global_position, target.global_position)
				if not obstruction.is_empty() and obstruction.collider is WorldProp:
					obstruction.collider.take_damage(hit_damage)
				world.effects.pulse_trace(global_position, endpoint)
				if target_exposed and absf(offset.cross(attack_direction)) <= 16.0 and offset.dot(attack_direction) > 0.0 and offset.length() <= shot_range:
					target.take_damage(hit_damage, global_position)
				cooldown = attack_recovery
			elif sweeping:
				attack_visual_time = 8.0 / 18.0
				var clear: bool = target != null and world._line_clear(global_position, target.global_position)
				world.strike_scenery(global_position, attack_direction, hit_damage + 6)
				if clear and offset.length() <= 70.0 and offset.normalized().dot(attack_direction) >= 0.35:
					target.take_damage(hit_damage + 6, global_position)
				world.spawn_slash(global_position, attack_direction)
				cooldown = attack_recovery
			else:
				lunge = 0.22
				hit_done = false
				scenery_hit_done = false
	elif lunge > 0.0:
		lunge -= delta
		velocity = attack_direction * lunge_speed
		state = "attack"
		if not scenery_hit_done and world.strike_scenery(global_position, attack_direction, hit_damage) > 0:
			scenery_hit_done = true
		if not hit_done:
			var victim = world.combat_target(global_position, true)
			if victim != null and global_position.distance_to(victim.global_position) < 35.0 and world._line_clear(global_position, victim.global_position):
				hit_done = true
				victim.take_damage(hit_damage, global_position)
		if lunge <= 0.0:
			cooldown = attack_recovery
	elif active and target != null and offset.length() <= awareness:
		facing = offset.normalized()
		var obstruction: Dictionary = world.trace_scenery(global_position, global_position + facing * 42.0)
		var scenery_in_reach: bool = not obstruction.is_empty() and obstruction.collider is WorldProp
		var target_in_reach: bool = offset.length() < maxf(60.0, shot_range) and (shot_range == 0.0 or world._line_clear(global_position, target.global_position))
		if cooldown <= 0.0 and (target_in_reach or scenery_in_reach):
			windup = windup_duration
			attack_direction = facing
			attack_index += 1
			sweeping = sweep_enabled and attack_index % 2 == 0
		elif offset.length() > 35.0:
			velocity = facing * move_speed
			state = "walk"
	velocity += knock_velocity
	move_and_slide()
	# Ranged shots and sweeps resolve immediately, but their pose needs a full cycle.
	# This timer affects artwork only; damage and attack recovery keep their timing.
	if attack_visual_time > 0.0 and state != "hurt":
		state = "attack"
	animate(state, delta)

func is_boss() -> bool:
	return max_health >= 300

func take_damage(base: int, source: Vector2 = Vector2.INF) -> void:
	if health <= 0:
		return
	if source == Vector2.INF:
		source = world.player.global_position
	if armoured or (front_shield and exposed <= 0.0 and global_position.direction_to(world.player.position).dot(facing) > 0.55):
		world.effects.burst(global_position, Color("efc788"), 7)
		world.damage_number(global_position + Vector2(0, -48), "BLOCK")
		return
	var amount := health - min_health if world.admin_enabled("one_hit") else CombatRules.damage(base, exposed > 0.0)
	amount = mini(amount, health - min_health)
	health -= amount
	flash_time = 0.17
	world.impact(global_position, true)
	world.damage_number(global_position + Vector2(0, -48), str(amount))
	var direction: Vector2 = (global_position - source).normalized() if global_position != source else facing * -1.0
	var heavy: = amount >= 30
	# Hit reaction: knockback and a short flinch. Bosses only flinch on heavy hits.
	knock_velocity = direction * ((40.0 if is_boss() else 120.0) + amount * (1.5 if is_boss() else 4.0))
	if not is_boss() or heavy:
		stun = maxf(stun, 0.22 if heavy else 0.14)
	if world.has_method("register_hit"):
		world.register_hit(self, amount, direction, health <= 0)
	if health <= 0:
		queue_redraw()
		active = false
		windup = 0.0
		lunge = 0.0
		attack_visual_time = 0.0
		visual.modulate = Color(0.45, 0.5, 0.6, 0.7)
		visual.rotation = PI * 0.5
		visual.position.y = -10
		_fall(direction)
		world.enemy_defeated(self)

## Death reaction: thrown back a little, a hop and a dimming fade-in of the KO pose.
func _fall(direction: Vector2) -> void:
	if not is_inside_tree():
		return
	if death_tween != null:
		death_tween.kill()
	visual.rotation = 0.0
	visual.position.y = standing_visual_position.y
	death_tween = create_tween().set_parallel(true)
	death_tween.tween_property(self, "position", position + direction * 26.0, 0.3).set_ease(Tween.EASE_OUT)
	death_tween.tween_property(visual, "rotation", PI * 0.5 * (1.0 if direction.x >= 0.0 else -1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	death_tween.tween_property(visual, "position:y", -10.0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func hack() -> void:
	if health <= 0:
		return
	exposed = 6.0
	stun = 1.8
	windup = 0.0
	lunge = 0.0
	attack_visual_time = 0.0
	cooldown = 1.2
	flash_time = 0.1

func hack_interrupt(duration: float) -> void:
	# A kick interrupts a vulnerable attacker without granting the hack damage bonus.
	stun = maxf(stun, duration)
	windup = 0.0
	lunge = 0.0
	attack_visual_time = 0.0
	cooldown = maxf(cooldown, duration)

func reset_fight(hp: int = 180) -> void:
	if death_tween != null:
		death_tween.kill()
		death_tween = null
	knock_velocity = Vector2.ZERO
	health = hp
	exposed = 0.0
	stun = 0.0
	windup = 0.0
	lunge = 0.0
	attack_visual_time = 0.0
	cooldown = 1.0
	flash_time = 0.0
	visual.modulate = Color.WHITE
	reset_visual_pose()

func _draw() -> void:
	super._draw()
	if health <= 0:
		return
	if active and not world.in_cinematic():
		draw_rect(Rect2(-22, -64, 44, 3), Color("162435"))
		draw_rect(Rect2(-22, -64, 44.0 * health / max_health, 3), Color("57d5e4") if exposed > 0 else Color("ec597e"))
	if windup > 0.0:
		var radius := 16.0 + 26.0 * (1.0 - windup / windup_duration)
		var half_arc := 1.21 if sweeping else 0.65
		draw_arc(Vector2.ZERO, radius + (18.0 if sweeping else 0.0), attack_direction.angle() - half_arc, attack_direction.angle() + half_arc, 16, Color("ff5974"), 2.0)
		if not sweeping:
			var target := attack_direction * maxf(56.0, shot_range)
			draw_line(Vector2.ZERO, target, Color(1.0, 0.3, 0.42, 0.4), 1.0)
	if front_shield and exposed <= 0.0:
		draw_arc(Vector2(0, -23), 19.0, facing.angle() - 0.9, facing.angle() + 0.9, 12, Color("8ca8c3"), 4.0)
	if exposed > 0.0:
		draw_arc(Vector2(0, -28), 23, 0.0, TAU, 20, Color(0.2, 0.85, 1.0, 0.6), 1.0)
