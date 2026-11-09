extends SceneTree
## v0.36.0 · CodexAI. Arrival geography, consent order, privacy states and checkpoints.
const Lake = preload("res://scripts/lake_sequence.gd")
const Tableau = preload("res://scripts/lake_tableau.gd")
const Painted = preload("res://scripts/painted_world.gd")
var checks := 0
var failures := 0

func _initialize() -> void: run.call_deferred()

func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+text)

func in_water_or_on_edge(point: Vector2) -> bool:
	var outline := PackedVector2Array(Painted.WATER_EDGE)
	if Geometry2D.is_point_in_polygon(point,outline): return true
	# The ray test is unspecified on polygon vertices; the clip must keep them.
	for i in outline.size():
		if point.distance_to(Geometry2D.get_closest_point_to_segment(point,outline[i],outline[(i+1)%outline.size()]))<0.01: return true
	return false

func finish(w) -> void:
	for i in 10:
		if w.cutscene.running: w.cutscene.skip()
		await process_frame

func pad_b() -> void:
	for pressed in [true,false]:
		var event := InputEventJoypadButton.new()
		event.device = 77
		event.button_index = JOY_BUTTON_B
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func run() -> void:
	var image: Image = Tableau.ART.get_image()
	check(image.get_size()==Vector2i(1536,1024),"contact source has four complete equal cells")
	for cell in 4:
		var origin := Vector2i((cell%2)*768,(cell/2)*512)
		check(image.get_pixelv(origin+Vector2i(5,5)).a<0.01 and image.get_pixelv(origin+Vector2i(760,505)).a<0.01,"contact source has transparent exterior in every cell")
		check(image.get_pixelv(origin+Vector2i(300,240)).a>0.5,"contact source retains opaque dark armor, without alpha forcing")
	for corner in [Lake.FOOTPRINT.position,Lake.FOOTPRINT.end,Lake.FOOTPRINT.get_center()]:
		check(not Geometry2D.is_point_in_polygon(corner,PackedVector2Array(Painted.WATER_EDGE)) and corner.y<540,"the complete landing/contact area is dry shore")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 8
	Engine.max_fps = 240
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	check(w.lake_scene_pending and w.cutscene.running and not w.player.visible and not w.raven.visible,"fresh lake starts with the visible flight, not spawned people")
	var d = w.lake_sequence
	var same_vehicle: Node = d.vehicle
	for polygon in d.water.get_children():
		var clipped := true
		for point in polygon.polygon:
			clipped = clipped and in_water_or_on_edge(point) and point.y>=211.99
		check(clipped,"dragon and mystical water overlay stay inside the actual lake")
	check(w.save_game() and w.load_game() and w.lake_scene_pending and w.lake_sequence.stage=="approach","loading during approach restarts the arrival safely")
	d = w.lake_sequence
	same_vehicle = d.vehicle
	var saw_exits := false
	for i in 1800:
		await process_frame
		if d.stage=="exit_raven": saw_exits = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(not w.lake_scene_pending and saw_exits and d.events.has("exit_shadepi"),"actual approach, touchdown and both disembarkations finish")
	check(d.vehicle==same_vehicle and d.craft==Lake.PARK and d.power==0,"same vehicle remains parked after touchdown")
	check(w.player.visible and w.raven.visible and w.player.modulate.a==1 and w.raven.modulate.a==1 and w.player.z_index==0 and w.raven.z_index==0,"both complete figures and ordinary depth order are restored on land")
	check(w.player.position==Lake.SHORE[0] and w.raven.position==Lake.SHORE[1],"both walk from the craft to the shore")
	check(w.load_game() and not w.cutscene.running and w.player.position==Lake.SHORE[0],"completed-arrival checkpoint resumes on shore without repeating flight")
	d = w.lake_sequence
	for step in 4:
		w.player.position = w._target()
		w.interact()
		await finish(w)
	check(w.beat==w.Beat.END and w.point_index==0,"consent and admission still precede the final scene")
	# Restart finale without skipping to verify every privacy/contact state.
	w.fresh_entry = true
	w._enter(w.Beat.END)
	d = w.lake_sequence
	var seen := {}
	var source_hidden := true
	var pause_checked := false
	for i in 1600:
		await process_frame
		seen[d.stage] = true
		if d.tableau.visible:
			source_hidden = source_hidden and not w.player.visual.visible and not w.raven.visual.visible and d.tableau.pose>=0 and d.tableau.pose<=3 and d.tableau.target_pose<=3
		if d.stage=="mask" and d.tableau.pose==1 and not pause_checked:
			w.menu_open = true
			var before: float = d.clock
			var glow_before: float = d.glow
			for frame in 5: await process_frame
			check(d.clock==before and d.glow==glow_before,"pause freezes romantic light and source shader clocks")
			w.close_menu()
			pause_checked = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(seen.has("mask") and seen.has("kiss") and seen.has("dragon") and seen.has("embrace"),"mask, kiss, passing shadow and embrace really play")
	check(source_hidden and pause_checked,"only the four approved contact poses are visible during the private moment")
	check(d.tableau.pose==3 and d.dragon_passage==-1 and not w.lake_scene_pending,"final rest restores the masked embrace and clears the brief dragon")
	check(w.save_game() and w.load_game() and not w.cutscene.running and w.lake_sequence.tableau.pose==3,"completed finale loads the peaceful masked end pose")
	w.fresh_entry = true
	w._enter(w.Beat.END)
	check(w.save_game() and w.load_game() and w.cutscene.running and w.lake_scene_pending,"pending finale resumes as a scene rather than losing the kiss")
	await finish(w)
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	w.set_process(false)
	var devices: Array[int] = [77]
	w.gamepads.assign(devices,false)
	await pad_b()
	await process_frame
	check(not w.cutscene.running and not w.lake_scene_pending and w.player.visible,"raw controller B skips arrival cleanly and leaves the actors visible")
	w.fresh_entry = true
	w._enter(w.Beat.LAKE)
	await process_frame
	w._enter(w.Beat.ROOF)
	check(w.lake_sequence==null and w.player.modulate==Color.WHITE and w.raven.modulate==Color.WHITE,"chapter change cancels arrival without leaving invisible or translucent actors")
	w._enter(w.Beat.END)
	check(w.lake_sequence!=null and w.lake_sequence.tableau.pose==3,"legacy end entry uses a masked rest pose")
	w.save_game()
	var legacy := ConfigFile.new()
	var checkpoint: String = w.Admin.checkpoint_path(w.SAVE,self)
	legacy.load(checkpoint)
	legacy.erase_section_key("campaign","lake_scene_pending")
	legacy.save(checkpoint)
	check(w.load_game() and w.lake_scene_pending and w.cutscene.running,"older completed saves receive the new private finale once")
	await finish(w)
	check(w.load_game() and not w.lake_scene_pending and not w.cutscene.running,"upgraded end save does not replay the finale again")
	w.queue_free()
	await process_frame
	Engine.time_scale = 1
	print("LAKE SEQUENCE: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
