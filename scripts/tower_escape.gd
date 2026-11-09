extends Node2D
## v0.35.0 · CodexAI: one exterior shot, continuous flight velocity and fixed nozzles.
const Motion = preload("res://scripts/cinematic_motion.gd")
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const EXTERIOR = preload("res://assets/story/tower/exterior.png")
const FX = preload("res://assets/memories/attack/props-fx.png")
const PARK := Vector2(198,182)
const STARTS: Array[Vector2] = [Vector2(44,221),Vector2(64,237)]
const ROUTE: Array = [[Vector2(111,236),Vector2(132,246)],[Vector2(188,238),Vector2(216,241)]]
# Shared endpoint velocities (screen pixels/sec) keep phase joins free of stops.
const FLIGHT: Array = [
	[Vector2(198,182),Vector2(278,193),Vector2.ZERO,Vector2(52,18),2.2],
	[Vector2(278,193),Vector2(354,230),Vector2(52,18),Vector2(92,55),1.0],
	[Vector2(354,230),Vector2(430,209),Vector2(92,55),Vector2(125,-54),1.0],
	[Vector2(430,209),Vector2(730,83),Vector2(125,-54),Vector2(205,-75),1.9],
]
var world: Node2D
var deck: Node2D
var vehicle: Node2D
var heroes: Array[PixelActor] = []
var stage := "run"
var craft := PARK
var tilt := 0.0
var grow := 0.62
var engine := false
var power := 0.0
var blast := 0.0
var clock := 0.0
var events: Array[String] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	deck = Node2D.new()
	add_child(deck)
	vehicle = Aerodyne.new()
	deck.add_child(vehicle)
	for i in 2:
		var actor := PixelActor.new()
		actor.setup(load("res://assets/sprites/heroes/"+("shadepi" if i==0 else "raven")+".png"),world)
		actor.position = STARTS[i]
		actor.scale = Vector2.ONE*0.625
		actor.collision_layer = 0
		actor.collision_mask = 0
		actor.z_index = 2
		deck.add_child(actor)
		heroes.append(actor)
	_sync_vehicle()

func set_stage(value: String) -> void:
	stage = value
	if not events.has(value): events.append(value)
	queue_redraw()

func _process(delta: float) -> void:
	if world.menu_open or world.terminal!=null: return
	clock += delta
	_sync_vehicle()
	queue_redraw()

func _sync_vehicle() -> void:
	vehicle.set_pose(craft,grow,tilt,power,clock)

func flight_step(segment: int, p: float) -> void:
	var path: Array = FLIGHT[segment]
	craft = Motion.hermite(path[0],path[1],path[2],path[3],path[4],p)
	# Nose first over the edge, then align thrust opposite the escape direction.
	var rolls := [Vector2(0,1.30),Vector2(1.30,2.05),Vector2(2.05,1.10),Vector2(1.10,1.12)]
	var sizes := [Vector2(0.62,0.60),Vector2(0.60,0.58),Vector2(0.58,0.56),Vector2(0.56,0.46)]
	var blend := smoothstep(0,1,p)
	tilt = lerpf(rolls[segment].x,rolls[segment].y,blend)
	grow = lerpf(sizes[segment].x,sizes[segment].y,blend)
	if segment==2: power = smoothstep(0,0.65,p)
	if segment==3: blast = p
	_sync_vehicle()
	queue_redraw()

func _draw() -> void:
	# This image, framing, deck and hull persist from running to departure.
	draw_texture_rect(EXTERIOR,Rect2(0,0,640,640.0*EXTERIOR.get_height()/EXTERIOR.get_width()),false)
	if stage in ["run","board","tip"]:
		var contact := 1.0 if stage!="tip" else clampf(1-(craft.x-PARK.x)/65,0,1)
		draw_set_transform(craft+Vector2(0,33),0,Vector2(1,0.25))
		draw_circle(Vector2.ZERO,42,Color(0,0,0,0.32*contact))
		draw_set_transform(Vector2.ZERO)
	if blast>0:
		var cell := Vector2(FX.get_size())/4
		# One advancing detonation at the actual windows, never looping fireballs.
		for i in 3:
			var t := clampf(blast*3.1-i*0.18,0,3.0)
			var frame := mini(2,int(t))
			var blend := smoothstep(0,1,t-frame)
			var p: Vector2 = [Vector2(114,137),Vector2(192,125),Vector2(53,158)][i]
			var extent := Vector2(150,120)*(0.65+minf(t,1.5)*0.28)
			for step in 2:
				var alpha := (blend if step==1 else 1.0-blend)*minf(blast*12,1)
				draw_texture_rect_region(FX,Rect2(p-extent*0.5,extent),Rect2(Vector2(frame+step,3)*cell,cell),Color(1,0.9,0.8,alpha))

func _board(cs, index: int) -> void:
	var actor := heroes[index]
	var start := actor.position
	await cs.animate(func(p: float):
		actor.facing = Vector2(0,-1)
		actor.position = start.lerp(Vector2(211,195),p)+Vector2(0,-sin(p*PI)*5)
		if not world.menu_open and world.terminal==null:
			actor.animate("walk",actor.get_process_delta_time())
		actor.modulate.a = 1-smoothstep(0.50,0.95,p)
	,0.8)

func run() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	set_stage("run")
	await cs.say("RAVEN","Zum Aerodyne! Jetzt!")
	if not cs.alive(ticket): return
	for targets in ROUTE:
		await Motion.walk_pair(cs,heroes,targets,76)
		if not cs.alive(ticket): return
	set_stage("board")
	world.sound("prop_metal")
	await _board(cs,1)
	if not cs.alive(ticket): return
	await _board(cs,0)
	if not cs.alive(ticket): return
	for actor in heroes: actor.hide()
	await cs.say("SHADEPI","Halt dich fest.")
	if not cs.alive(ticket): return
	await cs.say("ARTOS","Haupttriebwerk … keine Zündung.")
	if not cs.alive(ticket): return
	world.sound("drive_engine_fail")
	set_stage("tip")
	await cs.animate(func(p: float): flight_step(0,p),FLIGHT[0][4])
	if not cs.alive(ticket): return
	set_stage("fall")
	cs.speaker_label.text = "RAVEN"
	cs.line_label.text = "Shadepi …!"
	await cs.animate(func(p: float): flight_step(1,p),FLIGHT[1][4])
	if not cs.alive(ticket): return
	set_stage("ignition")
	engine = true
	world.sound("drive_boost")
	cs.speaker_label.text = "SHADEPI"
	cs.line_label.text = "Komm schon … Ja!"
	await cs.animate(func(p: float): flight_step(2,p),FLIGHT[2][4])
	if not cs.alive(ticket): return
	set_stage("blast")
	world.sound("drive_explosion")
	world.shake = 10
	cs.flash(Color(1,0.8,0.5,0.35),0.25)
	await cs.animate(func(p: float): flight_step(3,p),FLIGHT[3][4])
	if not cs.alive(ticket): return
	set_stage("clear")
	await cs.wait(0.6)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.65)
	if not cs.alive(ticket): return
	cs.end(func(): world._advance())
