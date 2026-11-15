extends CanvasLayer
## v0.63.0 · CodexAI. Faint pixel sprites, an analog thumbstick and edge action circles.
const UiSkin = preload("res://scripts/ui_skin.gd")
const DEVICE := 100
const STICK_CENTER := Vector2(70,284)
const STICK_RADIUS := 46.0
const ART_PATHS := {
 "ring":("res://assets/ui/touch/ring.png"), "thumb":("res://assets/ui/touch/thumb.png"),
 "pistol":("res://assets/ui/touch/pistol.png"), "katana":("res://assets/ui/touch/katana.png"),
 "kick":("res://assets/ui/touch/kick.png"), "dodge":("res://assets/ui/touch/dodge.png"),
 "interact":("res://assets/ui/touch/interact.png"), "charge":("res://assets/ui/touch/charge.png"),
 "hack":("res://assets/ui/touch/hack.png")}
var textures: Dictionary = {}
var enabled := false
var surfaces: Dictionary = {}
var fingers: Dictionary = {}
var held: Dictionary = {}
var stick_finger := -1
var stick := Vector2.ZERO
var controls: Control
var labels: Dictionary = {}
var stick_base: TextureRect
var stick_knob: TextureRect
var net: Node
var last_world: Node

func _ready():
	if Engine.is_editor_hint(): return
	for key in ART_PATHS: textures[key]=load(ART_PATHS[key])
	set_meta("root_only",true)
	layer = 930; process_mode = Node.PROCESS_MODE_ALWAYS; process_priority = 300
	enabled = OS.has_feature("android") or "--touch-controls" in OS.get_cmdline_user_args()
	net = get_node("/root/NetworkSession")
	controls = Control.new(); controls.size = Vector2(640,360); controls.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(controls)
	stick_base = _image(controls,"ring",Rect2(STICK_CENTER-Vector2.ONE*STICK_RADIUS,Vector2.ONE*STICK_RADIUS*2))
	stick_knob = _image(controls,"thumb",Rect2(STICK_CENTER-Vector2(20,20),Vector2(40,40)))
	for entry in [[JOY_BUTTON_X,Vector2(596,260),27.0,"pistol",""], [JOY_BUTTON_A,Vector2(604,202),20.0,"interact",""], [JOY_BUTTON_B,Vector2(601,320),22.0,"dodge",""], ["lt",Vector2(540,317),21.0,"kick",""], ["rt",Vector2(543,258),21.0,"charge","Halten"], [JOY_BUTTON_Y,Vector2(604,145),18.0,"charge","Spezial"], [JOY_BUTTON_RIGHT_SHOULDER,Vector2(554,192),18.0,"hack","Hack"], [JOY_BUTTON_START,Vector2(22,94),13.0,"","Ⅱ"]]:
		_surface(entry[0],entry[1],entry[2],entry[3],entry[4])
	_tag(self)
	get_window().go_back_requested.connect(_back)
	controls.visible = enabled
	_refresh_art()

func _image(parent: Node, art: String, rect: Rect2) -> TextureRect:
	var image := TextureRect.new(); image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	image.texture=textures[art]; image.position=rect.position; image.size=rect.size
	image.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	image.mouse_filter=Control.MOUSE_FILTER_IGNORE; parent.add_child(image); return image

func _surface(key: Variant, center: Vector2, radius: float, art: String, caption: String):
	var area := Rect2(center-Vector2.ONE*radius,Vector2.ONE*radius*2)
	surfaces[key]=area
	var group := Control.new(); group.position=area.position; group.size=area.size; group.mouse_filter=Control.MOUSE_FILTER_IGNORE; controls.add_child(group)
	var ring := _image(group,"ring",Rect2(Vector2.ZERO,area.size)); ring.modulate.a=0.14
	var icon: TextureRect
	if not art.is_empty(): icon=_image(group,art,Rect2(area.size*0.18,area.size*0.64))
	group.set_meta("ring",ring); group.set_meta("icon",icon)
	if not caption.is_empty():
		var label := Label.new(); label.text=caption; label.size=Vector2(area.size.x+16,12)
		label.position=Vector2(-8,area.size.y-1) if not art.is_empty() else Vector2(-8,5)
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font",UiSkin.font()); label.add_theme_font_size_override("font_size",7 if not art.is_empty() else 16)
		label.modulate.a=0.42; group.add_child(label)
	labels[key]=group

func _tag(node: Node):
	if node is CanvasItem: node.visibility_layer=1<<20
	for child in node.get_children(): _tag(child)

func _process(_delta: float):
	var modal: bool = is_instance_valid(net.lobby) and net.lobby.visible
	var world := get_tree().current_scene
	var terminal = world.get("terminal") if world != null else null
	var local_terminal: bool = not net.is_client() and is_instance_valid(terminal) and terminal.visible
	var local_menu: bool = not net.is_client() and world != null and world.get("menu_open") == true
	controls.visible=enabled and not modal and not local_menu and not local_terminal
	if world != last_world:
		release_all(); last_world=world
		if enabled:
			# GUI retains touch-to-mouse; moving must not also fire a weapon.
			for action in ["attack","mouse_attack","raven_mouse_attack"]:
				if not InputMap.has_action(action): continue
				for event in InputMap.action_get_events(action):
					if event is InputEventMouseButton: InputMap.action_erase_event(action,event)
	var compact: bool=enabled or (net.is_host() and net.connected())
	if world != null and world.get("ui") != null:
		if compact:
			for key in ["controls","abilities","combat_hint"]:
				var item=world.ui.get(key)
				if item is CanvasItem: item.hide()
		var bar=world.ui.get("controls_bar")
		if bar is CanvasItem: bar.visible=not compact and world.ui.controls.visible
		var raven: bool=net.is_client() or world.raven_leads() or (world.get("gamepads")!=null and world.gamepads.raven_device==DEVICE)
		var icon: TextureRect=labels[JOY_BUTTON_X].get_meta("icon")
		icon.texture=textures["pistol" if raven else "katana"]
	if not controls.visible and not fingers.is_empty(): release_all()
	_refresh_art()

func _refresh_art():
	if not is_instance_valid(stick_base): return
	stick_base.modulate.a=0.28 if stick_finger>=0 else 0.13
	stick_knob.modulate.a=0.34 if stick_finger>=0 else 0.12
	for key in labels:
		var active: bool=held.get(key,0)>0
		var group: Control=labels[key]
		var ring: TextureRect=group.get_meta("ring"); ring.modulate.a=0.48 if active else 0.14
		if group.has_meta("icon"):
			var icon: TextureRect=group.get_meta("icon")
			icon.modulate=Color(1.35,1.4,1.45,0.95 if active else 0.64)

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.physical_keycode==KEY_F8:
		release_all(); net.show_lobby(); get_viewport().set_input_as_handled(); return
	if not enabled or not controls.visible: return
	if event is InputEventScreenTouch:
		var owned: bool=fingers.has(event.index)
		if event.pressed:
			var point: Vector2=event.position
			if point.distance_to(STICK_CENTER)<=STICK_RADIUS+18:
				if stick_finger==-1: stick_finger=event.index; fingers[event.index]="stick"; _move_stick(point)
			else:
				for key in surfaces:
					var area: Rect2=surfaces[key]
					if point.distance_to(area.get_center())<=area.size.x*0.5:
						fingers[event.index]=key; _hold(key,true); break
		elif owned:
			var key: Variant=fingers[event.index]
			if key is String and key=="stick": stick_finger=-1; _move_stick(STICK_CENTER)
			else: _hold(key,false)
			fingers.erase(event.index)
		if owned or fingers.has(event.index): get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and fingers.has(event.index):
		if fingers[event.index] is String and fingers[event.index]=="stick": _move_stick(event.position)
		get_viewport().set_input_as_handled()

func _move_stick(point: Vector2):
	stick=((point-STICK_CENTER)/STICK_RADIUS).limit_length(1.0)
	if stick.length()<0.18: stick=Vector2.ZERO
	if is_instance_valid(stick_knob): stick_knob.position=STICK_CENTER-Vector2(20,20)+stick*24
	for i in 2:
		var e:=InputEventJoypadMotion.new(); e.device=DEVICE; e.axis=JOY_AXIS_LEFT_X if i==0 else JOY_AXIS_LEFT_Y; e.axis_value=stick[i]; Input.parse_input_event(e)
func _hold(key: Variant, down: bool):
	var count: int=held.get(key,0); held[key]=maxi(0,count+(1 if down else -1))
	if (count>0)==(held[key]>0): return
	if key is String:
		var e:=InputEventJoypadMotion.new(); e.device=DEVICE; e.axis=JOY_AXIS_TRIGGER_LEFT if key=="lt" else JOY_AXIS_TRIGGER_RIGHT; e.axis_value=1.0 if down else -1.0; Input.parse_input_event(e)
	else:
		var e:=InputEventJoypadButton.new(); e.device=DEVICE; e.button_index=key; e.pressed=down; Input.parse_input_event(e)
func release_all():
	for key in held.keys():
		if held[key]>0: held[key]=1; _hold(key,false)
	fingers.clear(); stick_finger=-1; _move_stick(STICK_CENTER)
func _back():
	release_all()
	if is_instance_valid(net.lobby) and net.lobby.visible: net.lobby.hide(); return
	if net.is_client(): net.show_lobby(); return
	var e:=InputEventJoypadButton.new(); e.device=DEVICE; e.button_index=JOY_BUTTON_START; e.pressed=true; Input.parse_input_event(e)
	e=e.duplicate(); e.pressed=false; Input.parse_input_event(e)
func _notification(what: int):
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]: release_all()
