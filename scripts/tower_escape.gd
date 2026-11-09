extends Node2D
## v0.35.1 · CodexAI: launch from the actual roof pad, fall past the balcony below.
const Motion = preload("res://scripts/cinematic_motion.gd")
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const Flight = preload("res://scripts/aerodyne_flight.gd")
const ROOF = preload("res://assets/world/painted/rooftop.png")
const EXTERIOR = preload("res://assets/story/tower/exterior.png")
const FX = preload("res://assets/memories/attack/props-fx.png")
const PARK := Flight.PAD_WORLD-Vector2(0,20)
const ROOF_SCALE := 0.625
const ROOF_OFFSET := Vector2(0,-45)
const STARTS: Array[Vector2] = [Vector2(810,350),Vector2(838,368)]
const ROOF_ROUTE: Array = [[Vector2(640,400),Vector2(668,418)],[Vector2(430,410),Vector2(458,428)]]
const ROOF_RELEASE := Vector2(428,450)
const ROOF_EDGE_EXIT := Vector2(465,530)
# Screen-space descent beside the lower balcony. No craft ever parks there.
const FLIGHT: Array = [
	[Vector2(410,-55),Vector2(412,90),Vector2(6.25,112.5),Vector2(2,190),0.9],
	[Vector2(412,90),Vector2(414,208),Vector2(2,190),Vector2(4,240),0.55],
	[Vector2(414,208),Vector2(492,212),Vector2(4,240),Vector2(145,-60),0.95],
	[Vector2(492,212),Vector2(740,125),Vector2(145,-60),Vector2(210,-75),1.4],
]
var world: Node2D
var deck: Node2D
var vehicle: Node2D
var heroes: Array[PixelActor] = []
var stage := "run"
var view := "roof"
var park := PARK
var craft := PARK
var tilt := 0.0
var grow := 0.90
var engine := false
var power := 0.0
var blast := 0.0
var clock := 0.0
var roof_contact := 1.0
var left_roof := false
var events: Array[String] = []

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	deck = Node2D.new()
	deck.scale = Vector2.ONE*ROOF_SCALE
	deck.position = ROOF_OFFSET
	add_child(deck)
	# The previous playable landing owns the actual parked location.
	park = world.aerodyne_spot-Vector2(0,20)
	craft = park
	vehicle = Aerodyne.new()
	deck.add_child(vehicle)
	for i in 2:
		var actor := PixelActor.new()
		actor.setup(load("res://assets/sprites/heroes/"+("shadepi" if i==0 else "raven")+".png"),world)
		actor.position = STARTS[i]
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

func roof_route() -> Array:
	var route := ROOF_ROUTE.duplicate(true)
	route.append([park+Vector2(30,82),park+Vector2(56,96)])
	return route

func roof_step(p: float, failing: bool = false) -> void:
	if failing:
		craft = Motion.hermite(ROOF_RELEASE,ROOF_EDGE_EXIT,Vector2(100,120),Vector2(10,180),0.6,p)
		tilt = lerpf(2.35,2.9,smoothstep(0,1,p))
		power = 0.85*(1-smoothstep(0,0.6,p))
		grow = 0.88
	else:
		craft = Motion.hermite(park,ROOF_RELEASE,Vector2.ZERO,Vector2(100,120),2.2,p)
		# Lift visibly clear of the pad before moving toward its front edge.
		# The squared arc has zero endpoint slope, preserving both phase joins.
		craft.y -= pow(sin(p*PI),2)*70
		tilt = lerpf(0,2.35,smoothstep(0,1,p))
		power = smoothstep(0,0.25,p)*0.85
		grow = lerpf(0.90,0.88,p)
		roof_contact = 1-smoothstep(0,0.55,p)
	_sync_vehicle()
	queue_redraw()

func follow_to_facade() -> void:
	# A motivated view change: they have already crossed the roof's front edge.
	left_roof = craft.y>495
	view = "facade"
	deck.scale = Vector2.ONE
	deck.position = Vector2.ZERO
	craft = FLIGHT[0][0]
	grow = 0.55
	tilt = 2.9
	power = 0
	_sync_vehicle()
	queue_redraw()

func flight_step(segment: int, p: float) -> void:
	var path: Array = FLIGHT[segment]
	craft = Motion.hermite(path[0],path[1],path[2],path[3],path[4],p)
	var rolls := [Vector2(2.9,3.03),Vector2(3.03,3.03),Vector2(3.03,1.15),Vector2(1.15,1.12)]
	var sizes := [Vector2(0.55,0.54),Vector2(0.54,0.53),Vector2(0.53,0.51),Vector2(0.51,0.44)]
	var blend := smoothstep(0,1,p)
	tilt = lerpf(rolls[segment].x,rolls[segment].y,blend)
	grow = lerpf(sizes[segment].x,sizes[segment].y,blend)
	if segment==2: power = smoothstep(0,0.65,p)
	if segment==3: blast = p
	_sync_vehicle()
	queue_redraw()

func _draw() -> void:
	if view=="roof":
		draw_set_transform(ROOF_OFFSET,0,Vector2.ONE*ROOF_SCALE)
		draw_texture_rect(ROOF,Rect2(0,0,1024,640),false)
		draw_set_transform(ROOF_OFFSET+(park+Vector2(0,20))*ROOF_SCALE,0,Vector2(1,0.25))
		draw_circle(Vector2.ZERO,42,Color(0,0,0,0.32*roof_contact))
		draw_set_transform(Vector2.ZERO)
		return
	draw_texture_rect(EXTERIOR,Rect2(0,0,640,640.0*EXTERIOR.get_height()/EXTERIOR.get_width()),false)
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
		actor.position = start.lerp(park+Vector2(13,13),p)+Vector2(0,-sin(p*PI)*8)
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
	for targets in roof_route():
		await Motion.walk_pair(cs,heroes,targets,125)
		if not cs.alive(ticket): return
	set_stage("board")
	world.sound("prop_metal")
	await _board(cs,1)
	if not cs.alive(ticket): return
	await _board(cs,0)
	if not cs.alive(ticket): return
	for actor in heroes: actor.hide()
	await cs.say("SHADEPI","Halt dich fest. Wir starten.")
	if not cs.alive(ticket): return
	set_stage("launch")
	engine = true
	world.sound("drive_engine_restart")
	await cs.animate(func(p: float): roof_step(p),2.2)
	if not cs.alive(ticket): return
	world.sound("drive_engine_fail")
	engine = false
	cs.speaker_label.text = "ARTOS"
	cs.line_label.text = "Schubverlust! Haupttriebwerk ausgefallen!"
	set_stage("tip")
	await cs.animate(func(p: float): roof_step(p,true),0.6)
	if not cs.alive(ticket): return
	follow_to_facade()
	set_stage("fall")
	cs.speaker_label.text = "RAVEN"
	cs.line_label.text = "Shadepi …!"
	for segment in 2:
		await cs.animate(func(p: float): flight_step(segment,p),FLIGHT[segment][4])
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
