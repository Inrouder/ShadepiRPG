extends SceneTree
## v0.62.0 CodexAI: two independent touch fingers, held triggers, menus and lifecycle.
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: " + label)
func touch(index: int, at: Vector2, pressed: bool):
	var e := InputEventScreenTouch.new(); e.index = index; e.position = root.get_final_transform() * at; e.pressed = pressed; Input.parse_input_event(e)
	await process_frame; await process_frame
func drag(mobile, offset: Vector2):
	var e:=InputEventScreenDrag.new(); e.index=0; e.position=root.get_final_transform()*(mobile.STICK_CENTER+offset*mobile.STICK_RADIUS); Input.parse_input_event(e)
	await process_frame; await process_frame
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var mobile = root.get_node("MobileControls"); mobile.enabled = true; Input.emulate_mouse_from_touch=true; mobile.controls.show()
	var w = load("res://scenes/chapter_two.tscn").instantiate(); root.add_child(w); current_scene = w
	for i in 10: await process_frame
	w.close_menu(); w.cutscene.abort(); w.ui.clear_dialogue(); w.started = true
	w.gamepads.assign(preload("res://scripts/gamepad_bindings.gd").devices(),false)
	check(w.gamepads.shadepi_device == mobile.DEVICE,"touch is player-one virtual pad")
	check(mobile.stick_base.size==Vector2(92,92) and mobile.stick_knob.size==Vector2(40,40),"texture minimum sizes cannot push joystick art off-screen")
	await touch(0,mobile.STICK_CENTER+Vector2(mobile.STICK_RADIUS*0.85,0),true)
	check(Input.get_joy_axis(mobile.DEVICE,JOY_AXIS_LEFT_X)>0.6 and Input.is_action_pressed("move_right"),"stick controls actual gameplay action")
	check(not Input.is_action_pressed("attack") and not Input.is_action_pressed("mouse_attack"),"first stick finger does not become an accidental mouse attack")
	await drag(mobile,Vector2(0.4,-0.6))
	check(is_equal_approx(Input.get_joy_axis(mobile.DEVICE,JOY_AXIS_LEFT_X),0.4) and is_equal_approx(Input.get_joy_axis(mobile.DEVICE,JOY_AXIS_LEFT_Y),-0.6),"drag produces continuous diagonal analog axes")
	check(mobile.stick_knob.position.is_equal_approx(mobile.STICK_CENTER-Vector2(20,20)+Vector2(0.4,-0.6)*24),"visible thumb follows the same analog displacement")
	await drag(mobile,Vector2(0.02,0.02))
	check(mobile.stick==Vector2.ZERO,"small thumb movement stays in the deadzone")
	await drag(mobile,Vector2(0.85,0))
	await touch(2,mobile.surfaces[JOY_BUTTON_X].get_center(),true)
	check(Input.is_action_pressed("attack") and Input.is_action_pressed("move_right"),"second finger attacks while first moves")
	await touch(2,mobile.surfaces[JOY_BUTTON_X].get_center(),false)
	check(not Input.is_action_pressed("attack") and Input.is_action_pressed("move_right"),"releasing attack retains independent movement")
	await touch(0,mobile.STICK_CENTER+Vector2(mobile.STICK_RADIUS*0.85,0),false)
	check(not Input.is_action_pressed("move_right"),"stick release stops moving")
	await touch(5,mobile.surfaces[JOY_BUTTON_X].position+Vector2.ONE,true)
	check(not mobile.fingers.has(5) and not Input.is_action_pressed("attack"),"outside a visible action circle cannot fire")
	await touch(5,mobile.surfaces[JOY_BUTTON_X].position+Vector2.ONE,false)
	await touch(3,mobile.surfaces["rt"].get_center(),true)
	check(Input.is_action_pressed("charge"),"RT holds actual charged attack")
	await touch(4,mobile.surfaces["rt"].get_center(),true); await touch(3,mobile.surfaces["rt"].get_center(),false)
	check(Input.is_action_pressed("charge"),"two fingers on same control do not release each other")
	await touch(4,mobile.surfaces["rt"].get_center(),false)
	check(not Input.is_action_pressed("charge"),"last release sends trigger-up")
	await touch(0,mobile.STICK_CENTER+Vector2(mobile.STICK_RADIUS*0.85,0),true); mobile._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await process_frame
	check(mobile.fingers.is_empty() and not Input.is_action_pressed("move_right"),"backgrounding cancels every held touch")
	root.get_node("NetworkSession").show_lobby(); await process_frame
	check(not mobile.controls.visible and w.menu_open,"WLAN panel pauses story and hides touch controls")
	root.go_back_requested.emit(); await process_frame
	check(not root.get_node("NetworkSession").lobby.visible,"system back closes the visible local WLAN window")
	var net = root.get_node("NetworkSession")
	net.host(0); net.world=w; w.set_coop(true)
	check(w.gamepads.shadepi_device==mobile.DEVICE and w.gamepads.raven_device==net.REMOTE_DEVICE,"waiting WLAN host keeps touch on player one through peer loss")
	net.close()
	w.free(); current_scene = null; await process_frame
	print("MOBILE INPUT: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
