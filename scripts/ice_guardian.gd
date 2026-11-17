extends "res://scripts/dive_threat.gd"
## v0.66.0 · CodexAI. Mobile guardian, seven denser volleys and a stationary punish window.
const COMBAT_ART: Texture2D = preload("res://assets/sprites/npcs/ice-guardian-combat.png")
const Bolt = preload("res://scripts/ice_orb.gd")
const WINDUP := 1.1
const SALVO := 2.1
const COOLING := 3.6
const CORE_RANGE := 66.0
const MAX_HEALTH := 8
const SHOT_COUNT := 7
const SHOT_INTERVAL := 0.28
const FLIGHT_ROUTE: Array[Vector2] = [Vector2(1300,430),Vector2(1320,730),Vector2(1090,780),Vector2(1060,480)]
var flight_point := 0
enum Phase { AIM, FIRE, COOL, DEFEATED }
var phase := Phase.AIM
var phase_time := 0.0
var health := MAX_HEALTH
var volleys := 0
var cycle_damage := 0
var hit_cooldown := 0.0
var cooling_extended := false
var aim := Vector2.LEFT
var bolts: Array[Node2D] = []
var atlas_frame := 0

func _init() -> void:
	guardian = true

func _ready() -> void:
	super._ready()
	bounds=Rect2(Vector2(30,30),world.ice_map_size()-Vector2(60,60))
	# Atlas replaces only this boss; standard Raven/Shadepi stay untouched.
	visual.texture = COMBAT_ART
	visual.hframes = 4
	visual.vframes = 2
	visual_scale = 88.0 / (visual.texture.get_width() / 4.0)
	visual.position.y = -18.0
	aim = position.direction_to(world.raven.position)
	_update_visual()

func _process(delta: float) -> void:
	if world.is_busy(): return
	visual_elapsed += delta
	elapsed += delta
	phase_time += delta
	hit_cooldown = maxf(0, hit_cooldown - delta)
	flash = maxf(0, flash - delta)
	if phase in [Phase.AIM,Phase.FIRE]:
		var destination: Vector2=FLIGHT_ROUTE[flight_point]
		_move(position.direction_to(destination)*minf((115.0 if health>4 else 145.0)*delta,position.distance_to(destination)))
		if position.distance_to(destination)<4: flight_point=(flight_point+1)%FLIGHT_ROUTE.size()
	if phase == Phase.AIM:
		if phase_time<WINDUP*0.65: aim=position.direction_to(world.raven.position)
		if phase_time >= WINDUP:
			phase = Phase.FIRE
			phase_time = 0
			volleys = 0
	elif phase == Phase.FIRE:
		while volleys < SHOT_COUNT and phase_time >= volleys * SHOT_INTERVAL:
			_fire_volley()
			volleys += 1
		if phase_time >= SALVO:
			phase = Phase.COOL
			phase_time = 0
			world.sound("hack", 0.1)
	elif phase == Phase.COOL:
		if phase_time >= COOLING:
			phase = Phase.AIM
			phase_time = 0
			cycle_damage = 0
			cooling_extended = false
			aim = position.direction_to(world.raven.position)
	elif phase_time >= 0.85:
		world._destroy_threat(self)
	_update_visual()
	queue_redraw()

func _fire_volley() -> void:
	# Aim is locked BEFORE the volley: moving sideways genuinely dodges it.
	for spread in [-0.18, 0.0, 0.18]:
		var orb = Bolt.new()
		orb.world = world
		orb.owner_boss = self
		orb.position = position
		orb.direction = aim.rotated(spread + (0.035 if volleys % 2 else -0.035))
		orb.speed = 190.0 if health > 4 else 235.0
		world.actors.add_child(orb)
		bolts.append(orb)
	world.sound("electric", -0.12)

func vulnerable() -> bool:
	return phase == Phase.COOL and cycle_damage < 2 and health > 0

func crack(_from: Vector2) -> void:
	# Shooting a closed shell cannot skip the salvo, nor hack it permanently open.
	flash = 0.08

func receive_strike(source: PixelActor, strength: int) -> bool:
	return receive_contact(source.position,strength)

func receive_contact(origin: Vector2,strength: int) -> bool:
	if phase == Phase.DEFEATED: return false
	if not vulnerable():
		world.damage_number(position + Vector2(-28, -62), "PANZERUNG")
		return false
	if origin.distance_to(position) > CORE_RANGE:
		world.damage_number(position + Vector2(-28, -62), "NÄHER RAN")
		return false
	if hit_cooldown > 0 or not world._line_clear(origin, position): return false
	var damage := mini(mini(strength, 2 - cycle_damage), health)
	health -= damage
	cycle_damage += damage
	hit_cooldown = 0.48
	flash = 0.15
	world.damage_number(position + Vector2(-15, -62), "KERN −%d" % damage, true)
	world.effects.burst(position + Vector2(0,-18), Color("85f6ff"), 16)
	world.sound("hit", 0.18)
	world.shake = 3.0
	world.hitstop(0.05)
	if health <= 0:
		phase = Phase.DEFEATED
		phase_time = 0
		clear_bolts()
	elif cycle_damage >= 2:
		# Give a deliberate retreat beat before the NEXT visible wind-up.
		phase_time = maxf(phase_time, COOLING - 2.0)
	return true

func extend_cooling() -> void:
	if vulnerable() and not cooling_extended:
		phase_time = maxf(0, phase_time - 1.2)
		cooling_extended = true

func clear_bolts() -> void:
	for bolt in bolts:
		if is_instance_valid(bolt):
			bolt.set_physics_process(false)
			bolt.hide()
			bolt.queue_free()
	bolts.clear()

func _exit_tree() -> void:
	clear_bolts()

func status_text() -> String:
	if phase == Phase.DEFEATED: return "WÄCHTER GELÖSCHT"
	if vulnerable(): return "KERN OFFEN · NAH RAN!"
	if phase == Phase.COOL: return "ZURÜCK IN DECKUNG"
	return "SALVE · AUSWEICHEN!" if phase == Phase.FIRE else "ZIEL ERFASST · DECKUNG!"

func _update_visual() -> void:
	if visual == null: return
	match phase:
		Phase.DEFEATED: atlas_frame = 7
		Phase.COOL: atlas_frame = 6 if flash > 0 else 5 if cycle_damage < 2 else 4
		Phase.FIRE: atlas_frame = 3 + int(fposmod(phase_time, SHOT_INTERVAL) > 0.12)
		_: atlas_frame = 0 if phase_time < 0.25 else 1 + int(phase_time > WINDUP * 0.65)
	if visual.hframes == 4: visual.frame = atlas_frame
	visual.scale = Vector2.ONE * visual_scale
	visual.position = Vector2(0, -18 + sin(visual_elapsed * 2.8) * 2.0)
	if phase == Phase.FIRE:
		visual.position -= aim * (3.0 * maxf(0, 1.0 - fposmod(phase_time, SHOT_INTERVAL) / 0.16))
	visual.rotation = sin(visual_elapsed * 1.5) * 0.025
	visual.modulate = Color(1.5,1.5,1.5) if flash > 0 else Color.WHITE

func _draw() -> void:
	# Only aiming/UI markings; body and bullets are textured source pixels.
	if phase == Phase.AIM:
		for i in 16:
			var start := aim * (45 + i * 22)
			draw_line(start, start + aim * 10, Color(1.0,0.32,0.5,0.5), 1.0)
