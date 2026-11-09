extends Node2D
## v0.36.0 · CodexAI. Land on dry ground, leave the craft, then the lake finale.
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const Motion = preload("res://scripts/cinematic_motion.gd")
const Tableau = preload("res://scripts/lake_tableau.gd")
const Painted = preload("res://scripts/painted_world.gd")
const DRAGON = preload("res://assets/story/lake/dragon.png")
const WATER = preload("res://shaders/lake_mystic.gdshader")
const PARK := Vector2(225,430)
const FOOTPRINT := Rect2(177,442,96,44)
const SHORE: Array[Vector2] = [Vector2(570,405),Vector2(592,420)]
var world: Node2D
var vehicle: Node2D
var tableau: Node2D
var water: Node2D
var water_material: ShaderMaterial
var stage := "parked"
var clock := 0.0
var craft := PARK
var grow := 0.9
var roll := 0.0
var bank := 0.0
var power := 0.0
var altitude := 0.0
var glow := 0.0
var glow_target := 0.0
var dragon_passage := -1.0
var events: Array[String] = []

func _ready() -> void:
	y_sort_enabled = true
	water = Node2D.new()
	add_child(water)
	water_material = ShaderMaterial.new()
	water_material.shader = WATER
	water_material.set_shader_parameter("dragon",DRAGON)
	var clip := PackedVector2Array([Vector2(0,212),Vector2(1024,212),Vector2(1024,490),Vector2(0,490)])
	for outline in Geometry2D.intersect_polygons(PackedVector2Array(Painted.WATER_EDGE),clip):
		var surface := Polygon2D.new()
		surface.polygon = outline
		surface.texture = Painted.ART.lakeside
		surface.material = water_material
		var uv := PackedVector2Array()
		for point in outline: uv.append(point/Vector2(1024,640)*surface.texture.get_size())
		surface.uv = uv
		water.add_child(surface)
	vehicle = Aerodyne.new()
	add_child(vehicle)
	tableau = Tableau.new()
	add_child(tableau)
	var body := StaticBody2D.new()
	body.position = FOOTPRINT.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = FOOTPRINT.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	_sync()

func paused() -> bool:
	return world==null or world.menu_open or world.terminal!=null

func _process(delta: float) -> void:
	if paused(): return
	clock += delta
	glow = move_toward(glow,glow_target,delta*0.24)
	_sync()
	queue_redraw()

func _sync() -> void:
	vehicle.set_pose(craft,grow,roll,power,clock,bank)
	water.visible = glow>0.001 or dragon_passage>=0
	water_material.set_shader_parameter("clock",clock)
	water_material.set_shader_parameter("glow",glow*(0.6 if world.visual_quality==0 else 1.0))
	water_material.set_shader_parameter("passage",dragon_passage)
	tableau.material_pose.set_shader_parameter("warmth",glow)

func set_stage(value: String) -> void:
	stage = value
	if not events.has(value): events.append(value)

func _draw() -> void:
	var fade := 0.34*(1-altitude)
	draw_set_transform(PARK+Vector2(0,28),0,Vector2(1,0.3))
	draw_circle(Vector2.ZERO,48-altitude*12,Color(0,0,0,fade))
	draw_set_transform(Vector2.ZERO)

func arrival_step(segment: int, p: float) -> void:
	var k := smoothstep(0,1,p)
	bank = -0.65*sin(p*PI) if segment==1 else 0.0
	if segment==0:
		craft = Motion.hermite(Vector2(1010,120),Vector2(650,220),Vector2(-130,12),Vector2(-120,50),3.2,p)
		grow = lerpf(0.26,0.4,k)
		roll = -2.0
		power = 0.75
		altitude = 1
	elif segment==1:
		craft = Motion.hermite(Vector2(650,220),PARK-Vector2(0,40),Vector2(-120,50),Vector2.ZERO,4.2,p)
		grow = lerpf(0.4,0.9,k)
		roll = lerpf(-2.0,0.0,k)
		power = lerpf(0.75,0.4,k)
		altitude = lerpf(1,0.35,k)
	else:
		craft = (PARK-Vector2(0,40)).lerp(PARK,k)
		grow = 0.9
		roll = 0
		power = lerpf(0.4,0.05,k)
		altitude = lerpf(0.35,0,k)
	_sync()
	queue_redraw()

func _exit(cs, actor: PixelActor, target: Vector2) -> void:
	# Starboard cabin port, clear of the rear engine bells.
	var start := PARK+Vector2(58,0)
	actor.position = start
	actor.modulate.a = 0
	actor.z_index = 3
	actor.show()
	await cs.animate(func(p: float):
		actor.position = start.lerp(target,p)+Vector2(0,-sin(p*PI)*5)
		actor.modulate.a = smoothstep(0,0.45,p)
		actor.facing = (target-start).normalized()
		if not paused(): actor.animate("walk",actor.get_process_delta_time())
	,0.9)

func play_arrival() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.player.hide()
	world.raven.hide()
	set_stage("approach")
	world.sound("drive_boost")
	arrival_step(0,0)
	vehicle.z_index = 2
	await cs.fade(Color.BLACK,0)
	if not cs.alive(ticket): return
	await cs.camera(Vector2(540,285),0,0.72)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT,0.9)
	if not cs.alive(ticket): return
	await cs.animate(func(p: float): arrival_step(0,p),3.2)
	if not cs.alive(ticket): return
	set_stage("descent")
	cs.camera(Vector2(360,420),4.2,1.0)
	await cs.animate(func(p: float): arrival_step(1,p),4.2)
	if not cs.alive(ticket): return
	set_stage("touchdown")
	await cs.animate(func(p: float): arrival_step(2,p),1.4)
	if not cs.alive(ticket): return
	world.sound("prop_metal")
	vehicle.z_index = 0
	power = 0
	await cs.wait(0.6)
	if not cs.alive(ticket): return
	set_stage("exit_raven")
	await cs.animate(vehicle.set_door,0.65)
	if not cs.alive(ticket): return
	await _exit(cs,world.raven,PARK+Vector2(93,44))
	if not cs.alive(ticket): return
	set_stage("exit_shadepi")
	await _exit(cs,world.player,PARK+Vector2(77,76))
	if not cs.alive(ticket): return
	await cs.animate(func(p: float): vehicle.set_door(1-p),0.65)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 7","Der neue Orden",2.2)
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Diese Stille … Ich habe vergessen, wie sich das anfühlt.")
	if not cs.alive(ticket): return
	set_stage("shore")
	await Motion.walk_pair(cs,[world.player,world.raven],[Vector2(430,475),Vector2(454,492)],72)
	if not cs.alive(ticket): return
	await Motion.walk_pair(cs,[world.player,world.raven],SHORE,66)
	if not cs.alive(ticket): return
	world.player.z_index = 0
	world.raven.z_index = 0
	cs.face(world.player,world.raven.position)
	cs.face(world.raven,world.player.position)
	cs.pose(world.player,"idle")
	cs.pose(world.raven,"idle")
	await cs.lines([["RAVEN","Was ist das für ein Ort?"],["SHADEPI","Ein Zufluchtsort des Ordens. Komm, ich zeige dir etwas."]])
	if not cs.alive(ticket): return
	set_stage("parked")
	cs.end(func():
		world.lake_scene_pending = false
		world.autosave()
		world.toast("Gemeinsam ans Wasser · E / A")
	)

func ritual_step(index: int) -> void:
	glow_target = [0.05,0.4,0.65,0.85][clampi(index,0,3)]

func rest() -> void:
	set_stage("rest")
	tableau.position = world.player.position
	tableau.set_pose(3)
	tableau.show()
	for actor in [world.player,world.raven]:
		actor.visual.hide()
		actor.cast_shadow.hide()
	glow_target = 0.25

func play_finale() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	cs.pose(world.player,"idle")
	cs.pose(world.raven,"idle")
	await cs.walk(world.raven,world.player.position+Tableau.RAVEN_OFFSET,35)
	if not cs.alive(ticket): return
	tableau.position = world.player.position
	tableau.set_pose(0)
	tableau.show()
	for actor in [world.player,world.raven]:
		actor.visual.hide()
		actor.cast_shadow.hide()
	set_stage("hands")
	glow_target = 0.65
	await cs.camera(tableau.position+Vector2(10,-32),1.4,2.1)
	if not cs.alive(ticket): return
	await cs.lines([["RAVEN","Und jetzt … darf ich?"],["SHADEPI","Ja."]])
	if not cs.alive(ticket): return
	set_stage("mask")
	await tableau.transition(cs,1,0.9)
	if not cs.alive(ticket): return
	await cs.wait(1.0)
	if not cs.alive(ticket): return
	set_stage("kiss")
	await tableau.transition(cs,2,0.8)
	if not cs.alive(ticket): return
	glow_target = 1.0
	await cs.wait(2.2)
	if not cs.alive(ticket): return
	set_stage("dragon")
	cs.camera(Vector2(720,360),1.8,1.1)
	await cs.animate(func(p: float):
		dragon_passage = p
		_sync()
	,3.6)
	if not cs.alive(ticket): return
	dragon_passage = -1
	set_stage("embrace")
	await tableau.transition(cs,3,0.9)
	if not cs.alive(ticket): return
	await cs.wait(1.4)
	if not cs.alive(ticket): return
	await cs.camera(tableau.position+Vector2(10,-30),1.0,1.8)
	if not cs.alive(ticket): return
	await cs.lines([["RAVEN","Kenzōs Auftraggeber … morgen suchen wir weiter."],["SHADEPI","Morgen."],["RAVEN","Heute bleibst du hier."],["SHADEPI","Bei dir."]])
	if not cs.alive(ticket): return
	await cs.title("DER ORDEN DES WEISSEN DRACHEN","Ein neuer Anfang",3.0)
	if not cs.alive(ticket): return
	cs.end(func():
		rest()
		world.lake_scene_pending = false
		world.autosave()
		world.toast("Der neue Orden · Die gemeinsame Suche beginnt")
	)
