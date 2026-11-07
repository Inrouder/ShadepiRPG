extends "res://scripts/memories/attack_memory.gd"
const RUINS = preload("res://assets/memories/sacrifice/courtyard.png")
const Minotaur = preload("res://scripts/memories/minotaur.gd")
const ChargeLy = preload("res://scripts/memories/charge_ly.gd")
var tank: PixelActor
var charge: Sprite2D
var events: Array[String] = []

func make_map() -> Node2D:
	var result = Map.new()
	result.background_texture = RUINS
	return result
func make_actor(id: String) -> PixelActor: return ChargeLy.new() if id=="ly" else Actor.new()
func squad_ids() -> Array: return ["shadepi","robot","ly"]
func resident_count() -> int: return 0
func initial_bot_count() -> int: return 0
func _ready() -> void:
	super._ready()
	for i in 3:
		squad[i].position=[Vector2(430,360),Vector2(370,335),Vector2(390,490)][i]
		squad[i].facing=Vector2.RIGHT
		squad[i].animate("idle",0)
	tank=Minotaur.new()
	actors.add_child(tank)
	tank.prepare(self)
	tank.position=Vector2(940,400)
	tank.hide()
	var pose: Dictionary=ChargeLy.charge_data[7]
	var rect: Array=pose.region
	var texture:=AtlasTexture.new()
	texture.atlas=ChargeLy.CHARGE_ART
	texture.region=Rect2(rect[0],rect[1],rect[2],rect[3])
	charge=Sprite2D.new()
	charge.texture=texture
	charge.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	charge.scale=Vector2.ONE*float(pose.scale)
	charge.offset=Vector2(rect[2],rect[3])*0.5-Vector2(pose.anchor[0],pose.anchor[1])
	charge.z_index=3
	actors.add_child(charge)
	charge.hide()

func active() -> bool: return not closed and cutscene.running
func mark(value: String) -> void:
	if active(): events.append(value)
func sound(kind: String) -> void:
	if active() and not cutscene.skipping and host!=null: host.sound(kind,0.05)
func pose(actor: PixelActor,state: String) -> void:
	if active():
		cutscene.pose(actor,state)
		actor.animate(state,0)
func fire_at(point: Vector2) -> void:
	if not active() or tank.destroyed: return
	tank.animation_name=""
	pose(tank,"fire")
	if cutscene.skipping: return
	effects.weapon_trace(tank.muzzle(),point+Vector2(0,-25),false)
	effects.burst(point,Color("ffbf70"),9)
	sound("pistol")

func play() -> void:
	if closed or cutscene.running: return
	cutscene.begin()
	phase="arrival"
	mark("arrival")
	await cutscene.letterbox(true)
	await cutscene.camera(Vector2(560,375),0.9,0.88)
	await cutscene.title("ERINNERUNG II","LYS OPFER",1.7)
	if not active(): return
	phase="minotaur"
	tank.show()
	mark("minotaur_arrives")
	sound("drive_knock")
	await cutscene.walk(tank,Vector2(780,400),55)
	await cutscene.camera(Vector2(715,385),0.8,0.9)
	if not active(): return
	await cutscene.say("ROBOTERKOPF-KRIEGER","Ein Minotaurus. Haltet Abstand!")
	if not active(): return
	phase="defence"
	cutscene.walk(squad[1],Vector2(590,335),90)
	cutscene.walk(squad[2],Vector2(635,490),90)
	await cutscene.walk(squad[0],Vector2(650,365),90)
	if not active(): return
	for round_index in 3:
		pose(tank,"guard")
		await cutscene.wait(0.45)
		if not active(): return
		fire_at(squad[0].position+Vector2(-24,15))
		await cutscene.wait(0.2)
		if not active(): return
		await cutscene.walk(squad[0],Vector2(705,375),135)
		if not active(): return
		pose(squad[0],"attack")
		pose(squad[1],"windup")
		await cutscene.wait(0.2)
		if not active(): return
		pose(squad[1],"strike")
		if not cutscene.skipping:
			effects.slash(Vector2(735,375),Vector2.RIGHT)
			effects.burst(Vector2(745,380),Color("f4ce8c"),12)
			sound("slash")
		await cutscene.wait(0.25)
		if not active(): return
		pose(squad[1],"recover")
		await cutscene.walk(squad[0],Vector2(650,365),110)
		if not active(): return
	mark("armour_holds")
	await cutscene.say("SHADEPI","Die Klinge kommt nicht durch!")
	if not active(): return
	await cutscene.walk(tank,Vector2(750,400),45)
	if not active(): return
	pose(tank,"hurt")
	phase="weak_point"
	mark("servo_exposed")
	await cutscene.say("ROBOTERKOPF-KRIEGER","Der Servoschacht. Unter dem Schild!")
	if not active(): return
	await cutscene.walk(squad[2],Vector2(665,465),85)
	if not active(): return
	pose(squad[2],"charge_draw")
	await cutscene.camera(Vector2(690,385),0.65,1.08)
	await cutscene.wait(0.6)
	if not active(): return
	phase="decision"
	pose(squad[2],"charge_arm")
	mark("charge_armed")
	await cutscene.say("SHADEPI","Nein! Ly, nicht!")
	if not active(): return
	await cutscene.say("LY","Verzeih mir, Bruder. FÜR DEN ORDEN!")
	if not active(): return
	phase="charge_run"
	mark("ly_commits")
	squad[2].carrying=true
	await cutscene.walk(squad[2],Vector2(700,435),150)
	if not active(): return
	pose(squad[2],"charge_leap")
	# Ly mounts the chassis above its ground footprint, rather than walking
	# through the collider. Kneeling hands align with the low service hatch.
	squad[2].collision_layer=0
	squad[2].collision_mask=0
	squad[2].z_index=2
	phase="mount"
	await cutscene.leap(squad[2],tank.position+Vector2(5,-27),32,0.55)
	if not active(): return
	pose(squad[2],"charge_attach")
	await cutscene.wait(0.5)
	if not active(): return
	charge.position=tank.weak_point()
	charge.show()
	mark("charge_attached")
	phase="attached"
	pose(squad[2],"charge_brace")
	pose(tank,"critical")
	await cutscene.wait(0.75)
	if not active(): return
	phase="detonation"
	mark("detonation")
	charge.hide()
	# He remains at the charge when it detonates; no escape or later respawn.
	squad[2].fallen=true
	squad[2].hide()
	cutscene.release(squad[2])
	mark("ly_fallen")
	for offset in [Vector2(-25,-50),Vector2(20,-40),Vector2(0,-5)]: map.impact(tank.position+offset)
	if not cutscene.skipping:
		effects.burst(tank.position,Color("ffd896"),40)
		sound("drive_explosion")
	pose(tank,"collapse")
	await cutscene.animate(func(k: float):
		if active(): cutscene.overlay.color=Color(1,0.85,0.65,sin(k*PI)*0.88),0.65)
	if not active(): return
	tank.disable()
	pose(tank,"wreck")
	mark("minotaur_destroyed")
	phase="aftermath"
	await cutscene.walk(squad[0],Vector2(610,370),95)
	await cutscene.camera(Vector2(710,365),0.9,1.05)
	await cutscene.wait(1.1)
	if not active(): return
	await cutscene.say("SHADEPI","Ly …")
	if not active(): return
	await cutscene.say("ROBOTERKOPF-KRIEGER","Shadepi. Der Weg ist frei.")
	if not active(): return
	mark("survivors_hold")
	await cutscene.fade(Color.BLACK,0.8)
	if not active(): return
	cutscene.end(_complete)
