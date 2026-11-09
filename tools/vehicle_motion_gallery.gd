extends SceneTree
## v0.40.0 · CodexAI. Real steering in the chase and flight, with source comparison.
const OUT := "/tmp/shadepi-vehicles-v040"
var frames := {"bike":0,"flight":0}
func _initialize(): run.call_deferred()
func shot(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+name+".png")
func release():
	for action in ["move_left","move_right","move_up","move_down","dash"]: Input.action_release(action)
func run():
	set_meta("shadepi_admin_testing",true)
	for name in frames: DirAccess.make_dir_recursive_absolute(OUT+"/"+name)
	Engine.max_fps = 60
	Engine.time_scale = 1
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.admin_flags["god_mode"] = true
	for kind in ["bike","flight"]:
		w._enter(w.Beat.CHASE if kind=="bike" else w.Beat.FLIGHT)
		w.set_process(false)
		var d = w.drive
		d.set_process(false)
		if kind=="flight": d.engine_repaired = true
		for leg in ["neutral","left","neutral-again","right","brake","dodge","return"]:
			release()
			if leg=="left": Input.action_press("move_left",0.8)
			if leg=="right": Input.action_press("move_right",0.8)
			if leg=="brake": Input.action_press("move_down")
			if leg=="dodge" and kind=="flight":
				d.roll = d.ROLL_TIME
				d.roll_dir = -1
				d.vel.x -= 330
			var seen := false
			var clock := 0.0
			while clock<1.0:
				await process_frame
				var delta := minf(root.get_process_delta_time(),0.05)
				clock += delta
				d._process(delta)
				# QA god mode avoids combat damage while actual driving/rendering remain active.
				if kind=="bike": d.armour = 100
				if clock>0.35 and not seen:
					await shot(kind+"-"+leg)
					seen = true
				if int(clock*60)%3==0:
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png(OUT+"/"+kind+"/frame-%04d.png"%frames[kind])
					frames[kind] += 1
		release()
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	w.set_process(true)
	var saw_turn := false
	for i in 2500:
		await process_frame
		var lake = w.lake_sequence
		if lake.stage=="descent" and absf(lake.bank)>0.5 and not saw_turn:
			await shot("lake-turn")
			saw_turn = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	print("ACTUAL LAKE ARRIVAL: bank seen=",saw_turn,"; stage=",w.lake_sequence.stage)
	w._enter(w.Beat.ROOF)
	w.queue_free()
	await process_frame
	print("VEHICLE MOTION GALLERY: ",frames)
	quit()
