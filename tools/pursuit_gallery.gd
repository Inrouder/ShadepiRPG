extends SceneTree
## v0.41.0 · CodexAI. Actual pursuit, shot origins, release and rotor source review.
const Car = preload("res://scripts/pursuit_car_art.gd")
const Drone = preload("res://scripts/cargo_drone_art.gd")
const OUT := "/tmp/shadepi-pursuit-v041"
var seen := {}
var frames := 0
func _initialize(): run.call_deferred()
func capture(tag: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"/"+tag+".png")
	seen[tag] = true
func run():
	set_meta("shadepi_admin_testing",true)
	DirAccess.make_dir_recursive_absolute(OUT+"/film")
	Engine.time_scale = 1
	Engine.max_fps = 60
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.CHASE)
	w.set_process(false)
	w.admin_flags["god_mode"] = true
	var d = w.drive
	d.set_process(false)
	var clock := 0.0
	var hacked := false
	var source_frames := {}
	var rotor_frames := {}
	while clock<13:
		await process_frame
		var delta := minf(root.get_process_delta_time(),0.05)
		clock += delta
		d._process(delta)
		d.armour = 100
		source_frames[d.car_frame()] = true
		if d.car_recoil>0.23 and not seen.has("shot"): await capture("shot")
		if d.ram_warning>0.2 and not seen.has("ram"): await capture("ram")
		if not d.drones.is_empty():
			rotor_frames[Drone.frame_for(d.fx_clock)] = true
			if d.drones[0].state=="hover" and not seen.has("drone"): await capture("drone")
			if d.drones[0].drops>0 and not seen.has("release"): await capture("release")
			if clock>9 and not hacked:
				# QA positions the bike under the current target; the actual hack action follows.
				d.x = d.drones[0].p.x
				Input.action_press("hack")
				d._bike_weapons()
				Input.action_release("hack")
				hacked = true
			if d.drones[0].state=="hacked" and not seen.has("hacked"): await capture("hacked")
		if frames%3==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+"/film/frame-%04d.png"%(frames/3))
		frames += 1
	w._enter(w.Beat.FLIGHT)
	w.set_process(false)
	w.drive.set_process(false)
	w.drive.hazards.append({"k":"cargo","p":Vector2(320,180),"vx":0.0,"near":false})
	w.drive.queue_redraw()
	await capture("flight-cargo")
	w._enter(w.Beat.GARAGE)
	w.queue_free()
	await process_frame
	print("PURSUIT GALLERY: ",seen,"; source frames=",source_frames,"; rotor frames=",rotor_frames,"; film frames=",ceili(frames/3.0))
	quit(0 if source_frames.size()==9 and rotor_frames.size()==4 and seen.size()==6 else 1)
