extends Node2D
## v0.65.1 · CodexAI. One continuous escape: city → moonlit nomads → two hours later → lake.
const Aerodyne = preload("res://scripts/cinematic_aerodyne.gd")
const DESERT_PATH := "res://assets/story/outbound/desert.png"
const COCKPIT_PATH := "res://assets/story/outbound/cockpit-night.png"
const LIGHT = preload("res://assets/world/light.png")
const FLAME = preload("res://assets/fx/drive/flame.png")
const FIRES := [Vector2(721,691),Vector2(1013,755),Vector2(1332,647)]
const RAVEN_LINE := "Woohoo! Das war geil! Aber verdammt knapp. Wäre beinahe ins Höschen gegangen. Und wo jetzt hin?"
const SHADEPI_LINE := "Wir sollten für ein paar Stunden untertauchen. Ich möchte dir etwas zeigen."
var world: Node2D
var vehicle: Node2D
var background: Texture2D
var cockpit: Texture2D
var presentation := "exterior"
var cockpit_frame := 0
var clock := 0.0
var progress := 0.0
var stage := "city"
var events: Array[String] = []
var craft := Vector2(-100,224)
var entry := 0.0
var crossing := 0.0

func _ready():
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	background=load(DESERT_PATH)
	if not is_instance_valid(vehicle): vehicle=Aerodyne.new(); add_child(vehicle)
	else: vehicle.reparent(self,false)
	vehicle.set_side_view(true)
	_sync()

func paused() -> bool: return world.menu_open or world.terminal!=null
func _process(delta: float):
	if paused(): return
	clock+=delta
	progress=minf(1.0,progress+delta/55.0)
	if presentation=="cockpit":
		var cs=world.cutscene
		cockpit_frame=0 if cs.waiting_input and cs.speaker_label.text=="RAVEN" and int(clock*3)%3==0 else 1
		if cs.speaker_label.text=="SHADEPI": cockpit_frame=2 if cs.waiting_input else 3
	_sync(); queue_redraw()
func mark(value: String):
	stage=value
	if not events.has(value): events.append(value)
func _sync():
	if not is_instance_valid(vehicle): return
	craft=Vector2(lerpf(-100,180,entry)+crossing*320+progress*40,224-crossing*58-progress*20+sin(clock*0.7)*2)
	vehicle.visible=presentation=="exterior"
	vehicle.set_pose(craft,0.75-progress*0.06-crossing*0.12,0,0.75,clock)
func background_rect() -> Rect2:
	return Rect2(-crossing*58-progress*6,-crossing*10-progress*10,704,396)
func enter_cockpit():
	cockpit=load(COCKPIT_PATH)
	presentation="cockpit"
	_sync(); queue_redraw()
func _draw():
	if presentation=="cockpit" and cockpit!=null:
		var cell:=Vector2(cockpit.get_size())/2.0
		draw_texture_rect_region(cockpit,Rect2(0,0,640,360),Rect2(Vector2(cockpit_frame%2,cockpit_frame/2)*cell,cell))
		return
	if background==null: return
	var rect:=background_rect()
	draw_texture_rect(background,rect,false)
	# Fire and reflected warmth stay on the painted campfire cores as the camera travels.
	for i in FIRES.size():
		var p: Vector2=rect.position+FIRES[i]/Vector2(background.get_size())*rect.size
		var flicker:=0.85+0.15*sin(clock*8.0+i*2.0)
		draw_texture_rect(LIGHT,Rect2(p-Vector2(9,7),Vector2(18,14)),false,Color(1,0.46,0.14,0.18*flicker))
		var frame: int=posmod(int(clock*11+i),6)
		draw_texture_rect_region(FLAME,Rect2(p-Vector2(2,5),Vector2(4,6)),Rect2(frame*96,0,96,144),Color(1,0.86,0.75,0.55))

func play(cs, ticket: int):
	mark("city")
	await cs.fade(Color.BLACK,0.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0,0,0,0),0.65)
	if not cs.alive(ticket): return
	world.sound("drive_engine_restart")
	await cs.animate(func(p: float): entry=smoothstep(0,1,p); _sync(),3.2)
	if not cs.alive(ticket): return
	mark("nomads")
	await cs.animate(func(p: float): crossing=smoothstep(0,1,p); _sync(),4.0)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.25)
	if not cs.alive(ticket): return
	enter_cockpit()
	mark("conversation")
	await cs.fade(Color(0,0,0,0),0.35)
	if not cs.alive(ticket): return
	await cs.say("RAVEN",RAVEN_LINE)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI",SHADEPI_LINE)
	if not cs.alive(ticket): return
	await cs.wait(0.8)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.9)
	if not cs.alive(ticket): return
	mark("two_hours_later")
	await cs.title("ZWEI STUNDEN SPÄTER","Abseits der Stadt",2.4)
