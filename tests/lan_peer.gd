extends SceneTree
## v0.62.0 CodexAI. Launch as two OS processes; real ENet/UDP, image and input round trip.
var checks := 0
var failures := 0
var net
var test_port := 39262
func _initialize(): Engine.max_fps = 60; run.call_deferred()
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: " + label)
func wait_for(test: Callable, seconds: float = 8.0):
	var deadline := Time.get_ticks_msec()+int(seconds*1000)
	while not test.call() and Time.get_ticks_msec()<deadline: await process_frame
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--test-port="): test_port = arg.get_slice("=",1).to_int()
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	net = root.get_node("NetworkSession")
	var hosting := "--lan-host" in OS.get_cmdline_user_args()
	var w = load("res://scenes/main.tscn" if hosting else "res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w); current_scene = w
	for i in 12: await process_frame
	if hosting:
		w.cutscene.abort(); w.close_menu(); w.ui.clear_dialogue(); w.started = true
		var previous_effects := AudioServer.get_bus_effect_count(0)
		check(net.host(test_port) == OK,"host listens on real UDP port"); net.pin = "123456"
		await wait_for(func():return net.connected())
		check(net.connected() and w.coop_session(),"authenticated peer activates cooperative story")
		var before: Vector2 = w.raven.position; var p1: Vector2 = w.player.position
		var img := Image.create(64,36,false,Image.FORMAT_RGB8); img.fill(Color.CYAN)
		for i in 6:
			net.send_video(img.save_jpg_to_buffer())
			await create_timer(0.15).timeout
		print("LAN movement: ",before," → ",w.raven.position," P1 ",p1," → ",w.player.position," pad ",w.gamepads.raven_device," coop ",w.coop)
		check(w.raven.position.x > before.x+5 and w.player.position.distance_to(p1)<2,"peer input moves only player two in actual scene")
		check(w.gamepads.raven_device == net.REMOTE_DEVICE,"remote input has its own gamepad binding")
		var next_world = load("res://scenes/chapter_two.tscn").instantiate()
		root.add_child(next_world); current_scene=next_world; w.free(); w=next_world
		for i in 6: await process_frame
		check(net.connected() and net.world==w and w.coop,"chapter transition keeps one connected cooperative story")
		check(w.gamepads.raven_device==net.REMOTE_DEVICE,"player-two device follows the new chapter")
		await wait_for(func():return not net.connected())
		check(w.menu_open,"disconnect pauses host story")
		check(not Input.is_action_pressed("raven_move_right"),"disconnect releases remote movement")
		net.close(); check(AudioServer.get_bus_effect_count(0)==previous_effects,"audio capture effect removed on close")
	else:
		check(net.join("not-an-ip","123456",test_port)==ERR_INVALID_PARAMETER,"invalid address rejected without opening socket")
		check(net.join("127.0.0.1","000000",test_port)==OK,"wrong-code trial connects transport only")
		await wait_for(func():return net.role=="offline")
		check(net.role=="offline" and net.status.contains("Code"),"wrong session code cannot claim player two")
		check(net.join("127.0.0.1","123456",test_port)==OK,"client starts real connection")
		await wait_for(func():return net.role=="client")
		check(net.role=="client" and w.process_mode==Node.PROCESS_MODE_DISABLED,"client suspends its local simulation")
		net.pending_axes=Vector2.RIGHT
		await wait_for(func():return net.received_frames>=3)
		check(net.received_frames>=3 and net.picture.texture!=null,"encoded host image arrives and becomes a real texture")
		check(Vector2i(net.picture.texture.get_size())==Vector2i(64,36),"image dimensions preserved")
		check(net.playback!=null,"client audio playback is ready")
		await create_timer(2.0).timeout
		net.pending_axes=Vector2.ZERO
		net.close(); check(w.process_mode!=Node.PROCESS_MODE_DISABLED and w.visible,"local story restored without reloading save")
	await process_frame; await process_frame
	w.free(); current_scene=null; await create_timer(0.2).timeout
	print("LAN %s: %d checks, %d failures" % ["HOST" if hosting else "CLIENT",checks,failures]); quit(1 if failures else 0)
