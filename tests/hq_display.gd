extends SceneTree
## v0.51.0 · CodexAI. Same simulation/input, capped actual game texture at every output.
const Renderer=preload("res://scripts/hq_renderer.gd")
var checks:=0
var failures:=0
var settings
func _initialize():run.call_deferred()
func check(ok:bool,message:String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+message)
func freeze(node:Node):
	node.set_process(false);node.set_physics_process(false)
	for child in node.get_children():freeze(child)
func settle():
	for i in 4:await process_frame
	if settings!=null:settings.renderer.sync_frame()
	if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
func click(control:Control):
	for pressed in [true,false]:
		var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed;event.position=root.get_final_transform()*control.get_global_rect().get_center()
		Input.parse_input_event(event);await process_frame
func pad(button:JoyButton):
	for pressed in [true,false]:
		var e=InputEventJoypadButton.new();e.device=77;e.button_index=button;e.pressed=pressed;Input.parse_input_event(e);await process_frame
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):push_error("Use isolated /tmp/shadepi- data");quit(1);return
	settings=root.get_node("DisplaySettings");settings.preferences_path="user://hq-validation.cfg"
	DirAccess.remove_absolute(settings.preferences_path)
	settings.load_preferences();check(settings.hq_enabled,"new/default installations activate HQ")
	settings.set_hq(false);settings.load_preferences();check(not settings.hq_enabled,"classic choice is saved separately from gameplay")
	var cfg=ConfigFile.new();cfg.set_value("display","hq_enabled","invalid");cfg.save(settings.preferences_path);settings.load_preferences();check(settings.hq_enabled,"invalid HQ preference safely defaults")
	for item in [[Vector2i(1280,720),Vector2i(1280,720)],[Vector2i(1600,900),Vector2i(1600,900)],[Vector2i(1920,1080),Vector2i(1920,1080)],[Vector2i(2560,1440),Vector2i(1920,1080)],[Vector2i(3840,2160),Vector2i(1920,1080)],[Vector2i(2560,1080),Vector2i(1920,1080)],[Vector2i(1024,768),Vector2i(1024,576)]]:
		check(Renderer.target_size(item[0])==item[1],"exact capped 16:9 target for "+str(item[0]))
	var w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w);current_scene=w
	w.cutscene.abort();w._enter(w.Section.HIDEOUT);w.started=true;w.close_menu();w.ui.clear_dialogue();freeze(w)
	root.position=Vector2i.ZERO;root.borderless=true
	w.camera.position=Vector2(540,362);w.camera.force_update_scroll()
	var devices:Array[int]=[77];w.gamepads.assign(devices,false)
	for output in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160),Vector2i(1920,1000),Vector2i(1024,768)]:
		root.size=output;settings.set_hq(true);await settle();settings.renderer.sync_frame()
		var target=settings.renderer.target
		check(target.size==Renderer.target_size(output) and target.size.x<=1920 and target.size.y<=1080,"game target is capped independently of physical output")
		check(target.get_visible_rect().size==Vector2(640,360) and w.get_viewport()==root,"logical view and simulation ownership remain unchanged")
		check(root.canvas_cull_mask==Renderer.PRESENTATION_BIT and target.canvas_cull_mask & Renderer.PRESENTATION_BIT==0,"presentation cannot render into its own source texture")
		var aim=w.raven.global_position+Vector2(45,0)
		var physical=root.get_final_transform()*(w.raven.get_canvas_transform()*aim)
		if DisplayServer.get_name()!="headless":
			DisplayServer.warp_mouse(root.position+Vector2i(physical))
			await settle()
			check(w.raven.get_global_mouse_position().distance_to(aim)<1.5,"real physical mouse maps back to the same world aiming point")
		else:
			var restored=w.raven.get_canvas_transform().affine_inverse()*(root.get_final_transform().affine_inverse()*physical)
			check(restored.distance_to(aim)<.01,"window/world input transforms retain the same aiming point")
		var point=root.get_final_transform()*w.raven.get_global_transform_with_canvas().origin
		if DisplayServer.get_name()!="headless":
			check(target.get_texture().get_image().get_size()==target.size,"GPU readback proves capped real render texture")
			if output==Vector2i(3840,2160):
				var source:Image=target.get_texture().get_image();var presented:Image=root.get_texture().get_image();var correct:bool=presented.get_size()==output
				for y in range(30,1080,83):
					for x in range(30,1920,113):
						var a=source.get_pixel(x,y);var b=presented.get_pixel(x*2,y*2)
						correct=correct and absf(a.r-b.r)<.015 and absf(a.g-b.g)<.015 and absf(a.b-b.b)<.015
				check(correct,"4K presents the same Full-HD pixels at twice their size")
		settings.set_hq(false);await settle()
		var classic_point=root.get_final_transform()*w.raven.get_global_transform_with_canvas().origin
		check(point.distance_to(classic_point)<.1,"HQ preserves physical actor position and camera composition")
		check(root.content_scale_mode==Window.CONTENT_SCALE_MODE_VIEWPORT and settings.renderer.target.size==Vector2i(2,2),"classic releases the HQ framebuffer and restores old rendering")
	settings.set_hq(true);root.size=Vector2i(1920,1080);await settle()
	w._process(.01);check(w.filter_material.get_shader_parameter("pixel_scale")==3.0,"bloom keeps its world-space radius at Full HD")
	w.menu_open=true;w.ui.show_menu();w.ui._open_display_panel();await settle()
	var panel=w.ui.display_panel
	check(root.gui_get_focus_owner()==panel.mode_select,"GUI focus still belongs to the original window")
	await click(panel.quality_select);check(panel.quality_select.get_popup().visible,"physical HD mouse opens HQ dropdown")
	await pad(JOY_BUTTON_B);check(panel.visible and not panel.quality_select.get_popup().visible,"controller B closes the dropdown before the panel")
	panel.quality_select.grab_focus();await pad(JOY_BUTTON_A);await pad(JOY_BUTTON_DPAD_DOWN);await pad(JOY_BUTTON_A)
	check(not settings.hq_enabled and panel.visible,"controller selects classic without losing options panel")
	panel.quality_select.grab_focus();await pad(JOY_BUTTON_A);await pad(JOY_BUTTON_DPAD_UP);await pad(JOY_BUTTON_A)
	check(settings.hq_enabled,"controller reselects HQ while scene remains loaded")
	await pad(JOY_BUTTON_B);check(not panel.visible and root.gui_get_focus_owner()==w.ui.display_button,"closing options restores menu focus")
	w.close_menu();w._enter(w.Section.DIVE,2);freeze(w);await settle()
	check(w.raven.body_material.shader==w.NET_AVATAR and w.ice_guardian()!=null,"net avatar and guardian survive display toggles")
	w.begin_cutscene();await settle();check(settings.renderer.attached.has(w.cutscene),"cinema canvas is mirrored at its original stacking layer")
	w.cutscene.abort();await settle();check(not settings.renderer.attached.has(w.cutscene),"hidden cinema canvas is detached")
	var old=w.ui
	check(change_scene_to_file("res://scenes/chapter_one.tscn")==OK,"normal chapter routing remains valid")
	await scene_changed;await settle();w=current_scene;freeze(w)
	check(settings.hq_enabled and w.get_viewport()==root and w.ui!=old,"chapter change keeps HQ without migrating gameplay nodes")
	check(not settings.renderer.attached.has(old),"removed chapter canvases are not retained")
	settings.set_hq(false);check(root.canvas_cull_mask!=Renderer.PRESENTATION_BIT,"classic restores original visibility mask")
	w.free();current_scene=null;await process_frame
	print("HQ DISPLAY: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
