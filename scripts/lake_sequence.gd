extends Node2D
## v0.69.0 · CodexAI. Clearing landing, walk-and-talk, intimate lake and cosmic credits.
const CLEARING = preload("res://assets/story/lake/epilogue/clearing.png")
const Petals = preload("res://scripts/lake_petals.gd")
const Epilogue = preload("res://scripts/lake_epilogue.gd")
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const Motion = preload("res://scripts/cinematic_motion.gd")
const Tableau = preload("res://scripts/lake_tableau.gd")
const Painted = preload("res://scripts/painted_world.gd")
const DRAGON = preload("res://assets/story/lake/dragon-flight.png")
const WATER = preload("res://shaders/lake_mystic.gdshader")
const PARK := Vector2(225,430)
const FOOTPRINT := Rect2(177,442,96,44)
const SHORE: Array[Vector2] = [Vector2(570,405),Vector2(592,420)]
var clearing_active := false
var petals: Node2D
var epilogue: CanvasLayer
var landing_body: StaticBody2D
var world: Node2D
var vehicle: Node2D
var tableau: Node2D
var water: Node2D
var water_material: ShaderMaterial
var stage := "parked"
var moon_halo: Sprite2D
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
	moon_halo = Sprite2D.new()
	moon_halo.texture = preload("res://assets/world/light.png")
	moon_halo.position = Vector2(727,97)
	moon_halo.scale = Vector2(176,176)/moon_halo.texture.get_size()
	moon_halo.z_index = -1
	moon_halo.modulate = Color(0.50,0.65,1.0,0.14)
	add_child(moon_halo)
	water = Node2D.new()
	add_child(water)
	water_material = ShaderMaterial.new()
	water_material.shader = WATER
	water_material.set_shader_parameter("dragon",DRAGON)
	var clip := PackedVector2Array([Vector2(0,212),Vector2(1024,212),Vector2(1024,490),Vector2(0,490)])
	for outline in Geometry2D.intersect_polygons(PackedVector2Array(Painted.WATER_EDGE),clip):
		var surface := Polygon2D.new()
		surface.polygon = outline
		surface.texture = Painted.texture("lakeside")
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
	landing_body=body
	body.position = FOOTPRINT.get_center()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = FOOTPRINT.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)
	petals=Petals.new();petals.sequence=self;add_child(petals)
	epilogue=Epilogue.new();add_child(epilogue)
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
	vehicle.visible=clearing_active
	vehicle.set_pose(craft,grow,roll,power,clock,bank)
	moon_halo.visible=not clearing_active
	if is_instance_valid(world.scene_atmosphere.water):world.scene_atmosphere.water.visible=not clearing_active and world.visual_quality>0
	water.visible = not clearing_active and (glow>0.001 or dragon_passage>=0)
	water_material.set_shader_parameter("clock",clock)
	water_material.set_shader_parameter("glow",glow*(0.6 if world.visual_quality==0 else 1.0))
	water_material.set_shader_parameter("passage",dragon_passage)
	water_material.set_shader_parameter("detail",0.0 if world.visual_quality==0 else 1.0)
	moon_halo.modulate.a = 0.12+0.025*sin(clock*0.35)
	tableau.material_pose.set_shader_parameter("warmth",glow)

func set_stage(value: String) -> void:
	stage = value
	if not events.has(value): events.append(value)

func _draw() -> void:
	if not clearing_active:return
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
	world.ui.set_lake_cinema(true)
	cs.ended.connect(_scene_ended,CONNECT_ONE_SHOT)
	var ticket: int = cs.generation
	world.player.hide()
	world.raven.hide()
	set_clearing(true)
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
	set_stage("forest_walk")
	await _walk_talk(cs,[Vector2(460,456),Vector2(482,470)],"RAVEN","Diese Stille … Nach der Stadt ist das fast unwirklich.")
	if not cs.alive(ticket): return
	await _walk_talk(cs,[Vector2(650,390),Vector2(671,407)],"SHADEPI","Hier hat der Orden früher Zuflucht gesucht. Den Weg kennt kaum jemand.")
	if not cs.alive(ticket): return
	await _walk_talk(cs,[Vector2(842,330),Vector2(862,347)],"RAVEN","Und du bringst ausgerechnet mich hierher?")
	if not cs.alive(ticket): return
	set_stage("lake_reveal")
	await cs.fade(Color.BLACK,0.7)
	if not cs.alive(ticket):return
	set_clearing(false)
	world.player.position=Vector2(320,466);world.raven.position=Vector2(343,481)
	await cs.camera(Vector2(460,374),0,1.2)
	await cs.fade(Color.TRANSPARENT,0.9)
	if not cs.alive(ticket):return
	await _walk_talk(cs,[Vector2(444,448),Vector2(465,463)],"SHADEPI","Das Heiligtum hat dich schon in der Gasse erkannt. Aber ich wäre auch ohne Prophezeiung an deiner Seite.",27)
	if not cs.alive(ticket):return
	set_stage("shore")
	await _walk_talk(cs,SHORE,"RAVEN","Gut. Ich will wissen, was du fühlst. Nicht, was irgendeine Prophezeiung von uns will.",26)
	if not cs.alive(ticket): return
	world.player.z_index=0;world.raven.z_index=0
	cs.face(world.player,world.raven.position);cs.face(world.raven,world.player.position)
	cs.pose(world.player,"idle");cs.pose(world.raven,"idle")
	set_stage("parked")
	cs.end(func():
		world.ui.set_lake_cinema(false)
		world.lake_scene_pending = false
		world.autosave()
		world.toast("Gemeinsam ans Wasser · E / A")
	)

func set_clearing(value: bool) -> void:
	clearing_active=value
	if is_instance_valid(landing_body):landing_body.collision_layer=1 if value else 0
	world.queue_redraw();_sync()

func _walk_talk(cs,targets: Array,speaker: String,text: String,speed: float=34.0) -> void:
	var ticket: int=cs.generation
	var pair: Array=[world.player,world.raven]
	var duration: float=world.player.position.distance_to(targets[0])/speed
	cs.camera((targets[0]+targets[1])*0.5-Vector2(0,40),duration,1.35)
	for i in 2:cs.walk(pair[i],targets[i],speed)
	await cs.say(speaker,text)
	if not cs.alive(ticket):return
	while cs.walkers.has(pair[0]) or cs.walkers.has(pair[1]):
		await cs.wait(0.05)
		if not cs.alive(ticket):return

func _restore_actors() -> void:
	for actor in [world.player,world.raven]:
		if not is_instance_valid(actor):continue
		actor.external_pose=false;actor.modulate=Color.WHITE;actor.z_index=0;actor.show()
		if is_instance_valid(actor.visual):actor.visual.show()
		if is_instance_valid(actor.cast_shadow):actor.cast_shadow.show()
		if is_instance_valid(actor.light_occluder):actor.light_occluder.visible=not actor.cloaked
		actor.queue_redraw()

func _scene_ended() -> void:
	if not is_instance_valid(world):return
	world.ui.set_lake_cinema(false)
	epilogue.reset();tableau.hide();_restore_actors()
	if clearing_active:
		world.player.position=SHORE[0];world.raven.position=SHORE[1]
		set_clearing(false)
	world.camera.zoom=Vector2.ONE;world.camera.position=world.camera_home()

func ritual_step(index: int) -> void:
	glow_target = [0.05,0.4,0.65,0.85][clampi(index,0,3)]

func _hide_actors() -> void:
	for actor in [world.player,world.raven]:
		actor.external_pose = true
		actor.visual.hide()
		actor.cast_shadow.hide()
		actor.light_occluder.hide()
		actor.queue_redraw()

func _exit_tree() -> void:
	if not is_instance_valid(world):return
	if is_instance_valid(world.ui):world.ui.set_lake_cinema(false)
	for actor in [world.player,world.raven]:
		if not is_instance_valid(actor):continue
		actor.external_pose = false
		if is_instance_valid(actor.visual):actor.visual.show()
		if is_instance_valid(actor.cast_shadow):actor.cast_shadow.show()
		if is_instance_valid(actor.light_occluder):actor.light_occluder.visible=not actor.cloaked
		actor.queue_redraw()

func rest() -> void:
	set_stage("rest")
	tableau.position = world.player.position
	tableau.set_pose(3)
	tableau.show()
	_hide_actors()
	glow_target = 0.25

func play_finale() -> void:
	var cs = world.begin_cutscene()
	world.ui.set_lake_cinema(true)
	cs.ended.connect(_scene_ended,CONNECT_ONE_SHOT)
	var ticket: int = cs.generation
	cs.pose(world.player,"idle")
	cs.pose(world.raven,"idle")
	await cs.walk(world.raven,world.player.position+Tableau.RAVEN_OFFSET,35)
	if not cs.alive(ticket): return
	tableau.position = world.player.position
	tableau.set_pose(0)
	tableau.show()
	_hide_actors()
	set_stage("hands")
	glow_target = 0.65
	await cs.camera(tableau.position+Vector2(10,-32),2.0,2.7)
	if not cs.alive(ticket): return
	await cs.lines([["RAVEN","Jetzt gehöre ich zum Orden … darf ich?"],["SHADEPI","Jetzt darfst du."]])
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
	cs.camera(tableau.position+Vector2(13,-33),2.8,3.15)
	await cs.wait(2.8)
	if not cs.alive(ticket): return
	set_stage("dragon")
	petals.gust()
	cs.camera(Vector2(615,350),2.2,0.95)
	await cs.animate(func(p: float):
		dragon_passage = p
		_sync()
	,5.6)
	if not cs.alive(ticket): return
	dragon_passage = -1
	set_stage("embrace")
	await tableau.transition(cs,3,0.9)
	if not cs.alive(ticket): return
	await cs.wait(1.4)
	if not cs.alive(ticket): return
	await cs.camera(tableau.position+Vector2(10,-30),1.7,2.6)
	if not cs.alive(ticket): return
	await cs.lines([["RAVEN","Kenzōs Auftraggeber … morgen suchen wir weiter."],["SHADEPI","Morgen."],["RAVEN","Heute bleibst du hier."],["SHADEPI","Bei dir."]])
	if not cs.alive(ticket): return
	await cosmic_departure(cs)
	if not cs.alive(ticket):return
	cs.end(func():
		rest()
		world.ui.set_lake_cinema(false)
		world.lake_scene_pending = false
		world.autosave()
		world.toast("Der neue Orden · Die gemeinsame Suche beginnt")
	)

func cosmic_departure(cs) -> void:
	var ticket: int=cs.generation
	set_stage("moon")
	await cs.camera(Vector2(727,97),4.8,3.2)
	if not cs.alive(ticket):return
	set_stage("stars")
	await cs.animate(func(p: float):epilogue.frame(p*0.28,clock,p),3.2)
	if not cs.alive(ticket):return
	set_stage("galaxy")
	await cs.animate(func(p: float):epilogue.frame(lerpf(0.28,0.65,p),clock),4.4)
	if not cs.alive(ticket):return
	set_stage("swarm")
	await cs.animate(func(p: float):epilogue.frame(lerpf(0.65,1.0,p),clock),5.2)
	if not cs.alive(ticket):return
	await cs.wait(1.5)
	if not cs.alive(ticket):return
	set_stage("credits")
	for page in Epilogue.PAGES.size():
		await cs.animate(func(p: float):
			epilogue.frame(1.0,clock)
			epilogue.credit(page,p)
		,4.6 if page==1 else 3.8)
		if not cs.alive(ticket):return
	await cs.fade(Color.BLACK,0.8)
	if not cs.alive(ticket):return
	epilogue.reset()
	await cs.camera(world.camera_home(),0,1)
	await cs.fade(Color.TRANSPARENT,1.0)
	if not cs.alive(ticket):return
