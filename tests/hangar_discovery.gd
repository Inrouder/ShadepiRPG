extends SceneTree
## v0.39.0 · CodexAI. Platform continuity, uncluttered paths and safe actor ownership.
const Art = preload("res://scripts/hangar_art.gd")
const Discovery = preload("res://scripts/hangar_discovery.gd")
const Painted = preload("res://scripts/painted_world.gd")
const Dressing = preload("res://scripts/world_dressing.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, text: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+text)
func finish(w):
	for i in 1300:
		await process_frame
		if not w.cutscene.running: return
		w.cutscene.skip()
	check(false,"discovery completes after skip")
func clear_path(a: Vector2,b: Vector2) -> bool:
	var obstacles: Array[Rect2] = []
	obstacles.assign(Painted.SOLIDS.hangar)
	for item in Dressing.items("hangar"):
		var size: Vector2 = WorldProp.TYPES[item[1]].footprint
		obstacles.append(Rect2(item[2]-Vector2(size.x*0.5,size.y),size))
	for i in 151:
		var p := a.lerp(b,i/150.0)
		for rect in obstacles:
			if rect.grow(7).has_point(p): return false
	return true
func start(w):
	w._enter(w.Beat.GARAGE,0,1)
	w.player.position = w._target()
	w.raven.position = w._target()+Vector2(-28,10)
	w.interact()
	check(w.terminal!=null and preload("res://tests/terminal_solver.gd").complete(w),"actual garage decoder callback starts the discovery")
func pad_b():
	var event := InputEventJoypadButton.new()
	event.device = 77
	event.button_index = JOY_BUTTON_B
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
func run():
	var image := Art.DECK.get_image()
	check(image.get_size()==Vector2i(1536,1024) and Art.SHAFT.get_size()==Vector2(1024,1536),"six HQ deck images and portrait shaft are imported")
	for i in 6:
		var origin := Vector2i(i%3*512,i/3*512)
		check(image.get_pixelv(origin+Vector2i(5,5)).a<0.02 and image.get_pixelv(origin+Vector2i(256,256)).a>0.9,"deck frame has genuine transparent exterior and opaque walking surface")
	check(Art.SWITCH.get_image().get_pixelv(Vector2i(Art.SOURCE_FINGER)+Vector2i(0,512)).a>0.8 and (Art.SWITCH_FEET+(Art.SOURCE_FINGER-Art.SWITCH_ANCHOR)*0.125).distance_to(Art.SWITCH_TARGET)<0.05,"visible pressing fingertip meets the actual hidden symbol")
	for i in 2:
		check(Art.GARAGE_DECK.grow(-12).has_point(Art.MOUNTS[i]) and Art.DOCK.grow(-12).has_point(Art.ARRIVALS[i]),"both riders remain inside the actual deck at both stops")
		var previous: Vector2 = Art.ARRIVALS[i]
		for leg in Discovery.EXIT_ROUTE:
			check(clear_path(previous,leg[i]),"exit leg clears the motorcycle, consoles, relocated crate and barrels")
			previous = leg[i]
	check(clear_path(Discovery.EXIT_ROUTE.back()[0],Vector2(40,450)),"Shadepi's departure stays on a clear floor route")
	for item in Dressing.items("hangar"):
		var size: Vector2 = WorldProp.TYPES[item[1]].footprint
		check(not Art.DOCK.intersects(Rect2(item[2]-Vector2(size.x*0.5,size.y),size)),"no stored cargo occupies the arrival platform")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.max_fps = 240
	Engine.time_scale = 8
	var player: Node = w.player
	var raven: Node = w.raven
	start(w)
	check(w.discovery_pending and w.save_game() and w.load_game() and w.discovery_pending and w.terminal==null,"loading during discovery restarts the scene without reopening the solved decoder")
	var d = w.hangar_discovery
	var saw_trip := false
	var pause_checked := false
	var continuity_checked := false
	var ordered := false
	for i in 2500:
		await process_frame
		if not is_instance_valid(w.hangar_discovery): break
		d = w.hangar_discovery
		if d.stage=="descent":
			saw_trip = d.mounted and w.player.get_parent()==d.screen.space and w.raven.get_parent()==d.screen.space
			if not pause_checked:
				w.menu_open = true
				var before: float = d.travel
				var clock: float = d.clock
				for j in 5: await process_frame
				check(d.travel==before and d.clock==clock,"pause freezes descent, rider registration and mechanism clock")
				pause_checked = true
				w.close_menu()
		if d.stage=="dock" and not continuity_checked:
			var expected: Vector2 = d.screen.garage_matrix*Art.MOUNTS[0]
			var actual: Vector2 = d.screen.space.transform*w.player.position
			check(expected.distance_to(actual)<0.1,"docking preserves actual on-screen foot position across room coordinates")
			continuity_checked = true
		if d.stage=="reaction": ordered = d.events.find("aircraft")<d.events.find("reaction") and d.events.has("opening")
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(saw_trip and continuity_checked and ordered,"complete visible trip reveals the aircraft before Raven reacts")
	check(w.player==player and w.raven==raven and w.player.get_parent()==w.actors and w.raven.get_parent()==w.actors,"same actual actors return to the ordinary world, never freed with the lift view")
	check(w.beat==w.Beat.HANGAR and not w.discovery_pending and not w.player.visible and w.raven.visible,"Shadepi goes to the compensator while Raven receives normal hangar control")
	check(w.hangar_world.vehicle.Art.ATLAS==preload("res://scripts/aerodyne_art.gd").ATLAS,"explored and flying craft use the identical mechanical source")
	check(w.save_game() and w.load_game() and not w.cutscene.running and w.hangar_discovery==null,"completed discovery loads without replaying the trip or reveal")
	w.fresh_entry = true
	w._enter(w.Beat.HANGAR)
	check(w.save_game() and w.load_game() and w.discovery_pending and w.hangar_discovery.view=="hangar","direct pending hangar introduction resumes its reveal rather than repeating the garage")
	await finish(w)
	start(w)
	for i in 800:
		await process_frame
		if w.cutscene.waiting_input: w.cutscene.advance()
		if w.hangar_discovery.mounted: break
	w._enter(w.Beat.ROOF)
	for i in 4: await process_frame
	check(w.hangar_discovery==null and is_instance_valid(w.player) and w.player.get_parent()==w.actors and w.raven.get_parent()==w.actors,"chapter change during the trip detaches riders safely and cancels late callbacks")
	start(w)
	w.set_process(false)
	var devices: Array[int] = [77]
	w.gamepads.assign(devices,false)
	await pad_b()
	await finish(w)
	check(w.beat==w.Beat.HANGAR and not w.discovery_pending and w.raven.get_parent()==w.actors,"raw controller B skips the full discovery without orphaned actors")
	w.set_process(true)
	w.save_game()
	var legacy := ConfigFile.new()
	var path: String = w.Admin.checkpoint_path(w.SAVE,self)
	legacy.load(path)
	legacy.erase_section_key("campaign","discovery_pending")
	legacy.save(path)
	check(w.load_game() and not w.cutscene.running and w.hangar_world!=null,"older hangar saves get the consistent ship without an invented pending scene")
	w.queue_free()
	await process_frame
	print("HANGAR DISCOVERY: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
