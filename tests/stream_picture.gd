extends SceneTree
## v0.64.0 · CodexAI. Native pixels: bounded shared render target, local HUD isolation and popups.
class Session extends Node:
	const VIDEO_SIZE:=Vector2i(960,540)
	var in_flight:=-1
	var clock:=100.0
	var frame_clock:=0.0
	var profile:=0
	func is_host(): return true
	func connected(): return true
var checks:=0
var failures:=0
var picture
func _initialize(): Engine.max_fps=30; run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok: failures+=1; push_error("FAIL: "+label)
func snap() -> Image:
	for i in 5: await process_frame
	picture.sync_frame(); await RenderingServer.frame_post_draw
	return picture.target.get_texture().get_image()
func difference(a: Image,b: Image,rect: Rect2i) -> int:
	var count:=0
	for y in range(rect.position.y,rect.end.y,2):
		for x in range(rect.position.x,rect.end.x,2):
			var ca:=a.get_pixel(x,y); var cb:=b.get_pixel(x,y)
			if absf(ca.r-cb.r)+absf(ca.g-cb.g)+absf(ca.b-cb.b)>0.08: count+=1
	return count
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var settings=root.get_node("DisplaySettings"); settings.mode=0
	root.mode=Window.MODE_WINDOWED; root.size=Vector2i(3840,2160)
	var mobile=root.get_node("MobileControls"); mobile.enabled=true
	var w=load("res://scenes/main.tscn").instantiate(); root.add_child(w); current_scene=w
	w.close_menu(); w.cutscene.abort(); w.ui.clear_dialogue(); w.started=true; w.enemy.active=false
	var session:=Session.new(); root.add_child(session)
	picture=load("res://scripts/network_picture.gd").new(); session.add_child(picture)
	for i in 6: await process_frame
	root.mode=Window.MODE_WINDOWED; root.size=Vector2i(3840,2160)
	Engine.time_scale=0.0
	var with_hud:=await snap(); var physical:=root.get_texture().get_image()
	print("STREAM SIZES ",physical.get_size()," → ",with_hud.get_size())
	check(physical.get_size()==Vector2i(3840,2160) and with_hud.get_size()==session.VIDEO_SIZE,"4K window produces a native 960x540 stream target")
	with_hud.save_png("/tmp/shadepi-v064-stream-clean.png")
	# Isolate overlay pixels from TIME-driven weather shaders using a static shared canvas.
	w.hide(); w.ui.hide()
	var fixture:=ColorRect.new(); fixture.size=Vector2(640,360); fixture.color=Color("142335"); root.add_child(fixture)
	with_hud=await snap()
	mobile.enabled=false
	var without_hud:=await snap()
	check(difference(with_hud,without_hud,Rect2i(0,0,960,540))<20,"host touch HUD contributes no pixels to the shared image")
	fixture.free(); w.show(); w.ui.show()
	w.menu_open=true; w.ui.show_menu(); w.ui._open_display_panel()
	var before:=await snap(); var option=w.ui.display_panel.quality_select
	for down in [true,false]:
		var e:=InputEventMouseButton.new(); e.button_index=MOUSE_BUTTON_LEFT; e.pressed=down; e.position=root.get_final_transform()*option.get_global_rect().get_center(); Input.parse_input_event(e); await process_frame
	var opened:=await snap(); var popup=option.get_popup()
	var rect:=Rect2(Vector2(popup.position),Vector2(popup.size))
	var region:=Rect2i(Rect2(rect.position*1.5,rect.size*1.5)).intersection(Rect2i(0,0,960,540))
	check(popup.visible and region.get_area()>100 and difference(before,opened,region)>region.get_area()/40,"embedded dropdown is visibly transmitted above HQ game")
	opened.save_png("/tmp/shadepi-v064-stream-popup.png"); popup.hide()
	session.profile=1
	var low:=await snap(); check(low.get_size()==Vector2i(640,360),"low-bandwidth profile owns a bounded 640x360 target")
	Engine.time_scale=1.0; session.free(); w.free(); current_scene=null
	for i in 3: await process_frame
	print("STREAM PICTURE v0.64.0 CodexAI: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
