extends Node2D
## v0.35.0 · CodexAI: walk through the clear aisle, board, restart, depart.
const HANGAR = preload("res://assets/story/departure/hangar-empty.png")
const COCKPIT = preload("res://assets/story/departure/cockpit.png")
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const Motion = preload("res://scripts/cinematic_motion.gd")
const HEROES = [preload("res://assets/sprites/heroes/shadepi.png"), preload("res://assets/sprites/heroes/raven.png")]
const SMOKE = preload("res://assets/memories/attack/props-fx.png")
const STARTS: Array[Vector2] = [Vector2(232,514),Vector2(266,526)]
const ROUTE: Array = [
	[Vector2(444,516),Vector2(478,526)],
	[Vector2(758,516),Vector2(792,526)],
	[Vector2(810,392),Vector2(845,396)],
]
var world: Node2D
var stage := "boarding"
var events: Array[String] = []
var cockpit_frame := 0
var craft := Vector2(884, 306)
var lift := 0.0
var clock := 0.0
var squad: Array[PixelActor] = []
var engines := false
var power := 0.0
var vehicle: Node2D
var scene_atmosphere: Node2D

func _ready() -> void:
	scale = Vector2.ONE * 0.625
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for i in 2:
		var actor := PixelActor.new()
		add_child(actor)
		actor.setup(HEROES[i], world)
		actor.collision_layer = 0
		actor.collision_mask = 0
		actor.position = STARTS[i]
		actor.z_index = 2
		squad.append(actor)
	vehicle = Aerodyne.new()
	add_child(vehicle)
	_sync_vehicle()
	scene_atmosphere = preload("res://scripts/scene_atmosphere.gd").new()
	scene_atmosphere.world = world
	scene_atmosphere.profile_override = "hangar"
	add_child(scene_atmosphere)
	scene_atmosphere.set_quality(world.visual_quality)

func set_stage(value: String) -> void:
	stage = value
	# Keep the lower aisle inside the letterbox while they cross the room.
	position.y = -62 if value=="boarding" else 0
	if not events.has(value): events.append(value)
	if scene_atmosphere != null: scene_atmosphere.visible = value in ["boarding","takeoff"]
	for actor in squad: actor.visible = value == "boarding"
	_sync_vehicle()
	queue_redraw()

func _process(delta: float) -> void:
	if world == null or world.menu_open or world.terminal != null: return
	clock += delta
	_sync_vehicle()
	queue_redraw()

func _sync_vehicle() -> void:
	if vehicle == null: return
	vehicle.visible = stage in ["boarding","takeoff"]
	vehicle.set_pose(craft,0.90-lift*0.18,0,power,clock)

func takeoff_step(k: float) -> void:
	lift = k
	craft = Vector2(884, 306).lerp(Vector2(865, -105), k * k)
	power = lerpf(0.8,1.0,k)
	_sync_vehicle()
	queue_redraw()

func _draw() -> void:
	if stage in ["cockpit", "failure", "knock", "restart"]:
		var cell := Vector2(COCKPIT.get_size()) / 2.0
		var wobble := Vector2(sin(clock * 23) * 2, cos(clock * 19)) if stage == "failure" else Vector2.ZERO
		draw_texture_rect_region(COCKPIT, Rect2(wobble, Vector2(1024, 576)), Rect2(Vector2(cockpit_frame % 2, cockpit_frame / 2) * cell, cell))
		return
	draw_texture_rect(HANGAR, Rect2(0, 0, 1024, 640), false)
	preload("res://scripts/painted_world.gd").draw_hangar_brand(self)
	draw_set_transform(Vector2(884, 340), 0, Vector2(1, 0.35))
	draw_circle(Vector2.ZERO, 70 * (1 - lift * 0.5), Color(0, 0, 0, 0.4 * (1 - lift)))
	draw_set_transform(Vector2.ZERO)
	if engines:
		var cell := Vector2(SMOKE.get_size()) / Vector2(4, 4)
		for i in 4:
			var frame := Rect2(Vector2((int(clock * 6) + i) % 4, 2) * cell, cell)
			draw_texture_rect_region(SMOKE, Rect2(Vector2(820 + i * 30, 310 - fmod(clock * 18 + i * 7, 25)), Vector2(52, 65)), frame, Color(0.8, 0.7, 0.6, 0.3 * (1 - lift)))

func play() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.drive.hide()
	world.flight_intro_pending = true
	world.autosave()
	set_stage("boarding")
	cs.pose(squad[0], "idle")
	cs.pose(squad[1], "idle")
	await cs.fade(Color.BLACK, 0)
	if not cs.alive(ticket): return
	# v0.47.0 · ClaudeHelper: der geplante Dienstagabend, nicht dieselbe Nacht.
	await cs.title("KAPITEL 6 · DIE RACHE", "Am nächsten Abend · Zurück im Hangar", 2.0)
	if not cs.alive(ticket): return
	await cs.fade(Color.TRANSPARENT, 0.7)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Da steht er. Ich habe ihn den ganzen Tag geprüft. Kenzōs Angestellte haben den Tower vor einer Stunde verlassen.")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Ich kann mich nicht mit irgendjemandem verbinden, Raven. Das Heiligtum hat dich hineingelassen. Du wurdest mir prophezeit.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Prophezeit? … Erklär mir das, wenn wir lebend zurück sind.")
	if not cs.alive(ticket): return
	for targets in ROUTE:
		await Motion.walk_pair(cs,squad,targets,90)
		if not cs.alive(ticket): return
	cs.face(squad[0],craft)
	cs.face(squad[1],craft)
	await cs.wait(0.35)
	if not cs.alive(ticket): return
	world.sound("prop_metal")
	await cs.animate(vehicle.set_door,0.6)
	if not cs.alive(ticket): return
	await _board(cs,squad[1],Vector2(878,339))
	if not cs.alive(ticket): return
	await _board(cs,squad[0],Vector2(857,344))
	if not cs.alive(ticket): return
	await cs.animate(func(p: float): vehicle.set_door(1-p),0.6)
	if not cs.alive(ticket): return
	await cs.wait(0.25)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.25)
	if not cs.alive(ticket): return
	cs.do(func():
		set_stage("cockpit")
		world.sound("prop_metal")
	)
	await cs.fade(Color.TRANSPARENT, 0.35)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Luke zu. Ich starte ihn.")
	if not cs.alive(ticket): return
	cs.do(func():
		cockpit_frame = 1
		set_stage("failure")
		world.sound("drive_engine_fail")
	)
	await cs.say("ARTOS", "A-a-artos-System … b-bootet … Antrieb nicht bereit.")
	if not cs.alive(ticket): return
	await cs.wait(1.0)
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Das hat er beim Test nicht gemacht.")
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Dreckmühle.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Dann habt ihr ja was gemeinsam.")
	if not cs.alive(ticket): return
	cs.do(func():
		cockpit_frame = 2
		set_stage("knock")
		world.sound("drive_knock")
	)
	await cs.wait(0.7)
	if not cs.alive(ticket): return
	cs.do(func():
		cockpit_frame = 3
		engines = true
		set_stage("restart")
		world.sound("drive_engine_restart")
	)
	await cs.animate(func(p: float): power = smoothstep(0,1,p)*0.8,1.1)
	if not cs.alive(ticket): return
	await cs.say("ARTOS", "Schub verfügbar. Hangarschleuse freigegeben.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Ich mag lieber Motorräder.")
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.25)
	if not cs.alive(ticket): return
	cs.do(func(): set_stage("takeoff"))
	await cs.fade(Color.TRANSPARENT, 0.35)
	if not cs.alive(ticket): return
	await cs.animate(takeoff_step, 4.6)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK, 0.4)
	if not cs.alive(ticket): return
	cs.do(func():
		set_stage("outside")
		hide()
		world.drive.show()
	)
	await cs.fade(Color.TRANSPARENT, 0.8)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI", "Wir sind draußen. Raven, am Tower-Scanner kalibrierst du die kopierte Kennung.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN", "Sequenz für Sequenz. Bring uns einfach heil hin.")
	if not cs.alive(ticket): return
	cs.end(func():
		world.flight_intro_pending = false
		world.departure = null
		world.autosave()
		queue_free()
	)

func _board(cs, actor: PixelActor, port: Vector2) -> void:
	var start := actor.position
	await cs.animate(func(p: float):
		actor.facing = (port-start).normalized()
		actor.position = start.lerp(port,p)+Vector2(0,-sin(p*PI)*8)
		if not world.menu_open and world.terminal==null:
			actor.animate("walk",actor.get_process_delta_time())
		actor.modulate.a = 1-smoothstep(0.55,0.95,p)
	,0.9)
