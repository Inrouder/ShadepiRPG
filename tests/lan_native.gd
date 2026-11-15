extends SceneTree
## v0.62.0 CodexAI: two real rendered windows; actual JPEG stream and remote touch input.
var net
var test_port := 39264
var world
var failures := 0
var checks := 0
func _initialize(): Engine.max_fps = 30; run.call_deferred()
func check(ok: bool, label: String):
	checks += 1
	if not ok: failures += 1; push_error("FAIL: " + label)
func until(test: Callable, seconds: float = 16.0):
	var end := Time.get_ticks_msec()+int(seconds*1000)
	while not test.call() and Time.get_ticks_msec()<end: await process_frame
func screen(index: int, pressed: bool):
	var e := InputEventScreenTouch.new(); e.index=index; e.pressed=pressed
	e.position=root.get_final_transform()*Vector2(128,278); Input.parse_input_event(e)
	for i in 3: await process_frame
func run():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--test-port="): test_port = arg.get_slice("=",1).to_int()
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var hosting := "--lan-host" in OS.get_cmdline_user_args()
	net=root.get_node("NetworkSession")
	root.get_node("DisplaySettings").mode=0; root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	world=load("res://scenes/main.tscn" if hosting else "res://scenes/chapter_one.tscn").instantiate(); root.add_child(world); current_scene=world
	for i in 12: await process_frame
	if hosting:
		world.close_menu(); world.cutscene.abort(); world.ui.clear_dialogue(); world.started=true; world.enemy.active=false
		check(net.host(test_port)==OK,"native host started"); net.pin="123456"
		await until(func():return net.connected())
		var before: Vector2=world.raven.position
		await until(func():return world.raven.position.x>before.x+3)
		check(world.raven.position.x>before.x+3,"actual remote touchscreen moved Raven")
		await until(func():return not net.connected())
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-v062-host.png")
		net.show_lobby()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-v062-lobby.png")
		net.close()
	else:
		check(net.join("127.0.0.1","123456",test_port)==OK,"native client joined")
		await until(func():return net.received_frames>=4)
		check(net.received_frames>=4,"actual host-rendered frames arrived")
		if net.received_frames>=4:
			check(Vector2i(net.picture.texture.get_size())==net.VIDEO_SIZE,"received profile is 960×540")
			await screen(2,true)
			if "--lan-film" in OS.get_cmdline_user_args():
				DirAccess.make_dir_recursive_absolute("/tmp/shadepi-v062-film")
				for frame in 24:
					await create_timer(0.1).timeout
					if frame == 12: await screen(2,false)
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("/tmp/shadepi-v062-film/frame-%03d.png" % frame)
			else: await create_timer(1.3).timeout
			await screen(2,false)
			await create_timer(0.5).timeout
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/shadepi-v062-client.png")
			print("NATIVE STREAM frames: ",net.received_frames)
		net.close()
	world.free(); current_scene=null; await create_timer(0.2).timeout
	print("NATIVE LAN %s: %d checks, %d failures" % ["HOST" if hosting else "CLIENT",checks,failures]); quit(1 if failures else 0)
