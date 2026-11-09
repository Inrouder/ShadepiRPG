extends SceneTree
## v0.37.0 · CodexAI. Mechanical source contact, registration, pause and door cleanup.
const Art = preload("res://scripts/aerodyne_art.gd")
const Rig = preload("res://scripts/cinematic_aerodyne.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func finish(w):
	for i in 700:
		await process_frame
		if not w.cutscene.running: return
		w.cutscene.skip()
	check(false,"scene finishes after skip")
func run():
	var image := Art.ATLAS.get_image()
	check(image.get_size()==Vector2i(1536,1024),"six complete HQ mechanical cells are imported")
	for i in 6:
		var source := Vector2i(Art.region(i).position)
		var anchor := Vector2i(Art.ANCHORS[i])
		check(image.get_pixelv(source+Vector2i(5,5)).a<0.01 and image.get_pixelv(source+Vector2i(505,505)).a<0.01,"source gutter has real transparent alpha")
		check(image.get_pixelv(source+anchor).a>0.9,"registered cockpit stays opaque")
		for nozzle in [Vector2i(-82,186),Vector2i(82,186)]:
			check(image.get_pixelv(source+anchor+nozzle).a>0.9,"registered nozzle center belongs to the actual hull in every mechanical state")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 8
	Engine.max_fps = 240
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	var frames := {}
	var saw_open := false
	for i in 1400:
		await process_frame
		var d = w.lake_sequence
		if d.power>0.1: frames[d.vehicle.hull.frame] = true
		if d.stage=="exit_shadepi": saw_open = saw_open or d.vehicle.hull.frame==3
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(frames.has(4) and frames.has(5),"actual approach uses distinct moving engine source images")
	check(saw_open and w.lake_sequence.vehicle.door==0 and w.lake_sequence.vehicle.hull.frame==0,"passengers leave an open cabin; parked hull closes and stops its machinery")
	w.fresh_entry = true
	w.flight_intro_pending = true
	w._enter(w.Beat.FLIGHT)
	var d = w.departure
	d.vehicle.set_door(0.5)
	var frame: int = d.vehicle.hull.frame
	var clock: float = d.clock
	w.menu_open = true
	for i in 4: await process_frame
	check(d.clock==clock and d.vehicle.hull.frame==frame,"menu pause freezes the cabin and mechanical frames")
	w.close_menu()
	await finish(w)
	check(not is_instance_valid(w.departure) and not w.flight_intro_pending,"skip traverses opening/closing without leaving the hangar director active")
	w._enter(w.Beat.ROOF)
	check(w.player.modulate.a==1 and w.raven.modulate.a==1,"chapter change leaves complete actors after boarding")
	w.queue_free()
	await process_frame
	print("AERODYNE ART: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
