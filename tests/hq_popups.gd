extends SceneTree
## v0.51.1 · CodexAI. A visible=true flag alone cannot prove that a list is rendered.
const Terminal=preload("res://scripts/terminal_ui.gd")
var checks:=0
var failures:=0
var settings
var w
var film_index:=0
const OUT:="/tmp/shadepi-popup-gallery"
var output_dir:=OUT
func _initialize():
	if "--small" in OS.get_cmdline_user_args():output_dir=OUT+"/small"
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func settle():
	for i in 5:await process_frame
	settings.renderer.sync_frame()
	if DisplayServer.get_name()!="headless":await RenderingServer.frame_post_draw
func pad(button:JoyButton):
	for pressed in [true,false]:
		var e=InputEventJoypadButton.new();e.device=77;e.button_index=button;e.pressed=pressed;Input.parse_input_event(e);await process_frame
func click(control:Control):
	for pressed in [true,false]:
		var e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;e.position=root.get_final_transform()*control.get_global_rect().get_center();Input.parse_input_event(e);await process_frame
func image() -> Image:
	await settle()
	return root.get_texture().get_image()
func visible_list(option:OptionButton,label:String,controller:bool=false):
	option.grab_focus()
	await settle()
	var base:Image
	if DisplayServer.get_name()!="headless":base=await image()
	if controller:option.grab_focus();await pad(JOY_BUTTON_A)
	else:await click(option)
	await settle()
	var popup=option.get_popup()
	check(popup.visible and popup.is_embedded(),label+" opens embedded list")
	if DisplayServer.get_name()!="headless":
		var opened:Image=await image()
		# Embedded Window.position/size are in root's logical coordinates.
		var rect=root.get_final_transform()*Rect2(Vector2(popup.position),Vector2(popup.size))
		var bounds=Rect2i(rect).intersection(Rect2i(Vector2i.ZERO,opened.get_size()))
		var changed:=0;var total:=0
		for y in range(bounds.position.y,bounds.end.y,3):
			for x in range(bounds.position.x,bounds.end.x,3):
				total+=1
				var a=base.get_pixel(x,y);var b=opened.get_pixel(x,y)
				if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>.05:changed+=1
		check(total>100 and changed>total*.12,label+" is visibly painted above HQ image")
		if label=="anzeige":
			var layer=settings.renderer.presentation.layer;var speed=Engine.time_scale;Engine.time_scale=0
			settings.renderer.presentation.layer=1024
			var hidden:Image=await image()
			settings.renderer.presentation.layer=layer
			var shown:Image=await image();var revealed:=0
			for y in range(bounds.position.y,bounds.end.y,3):
				for x in range(bounds.position.x,bounds.end.x,3):
					var a=shown.get_pixel(x,y);var b=hidden.get_pixel(x,y)
					if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>.05:revealed+=1
			check(popup.visible and revealed>total*.12,"pixel regression distinguishes rendered from invisible-but-open popup")
			Engine.time_scale=speed

		if "--gallery" in OS.get_cmdline_user_args():
			opened.save_png(output_dir+"/"+label+".png")
			# Film is a native logical-size capture drawn to a 640×360 test window later.
			opened.save_png(output_dir+"/frame-%03d.png"%film_index);film_index+=1
	await pad(JOY_BUTTON_B);await settle()
	check(not popup.visible,label+" B closes list")
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):push_error("Isolated /tmp/shadepi- data required");quit(1);return
	settings=root.get_node("DisplaySettings");settings.preferences_path="user://popup-test.cfg";settings.set_hq(true)
	root.position=Vector2i.ZERO;root.borderless=true;root.size=Vector2i(1920,1080)
	if "--small" in OS.get_cmdline_user_args():root.size=Vector2i(640,360)
	if "--4k" in OS.get_cmdline_user_args():root.size=Vector2i(3840,2160)
	DirAccess.make_dir_recursive_absolute(output_dir)
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w);current_scene=w
	w.cutscene.abort();w.ui.clear_dialogue();w.started=true;w.menu_open=true;w.ui.show_menu()
	var devices:Array[int]=[77];w.gamepads.assign(devices,false)
	await settle()
	check(settings.renderer.presentation.layer<1024,"HQ presentation stays below Godot embedded windows")
	check(root.canvas_cull_mask==settings.HQRenderer.PRESENTATION_BIT and settings.renderer.target.canvas_cull_mask & settings.HQRenderer.PRESENTATION_BIT==0,"HQ keeps its existing isolated output and game image")
	check(w.player.visual.visibility_layer==1,"dropdown fix does not change original item visibility masks")
	w.ui._open_display_panel();settings.mode=settings.Mode.WINDOWED;w.ui.display_panel._sync()
	await visible_list(w.ui.display_panel.quality_select,"anzeige",true)
	await visible_list(w.ui.display_panel.mode_select,"bildschirmmodus")
	await visible_list(w.ui.display_panel.resolution_select,"aufloesung",true)
	await visible_list(w.ui.display_panel.scaling_select,"skalierung")
	check(w.ui.display_panel.visible,"closing quality list keeps settings open")
	w.ui.display_panel.dismiss();w.ui._toggle_admin_panel();w.set_admin_option("unlock_all",true);w.ui._refresh_admin_controls();w.ui.admin_checks["unlock_all"].set_pressed_no_signal(true)
	await visible_list(w.ui.admin_chapter_picker,"kapitel",true)
	check(w.ui.admin_panel.visible,"closing chapter list keeps test menu open")
	w.ui.admin_chapter_picker.grab_focus();await pad(JOY_BUTTON_A);await pad(JOY_BUTTON_DPAD_DOWN);await pad(JOY_BUTTON_A);await settle()
	check(w.ui.admin_chapter_picker.selected==1 and w.ui.admin_checkpoint_picker.get_item_text(0)=="Industriehof","chapter selection refreshes the actual checkpoint list")
	await visible_list(w.ui.admin_checkpoint_picker,"kontrollpunkte")
	w.ui.admin_checkpoint_picker.grab_focus();await pad(JOY_BUTTON_A);await pad(JOY_BUTTON_DPAD_DOWN);await pad(JOY_BUTTON_A);await settle()
	check(w.ui.admin_checkpoint_picker.selected==1,"controller confirms checkpoint choice")
	w.ui._close_admin_panel();w.close_menu()
	for context in ["power","repair"]:
		var terminal=Terminal.new();terminal.context=context;w.add_child(terminal);w.terminal=terminal;terminal.set_process(false)
		await settle()
		var count:=0
		for control in terminal.controls:
			if control is OptionButton:
				await visible_list(control,context+"-"+str(count),count%2==0)
				check(not terminal.closed,context+" B does not abort hack from dropdown")
				control.grab_focus();await pad(JOY_BUTTON_A);await pad(JOY_BUTTON_DPAD_DOWN);await pad(JOY_BUTTON_A);await settle()
				check(control.selected==1 and not control.get_popup().visible,context+" controller confirms actual list choice")
				count+=1
		check(count>0,context+" includes all option controls")
		w.terminal=null;terminal.free();await process_frame
	settings.set_hq(false);check(w.player.visual.visibility_layer==1,"classic restores source visibility masks")
	settings.set_hq(true);check(w.player.visual.visibility_layer==1,"HQ can be enabled again without changing item masks")
	w.free();current_scene=null;await process_frame
	check(settings.renderer.attached.is_empty(),"removed scene leaves no attached game UI canvases")
	print("HQ POPUPS: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
