extends SceneTree
## v0.68.0 · CodexAI. Cold start, notice gating, real input and original menu handoff.
const Startup=preload("res://scenes/startup.tscn")
var b
var output_size:=Vector2i(1280,720)
var checks:=0
var failures:=0
func _initialize():Engine.max_fps=120;run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func frames(n: int=3):
	for i in n:await process_frame
func advance(seconds: float):
	var left:=seconds
	while left>0.000001:
		var dt:=minf(left,1.0/60);b._process(dt);left-=dt
func key(code: Key,pressed: bool,echo: bool=false):
	var e:=InputEventKey.new();e.keycode=code;e.physical_keycode=code;e.pressed=pressed;e.echo=echo
	Input.parse_input_event(e);await process_frame
func pad(pressed: bool):
	var e:=InputEventJoypadButton.new();e.device=77;e.button_index=JOY_BUTTON_A;e.pressed=pressed
	Input.parse_input_event(e);await process_frame
func fresh():
	if is_instance_valid(current_scene):current_scene.free();current_scene=null;await frames()
	b=Startup.instantiate();root.add_child(b);current_scene=b;b.set_process(false);await frames();root.size=output_size;await frames();b.active=true
func capture(name: String):
	if DisplayServer.get_name()=="headless" or not "--startup-capture" in OS.get_cmdline_user_args():return
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png("/tmp/shadepi-v068-"+name+".png")
func wait_menu():
	for i in 300:
		if not is_instance_valid(b) or b.changing_scene:break
		b._process(1.0/60);await process_frame
	await frames(5)
	check(is_instance_valid(current_scene) and current_scene.scene_file_path=="res://scenes/chapter_one.tscn","handoff loads the real existing menu")
	if current_scene.scene_file_path=="res://scenes/chapter_one.tscn":
		check(not current_scene.started and current_scene.menu_open,"confirmation never starts a new game")
		check(current_scene.ui.menu.visible and current_scene.ui.start_backdrop.visible,"normal main menu and backdrop are visible")
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
	root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED;root.size=output_size
	if "--small" in OS.get_cmdline_user_args():output_size=Vector2i(640,360)
	elif "--full-hd" in OS.get_cmdline_user_args():output_size=Vector2i(1920,1080)
	await fresh()
	check(root.size==output_size,"native test window uses the requested physical output size")
	check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/startup.tscn","cold launch uses the startup entry")
	check(b.logo_texture!=null and b.logo_texture.get_size()==Vector2(1920,1080),"original full-HD splash is present")
	check(FileAccess.get_sha256("res://docs/Game Logos.png")==FileAccess.get_sha256("res://assets/branding/game-logos.png"),"runtime PNG is byte-identical to user source")
	check(b.phase==b.Phase.LOGO and b.logo.visible and not b.notices.visible,"logo precedes the notice")
	advance(0.8);check(is_equal_approx(b.logo.modulate.a,1.0),"logo reaches full brightness without flashing")
	await capture("logo")
	var elapsed: float=b.elapsed;b.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT);advance(0.5)
	check(b.elapsed==elapsed,"background focus loss freezes the logo timer")
	b.notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	await key(KEY_ENTER,true);check(b.phase==b.Phase.NOTICE,"Enter skips only to the notice")
	check(b.continue_button.disabled,"notice requires a fresh confirmation after a short reading delay")
	await key(KEY_ENTER,false);await key(KEY_ENTER,true)
	check(b.phase==b.Phase.NOTICE,"early double press cannot bypass the notice")
	advance(0.85);await key(KEY_E,true,true);await key(KEY_ENTER,true,true)
	check(b.phase==b.Phase.NOTICE and not b.continue_button.disabled,"held-key echo cannot auto-dismiss the notice")
	await key(KEY_E,false);await key(KEY_ENTER,false);await frames()
	for item in [b.health,b.breaks,b.legal]:
		check(item.get_line_count()*item.get_line_height()<=item.size.y+1,"notice text fits its visible region")
		check(item.size.x<=537 and item.get_global_rect().end.x<=600,"notice text wraps inside the card instead of growing past the screen")
	check(b.health.get_global_rect().end.y<=b.breaks.position.y,"health text does not overlap break advice")
	check(b.legal.get_global_rect().end.y<=b.continue_button.position.y,"legal text does not overlap Continue")
	var path: String=b.menu_path;b.menu_path="res://scenes/not-a-scene.tscn";b.request_menu()
	check(b.phase==b.Phase.NOTICE and b.hint.text.contains("nicht geladen"),"a missing menu keeps a readable retry screen")
	b.menu_path=path;b.hint.text="ENTER / LEERTASTE / E · CONTROLLER A · TIPPEN"
	await capture("notice")
	await key(KEY_ENTER,true);check(b.phase==b.Phase.LOADING,"fresh Enter requests the menu")
	await wait_menu();await key(KEY_ENTER,false);await frames()
	check(not current_scene.started,"held confirmation does not activate menu actions")
	await capture("menu")
	await fresh();advance(3.0);check(b.phase==b.Phase.NOTICE,"logo advances automatically to the notice")
	advance(1.0);await pad(true);check(b.phase==b.Phase.LOADING,"controller A confirms")
	await wait_menu();await pad(false)
	await fresh();var mobile=root.get_node("MobileControls");mobile.enabled=true
	b.show_notice();advance(1.0);await frames()
	check(not mobile.controls.visible,"story touch HUD stays hidden on the startup notice")
	var touch:=InputEventScreenTouch.new();touch.index=1;touch.pressed=true;touch.position=root.get_final_transform()*b.continue_button.get_global_rect().get_center();Input.parse_input_event(touch);await process_frame
	check(b.phase==b.Phase.LOADING,"touch button works at the scaled viewport position")
	touch=touch.duplicate();touch.pressed=false;Input.parse_input_event(touch);await wait_menu()
	current_scene.free();current_scene=null;await frames()
	print("STARTUP v0.68.0 CodexAI: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
