extends Node2D
## v0.38.0 · CodexAI. Chapter 2: enter, connect, return, fetch spray, stabilize.
const ART = preload("res://assets/story/ice-bath/poses.png")
const ROOM = preload("res://assets/world/painted/hideout.png")
const SHADER = preload("res://shaders/ice_bath_pose.gdshader")
const SEAT := Vector2(652,361)
const APPROACH := Vector2(674,387)
const PLAYER_WAIT := Vector2(609,393)
const SUPPORT := Vector2(634,390)
const EXIT := Vector2(657,392)
const SCALE := 0.125
const REGIONS: Array[Rect2] = [Rect2(0,0,384,512),Rect2(384,0,384,512),Rect2(768,0,384,512),Rect2(1152,0,384,512),Rect2(0,512,384,512),Rect2(384,512,352,512),Rect2(744,512,384,512),Rect2(1128,512,408,512)]
const ANCHORS: Array[Vector2] = [Vector2(183,294),Vector2(170,300),Vector2(202,300),Vector2(200,300),Vector2(195,307),Vector2(208,300),Vector2(276,316),Vector2(290,318)]
const ORIGINS: Array[Vector2] = [SEAT,Vector2(661,355),Vector2(680,348),Vector2(680,348),Vector2(680,348),SEAT,SEAT,SEAT]
const PORTS: Array[Vector2] = [Vector2(186,159),Vector2(188,177),Vector2(285,195),Vector2(283,195),Vector2(270,196),Vector2(218,206),Vector2(276,215),Vector2(290,216)]
var world: Node2D
var sprite: Sprite2D
var material_pose: ShaderMaterial
var rim: Polygon2D
var cable: Line2D
var pose := 0
var target_pose := 0
var clock := 0.0
var stage := "idle"
var events: Array[String] = []
var cable_attached := false
var mix_value := 0.0

func _ready() -> void:
	position = SEAT
	cable = Line2D.new()
	cable.width = 1.1
	cable.texture_mode = Line2D.LINE_TEXTURE_TILE
	cable.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var strip := AtlasTexture.new()
	strip.atlas = ROOM
	strip.region = Rect2(Vector2(710,324)/Vector2(1024,640)*ROOM.get_size(),Vector2(4,8)/Vector2(1024,640)*ROOM.get_size())
	strip.filter_clip = true
	cable.texture = strip
	add_child(cable)
	sprite = Sprite2D.new()
	sprite.texture = ART
	sprite.scale = Vector2(896.0/1536.0,768.0/1024.0)*SCALE
	sprite.position = (Vector2(448,384)-Vector2(400,480))*SCALE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	material_pose = ShaderMaterial.new()
	material_pose.shader = SHADER
	material_pose.set_shader_parameter("sheet",ART)
	sprite.material = material_pose
	add_child(sprite)
	rim = Polygon2D.new()
	rim.texture = ROOM
	var outline := PackedVector2Array([Vector2(630,348),Vector2(648,354),Vector2(676,359),Vector2(704,352),Vector2(721,342),Vector2(733,345),Vector2(731,365),Vector2(717,375),Vector2(692,381),Vector2(659,380),Vector2(635,369),Vector2(626,356)])
	var uv := PackedVector2Array()
	var points := PackedVector2Array()
	for p in outline:
		points.append(p-SEAT)
		uv.append(p/Vector2(1024,640)*ROOM.get_size())
	rim.polygon = points
	rim.uv = uv
	add_child(rim)
	set_pose(0)
	hide()

func paused() -> bool: return world==null or world.menu_open or world.terminal!=null
func _process(delta: float) -> void:
	if paused(): return
	clock += delta
	material_pose.set_shader_parameter("clock",clock)

func mark(value: String) -> void:
	stage = value
	if not events.has(value): events.append(value)

func _source(index: int, suffix: String) -> void:
	var r := REGIONS[index]
	material_pose.set_shader_parameter("region_"+suffix,Vector4(r.position.x,r.position.y,r.size.x,r.size.y))
	material_pose.set_shader_parameter("anchor_"+suffix,ANCHORS[index])
	material_pose.set_shader_parameter("offset_"+suffix,ORIGINS[index]-SEAT)
	material_pose.set_shader_parameter("breath_"+suffix,1.0 if index in [3,5] else 0.0)

func set_pose(index: int) -> void:
	pose = clampi(index,0,7)
	target_pose = pose
	_source(pose,"a")
	_source(pose,"b")
	_blend(0.0)

func _blend(p: float) -> void:
	mix_value = p
	material_pose.set_shader_parameter("blend",p)
	var immersion: float = lerpf(1.0 if pose in [1,2,3,4] else 0.0,1.0 if target_pose in [1,2,3,4] else 0.0,p)
	material_pose.set_shader_parameter("immersed",immersion)
	material_pose.set_shader_parameter("spray",1.0 if pose==6 or target_pose==6 else 0.0)
	rim.visible = immersion>0.5
	cable.visible = cable_attached
	var a: Vector2 = ORIGINS[pose]+(PORTS[pose]-ANCHORS[pose])*SCALE
	var b: Vector2 = ORIGINS[target_pose]+(PORTS[target_pose]-ANCHORS[target_pose])*SCALE
	var port := a.lerp(b,p)
	cable.points = PackedVector2Array([Vector2(716,320)-SEAT,Vector2(707,328)-SEAT,Vector2(port.x+10,port.y+3)-SEAT,port-SEAT])

func transition(cs, index: int, seconds: float = 0.65) -> void:
	var ticket: int = cs.generation
	target_pose = clampi(index,0,7)
	_source(target_pose,"b")
	await cs.animate(_blend,seconds)
	if not cs.alive(ticket): return
	set_pose(target_pose)

func restore_actors() -> void:
	for actor in [world.player,world.raven]:
		actor.visual.show()
		actor.cast_shadow.show()
		actor.light_occluder.visible = not actor.cloaked
		actor.modulate = Color.WHITE
		actor.visual.modulate = Color.WHITE
		actor.visual.position = actor.standing_visual_position
		actor.z_index = 0

func rest_recovery() -> void:
	mark("waiting_spray")
	set_pose(5)
	cable_attached = true
	_blend(0)
	show()
	world.raven.position = APPROACH
	world.raven.modulate.a = 0
	world.raven.visual.hide()
	world.raven.cast_shadow.hide()
	world.raven.light_occluder.hide()

func play_entry() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.bath_pending = 1
	world.autosave()
	mark("approach")
	cs.walk(world.player,PLAYER_WAIT,65)
	await cs.walk(world.raven,APPROACH,48)
	if not cs.alive(ticket): return
	await cs.camera(Vector2(668,348),0.8,2.0)
	if not cs.alive(ticket): return
	mark("connect")
	set_pose(0)
	show()
	world.raven.modulate.a = 0
	world.raven.visual.hide()
	world.raven.cast_shadow.hide()
	world.raven.light_occluder.hide()
	await cs.wait(0.65)
	if not cs.alive(ticket): return
	cable_attached = true
	_blend(0)
	world.sound("prop_metal")
	await cs.lines([["RAVEN","Der Kühlkreislauf läuft. Ich gehe rein."],["SHADEPI","Ich bleibe hier."]])
	if not cs.alive(ticket): return
	mark("lower")
	await transition(cs,1,0.8)
	if not cs.alive(ticket): return
	world.effects.water_step(Vector2(676,356))
	await transition(cs,2,0.9)
	if not cs.alive(ticket): return
	mark("submerged")
	await transition(cs,3,0.8)
	if not cs.alive(ticket): return
	await cs.wait(0.9)
	if not cs.alive(ticket): return
	mark("network")
	world.sound("hack")
	await cs.flash(Color(0.3,0.8,0.95,0.65),0.55)
	if not cs.alive(ticket): return
	cs.end(func():
		world.player.position = PLAYER_WAIT
		world._enter(world.Section.DIVE,0,true)
		world.autosave()
	)

func play_return() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.bath_pending = 2
	world.autosave()
	world.player.position = PLAYER_WAIT
	world.player.facing = Vector2.RIGHT
	set_pose(3)
	cable_attached = true
	show()
	world.raven.modulate.a = 0
	world.raven.visual.hide()
	world.raven.cast_shadow.hide()
	world.raven.light_occluder.hide()
	mark("return")
	await cs.camera(Vector2(667,348),0.35,2.0)
	if not cs.alive(ticket): return
	# v0.47.0 · ClaudeHelper: das Heiligtum reagiert auf Ravens Deep Dive (Roman, Kapitel 2).
	await cs.say("SHADEPI / HUD","[EINDÄMMUNGSSTATUS · 85 %] Dieses Kribbeln in der Wirbelsäule … Es spürt sie. Ruhig. Nicht jetzt.")
	if not cs.alive(ticket): return
	world.sound("hack")
	await cs.flash(Color(0.7,0.22,0.3,0.35),0.25)
	if not cs.alive(ticket): return
	mark("gasp")
	await transition(cs,4,0.4)
	if not cs.alive(ticket): return
	await cs.say("RAVEN","Nicht gut … Zu heiß … Ich kriege keine Luft.")
	if not cs.alive(ticket): return
	await transition(cs,5,1.0)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI","Deine Synapsen überhitzen. Nicht bewegen – ich hole das Kryospray.")
	if not cs.alive(ticket): return
	cs.end(func():
		rest_recovery()
		world.bath_pending = 0
		world.autosave()
		world.toast("Kryospray am Überwachungstisch holen · E / A")
	)

func play_rescue() -> void:
	var cs = world.begin_cutscene()
	var ticket: int = cs.generation
	world.bath_pending = 3
	world.autosave()
	mark("support")
	await cs.walk(world.player,SUPPORT,70)
	if not cs.alive(ticket): return
	await cs.camera(Vector2(651,348),0.65,2.1)
	if not cs.alive(ticket): return
	world.player.modulate.a = 0
	world.player.visual.hide()
	world.player.cast_shadow.hide()
	world.player.light_occluder.hide()
	mark("spray")
	await transition(cs,6,0.65)
	if not cs.alive(ticket): return
	world.sound("hack")
	await cs.wait(1.6)
	if not cs.alive(ticket): return
	await cs.say("SHADEPI","Atme. Langsam.")
	if not cs.alive(ticket): return
	cable_attached = false
	mark("stabilized")
	await transition(cs,7,0.8)
	if not cs.alive(ticket): return
	await world._oath_words(cs)
	if not cs.alive(ticket): return
	mark("rise")
	world.player.position = SUPPORT
	world.raven.position = EXIT
	cs.face(world.player,EXIT)
	cs.face(world.raven,SUPPORT)
	for actor in [world.player,world.raven]:
		cs.pose(actor,"idle")
		actor.visual.show()
		actor.cast_shadow.show()
		actor.modulate.a = 0
	await cs.animate(func(p: float):
		sprite.modulate.a = 1-p
		for actor in [world.player,world.raven]: actor.modulate.a = p
	,0.7)
	if not cs.alive(ticket): return
	restore_actors()
	hide()
	cs.do(func():
		world._enter(world.Section.END,0,true)
		world.autosave()
		world._scene_chapter_end()
	)
