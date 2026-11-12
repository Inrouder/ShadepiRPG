extends SceneTree
## v0.43.0 · CodexAI. Real story progression, source contacts and stale scene safety.
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func seek(w, wanted: String):
	for i in 12000:
		await process_frame
		if w.intro.stage == wanted: return true
		if w.cutscene.waiting_input: w.cutscene.advance()
	return false
func settle(w):
	for i in 12000:
		await process_frame
		if w.cutscene.waiting_input: w.cutscene.advance()
		if not w.cutscene.running: return
	check(false,"scene terminates")
func run():
	set_meta("shadepi_admin_testing",true)
	var w = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	var Intro = w.intro
	var image: Image = Intro.ART.get_image()
	check(image.get_size()==Vector2i(1774,887),"actual source dimensions, without assumed nominal cell sizes")
	for i in 8:
		check(Rect2(Vector2.ZERO,image.get_size()).encloses(Intro.REGIONS[i]),"whole region inside original source %d"%i)
		var foot: Vector2i = Vector2i(Intro.REGIONS[i].position+Intro.FEET[i])
		var occupied := false
		for x in range(-80,81):
			if image.get_pixelv(foot+Vector2i(x,-3)).a>0.5: occupied = true
		check(occupied,"registered floor intersects the actual boots %d"%i)
		check(image.get_pixelv(Vector2i(Intro.REGIONS[i].position)+Vector2i(4,4)).a<0.02,"transparent empty cell corner %d"%i)
	check(is_equal_approx((428-33)*Intro.SCALE,58.855),"standing Raven matches 57–59 world-pixel body height")
	Engine.max_fps = 240
	Engine.time_scale = 12
	w.new_game(false)
	check(await seek(w,"offer"),"actual walk reaches the bounty offer")
	check(not w.raven.visible and w.intro.pose_sprite.visible and w.intro.panel.visible,"replacement hides the complete normal body and shadows")
	var hand: Vector2 = w.intro.pose_sprite.position+Intro.HAND*Intro.SCALE
	check(hand.distance_to(w.apartment_point(Vector2(160,240)))<0.05,"terminal reach contacts the actual monitor")
	w.menu_open = true
	var before: Vector2 = w.intro.pose_sprite.position
	for i in 8: await process_frame
	check(w.intro.stage=="offer" and w.intro.pose_sprite.position==before,"pause holds the current contact pose")
	w.close_menu()
	check(await seek(w,"accept") and "übernommen" in w.intro.text.text,"bounty acceptance is visible")
	check(await seek(w,"weapon-check"),"pistol inspection follows accepting the bounty")
	check(await seek(w,"holster"),"weapon is holstered before leaving")
	# v0.60.0 · ClaudeHelper: Zwischen Wohnung und Straße liegt die spielbare Gasse.
	check(await seek(w,"backalley"),"Raven leaves through the back door into the alley")
	await settle(w)
	check(w.in_backalley() and w.phase==w.Phase.APARTMENT and w.actor_is_playable(w.raven) and not w.backalley_met,"the alley is playable before the street")
	w.raven.position = w.backalley_punk.position+Vector2(-60,6)
	for i in 6: await process_frame
	check(w.backalley_met and w.in_cinematic(),"the punk stops Raven as she passes")
	await settle(w)
	check(w.backalley_punk.health==0 and not w.backalley.locked,"Raven's hack drops the punk and opens the way on")
	w.raven.position = w.backalley.exit()
	check(await seek(w,"roof-watch") and w.intro.screen.visible,"Shadepi first appears visibly over the city")
	await settle(w)
	check(not w.in_backalley() and w.camera.limit_bottom==640,"leaving the alley restores the street camera")
	check(w.phase==w.Phase.HUNT and w.encounter!=null,"complete film preserves the first playable hunt wave")
	check(w.raven.visible and not w.player.visible and not w.intro.screen.visible and not w.intro.panel.visible,"film returns to Raven with all film overlays released")
	w.new_game(false)
	w.cutscene.skip()
	await settle(w)
	check(w.in_backalley() and w.raven.position.distance_to(w.backalley.point(Vector2(150,296)))<2.0,"skipping the apartment film lands in the alley")
	w.skip_backalley()
	await settle(w)
	check(w.phase==w.Phase.HUNT and w.intro.hidden_actor==null,"full skip reaches the same playable hunt checkpoint")
	for stop in ["offer","weapon-check","backalley"]:
		w.new_game(false)
		check(await seek(w,stop),"reach interruption point "+stop)
		w._enter_checkpoint(w.Phase.HUNT)
		for i in 15: await process_frame
		check(w.phase==w.Phase.HUNT and not w.cutscene.running and w.raven.visible and not w.intro.screen.visible and not w.intro.pose_sprite.visible,"checkpoint abort restores visibility and prevents stale continuation at "+stop)
	w._enter_checkpoint(w.Phase.RESCUE)
	w._scene_shadepi_lands()
	check(await seek(w,"landing"),"new landing reaches foot contact")
	check(is_zero_approx(w.intro.fall_height) and not w.player.visible,"landed body uses the real crouched source at the floor")
	w.menu_open = true
	for i in 8: await process_frame
	check(w.intro.stage=="landing", "pause freezes landing recovery")
	w.close_menu()
	check(await seek(w,"rise"),"crouched arrival has a separate rising frame")
	await settle(w)
	check(w.player.visible and w.player.visual.position==w.player.standing_visual_position and w.encounter!=null,"landing restores normal actor and existing rescue waves")
	w._scene_shadepi_lands()
	check(await seek(w,"drop"),"drop can be interrupted before impact")
	w._enter_checkpoint(w.Phase.TEAM)
	w.cutscene.abort()
	for i in 15: await process_frame
	check(w.phase==w.Phase.TEAM and w.player.visible and not w.intro.pose_sprite.visible and w.intro.hidden_actor==null,"loading next encounter cancels airborne pose and delayed impact")
	w._enter_checkpoint(w.Phase.ROOFTOP)
	w.raven.position = w.DOWNED_SPOT
	w._rooftop_dialogue()
	check(await seek(w,"roof-alert"),"rescue cutaway shows the same observing Shadepi")
	w.cutscene.skip()
	await settle(w)
	check(w.phase==w.Phase.RESCUE and w.player.visible and not w.intro.screen.visible,"skipping rooftop threat reaches rescue without retaining the cutaway")
	w.free()
	await process_frame
	await process_frame
	Intro = null
	await process_frame
	print("CHAPTER ONE INTRO: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
