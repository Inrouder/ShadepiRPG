extends SceneTree
## v0.63.0 CodexAI. Native viewport evidence; never touches normal player saves.
func _initialize(): Engine.max_fps=30; run.call_deferred()
func snap(name: String):
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v063-"+name+".png")
func touch(index: int, point: Vector2, down: bool):
	var e:=InputEventScreenTouch.new(); e.index=index; e.position=root.get_final_transform()*point; e.pressed=down; Input.parse_input_event(e)
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	root.get_node("DisplaySettings").mode=0; root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	var w=load("res://scenes/chapter_one.tscn").instantiate(); root.add_child(w); current_scene=w
	await snap("main-menu")
	w.admin_flags["unlock_all"]=true; w.ui.show_menu()
	await snap("unlocked-menu")
	w.free()
	w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w
	w.cutscene.abort(); w.close_menu(); w.ui.clear_dialogue(); w.started=true; w.enemy.active=false
	await snap("touch-idle")
	var mobile=root.get_node("MobileControls")
	touch(0,mobile.STICK_CENTER+Vector2(mobile.STICK_RADIUS*0.8,0),true)
	touch(1,mobile.surfaces[JOY_BUTTON_X].get_center(),true)
	await snap("touch-active")
	touch(0,mobile.STICK_CENTER,false); touch(1,mobile.surfaces[JOY_BUTTON_X].get_center(),false)
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-v063-film")
	for i in 20:
		if i==3: touch(0,mobile.STICK_CENTER+Vector2(32,0),true)
		if i==7: touch(1,mobile.surfaces["rt"].get_center(),true)
		if i==14: touch(1,mobile.surfaces["rt"].get_center(),false)
		if i==16: touch(0,mobile.STICK_CENTER,false)
		await create_timer(0.1).timeout; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/shadepi-v063-film/%03d.png"%i)
	w.ui.network_button.grab_focus(); w.ui.network_button.pressed.emit()
	await snap("network")
	root.get_node("NetworkSession").lobby.hide()
	w.free(); current_scene=null; await create_timer(0.2).timeout
	quit()
