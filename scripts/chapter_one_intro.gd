extends Node2D
## v0.43.0 · CodexAI. Registered contact poses; cancellable Chapter-1 film beats.
const ART = preload("res://assets/story/chapter-one/poses.png")
const ROOF = preload("res://assets/world/painted/rooftop.png")
const UISkin = preload("res://scripts/ui_skin.gd")
const FX = preload("res://scripts/effects.gd")
const SCALE := 0.149
const REGIONS: Array[Rect2] = [Rect2(0,0,443,443),Rect2(443,0,444,443),Rect2(887,0,443,443),Rect2(1330,0,444,443),Rect2(0,443,443,444),Rect2(443,443,444,444),Rect2(887,443,443,444),Rect2(1330,443,444,444)]
const FEET: Array[Vector2] = [Vector2(244,428),Vector2(245,428),Vector2(246,428),Vector2(242,427),Vector2(253,406),Vector2(254,406),Vector2(252,413),Vector2(258,408)]
const HAND := Vector2(100,145)
var world: Node2D
var pose_sprite: Sprite2D
var layer: CanvasLayer
var screen: Node2D
var roof_pose: Sprite2D
var roof_fx: Node2D
var panel: PanelContainer
var text: Label
var hidden_actor: PixelActor
var actor_was_visible := false
var stage := "idle"
var events: Array[String] = []
var fall_height := 0.0

func _ready():
	pose_sprite = Sprite2D.new()
	pose_sprite.centered = false
	pose_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	pose_sprite.hide()
	add_child(pose_sprite)
	layer = CanvasLayer.new()
	layer.layer = 8
	add_child(layer)
	screen = Node2D.new()
	layer.add_child(screen)
	var sky := Sprite2D.new()
	sky.texture = ROOF
	sky.centered = false
	sky.scale = Vector2.ONE*0.75
	screen.add_child(sky)
	roof_pose = Sprite2D.new()
	roof_pose.centered = false
	roof_pose.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	screen.add_child(roof_pose)
	roof_fx = FX.new()
	roof_fx.world = world
	roof_fx.animate_while_busy = true
	roof_fx.ambient_steam_enabled = false
	roof_fx.steam_vents.clear()
	screen.add_child(roof_fx)
	screen.hide()
	panel = PanelContainer.new()
	panel.position = Vector2(350,48)
	panel.custom_minimum_size = Vector2(260,112)
	panel.add_theme_stylebox_override("panel",UISkin.panel("raven"))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	text = Label.new()
	text.add_theme_font_override("font",UISkin.font())
	text.add_theme_font_size_override("font_size",20)
	text.add_theme_constant_override("line_spacing",-5)
	text.add_theme_color_override("font_color",Color("a6e6ec"))
	panel.add_child(text)
	panel.hide()
	world.cutscene.ended.connect(clear)

func mark(value: String):
	stage = value
	events.append(value)

func _art(sprite: Sprite2D, frame: int, origin: Vector2, scale_value: float):
	var atlas := AtlasTexture.new()
	atlas.atlas = ART
	atlas.region = REGIONS[frame]
	atlas.filter_clip = true
	sprite.texture = atlas
	sprite.scale = Vector2.ONE*scale_value
	sprite.position = origin-FEET[frame]*scale_value

func show_pose(actor: PixelActor, frame: int, height: float = 0.0):
	if hidden_actor != actor:
		restore_actor()
		hidden_actor = actor
		actor_was_visible = actor.visible
	actor.hide() # Body, normal cast/contact shadows and occluder all disappear together.
	fall_height = height
	_art(pose_sprite,frame,actor.position-Vector2(0,height),SCALE)
	pose_sprite.z_index = roundi(actor.position.y)
	pose_sprite.show()

func restore_actor():
	if is_instance_valid(hidden_actor):
		hidden_actor.visible = actor_was_visible
		hidden_actor.reset_visual_pose()
	hidden_actor = null
	if is_instance_valid(pose_sprite): pose_sprite.hide()
	fall_height = 0

func clear():
	restore_actor()
	if is_instance_valid(screen): screen.hide()
	if is_instance_valid(panel): panel.hide()
	if is_instance_valid(roof_fx): roof_fx.set_process(false)
	stage = "idle"

func _process(_delta: float):
	if not world.cutscene.running and stage != "idle": clear()

func observe(cs, threatened: bool):
	var ticket: int = cs.generation
	mark("roof-alert" if threatened else "roof-watch")
	panel.hide()
	screen.show()
	roof_fx.quality = world.effects.quality
	roof_fx.set_process(true)
	_art(roof_pose,4,Vector2(412,273),SCALE*1.8)
	await cs.fade(Color(0,0,0,0),0.4)
	if not cs.alive(ticket): return
	await cs.wait(0.8)
	if not cs.alive(ticket): return
	_art(roof_pose,5,Vector2(412,273),SCALE*1.8)
	# v0.47.0 · ClaudeHelper: Shadepis Motiv und sein Eingreifen nach dem Roman.
	if threatened:
		await cs.say("SHADEPI","Zwei Wärmesignaturen. Eine glüht vor Gier, die andere flackert wie eine Kerze im Sturm. Sie bewegt sich nicht mehr.")
		if not cs.alive(ticket): return
		await cs.say("SHADEPI","Das reicht. Tarnung – über die Wartungsgasse komme ich durch.")
	else:
		await cs.say("SHADEPI","Fünf Jahre seit dem Feuer im Kloster. Fünf Jahre, und noch immer keine Spur.")
		if not cs.alive(ticket): return
		await cs.say("SHADEPI","Wieder dieselbe Kameraschleife. Kleine Verbrechen führen zu großen Monstern. Was versteckt ihr da unten?")
	if not cs.alive(ticket): return
	await cs.wait(0.45)
	if not cs.alive(ticket): return
	screen.hide()
	roof_fx.set_process(false)

func play_apartment():
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	events.clear()
	mark("wake")
	world.raven.position = world.apartment_point(Vector2(760,360))
	world.raven.facing = Vector2.LEFT
	cs.pose(world.raven,"idle")
	await cs.camera(world.APARTMENT_CAMERA,0,world.APARTMENT_ZOOM)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0,0,0,0),1.0)
	if not cs.alive(ticket): return
	await cs.title("KAPITEL 1","Echos in Neon und Schatten",2.0)
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Na schön. Mal sehen, was heute reinkommt.")
	if not cs.alive(ticket): return
	world.sound("hack")
	var monitor: Vector2 = world.apartment_point(Vector2(160,240))
	var feet := monitor-(HAND-FEET[0])*SCALE
	await cs.walk(world.raven,feet,72)
	if not cs.alive(ticket): return
	world.raven.facing = Vector2.LEFT
	await cs.camera(Vector2(world.APARTMENT_RECT.position.x+320.0/1.85,feet.y-33),0.75,1.85)
	if not cs.alive(ticket): return
	mark("offer")
	show_pose(world.raven,0)
	panel.show()
	text.text = "KOPFGELDNETZ / EINGANG\n\nCHROME JACKAL\nBingo Street · Wartungshof\nPrämie erhöht / Auftrag offen"
	await cs.say("RAVEN","Chrome Jackal. Die Prämie ist schon wieder gestiegen.")
	if not cs.alive(ticket): return
	mark("accept")
	show_pose(world.raven,1)
	world.sound("hack")
	text.text = "KOPFGELDNETZ / BESTÄTIGT\n\nCHROME JACKAL\nAuftrag übernommen · Raven Black\nLetzter Ping gesichert"
	await cs.wait(0.65)
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Die Kameras zeigen eine Schleife. Ich nehme den Weg darunter.")
	if not cs.alive(ticket): return
	panel.hide()
	restore_actor()
	await cs.walk(world.raven,world.apartment_point(Vector2(350,332)),68)
	if not cs.alive(ticket): return
	mark("weapon-check")
	show_pose(world.raven,2)
	world.sound("prop_metal")
	await cs.wait(0.8)
	if not cs.alive(ticket): return
	mark("holster")
	show_pose(world.raven,3)
	await cs.wait(0.55)
	if not cs.alive(ticket): return
	restore_actor()
	await cs.walk(world.raven,world.APARTMENT_EXIT,74)
	if not cs.alive(ticket): return
	await cs.fade(Color.BLACK,0.45)
	if not cs.alive(ticket): return
	# v0.60.0 · ClaudeHelper: Raven tritt aus der Hintertür in die Gasse; die Straße folgt danach.
	mark("backalley")
	world.enter_backalley()
	await cs.camera(world.backalley.point(Vector2(320,180)),0,1.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0,0,0,0),0.6)
	if not cs.alive(ticket): return
	await cs.walk(world.raven,world.backalley.point(Vector2(150,296)),70)
	if not cs.alive(ticket): return
	cs.face(world.raven,world.backalley.point(Vector2(300,150)))
	cs.pose(world.raven,"idle")
	await cs.say("RAVEN","Der Drache ist neu. »Where are you?« … Irgendwer in dieser Stadt sucht jemanden.")
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Viel Glück damit. Hier findet man höchstens Ärger.")
	if not cs.alive(ticket): return
	cs.end()

## Von der Gasse auf die Bingo Street: Shadepi beobachtet vom Dach, dann beginnt die Jagd.
func play_street():
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	await cs.fade(Color.BLACK,0.4)
	if not cs.alive(ticket): return
	await observe(cs,false)
	if not cs.alive(ticket): return
	mark("street")
	world._leave_apartment()
	await cs.camera(world.camera_home(),0,1.0)
	if not cs.alive(ticket): return
	await cs.fade(Color(0,0,0,0),0.65)
	if not cs.alive(ticket): return
	cs.end()

func play_landing():
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.player.facing = Vector2.RIGHT
	cs.pose(world.player,"idle")
	await cs.camera(world.player.position+Vector2(70,-62),0,1.1)
	if not cs.alive(ticket): return
	mark("drop")
	show_pose(world.player,6,190)
	await cs.animate(func(t: float): show_pose(world.player,6,190*(1-t*t)),0.42)
	if not cs.alive(ticket): return
	mark("landing")
	world.effects.burst(world.player.position+Vector2(0,15),Color("9fb3c6"),20)
	world.effects.water_step(world.player.position)
	world.shake = 7.0
	world.sound("hit")
	await cs.wait(0.22)
	if not cs.alive(ticket): return
	mark("rise")
	show_pose(world.player,7)
	await cs.wait(0.28)
	if not cs.alive(ticket): return
	restore_actor()
	var foe: PixelActor = world.patrol.back() if not world.patrol.is_empty() else null
	if foe != null:
		cs.face(world.player,foe.position)
		cs.face(foe,world.player.position)
		cs.pose(foe,"idle")
	await cs.say("SHADEPI","Lasst sie in Ruhe.")
	if not cs.alive(ticket): return
	await cs.say("GANGER","Wo kommt der denn her? Los, auf ihn!")
	if not cs.alive(ticket): return
	cs.end()
