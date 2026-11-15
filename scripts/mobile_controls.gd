extends CanvasLayer
## v0.62.0 · CodexAI. Multitouch virtual gamepad, shared real input path for story/hacks/arcade.
const UiSkin = preload("res://scripts/ui_skin.gd")
const DEVICE := 100
var enabled := false
var surfaces: Dictionary = {}
var fingers: Dictionary = {}
var held: Dictionary = {}
var stick_finger := -1
var stick := Vector2.ZERO
var controls: Control
var launcher: Button
var labels: Dictionary = {}
var net: Node
var last_world: Node
const STICK_CENTER := Vector2(78,278)
const STICK_RADIUS := 58.0

func _ready():
	set_meta("root_only",true)
	layer = 930; process_mode = Node.PROCESS_MODE_ALWAYS; process_priority = 300
	enabled = OS.has_feature("android") or "--touch-controls" in OS.get_cmdline_user_args()
	net = get_node("/root/NetworkSession")
	controls = Control.new(); controls.size = Vector2(640,360); controls.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(controls)
	for entry in [["up",Vector2(55,205),Vector2(46,44),"▲"],["left",Vector2(8,251),Vector2(46,48),"◀"],["right",Vector2(102,251),Vector2(46,48),"▶"],["down",Vector2(55,301),Vector2(46,44),"▼"]]:
		_surface(entry[0],Rect2(entry[1],entry[2]),entry[3])
	for entry in [[JOY_BUTTON_X,Vector2(476,238),"X · Angriff"],[JOY_BUTTON_A,Vector2(554,274),"A · Weiter"],[JOY_BUTTON_B,Vector2(476,310),"B · Ausw."],[JOY_BUTTON_Y,Vector2(554,202),"Y · Spezial"],[JOY_BUTTON_RIGHT_SHOULDER,Vector2(554,130),"RB · Hack"],["rt",Vector2(476,166),"RT · Laden"],["lt",Vector2(398,202),"LT · Kick"],[JOY_BUTTON_START,Vector2(8,8),"Ⅱ · Pause"]]:
		_surface(entry[0],Rect2(entry[1],Vector2(76,36)),entry[2])
	launcher = Button.new(); launcher.text = "WLAN · Koop"; launcher.position = Vector2(8,48); launcher.size = Vector2(144,28)
	if enabled:
		labels[JOY_BUTTON_START].position = Vector2(282,318)
		surfaces[JOY_BUTTON_START] = Rect2(Vector2(282,318),Vector2(76,36))
		launcher.position = Vector2(268,280); launcher.size = Vector2(104,28)
	UiSkin.apply_button(launcher,"raven",16); launcher.focus_mode = Control.FOCUS_NONE; launcher.pressed.connect(func(): release_all(); net.show_lobby()); add_child(launcher)
	_tag(self)
	get_window().go_back_requested.connect(_back)
	controls.visible = enabled

func _surface(key: Variant, area: Rect2, text: String):
	surfaces[key] = area
	var p := Panel.new(); p.position = area.position; p.size = area.size; p.add_theme_stylebox_override("panel",UiSkin.button("raven","normal")); p.mouse_filter = Control.MOUSE_FILTER_IGNORE; controls.add_child(p)
	var label := Label.new(); label.text = text; label.size = area.size; label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font",UiSkin.font()); label.add_theme_font_size_override("font_size",16); label.mouse_filter = Control.MOUSE_FILTER_IGNORE; p.add_child(label); labels[key] = p
func _tag(node: Node):
	if node is CanvasItem: node.visibility_layer = 1 << 20
	for child in node.get_children(): _tag(child)
func _process(_delta: float):
	var modal: bool = is_instance_valid(net.lobby) and net.lobby.visible
	var world := get_tree().current_scene
	var terminal = world.get("terminal") if world != null else null
	var local_terminal: bool = not net.is_client() and is_instance_valid(terminal) and terminal.visible
	var local_menu: bool = not net.is_client() and world != null and world.get("menu_open") == true
	controls.visible = enabled and not modal and not local_menu and not local_terminal
	if world != last_world:
		release_all(); last_world = world
		if enabled:
			# Keep touch-to-mouse for GUI, but a stick touch must never also fire a weapon.
			for action in ["attack","mouse_attack","raven_mouse_attack"]:
				if not InputMap.has_action(action): continue
				for event in InputMap.action_get_events(action):
					if event is InputEventMouseButton: InputMap.action_erase_event(action,event)
	var compact: bool = enabled or (net.is_host() and net.connected())
	if compact and world != null and world.get("ui") != null:
		for key in ["controls","abilities","combat_hint"]:
			var item = world.ui.get(key)
			if item is CanvasItem: item.hide()
	launcher.visible = not modal and (net.is_client() or (world != null and world.get("menu_open") == true))
	if not controls.visible and not fingers.is_empty(): release_all()
	for key in labels:
		var active: bool = held.get(key,0) > 0
		if key is String:
			active = active or (key == "up" and stick.y < -0.3) or (key == "down" and stick.y > 0.3) or (key == "left" and stick.x < -0.3) or (key == "right" and stick.x > 0.3)
		labels[key].modulate = Color(1.5,1.5,1.5,0.9) if active else Color(1,1,1,0.7)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_F8:
		release_all(); net.show_lobby(); get_viewport().set_input_as_handled(); return
	if not enabled or not controls.visible: return
	if event is InputEventScreenTouch:
		if event.pressed:
			var point: Vector2 = event.position
			if point.distance_to(STICK_CENTER) < STICK_RADIUS + 30 and point.x < 170:
				if stick_finger == -1: stick_finger = event.index; fingers[event.index] = "stick"; _move_stick(point)
			else:
				for key in surfaces:
					if key is String and key not in ["rt","lt"]: continue
					if surfaces[key].has_point(point): fingers[event.index] = key; _hold(key,true); break
		elif fingers.has(event.index):
			var key: Variant = fingers[event.index]
			if key is String and key == "stick": stick_finger = -1; _move_stick(STICK_CENTER)
			else: _hold(key,false)
			fingers.erase(event.index)
		if fingers.has(event.index) or not event.pressed: get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and fingers.has(event.index):
		if fingers[event.index] is String and fingers[event.index] == "stick": _move_stick(event.position)
		get_viewport().set_input_as_handled()

func _move_stick(point: Vector2):
	stick = ((point-STICK_CENTER) / STICK_RADIUS).limit_length(1.0)
	if stick.length() < 0.18: stick = Vector2.ZERO
	for i in 2:
		var e := InputEventJoypadMotion.new(); e.device = DEVICE; e.axis = JOY_AXIS_LEFT_X if i == 0 else JOY_AXIS_LEFT_Y; e.axis_value = stick[i]; Input.parse_input_event(e)
func _hold(key: Variant, down: bool):
	var count: int = held.get(key,0); held[key] = maxi(0,count+(1 if down else -1))
	if (count > 0) == (held[key] > 0): return
	if key is String:
		var e := InputEventJoypadMotion.new(); e.device = DEVICE; e.axis = JOY_AXIS_TRIGGER_LEFT if key == "lt" else JOY_AXIS_TRIGGER_RIGHT; e.axis_value = 1.0 if down else -1.0; Input.parse_input_event(e)
	else:
		var e := InputEventJoypadButton.new(); e.device = DEVICE; e.button_index = key; e.pressed = down; Input.parse_input_event(e)
func release_all():
	for key in held.keys():
		if held[key] > 0: held[key] = 1; _hold(key,false)
	fingers.clear(); stick_finger = -1; _move_stick(STICK_CENTER)
func _back():
	release_all()
	var e := InputEventJoypadButton.new(); e.device = DEVICE; e.button_index = JOY_BUTTON_START; e.pressed = true; Input.parse_input_event(e)
	e = e.duplicate(); e.pressed = false; Input.parse_input_event(e)
func _notification(what: int):
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]: release_all()
