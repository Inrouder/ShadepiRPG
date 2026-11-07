extends "res://scripts/memories/minotaur_battle.gd"
## Two real, independently damageable mechs. No timer victory in this encounter.
const BOSS_HEALTH := 168
var boss_health: Array[int] = [BOSS_HEALTH,BOSS_HEALTH]
var boss_stagger: Array[float] = [0,0]
var boss_stun: Array[float] = [0,0]
var collapse_time: Array[float] = [0,0]
var shots: Array[float] = [0,0]
var pending_tank := 0
var won := false

func start() -> void:
	super.start()
	for tank in world.tanks: world.cutscene.release(tank)
	clock.max_value=BOSS_HEALTH*2
	update_hud()

func reset() -> void:
	super.reset()
	boss_health=[BOSS_HEALTH,BOSS_HEALTH]
	boss_stagger=[0,0]
	boss_stun=[0,0]
	collapse_time=[0,0]
	shots=[0,0]
	pending_tank=0
	won=false
	for i in 2:
		while world.events.has("minotaur_%d_destroyed"%i): world.events.erase("minotaur_%d_destroyed"%i)
	world.squad[0].position=Vector2(550,420)
	for i in 2:
		var tank: PixelActor=world.tanks[i]
		tank.destroyed=false
		tank.collision_layer=1
		tank.collision_mask=1
		tank.position=Vector2(800,350 if i==0 else 490)
		tank.animate("guard",0)
	update_hud()

func attack() -> void:
	if not running or dead or won or world.menu_open or attack_cooldown>0 or dodge_time>0: return
	var player: PixelActor=world.squad[0]
	attack_cooldown=0.42
	attack_pose=0.25
	world.effects.slash(player.position+player.facing*26,player.facing)
	world.sound("slash")
	for i in 2:
		var target: PixelActor=world.tanks[i]
		var offset: Vector2=target.position-player.position
		if boss_health[i]<=0 or offset.length()>=124 or player.facing.dot(offset.normalized())<=0.15: continue
		boss_health[i]=maxi(0,boss_health[i]-28)
		boss_stagger[i]+=26
		hit_count+=1
		world.effects.burst(target.weak_point(),Color("f0ffff"),10)
		if boss_health[i]==0:
			collapse_time[i]=0.5
			target.animate("collapse",0)
			if pending_tank==i: clear_warning()
			world.sound("drive_explosion")
		elif boss_stagger[i]>=100:
			boss_stagger[i]=0
			boss_stun[i]=1.1
			if pending_tank==i: clear_warning()
			next_attack=0.7
	update_hud()

func tick(delta: float) -> void:
	if not running or dead or won or world.closed or world.menu_open: return
	elapsed+=delta
	stage=2 if boss_health[0]+boss_health[1]<BOSS_HEALTH else 1 if boss_health[0]+boss_health[1]<BOSS_HEALTH*1.65 else 0
	for field in ["attack_cooldown","attack_pose","dodge_cooldown","dodge_time","invulnerable"]:
		set(field,maxf(0,float(get(field))-delta))
	var player: PixelActor=world.squad[0]
	var move:=direction()
	if dodge_time>0: move=dodge_direction
	if move.length()>0.1: player.facing=move.normalized()
	player.velocity=move*(300 if dodge_time>0 else 128)
	player.move_and_slide()
	player.position=player.position.clamp(Vector2(330,292),Vector2(915,527))
	player.animate("attack" if attack_pose>0 else "walk" if move.length()>0.1 else "idle",delta)
	player.visual.modulate=Color(0.75,0.95,1,0.7) if invulnerable>0 else Color.WHITE
	for i in 2:
		boss_stun[i]=maxf(0,boss_stun[i]-delta)
		shots[i]=maxf(0,shots[i]-delta)
		var tank: PixelActor=world.tanks[i]
		if tank.destroyed: continue
		if boss_health[i]==0:
			collapse_time[i]=maxf(0,collapse_time[i]-delta)
			if collapse_time[i]==0:
				tank.disable()
				world.mark("minotaur_%d_destroyed"%i)
			else: tank.animate("collapse",delta)
		else: tank.animate("hurt" if boss_stun[i]>0 else "fire" if shots[i]>0 else "guard",delta)
	if world.tanks.all(func(t): return t.destroyed):
		won=true
		clear_inputs()
		clear_warning()
		player.velocity=Vector2.ZERO
		update_hud()
		return
	if warning>0:
		warning=maxf(0,warning-delta)
		for marker in markers: marker.modulate.a=0.45+sin(elapsed*24)*0.2
		if warning==0: resolve_volley()
	else:
		next_attack-=delta
		if next_attack<=0: begin_volley()
	update_hud()

func begin_volley() -> void:
	clear_warning()
	var alive: Array[int]=[]
	for i in 2:
		if boss_health[i]>0 and boss_stun[i]<=0: alive.append(i)
	if alive.is_empty():
		next_attack=0.3
		return
	pending_tank=alive[volley%alive.size()]
	volley+=1
	warning=[1.0,0.85,0.75][stage]
	var point: Vector2=world.squad[0].position
	targets.append(point)
	if stage>=1:
		targets.append(point+Vector2(64,0))
		targets.append(point-Vector2(64,0))
	if stage==2:
		targets.append(point+Vector2(0,62))
		targets.append(point-Vector2(0,62))
	for target in targets:
		var marker:=Sprite2D.new()
		marker.texture=world.map.region(0,3)
		marker.position=target
		marker.scale=Vector2.ONE*0.24
		marker.modulate=Color(1,0.25,0.18,0.6)
		marker.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		world.map.actors.add_child(marker)
		markers.append(marker)
	world.sound("drive_laser_warn")

func resolve_volley() -> void:
	var tank: PixelActor=world.tanks[pending_tank]
	if boss_health[pending_tank]<=0 or boss_stun[pending_tank]>0:
		clear_warning()
		return
	shots[pending_tank]=0.18
	tank.animation_name=""
	tank.animate("fire",0)
	for target in targets:
		world.effects.weapon_trace(tank.muzzle(),target+Vector2(0,-14),false)
		world.map.impact(target)
		if world.squad[0].position.distance_to(target)<34: damage([16,20,24][stage])
	world.sound("pistol")
	clear_warning()
	next_attack=[1.1,0.95,0.85][stage]

func update_hud() -> void:
	if not is_instance_valid(title): return
	title.text="DAS VERMÄCHTNIS · BESIEGE BEIDE MINOTAUREN"
	status.text="Leben %d · Minotaurus I %d / II %d · Servogelenke treffen!"%[health,boss_health[0],boss_health[1]]
	life.value=health
	clock.value=boss_health[0]+boss_health[1]
	if dead:
		title.text="KAMPF VERLOREN · E / A: NOCH EINMAL"
		status.text="Der Knoten bleibt offen. Esc / Start: Pause"
	elif won: status.text="Beide Minotauren zerstört."
	help.modulate=Color.WHITE if dodge_cooldown==0 else Color("9aabb9")

func resolve_skip() -> void:
	boss_health=[0,0]
	for tank in world.tanks: tank.disable()
	won=true
	clear_warning()
