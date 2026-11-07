extends RefCounted
## Finite, authored battle for the historical memory. No random ally deaths.
## Every wait uses the scene director, so pause, abort and skip share one clock.
var world: Node2D
var events: Array[String] = []
var wave := 0
var cs: CanvasLayer

func _init(scene: Node2D) -> void:
	world = scene
	cs = scene.cutscene

func active() -> bool:
	return is_instance_valid(world) and not world.closed and cs.running

func mark(event: String) -> void:
	if active(): events.append(event)

func sound(kind: String) -> void:
	if active() and not cs.skipping and world.host != null: world.host.sound(kind,0.06)

func pose(actor: PixelActor,state: String) -> void:
	if active():
		cs.pose(actor,state)
		actor.animate(state,0)

func fire(actor: PixelActor,target: PixelActor) -> void:
	if not active() or actor.fallen: return
	cs.face(actor,target.position)
	actor.animation_name = ""
	pose(actor,"shoot")
	if cs.skipping: return
	var sign_x := 1 if actor.facing.x>=0 else -1
	world.effects.weapon_trace(actor.position+Vector2(sign_x*29,-34),target.position+Vector2(0,-30),false)
	world.effects.burst(target.position+Vector2(0,-10),Color("ffca85"),6)
	sound("pistol")

func melee(actor: PixelActor,target: PixelActor) -> void:
	if not active() or actor.fallen: return
	cs.face(actor,target.position)
	pose(actor,"attack" if actor.identity=="shadepi" else "windup")
	await cs.wait(0.25)
	if not active(): return
	pose(actor,"attack" if actor.identity=="shadepi" else "strike")
	if not cs.skipping:
		world.effects.slash((actor.position+target.position)/2,(target.position-actor.position).normalized())
		world.effects.burst(target.position,Color("a6e5e9"),12)
		sound("slash")
	pose(target,"hurt")
	await cs.wait(0.15)
	if not active(): return
	pose(actor,"idle" if actor.identity=="shadepi" else "recover")
	await cs.wait(0.2)

func fall(actor: PixelActor) -> void:
	if not active() or actor.fallen: return
	cs.release(actor)
	pose(actor,"hurt")
	if not cs.skipping:
		world.effects.burst(actor.position,Color("ffb46d"),10)
		if actor.identity!="bot" and world.host!=null:
			world.host.combat_audio.voice("death",world.host.audio_on)
		else: sound("hit")
	await cs.wait(0.18)
	if not active(): return
	pose(actor,"kneel")
	await cs.wait(0.25)
	if not active(): return
	pose(actor,"fall")
	await cs.wait(0.25)
	if not active(): return
	actor.fallen = true
	actor.collision_layer = 0
	actor.collision_mask = 0
	pose(actor,"dead")

func spawn_wave(number: int,spots: Array) -> Array[PixelActor]:
	var group: Array[PixelActor] = []
	if not active(): return group
	wave = number
	world.phase = "wave_%d"%number
	mark("wave_%d_start"%number)
	for i in 3:
		var bot: PixelActor
		if number==1: bot = world.bots[i]
		else: bot = world.create_bot(Vector2(975,350+i*45))
		bot.show()
		cs.walk(bot,spots[i],85)
		group.append(bot)
	return group

func play() -> void:
	if not active(): return
	# The old introductory bots become the first wave; corpses are never reused.
	world.phase = "battle_line"
	await cs.camera(Vector2(715,395),0.8,0.95)
	if not active(): return
	cs.walk(world.squad[2],Vector2(590,340),85)
	cs.walk(world.squad[3],Vector2(570,495),85)
	cs.walk(world.squad[4],Vector2(530,400),65)
	await cs.walk(world.squad[1],Vector2(650,415),85)
	if not active(): return
	var group := spawn_wave(1,[Vector2(710,350),Vector2(740,415),Vector2(800,490)])
	await cs.wait(2.8)
	if not active(): return
	await cs.say("ROBOTERKOPF-KRIEGER","Ich decke links. Lasst sie nicht zum Seitengang!")
	if not active(): return
	cs.walk(world.squad[1],Vector2(696,415),90)
	cs.walk(world.squad[3],Vector2(756,490),90)
	await cs.walk(world.squad[0],Vector2(666,350),90)
	if not active(): return
	for i in 2:
		for bot in group: fire(bot,world.squad[4])
		fire(world.squad[4],group[i])
		await melee(world.squad[0],group[0])
		if not active(): return
		await melee(world.squad[1],group[1])
		if not active(): return
		await melee(world.squad[3],group[2])
		if not active(): return
	for bot in group:
		await fall(bot)
		if not active(): return
	mark("wave_1_clear")
	await cs.wait(0.6)
	if not active(): return
	# Oni deliberately intercepts the attack directed at Shadepi.
	group = spawn_wave(2,[Vector2(780,350),Vector2(820,410),Vector2(890,445)])
	await cs.wait(2.5)
	if not active(): return
	await cs.walk(world.squad[0],Vector2(705,350),80)
	if not active(): return
	await cs.walk(group[0],Vector2(760,350),90)
	if not active(): return
	pose(group[0],"windup")
	world.phase = "oni_warning"
	await cs.say("LY","Shadepi! Rechts!")
	if not active(): return
	await cs.walk(world.squad[1],Vector2(735,350),145)
	if not active(): return
	mark("oni_protected")
	world.phase = "oni_protection"
	await cs.camera(Vector2(735,365),0.55,1.3)
	await cs.say("ONI-KRIEGER","Runter, Shadepi!")
	if not active(): return
	await melee(world.squad[1],group[0])
	if not active(): return
	await fall(group[0])
	if not active(): return
	pose(group[1],"windup")
	await cs.wait(0.5)
	if not active(): return
	fire(group[1],world.squad[1])
	await fall(world.squad[1])
	if not active(): return
	mark("oni_fallen")
	world.phase = "oni_fallen"
	await cs.say("SHADEPI","Nein …")
	if not active(): return
	await cs.camera(Vector2(735,400),0.6,0.95)
	await cs.walk(world.squad[2],Vector2(776,410),95)
	if not active(): return
	await melee(world.squad[2],group[1])
	if not active(): return
	await fall(group[1])
	if not active(): return
	await cs.walk(world.squad[3],Vector2(846,445),95)
	if not active(): return
	await melee(world.squad[3],group[2])
	if not active(): return
	await fall(group[2])
	if not active(): return
	mark("wave_2_clear")
	# The heavy warrior buys the others time. The final incoming shot is shown
	# before its shooter falls, so his death has a visible source.
	group = spawn_wave(3,[Vector2(800,350),Vector2(850,410),Vector2(915,445)])
	await cs.wait(2.5)
	if not active(): return
	await cs.walk(world.squad[4],Vector2(725,410),72)
	if not active(): return
	world.phase = "mg_cover"
	mark("mg_cover")
	await cs.say("MG-KRIEGER","Zurück! Ich halte sie auf!")
	if not active(): return
	cs.walk(world.squad[2],Vector2(590,340),90)
	cs.walk(world.squad[3],Vector2(570,495),90)
	await cs.walk(world.squad[0],Vector2(640,380),90)
	if not active(): return
	for i in 3:
		pose(group[i],"windup")
		await cs.wait(0.4)
		if not active(): return
		fire(group[i],world.squad[4])
		for shot in 3:
			fire(world.squad[4],group[i])
			await cs.wait(0.12)
			if not active(): return
			pose(world.squad[4],"recover")
			await cs.wait(0.1)
			if not active(): return
		await fall(group[i])
		if not active(): return
		if i==1:
			pose(world.squad[4],"hurt")
			await cs.wait(0.35)
			if not active(): return
	world.phase = "mg_last_stand"
	world.map.impact(Vector2(748,410))
	sound("drive_explosion")
	await cs.say("MG-KRIEGER","Los! Zum inneren Hof!")
	if not active(): return
	await fall(world.squad[4])
	if not active(): return
	mark("heavy_fallen")
	mark("wave_3_clear")
	world.phase = "heavy_fallen"
	await cs.camera(Vector2(710,385),0.7,1.15)
	await cs.wait(1.2)
	if not active(): return
	await cs.say("LY","Shadepi … wir müssen weiter.")
	if not active(): return
	await cs.say("SHADEPI","Zum inneren Hof. Bleibt zusammen.")
	if not active(): return
	world.phase = "retreat"
	cs.walk(world.squad[2],Vector2(430,340),78)
	cs.walk(world.squad[3],Vector2(430,495),78)
	await cs.walk(world.squad[0],Vector2(490,380),72)
	if not active(): return
	mark("retreat")
