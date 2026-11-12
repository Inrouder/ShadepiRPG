extends SceneTree
## v0.35.1 · CodexAI. Actual roof launch, preserved landing and fall past a lower balcony.
const Painted = preload("res://scripts/painted_world.gd")
const Opening = preload("res://scripts/tower_story.gd")
const Hangar = preload("res://scripts/hangar_departure.gd")
const Escape = preload("res://scripts/tower_escape.gd")
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+text)

func clear_path(a: Vector2, b: Vector2, layout: String) -> bool:
	for i in 101:
		var point := a.lerp(b,i/100.0)
		for rect: Rect2 in Painted.SOLIDS[layout]:
			if rect.grow(7).has_point(point): return false
	return true

func run() -> void:
	Engine.max_fps = 240
	Engine.time_scale = 6
	check(clear_path(Opening.KENZO_WAIT,Vector2(600,388),"suite"),"Kenzō waits and approaches outside the chair and tables")
	var previous: Vector2 = Opening.ENTRY
	for point in Opening.RAVEN_APPROACH:
		check(clear_path(previous,point,"suite"),"Raven's actual entrance route avoids the suite furniture")
		previous = point
	for i in 2:
		previous = Hangar.STARTS[i]
		check(previous.y<535 and clear_path(previous,previous,"hangar"),"hangar entry is clear floor, before the foreground wall")
		for leg in Hangar.ROUTE:
			check(clear_path(previous,leg[i],"hangar"),"full hangar route clears consoles, crate and cylinder")
			previous = leg[i]
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 6
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	check(w.foes.back().position==Opening.KENZO_WAIT and w.foes.back().visible,"Kenzō is established visibly beside the chair in the first frame")
	check(w.raven.position==Opening.ENTRY and not w.player.visible,"Raven enters from the room entrance; Shadepi has not appeared")
	var saw_grip := false
	var walk_frames := 0
	var previous_player: Vector2 = w.player.position
	var approach_frames := 0
	for i in 1500:
		await process_frame
		if not is_instance_valid(w.tower_grip) and w.raven.position.x>Opening.ENTRY.x+50 and not w.player.visible:
			approach_frames += 1
		if is_instance_valid(w.tower_grip): saw_grip = true
		if w.player.visible and w.player.position.distance_to(previous_player)>0.1:
			walk_frames += 1
		previous_player = w.player.position
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(approach_frames>8,"Raven visibly crosses the room before the physical grab")
	check(saw_grip and walk_frames>8,"Shadepi reaches the grip by running through several frames, not spawning beside it")
	check(w.player.visible and not w.player.cloaked and w.raven.visual.visible,"opening restores playable figures after intervention")
	w._enter(w.Beat.ESCAPE,0,3)
	w._complete_point()
	w.skip_passages()
	var d = w.tower_departure
	check(d.view=="roof" and d.craft==w.aerodyne_spot-Vector2(0,20),"departure starts at the actual parked craft on the rooftop pad")
	for i in 2:
		previous = Escape.STARTS[i]
		for leg in d.roof_route():
			check(clear_path(previous,leg[i],"rooftop"),"roof route reaches the pad without crossing its console or doorway")
			previous = leg[i]
	w.aerodyne_spot = Vector2(198,344)
	check(w.save_game(),"landing position saves with departure checkpoint")
	w.aerodyne_spot = Vector2.ZERO
	check(w.load_game() and w.aerodyne_spot==Vector2(198,344),"landing position survives a complete checkpoint load")
	d = w.tower_departure
	check(d.park==Vector2(198,324),"loaded departure boards the same spot used at touchdown")
	var old_save := ConfigFile.new()
	var checkpoint: String = w.Admin.checkpoint_path(w.SAVE,self)
	old_save.load(checkpoint)
	old_save.erase_section_key("campaign","aerodyne_spot")
	old_save.save(checkpoint)
	check(w.load_game() and w.aerodyne_spot==Escape.Flight.PAD_WORLD,"older saves without a landing field use the original pad")
	old_save.set_value("campaign","aerodyne_spot","broken")
	old_save.save(checkpoint)
	check(w.load_game() and w.aerodyne_spot==Escape.Flight.PAD_WORLD,"invalid landing data falls back safely to the original pad")
	d = w.tower_departure
	for segment in 3:
		# A millisecond-scale sample avoids Vector2 float rounding at fast descent.
		var epsilon := 0.001
		d.flight_step(segment,1-epsilon)
		var a: Vector2 = d.craft
		d.flight_step(segment,1)
		var join: Vector2 = d.craft
		d.flight_step(segment+1,0)
		check(d.craft.distance_to(join)<0.0001,"flight position continuous at phase join")
		d.flight_step(segment+1,epsilon)
		var velocity_before: Vector2 = (join-a)/(epsilon*Escape.FLIGHT[segment][4])
		var velocity_after: Vector2 = (d.craft-join)/(epsilon*Escape.FLIGHT[segment+1][4])
		check(velocity_before.distance_to(velocity_after)<1.0,"flight velocity continuous at phase join; no abrupt stop/drop")
	for roll in [0.0,0.7,1.3,2.05]:
		d.vehicle.set_pose(Vector2(330,215),0.6,roll,0.8,2.1)
		for plume in d.vehicle.plumes:
			check(plume.get_parent()==d.vehicle.pivot and plume.visible,"exhaust inherits the hull's perspective and roll")
	var clock_before: float = d.clock
	w.menu_open = true
	var shader_clock: float = d.vehicle.plumes[0].material.get_shader_parameter("clock")
	await process_frame
	await process_frame
	check(d.clock==clock_before and d.vehicle.plumes[0].material.get_shader_parameter("clock")==shader_clock,"pause freezes geometry and the flame shader clock")
	w.close_menu()
	w.cutscene.abort()
	w._enter(w.Beat.ESCAPE,0,3)
	w._complete_point()
	w.skip_passages()
	d = w.tower_departure
	var same_deck: Node = d.deck
	var same_vehicle: Node = d.vehicle
	var uninterrupted := true
	var saw_launch := false
	var saw_fall := false
	var passed_balcony := false
	var recovered_below := false
	var discontinuity := ""
	for i in 1600:
		await process_frame
		if not is_instance_valid(w.tower_departure): break
		if d.stage in ["run","board","launch","tip"]:
			uninterrupted = uninterrupted and d.view=="roof"
			if d.stage=="launch": saw_launch = true
		if d.stage in ["tip","fall","ignition","blast"]:
			uninterrupted = uninterrupted and d.deck==same_deck and d.deck.visible and d.vehicle==same_vehicle
			if d.stage=="fall":
				uninterrupted = uninterrupted and saw_launch and d.left_roof and d.view=="facade"
				if d.craft.y<90: saw_fall = true
				if saw_fall and d.craft.y>180: passed_balcony = true
			if d.stage=="ignition" and d.power>0.6 and d.craft.y>220:
				recovered_below = passed_balcony
			if d.stage in ["tip","fall","ignition"]:
				uninterrupted = uninterrupted and w.cutscene.overlay.color.a<0.01
			if not uninterrupted: discontinuity = d.stage+" overlay="+str(w.cutscene.overlay.color)
		if w.cutscene.waiting_input: w.cutscene.advance()
		if w.beat==w.Beat.LAKE: break
	check(uninterrupted and w.beat==w.Beat.LAKE,"roof launch precedes the motivated facade view, with the same craft and no fade during descent: "+discontinuity)
	check(saw_launch and saw_fall and passed_balcony and recovered_below,"craft comes from above the balcony and catches itself below, after leaving the pad")
	w.fresh_entry = true
	w.flight_intro_pending = true
	w._enter(w.Beat.FLIGHT)
	var launch = w.departure
	var maximum_x := 0.0
	var first_boarding := false
	var boarding_pause_checked := false
	for i in 2200:
		await process_frame
		if not is_instance_valid(w.departure): break
		if launch.stage=="boarding":
			maximum_x = maxf(maximum_x,launch.squad[0].position.x)
			if launch.squad[1].modulate.a<0.5 and launch.squad[0].modulate.a>0.9: first_boarding = true
			if not boarding_pause_checked and launch.squad[1].modulate.a<0.8 and launch.squad[1].modulate.a>0.1:
				w.menu_open = true
				var animation_before: float = launch.squad[1].animation_time
				var position_before: Vector2 = launch.squad[1].position
				for frame in 5: await process_frame
				check(launch.squad[1].animation_time==animation_before and launch.squad[1].position==position_before,"pause freezes boarding footwork as well as the route")
				boarding_pause_checked = true
				w.close_menu()
		if w.cutscene.waiting_input: w.cutscene.advance()
	check(maximum_x>800 and first_boarding and boarding_pause_checked,"both cross the hangar aisle; Raven boards before Shadepi")
	check(w.departure==null and w.drive.visible and not w.flight_intro_pending,"new boarding still hands over to the existing flight")
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	await process_frame
	w._enter(w.Beat.HANGAR)
	check(w.player.visible==not w.raven_leads() and w.raven.visible,"chapter change during approach restores the chapter's normal character visibility")
	w.cutscene.skip()
	w.queue_free()
	await process_frame
	Engine.time_scale = 1
	print("CINEMATIC BLOCKING: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
