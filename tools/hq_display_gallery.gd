extends SceneTree
## v0.51.0 · CodexAI. Actual window, source render target, 4K cap and moving HQ scene.
const OUT := "/tmp/shadepi-hq-gallery"
var w
var settings
var frame:=0
var records:Array=[]
func _initialize():run.call_deferred()
func settle():
	for i in 5:await process_frame
	settings.renderer.sync_frame()
	await RenderingServer.frame_post_draw
func shot(tag:String):
	await settle()
	var file=OUT+"/"+tag+".png";var output:Array=[]
	var crop="%dx%d+%d+%d"%[root.size.x,root.size.y,root.position.x,root.position.y]
	if OS.execute("import",PackedStringArray(["-window","root","-crop",crop,"+repage",file]),output)!=0:push_error("Physical screenshot failed")
	if settings.hq_enabled:settings.renderer.target.get_texture().get_image().save_png(OUT+"/"+tag+"-source.png")
	var point=root.get_final_transform()*w.raven.get_global_transform_with_canvas().origin
	var image=Image.load_from_file(file)
	if image.get_size()!=root.size:push_error("Capture is clipped by desktop: "+str(image.get_size()));quit(1);return
	var origin=(Vector2i(point)-Vector2i(320,240)).clamp(Vector2i.ZERO,root.size-Vector2i(640,360))
	image.get_region(Rect2i(origin,Vector2i(640,360))).save_png(OUT+"/"+tag+"-detail.png")
	records.append({"tag":tag,"output":[root.size.x,root.size.y],"hq":settings.hq_enabled,"internal":[settings.game_render_size().x,settings.game_render_size().y]})
func run():
	DirAccess.make_dir_recursive_absolute(OUT);set_meta("shadepi_admin_testing",true)
	settings=root.get_node("DisplaySettings");settings.mode=settings.Mode.WINDOWED;root.mode=Window.MODE_WINDOWED;root.borderless=true;root.position=Vector2i.ZERO
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w);w.cutscene.abort();w._enter(w.Section.HIDEOUT);w.started=true;w.close_menu();w.ui.clear_dialogue();w.ui.clear_toast()
	w.set_process(false);w.raven.set_physics_process(false);w.player.set_physics_process(false)
	w.player.position=Vector2(505,425);w.raven.position=Vector2(560,425);w.player.facing=Vector2.RIGHT;w.raven.facing=Vector2.LEFT;w.player.animate("idle",0);w.raven.animate("idle",0);w.camera.position=Vector2(540,362)
	for output in [Vector2i(1920,1080),Vector2i(3840,2160)]:
		root.size=output
		for hq in [false,true]:
			settings.set_hq(hq);w.filter_material.set_shader_parameter("pixel_scale",settings.game_render_scale());await shot(("hq" if hq else "classic")+"-"+str(output.y))
	root.size=Vector2i(1920,1080);settings.set_hq(true);w.menu_open=true;w.ui.show_menu();w.ui._open_display_panel();await shot("options")
	for pressed in [true,false]:
		var e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;e.position=root.get_final_transform()*w.ui.display_panel.quality_select.get_global_rect().get_center();Input.parse_input_event(e);await process_frame
	await shot("quality-list");w.ui.display_panel.dismiss();w.close_menu()
	if "--stills-only" in OS.get_cmdline_user_args():
		w.free();await process_frame;print("HQ STILL GALLERY complete");quit();return
	w._enter(w.Section.DIVE,2);w.ui.clear_toast();w.raven.position=Vector2(1095,530);w.camera.position=w.ice_camera_home();w.set_process(false);w.raven.set_physics_process(false);w.ice_guardian().set_process(false)
	w.filter_material.set_shader_parameter("pixel_scale",settings.game_render_scale());await shot("ice")
	for i in 48:
		w.raven.facing=Vector2.from_angle((i/6)*PI/4);w.raven.animate("walk",.1);w._sync_net_avatar(.1)
		await settle()
		var image=settings.renderer.target.get_texture().get_image()
		var p=Vector2i(912,629);var crop=Rect2i(p-Vector2i(320,240),Vector2i(640,360))
		image.get_region(crop).save_png(OUT+"/frame-%04d.png"%frame);frame+=1
	w.free();await process_frame
	var file=FileAccess.open(OUT+"/measurements.json",FileAccess.WRITE);file.store_string(JSON.stringify(records,"\t"));file.close()
	print("HQ GALLERY: %d frames, %d real window / render target pairs"%[frame,records.size()]);quit()
