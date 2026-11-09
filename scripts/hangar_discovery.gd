extends Node2D
## v0.39.0 · CodexAI. Workbench, unlocking, visible descent, docking and reveal.
const Art = preload("res://scripts/hangar_art.gd")
const View = preload("res://scripts/hangar_lift_view.gd")
const Motion = preload("res://scripts/cinematic_motion.gd")
const EXIT_ROUTE := [[Vector2(232,500),Vector2(265,515)],[Vector2(412,500),Vector2(438,515)],[Vector2(420,450),Vector2(438,468)]]
var world: Node2D
var layer: CanvasLayer
var screen: Node2D
var switch_pose: Sprite2D
var ambient: CanvasModulate
var stage := "idle"
var view := "garage"
var deck_frame := 0
var clock := 0.0
var travel := 0.0
var gate := 0.0
var mounted := false
var events: Array[String] = []
func _ready():
	switch_pose = Sprite2D.new()
	switch_pose.texture = Art.SWITCH
	switch_pose.hframes = 2
	switch_pose.vframes = 2
	switch_pose.scale = Vector2.ONE*0.125
	switch_pose.position = Art.SWITCH_FEET+(Vector2(384,256)-Art.SWITCH_ANCHOR)*0.125
	switch_pose.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	world.actors.add_child(switch_pose)
	switch_pose.hide()
	layer = CanvasLayer.new()
	layer.layer = 8
	add_child(layer)
	ambient = CanvasModulate.new()
	ambient.color = world.ambient.color
	layer.add_child(ambient)
	screen = View.new()
	screen.director = self
	layer.add_child(screen)
	layer.hide()
func mark(value: String):
	stage = value
	if not events.has(value): events.append(value)
func _process(delta: float):
	if world.menu_open or world.terminal!=null: return
	clock += delta
	world.queue_redraw()
func restore():
	if mounted:
		for actor in [world.player,world.raven]: actor.reparent(world.actors,false)
		mounted = false
	for actor in [world.player,world.raven]:
		actor.modulate = Color.WHITE
		actor.visual.show()
		actor.cast_shadow.show()
		actor.light_occluder.visible = not actor.cloaked
	if is_instance_valid(switch_pose): switch_pose.queue_free()
	if is_instance_valid(layer): layer.hide()
func _mount():
	world.camera.force_update_scroll()
	screen.garage_matrix = get_viewport().get_canvas_transform()
	screen.space.transform = screen.garage_matrix
	for actor in [world.player,world.raven]: actor.reparent(screen.space,false)
	mounted = true
	layer.show()
func _dock():
	view = "hangar"
	for i in 2: [world.player,world.raven][i].position = Art.ARRIVALS[i]
	screen.bike.position += Art.SHIFT
	world.camera.position = Art.HANGAR_CAMERA
	world.camera.zoom = Vector2.ONE*1.2
	world.camera.force_update_scroll()
	# The garage camera is clamped at its right wall. Preserve its real projection
	# at docking, then dolly into the hangar while the shaft wall clears.
	screen.dock_matrix = screen.garage_matrix*Transform2D(0,-Art.SHIFT)
	screen.space.transform = screen.dock_matrix
	ambient.color = Color("afbfc9")
func play(from_garage: bool):
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.discovery_pending = true
	world.autosave()
	world.player.show()
	world.raven.show()
	if from_garage:
		mark("switch")
		await cs.walk(world.player,Art.SWITCH_FEET,72)
		if not cs.alive(ticket): return
		cs.face(world.player,Art.SWITCH_TARGET)
		await cs.camera(Art.SWITCH_FEET+Vector2(10,-36),0.85,1.7)
		if not cs.alive(ticket): return
		world.player.hide()
		switch_pose.show()
		for frame in 4:
			switch_pose.frame = frame
			if frame==2: world.sound("prop_metal")
			await cs.wait(0.22)
			if not cs.alive(ticket): return
		switch_pose.hide()
		world.player.show()
		mark("boarding")
		await cs.say("SHADEPI","Auf die Plattform. Das Motorrad nehmen wir mit.")
		if not cs.alive(ticket): return
		await Motion.walk_pair(cs,[world.player,world.raven],Art.MOUNTS,72)
		if not cs.alive(ticket): return
		cs.pose(world.player,"idle")
		cs.pose(world.raven,"idle")
		await cs.camera(Art.GARAGE_CAMERA,0.85,1.2)
		if not cs.alive(ticket): return
		mark("unlock")
		await cs.animate(func(p: float): deck_frame = mini(5,int(p*6)),1.35)
		if not cs.alive(ticket): return
		world.sound("drive_brake")
		_mount()
		view = "shaft"
		mark("descent")
		await cs.animate(func(p: float): travel = smoothstep(0,1,p),5.0)
		if not cs.alive(ticket): return
		mark("dock")
		_dock()
		world.sound("prop_metal")
		await cs.animate(func(p: float): deck_frame = maxi(0,5-int(p*6)),1.0)
		if not cs.alive(ticket): return
		mark("opening")
		await cs.animate(func(p: float): gate = smoothstep(0,1,p),1.6)
		if not cs.alive(ticket): return
	else:
		world.player.position = Art.ARRIVALS[0]
		world.raven.position = Art.ARRIVALS[1]
		world.camera.position = Art.HANGAR_CAMERA
		world.camera.zoom = Vector2.ONE*1.2
		_mount()
		view = "hangar"
		gate = 1
		screen.bike.position += Art.SHIFT
		ambient.color = Color("afbfc9")
	mark("hall")
	await cs.camera(Vector2(560,380),1.6,0.75)
	if not cs.alive(ticket): return
	mark("aircraft")
	await cs.camera(Art.CRAFT+Vector2(0,3),2.0,1.55)
	if not cs.alive(ticket): return
	await cs.wait(0.6)
	if not cs.alive(ticket): return
	mark("reaction")
	await cs.say("RAVEN","Wow. Beeindruckend.")
	if not cs.alive(ticket): return
	await cs.camera(Vector2(355,445),1.1,1.1)
	if not cs.alive(ticket): return
	mark("exit")
	for leg in EXIT_ROUTE:
		await Motion.walk_pair(cs,[world.player,world.raven],leg,74)
		if not cs.alive(ticket): return
	cs.face(world.player,world.raven.position)
	cs.face(world.raven,world.player.position)
	cs.pose(world.player,"idle")
	cs.pose(world.raven,"idle")
	await cs.camera(Vector2(429,418),0.8,1.5)
	if not cs.alive(ticket): return
	mark("briefing")
	for line in [["SHADEPI","Ich muss schon mal hoch in mein Versteck. Zum Kompensator. Das ist alle sechs Tage nötig."],["SHADEPI","Machst du den Aerodyne wieder gangbar? Und spiel die Kennung von Kenzōs Gleiter auf. Komm danach nach oben."],["RAVEN","Kriege ich hin. Geh ruhig vor. Ich komme, sobald er wieder läuft."]]:
		await cs.say(line[0],line[1])
		if not cs.alive(ticket): return
	mark("shadepi_leaves")
	cs.release(world.player)
	await cs.walk(world.player,Vector2(40,450),90)
	if not cs.alive(ticket): return
	world.player.hide()
	cs.end(func():
		var raven_spot: Vector2 = world.raven.position
		restore()
		world.fresh_entry = false
		world._enter(world.Beat.HANGAR)
		world.raven.position = raven_spot
		world.player.hide()
		world.camera.position = raven_spot+Vector2(0,-52)
		world.camera.force_update_scroll()
		world.discovery_pending = false
		world.autosave()
		world.toast("Aerodyne vorbereiten · E / A")
	)
