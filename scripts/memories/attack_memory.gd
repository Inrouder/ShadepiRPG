extends Node2D
signal finished(completed: bool)
const Actor = preload("res://scripts/memories/memory_actor.gd")
const Map = preload("res://scripts/memories/monastery_map.gd")
const Director = preload("res://scripts/cutscene.gd")
var autoplay := true
var embedded := false
var preview := false
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
var bots: Array[Sprite2D] = []

func _ready() -> void:
	map = Map.new()
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
	for i in 5:
		var actor = Actor.new()
		actors.add_child(actor)
		actor.prepare(["shadepi","oni","robot","ly","heavy"][i],self)
		actor.position = Vector2(340-i*34,376+(i%2)*62)
		actor.facing = Vector2.RIGHT
		actor.animate("idle",0)
		squad.append(actor)
	for i in 8:
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
	if autoplay: play.call_deferred()

func camera_home() -> Vector2: return Vector2(512,340)
func is_busy() -> bool: return menu_open or cutscene.running
func in_cinematic() -> bool: return cutscene != null and cutscene.running

func _unhandled_input(event: InputEvent) -> void:
	if not embedded and handle_event(event): get_viewport().set_input_as_handled()

func handle_event(event: InputEvent) -> bool:
	if closed: return false
	if event is InputEventKey and event.echo: return true
	var button: int = event.button_index if event is InputEventJoypadButton else -1
	var key: int = event.keycode if event is InputEventKey else -1
	if not event.is_pressed(): return event is InputEventJoypadMotion
	if key==KEY_ESCAPE or button==JOY_BUTTON_START:
		toggle_pause()
	elif menu_open:
		if key==KEY_UP or key==KEY_DOWN or button in [JOY_BUTTON_DPAD_UP,JOY_BUTTON_DPAD_DOWN]:
			var index: int = ui.buttons.find(get_viewport().gui_get_focus_owner())
			var step := -1 if key==KEY_UP or button==JOY_BUTTON_DPAD_UP else 1
			ui.buttons[posmod(index+step,3)].grab_focus()
		elif key==KEY_ENTER or key==KEY_E or button==JOY_BUTTON_A:
			var focus = get_viewport().gui_get_focus_owner()
			if focus is Button: focus.pressed.emit()
		elif button==JOY_BUTTON_B: toggle_pause()
	elif key==KEY_SPACE or button==JOY_BUTTON_B:
		cutscene.skip()
	elif key==KEY_ENTER or key==KEY_E or button==JOY_BUTTON_A:
		cutscene.advance()
	else:
		return event is InputEventJoypadButton or event is InputEventKey
	return true

func toggle_pause() -> void:
	menu_open = not menu_open
	map.paused = menu_open
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
	await cutscene.camera(Vector2(685,300),1.1,1)
	await cutscene.title("ERINNERUNG I","DER ANGRIFF",1.8)
	if closed: return
	phase = "flight"
	map.impact(Vector2(868,320))
	if host != null: host.sound("drive_explosion")
	for i in residents.size(): _escape(residents[i],i)
	await cutscene.camera(Vector2(400,360),1.5,1.1)
	await cutscene.say("MÖNCH","Zum Seitengang! Weg vom Tor!")
	if closed: return
	phase = "advance"
	for i in range(1,squad.size()): cutscene.walk(squad[i],Vector2(530-i*34,376+(i%2)*62),58 if i==4 else 77)
	await cutscene.walk(squad[0],Vector2(565,376),83)
	await cutscene.say("SHADEPI","Bringt euch in Sicherheit! Wir werden sie abwehren!")
	if closed: return
	phase = "breach"
	map.impact(Vector2(910,310))
	if host != null: host.sound("drive_explosion")
	await cutscene.camera(Vector2(734,350),1.2,1)
	await cutscene.wait(1.0)
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
