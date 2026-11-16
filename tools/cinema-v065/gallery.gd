extends SceneTree
## v0.65.0 · CodexAI. Real game frames; isolated saves, no generators or pixel redraws.
var w
func _initialize(): Engine.max_fps=30; run.call_deferred()
func frames(n: int=4):
	for i in n: await process_frame
func snap(name: String):
	await frames(); await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v065-"+name+".png")
func capture_frame(folder: String,index: int):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v065-"+folder+"/%03d.png"%index)
func prepare(folder: String):
	var path:="/tmp/shadepi-v065-"+folder
	DirAccess.make_dir_recursive_absolute(path)
	for file in DirAccess.get_files_at(path):
		if file.ends_with(".png"): DirAccess.remove_absolute(path+"/"+file)
func enter(beat: int):
	w.fresh_entry=false; w._enter(beat); w.cutscene.abort(); w.ui.clear_dialogue(); w.close_menu(); w.ui.show(); w.set_process(false)
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	set_meta("shadepi_admin_testing",true)
	root.get_node("DisplaySettings").mode=0; root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	w=load("res://scenes/campaign.tscn").instantiate(); root.add_child(w); current_scene=w
	await frames(12); root.size=Vector2i(1280,720)
	if "--garage-only" in OS.get_cmdline_user_args():
		enter(w.Beat.GARAGE); w.player.hide(); w.raven.hide(); w.ui.hide(); w.bike_mode="none"
		w.camera.position=Vector2(314,210); w.camera.zoom=Vector2.ONE*1.7; w.camera.force_update_scroll()
		w.garage_door=0.35; w.queue_redraw(); await snap("garage-partial")
		w.garage_door=0.85; w.queue_redraw(); await snap("garage-open")
		w.free(); current_scene=null; await frames(); quit(); return
	if "--outbound-only" not in OS.get_cmdline_user_args():
		enter(w.Beat.CHASE)
		var drive=w.drive; drive.set_process(false); drive.scroll=137.0; drive.elapsed=4.0
		drive.hazards.assign([Vector2(242,-48),Vector2(398,92)]); drive.next_hazard=999; drive.next_drone=999
		drive.transform=Transform2D.IDENTITY; drive.queue_redraw(); await snap("drive-before")
		drive.transform=drive.View.projection(); drive.queue_redraw(); await snap("drive-after")
		prepare("roll")
		drive.hazards.clear(); drive.stage=2; drive.armour=0; drive._process(0.01)
		for i in 39:
			drive._process(0.15); await capture_frame("roll",i)
			if i==7: await snap("roll-side")
			if i==11: await snap("roll-blast")
			if i==37: await snap("drive-exit")
		enter(w.Beat.FLIGHT)
		var flight=w.drive; flight.set_process(false); flight.engine_repaired=true; flight.scroll=197.0
		flight.hazards.assign([{"k":"cargo","p":Vector2(245,-55),"vx":0.0,"near":false},{"k":"bridge","p":Vector2(0,88),"gap":360.0,"w":130.0,"narrow":false,"near":false}])
		flight.transform=Transform2D.IDENTITY; flight.overlay.transform=Transform2D.IDENTITY; flight.queue_redraw(); await snap("flight-before")
		flight.transform=flight.View.projection(); flight.overlay.transform=flight.transform.affine_inverse(); flight.queue_redraw(); await snap("flight-after")
		enter(w.Beat.GARAGE); w.player.hide(); w.raven.hide(); w.ui.hide(); w.bike_mode="none"
		w.camera.position=Vector2(314,210); w.camera.zoom=Vector2.ONE*1.7; w.camera.force_update_scroll()
		w.garage_door=0.35; w.queue_redraw(); await snap("garage-partial")
		w.garage_door=0.85; w.queue_redraw(); await snap("garage-open")
	enter(w.Beat.ROOF)
	var scene=load("res://scripts/outbound_flight.gd").new(); scene.world=w; w.drive_layer.add_child(scene)
	var cs=w.begin_cutscene(); var ticket: int=cs.generation
	scene.play(cs,ticket)
	prepare("outbound")
	Engine.time_scale=3
	var index:=0; var waited:=0; var saved_camp:=false; var saved_time:=false
	for i in 600:
		await process_frame
		if cs.waiting_input:
			waited+=1
			if waited>18: cs.advance(); waited=0
		if i%3==0:
			await capture_frame("outbound",index); index+=1
		if scene.stage=="conversation" and not saved_camp:
			await snap("nomads"); saved_camp=true
		if scene.stage=="two_hours_later": Engine.time_scale=1
		if scene.stage=="two_hours_later" and cs.title_label.modulate.a>0.8 and not saved_time:
			w.menu_open=true; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/shadepi-v065-two-hours.png")
			w.menu_open=false; saved_time=true
		if saved_time and cs.title_label.modulate.a<0.05: break
	# Actual existing arrival, after the same black time card, using unmodified lake poses.
	Engine.time_scale=3
	w.fresh_entry=true; w._enter(w.Beat.LAKE); scene.free(); w.set_process(true)
	for i in 65:
		await process_frame
		if i%3==0: await capture_frame("outbound",index); index+=1
		if i==34: await snap("lake-entry")
		if w.cutscene.waiting_input: w.cutscene.advance()
	Engine.time_scale=1; w.free(); current_scene=null; await frames(); quit()
