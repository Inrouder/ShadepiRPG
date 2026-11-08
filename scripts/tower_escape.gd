extends Node2D
## v0.33.0 · CodexAI: visible run, boarding, drop, ignition and penthouse blast.
const Flight = preload("res://scripts/aerodyne_flight.gd")
const EXTERIOR = preload("res://assets/story/tower/exterior.png")
const FX = preload("res://assets/memories/attack/props-fx.png")
var world: Node2D
var deck: Node2D
var heroes: Array[PixelActor] = []
var stage := "run"
var craft := Vector2(300,155)
var tilt := 0.0
var engine := false
var blast := 0.0
var clock := 0.0
var events: Array[String] = []

class Deck:
	extends Node2D
	var boarded := false
	func _draw() -> void:
		draw_texture_rect(preload("res://assets/world/painted/rooftop.png"),Rect2(0,0,1024,640),false)
		Flight.draw_aerodyne_3q(self,Flight.PAD_WORLD+Vector2(0,-20),0.9,0,false,0)

func _ready() -> void:
	deck = Deck.new()
	deck.scale = Vector2.ONE*0.625
	add_child(deck)
	for i in 2:
		var actor := PixelActor.new()
		actor.setup(load("res://assets/sprites/heroes/"+("shadepi" if i==0 else "raven")+".png"),world)
		actor.position = Vector2(800+i*28,395+i*18)
		actor.collision_layer = 0
		actor.collision_mask = 0
		deck.add_child(actor)
		heroes.append(actor)

func set_stage(value: String) -> void:
	stage = value
	if not events.has(value): events.append(value)
	deck.visible = value in ["run","board"]
	queue_redraw()

func _process(delta: float) -> void:
	if world.menu_open or world.terminal!=null: return
	clock += delta
	queue_redraw()

func _draw() -> void:
	if stage in ["run","board"]: return
	draw_texture_rect(EXTERIOR,Rect2(0,0,640,640.0*EXTERIOR.get_height()/EXTERIOR.get_width()),false)
	if blast>0:
		var cell := Vector2(FX.get_size())/4
		for i in 7:
			var p := Vector2(70+i*30,105+sin(i*2.1)*23)
			var size := Vector2(160,125)*(0.45+blast*0.9)
			var frame := int(clock*9+i)%4
			draw_texture_rect_region(FX,Rect2(p-size*0.5,size),Rect2(Vector2(frame,3)*cell,cell),Color(1,0.85,0.7,minf(1,blast*2)))
	Flight.draw_aerodyne_3q(self,craft,0.6,tilt,false,clock if engine else 0)
	if engine:
		var cell := Vector2(FX.get_size())/4
		for side in [-1,1]:
			var plume := craft+Vector2(side*13,29).rotated(tilt)
			draw_texture_rect_region(FX,Rect2(plume-Vector2(11,0),Vector2(22,50)),Rect2(Vector2(int(clock*12)%4,1)*cell,cell),Color(0.6,0.9,1,0.9))

func run() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	set_stage("run")
	await cs.say("RAVEN","Zum Aerodyne! Jetzt!")
	if not cs.alive(ticket): return
	var starts := [heroes[0].position,heroes[1].position]
	await cs.animate(func(p: float):
		for i in 2:
			heroes[i].position = starts[i].lerp(Flight.PAD_WORLD+Vector2(48+i*15,22+i*9),p)
			heroes[i].facing = Vector2.LEFT
			heroes[i].animate("walk",1.0/60)
	,2.6)
	if not cs.alive(ticket): return
	set_stage("board")
	await cs.animate(func(p: float):
		for i in 2:
			heroes[i].position = (Flight.PAD_WORLD+Vector2(48+i*15,22+i*9)).lerp(Flight.PAD_WORLD+Vector2(7,0),p)
			heroes[i].visible = p<(0.55+i*0.35)
	,0.7)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.2)
	if not cs.alive(ticket): return
	set_stage("tip")
	await cs.fade(Color.TRANSPARENT,0.25)
	if not cs.alive(ticket): return
	await cs.say("ARTOS","Haupttriebwerk … keine Zündung.")
	if not cs.alive(ticket): return
	world.sound("drive_engine_fail")
	await cs.animate(func(p: float):
		craft = Vector2(300,155).lerp(Vector2(355,195),p)
		tilt = p*0.55
	,1.1)
	if not cs.alive(ticket): return
	set_stage("fall")
	cs.speaker_label.text = "RAVEN"
	cs.line_label.text = "Shadepi …!"
	await cs.animate(func(p: float):
		craft = Vector2(355,195).lerp(Vector2(415,228),p*p)
		tilt = lerpf(0.55,0.9,p)
	,0.65)
	if not cs.alive(ticket): return
	cs.speaker_label.text = "SHADEPI"
	cs.line_label.text = "Halt dich fest!"
	set_stage("ignition")
	engine = true
	world.sound("drive_boost")
	await cs.animate(func(p: float): tilt = lerpf(0.9,0.1,p),0.45)
	if not cs.alive(ticket): return
	set_stage("blast")
	world.sound("drive_explosion")
	world.shake = 14
	cs.flash(Color(1,0.8,0.5,0.65),0.3)
	await cs.animate(func(p: float):
		blast = minf(1,p*3)
		craft = Vector2(415,228).lerp(Vector2(700,100),p)
		tilt = lerpf(0.1,-0.3,p)
	,1.8)
	if not cs.alive(ticket): return
	set_stage("clear")
	await cs.wait(0.8)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.65)
	if not cs.alive(ticket): return
	cs.end(func(): world._advance())
