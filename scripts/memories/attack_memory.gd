extends Node2D
signal finished(completed: bool)
const Actor = preload("res://scripts/memories/memory_actor.gd")
const Map = preload("res://scripts/memories/monastery_map.gd")
const Director = preload("res://scripts/cutscene.gd")
@export var autoplay := true
var embedded := false
@export var preview := false
var menu_open := false
var terminal: Node = null
var ui: CanvasLayer
var camera: Camera2D
var actors: Node2D
var cutscene: CanvasLayer
var map: Node2D
var squad: Array[PixelActor] = []
var residents: Array[PixelActor] = []
var completed := false
var closed := false
var host: Node2D
var phase := "setup"
var bots: Array[PixelActor] = []
var battle: RefCounted
var effects: Node2D
var pause_axis_latched := false

func _ready() -> void:
	map = make_map()
	if host != null: map.quality = host.visual_quality
	add_child(map)
	actors = map.actors
	camera = Camera2D.new()
	camera.position = camera_home()
	camera.position_smoothing_enabled = false
	camera.limit_left = 0
	camera.limit_right = 1024
	camera.limit_top = 0
	camera.limit_bottom = 640
	add_child(camera)
	camera.make_current()
	var ids := squad_ids()
	for i in ids.size():
		var actor = make_actor(ids[i])
		actors.add_child(actor)
		actor.prepare(ids[i],self)
		actor.position = Vector2(340-i*34,376+(i%2)*62)
		actor.facing = Vector2.RIGHT
		actor.animate("idle",0)
		squad.append(actor)
	for i in resident_count():
		var actor = Actor.new()
		actors.add_child(actor)
		actor.prepare(["elder","monk","resident","caretaker"][i%4],self)
		actor.position = Vector2(400+(i%4)*50,330+(i/4)*160)
		actor.facing = Vector2.LEFT
		actor.animate("idle",0)
		residents.append(actor)
	ui = preload("res://scripts/memories/memory_hud.gd").new()
	ui.world = self
	add_child(ui)
	cutscene = Director.new()
	cutscene.world = self
	add_child(cutscene)
	effects = preload("res://scripts/effects.gd").new()
	effects.world = self
	effects.rain = false
	effects.steam_vents.clear()
	add_child(effects)
	for i in initial_bot_count(): create_bot(Vector2(960,350+i*45)).hide()
	if autoplay: play.call_deferred()

func make_map() -> Node2D: return Map.new()
func make_actor(_id: String) -> PixelActor: return Actor.new()
func squad_ids() -> Array: return ["shadepi","oni","robot","ly","heavy"]
func resident_count() -> int: return 8
func initial_bot_count() -> int: return 3

func create_bot(point: Vector2) -> PixelActor:
	var bot = Actor.new()
	actors.add_child(bot)
	bot.prepare("bot",self)
	bot.position = point
	bot.facing = Vector2.LEFT
	bot.animate("idle",0)
	bots.append(bot)
	return bot

func camera_home() -> Vector2: return Vector2(512,340)
func is_busy() -> bool: return menu_open or cutscene.running
func in_cinematic() -> bool: return cutscene != null and cutscene.running

func _unhandled_input(event: InputEvent) -> void:
	if not embedded and handle_event(event): get_viewport().set_input_as_handled()

func handle_event(event: InputEvent) -> bool:
	if closed: return false
	if event is InputEventKey and event.echo: return true
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_Y and menu_open:
			if absf(event.axis_value)<0.25: pause_axis_latched = false
			elif absf(event.axis_value)>0.6 and not pause_axis_latched:
				_focus_step(-1 if event.axis_value<0 else 1)
				pause_axis_latched = true
		return true
	var button: int = event.button_index if event is InputEventJoypadButton else -1
	var key: int = event.keycode if event is InputEventKey else -1
	if not event.is_pressed(): return event is InputEventJoypadMotion
	if key==KEY_ESCAPE or button==JOY_BUTTON_START:
		toggle_pause()
	elif menu_open:
		if key==KEY_UP or key==KEY_DOWN or button in [JOY_BUTTON_DPAD_UP,JOY_BUTTON_DPAD_DOWN]:
			var step := -1 if key==KEY_UP or button==JOY_BUTTON_DPAD_UP else 1
			_focus_step(step)
		elif key==KEY_TAB: _focus_step(-1 if event.shift_pressed else 1)
		elif key==KEY_ENTER or key==KEY_E or button==JOY_BUTTON_A:
			var focus = get_viewport().gui_get_focus_owner()
			if focus is Button: focus.pressed.emit()
		elif button==JOY_BUTTON_B: toggle_pause()
	elif key==KEY_SPACE or button==JOY_BUTTON_B:
		cutscene.skip()
	elif key==KEY_ENTER or key==KEY_E or button==JOY_BUTTON_A:
		if preview and not cutscene.running: play()
		else: cutscene.advance()
	else:
		return event is InputEventJoypadButton or event is InputEventKey
	return true

func _focus_step(step: int) -> void:
	var index: int = ui.buttons.find(get_viewport().gui_get_focus_owner())
	ui.buttons[posmod(index+step,3)].grab_focus()

func toggle_pause() -> void:
	menu_open = not menu_open
	pause_axis_latched = false
	map.paused = menu_open
	effects.set_process(not menu_open)
	ui.pause_panel.visible = menu_open
	if menu_open: ui.buttons[0].grab_focus()

func cancel() -> void:
	if closed: return
	closed = true
	cutscene.abort()
	finished.emit(false)

func play() -> void:
	if closed or cutscene.running: return
	phase = "arrival"
	cutscene.begin()
	await cutscene.letterbox(true)
	await cutscene.camera(Vector2(580,280),1.1,0.78)
	await cutscene.title("ERINNERUNG I","DER ANGRIFF",1.8)
	if closed: return
	phase = "flight"
	map.impact(Vector2(868,320))
	if host != null and not cutscene.skipping: host.sound("drive_explosion")
	for i in residents.size(): _escape(residents[i],i)
	await cutscene.camera(Vector2(355,340),1.5,0.95)
	await cutscene.say("MÖNCH","Zum Seitengang! Weg vom Tor!")
	if closed: return
	phase = "advance"
	for i in range(1,squad.size()): cutscene.walk(squad[i],Vector2(530-i*34,376+(i%2)*62),58 if i==4 else 77)
	await cutscene.walk(squad[0],Vector2(565,376),83)
	await cutscene.camera(Vector2(580,360),0.7,1.15)
	phase = "shout"
	await cutscene.say("SHADEPI","Bringt euch in Sicherheit! Wir werden sie abwehren!")
	if closed: return
	phase = "breach"
	await cutscene.camera(Vector2(680,350),1.2,0.95)
	if closed: return
	map.impact(Vector2(910,310))
	if host != null and not cutscene.skipping: host.sound("drive_explosion")
	for i in bots.size():
		bots[i].show()
		cutscene.walk(bots[i],Vector2(810+i*35,335+i*45),68)
	await cutscene.wait(1.8)
	if closed: return
	battle = preload("res://scripts/memories/memory_battle.gd").new(self)
	await battle.play()
	if closed: return
	await cutscene.fade(Color.BLACK,0.7)
	if closed: return
	cutscene.end(_complete)

func _escape(actor: PixelActor,index: int) -> void:
	await cutscene.walk(actor,Vector2(82,330+(index/4)*160),64+index*2)
	if closed: return
	await cutscene.walk(actor,Vector2(82,268),60)
	if closed: return
	actor.hide()

func _complete() -> void:
	if closed: return
	phase = "complete"
	completed = true
	closed = true
	finished.emit(true)

func _physics_process(delta: float) -> void:
	if not preview or cutscene.running or menu_open: return
	var direction := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	squad[0].velocity = direction*90
	if direction.length()>0.1: squad[0].facing = direction
	squad[0].move_and_slide()
	squad[0].animate("walk" if direction.length()>0.1 else "idle",delta)
	camera.position = squad[0].position+Vector2(0,-45)

func _exit_tree() -> void:
	closed = true
	if cutscene != null: cutscene.abort()
