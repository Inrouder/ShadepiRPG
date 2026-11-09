extends SceneTree
## v0.38.0 · CodexAI. Physical pose phases, input, inventory and resumable scenes.
const Bath = preload("res://scripts/ice_bath_sequence.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, text: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+text)
func finish(w):
	for i in 1500:
		await process_frame
		if not w.cutscene.running: return
		w.cutscene.skip()
	check(false,"scene finishes when skipped")
func pad(button: int):
	var event := InputEventJoypadButton.new()
	event.device = 77
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
func run():
	var image := Bath.ART.get_image()
	check(image.get_size()==Vector2i(1536,1024),"all eight HQ contact poses are imported")
	for region in Bath.REGIONS:
		var origin := Vector2i(region.position)
		var size := Vector2i(region.size)
		check(image.get_pixelv(origin+Vector2i(2,2)).a<0.02 and image.get_pixelv(origin+size-Vector2i(3,3)).a<0.02,"each actual pose crop has transparent exterior")
		var edges_clear := true
		for y in size.y:
			edges_clear = edges_clear and image.get_pixelv(origin+Vector2i(0,y)).a<0.6 and image.get_pixelv(origin+Vector2i(size.x-1,y)).a<0.6
		check(edges_clear,"expanded paired crops retain complete hair, cloak and hat without neighbor fragments")
	check(not Rect2(630,322,115,57).grow(12).has_point(Bath.PLAYER_WAIT) and not Rect2(630,322,115,57).grow(8).has_point(Bath.SUPPORT) and not Rect2(630,322,115,57).grow(8).has_point(Bath.EXIT),"waiting, support and exit feet have clearance outside the physical bath")
	var w = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(w)
	Engine.time_scale = 8
	Engine.max_fps = 240
	w._enter(w.Section.COOLING)
	w.raven.position = Bath.APPROACH
	check(w.raven.position==Bath.APPROACH,"cooling checkpoint keeps the ordinary waiting Raven outside the water")
	var d = w.ice_bath
	var drawn_rect := Rect2(d.sprite.position+d.sprite.get_rect().position*d.sprite.scale,d.sprite.get_rect().size*d.sprite.scale)
	for i in 8:
		var source_bounds := Rect2(Bath.ORIGINS[i]-Bath.SEAT-Bath.ANCHORS[i]*Bath.SCALE,Bath.REGIONS[i].size*Bath.SCALE)
		check(drawn_rect.encloses(source_bounds),"full registered source remains inside the actual render quad, including reclining head and hair")
	w._scene_dive()
	check(w.bath_pending==1 and w.cutscene.running,"entry is a running resumable scene")
	check(w.save_game() and w.load_game() and w.bath_pending==1 and w.cutscene.running,"load during entry restarts the correct scene")
	d = w.ice_bath
	var phases := {}
	var paused := false
	for i in 1800:
		await process_frame
		if not is_instance_valid(w.ice_bath): break
		d = w.ice_bath
		phases[d.stage] = true
		if d.stage=="lower" and not paused:
			w.menu_open = true
			var clock: float = d.clock
			var blend: float = d.mix_value
			for j in 5: await process_frame
			check(d.clock==clock and d.mix_value==blend,"pause freezes connection, breathing and pose transition clocks")
			paused = true
			w.close_menu()
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(phases.has("connect") and phases.has("lower") and phases.has("submerged") and phases.has("network"),"actual entry plays sitting, lowering, recline and network transition")
	check(w.section==w.Section.DIVE and w.ice_bath==null and w.raven.visual.visible and w.bath_pending==0,"virtual avatar is restored and bath tableau removed after connection")
	check(w.player.position==Bath.PLAYER_WAIT and not w.player.visible,"Shadepi remains beside the bath while Raven is in the net")
	w._finish_download()
	check(w.bath_pending==2,"countertrace starts the physical return scene")
	d = w.ice_bath
	for i in 1600:
		await process_frame
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(d.events.has("gasp") and d.pose==5 and d.visible,"Raven returns and remains exhausted on the rim")
	check(w.actor_is_playable(w.player) and not w.raven.visual.visible and w.raven.modulate.a==0 and not w.raven.light_occluder.visible and not w.spray_ready and w.bath_pending==0,"spray retrieval is playable; no duplicate standing Raven")
	w.player.position = w.SPRAY
	w.interact()
	check(w.spray_ready and w._target()==w.BATH,"pickup changes the objective back to Raven")
	check(w.load_game() and w.spray_ready and not w.cutscene.running and w.ice_bath.pose==5,"picked-up spray survives a complete checkpoint reload")
	w.player.position = w.BATH
	w.interact()
	check(w.bath_pending==3 and w.cutscene.running,"spray interaction begins the actual support/treatment scene")
	check(w.save_game() and w.load_game() and w.spray_ready and w.bath_pending==3,"load during rescue keeps inventory and restarts treatment")
	var saw_spray := false
	var saw_recovery := false
	for i in 2100:
		await process_frame
		if is_instance_valid(w.ice_bath):
			d = w.ice_bath
			if d.pose==6:
				saw_spray = not w.player.visual.visible and not w.raven.visual.visible
			if d.pose==7: saw_recovery = true
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: break
	check(saw_spray and saw_recovery,"actual treatment uses supported spray and recovery source poses")
	check(w.section==w.Section.END and w.ice_bath==null and w.saved_checkpoint()==w.Section.END,"treatment ends with the existing chapter conclusion checkpoint")
	check(w.raven.visual.visible and w.player.visual.visible and w.player.visual.modulate==Color.WHITE and w.raven.visual.modulate==Color.WHITE,"standing bodies regain complete opacity after the supported rise")
	check(w.load_game() and w.player.position==Bath.SUPPORT and w.raven.position==Bath.EXIT,"completed chapter loads both restored figures on dry floor rather than inside the bath")
	w._enter(w.Section.COOLING)
	w.player.position = w.BATH
	w.set_process(false)
	var devices: Array[int] = [77]
	w.gamepads.assign(devices,false)
	await pad(JOY_BUTTON_A)
	check(w.cutscene.running and w.bath_pending==1,"raw controller A starts the bath interaction")
	await pad(JOY_BUTTON_B)
	await finish(w)
	check(w.section==w.Section.DIVE and w.bath_pending==0,"raw controller B skips the new phases cleanly")
	w.set_process(true)
	w._enter(w.Section.RECOVERY)
	w._scene_return()
	await process_frame
	w._enter(w.Section.YARD)
	for i in 5: await process_frame
	check(w.ice_bath==null and w.player.visible and w.player.visual.visible and not w.raven.visible,"chapter change cancels old return tasks and restores ordinary scene visibility")
	w._enter(w.Section.RECOVERY)
	w.save_game()
	var legacy := ConfigFile.new()
	var checkpoint: String = w.Admin.checkpoint_path(w.SLOT,self)
	legacy.load(checkpoint)
	legacy.erase_section_key("chapter","spray_ready")
	legacy.erase_section_key("chapter","bath_pending")
	legacy.save(checkpoint)
	check(w.load_game() and not w.spray_ready and w.bath_pending==0 and w.ice_bath.pose==5,"old recovery saves resume safely at spray retrieval")
	legacy.set_value("chapter","spray_ready","wrong")
	legacy.set_value("chapter","bath_pending",99)
	legacy.save(checkpoint)
	check(w.load_game() and not w.spray_ready and w.bath_pending==0,"invalid new fields cannot start unrelated scenes or invent spray inventory")
	w.queue_free()
	await process_frame
	print("ICE BATH: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
