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
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var mobile = root.get_node("MobileControls"); mobile.enabled = true; Input.emulate_mouse_from_touch=true; mobile.controls.show()
	var w = load("res://scenes/chapter_two.tscn").instantiate(); root.add_child(w); current_scene = w
	for i in 10: await process_frame
	w.close_menu(); w.cutscene.abort(); w.ui.clear_dialogue(); w.started = true
	w.gamepads.assign(preload("res://scripts/gamepad_bindings.gd").devices(),false)
	check(w.gamepads.shadepi_device == mobile.DEVICE,"touch is player-one virtual pad")
	await touch(0,Vector2(128,278),true)
	check(Input.get_joy_axis(mobile.DEVICE,JOY_AXIS_LEFT_X)>0.6 and Input.is_action_pressed("move_right"),"stick controls actual gameplay action")
	check(not Input.is_action_pressed("attack") and not Input.is_action_pressed("mouse_attack"),"first stick finger does not become an accidental mouse attack")
	await touch(2,Vector2(510,250),true)
	check(Input.is_action_pressed("attack") and Input.is_action_pressed("move_right"),"second finger attacks while first moves")
	await touch(2,Vector2(510,250),false)
	check(not Input.is_action_pressed("attack") and Input.is_action_pressed("move_right"),"releasing attack retains independent movement")
	await touch(0,Vector2(128,278),false)
	check(not Input.is_action_pressed("move_right"),"stick release stops moving")
	await touch(3,Vector2(510,180),true)
	check(Input.is_action_pressed("charge"),"RT holds actual charged attack")
	await touch(4,Vector2(510,180),true); await touch(3,Vector2(510,180),false)
	check(Input.is_action_pressed("charge"),"two fingers on same control do not release each other")
	await touch(4,Vector2(510,180),false)
	check(not Input.is_action_pressed("charge"),"last release sends trigger-up")
	await touch(0,Vector2(128,278),true); mobile._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await process_frame
	check(mobile.fingers.is_empty() and not Input.is_action_pressed("move_right"),"backgrounding cancels every held touch")
	root.get_node("NetworkSession").show_lobby(); await process_frame
	check(not mobile.controls.visible and w.menu_open,"WLAN panel pauses story and hides touch controls")
	root.get_node("NetworkSession").lobby.hide(); await process_frame
	w.free(); current_scene = null; await process_frame
	print("MOBILE INPUT: %d checks, %d failures" % [checks,failures]); quit(1 if failures else 0)
