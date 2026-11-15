extends SceneTree
## v0.64.0 · CodexAI. Native UI evidence, bounded stream timings and texture counters; isolated saves.
var measurements: Array=[]
func _initialize(): Engine.max_fps=30; run.call_deferred()
func frames(n: int=6):
	for i in n: await process_frame
func snap(name: String):
	await frames(); await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v064-"+name+".png")
func record(name: String):
	await frames()
	var row={"scene":name,"texture_mib":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)/1048576.0,"loaded_worlds":preload("res://scripts/painted_world.gd")._loaded_art.keys()}
	measurements.append(row); print("RESOURCE ",JSON.stringify(row))
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var settings=root.get_node("DisplaySettings"); settings.mode=0
	root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	var w=load("res://scenes/chapter_one.tscn").instantiate(); root.add_child(w); current_scene=w
	await frames(12); root.size=Vector2i(1280,720)
	await record("main-menu")
	w.open_arcade(true); await snap("arcade-title"); await record("arcade")
	var a=w.arcade; a.start_match(0,1,false); await create_timer(1.9).timeout; a.cpu_think=10.0
	await snap("arcade-touch")
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-v064-film")
	for i in 20:
		if i==3: var e:=InputEventJoypadButton.new(); e.device=100; e.button_index=JOY_BUTTON_X; e.pressed=true; Input.parse_input_event(e)
		if i==5: var e:=InputEventJoypadButton.new(); e.device=100; e.button_index=JOY_BUTTON_X; e.pressed=false; Input.parse_input_event(e)
		if i==9: var e:=InputEventJoypadButton.new(); e.device=100; e.button_index=JOY_BUTTON_Y; e.pressed=true; Input.parse_input_event(e)
		if i==11: var e:=InputEventJoypadButton.new(); e.device=100; e.button_index=JOY_BUTTON_Y; e.pressed=false; Input.parse_input_event(e)
		if i==15: a.pause_game("NEON KOMBAT · PAUSE")
		await create_timer(0.1).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-v064-film/%03d.png"%i)
	await snap("arcade-pause")
	if "--ui-only" in OS.get_cmdline_user_args():
		w.free(); current_scene=null; await frames(); quit(); return
	a.close(); await frames(); w.free(); current_scene=null; await frames()
	w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w
	w.cutscene.abort(); w.close_menu(); w.ui.clear_dialogue(); w.started=true; w.enemy.active=false
	await record("world-hq")
	var net=root.get_node("NetworkSession")
	# Bounded renderer in isolation, without requiring a connected network peer.
	var session=load("res://tests/stream_picture.gd").Session.new(); root.add_child(session)
	var picture=load("res://scripts/network_picture.gd").new(); session.add_child(picture)
	for extent in [Vector2i(1280,720),Vector2i(3840,2160)]:
		root.size=extent; await frames()
		var samples: Array=[]
		for i in 4:
			picture.sync_frame(); await RenderingServer.frame_post_draw
			var t:=Time.get_ticks_usec(); var image: Image=picture.target.get_texture().get_image(); var r:=Time.get_ticks_usec()
			var jpg:=image.save_jpg_to_buffer(0.78); var end:=Time.get_ticks_usec()
			samples.append({"read_ms":(r-t)/1000.0,"jpeg_ms":(end-r)/1000.0,"bytes":jpg.size()})
		measurements.append({"window":str(extent),"target":str(picture.target.size),"samples":samples})
	print("MEASUREMENTS ",JSON.stringify(measurements))
	var file:=FileAccess.open("/tmp/shadepi-v064-measurements.json",FileAccess.WRITE); file.store_string(JSON.stringify(measurements,"\t")); file.close()
	session.free(); net.close(); w.free(); current_scene=null; await frames(); quit()
