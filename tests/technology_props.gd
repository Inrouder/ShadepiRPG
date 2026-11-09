extends SceneTree
## v0.42.0 · CodexAI. Real idle frames, modal lifecycle, destruction and checkpoint safety.
const Tech = preload("res://scripts/technology_art.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool,message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func device(w,id: String) -> WorldProp:
	for p in w.destructibles:
		if p.prop_id==id: return p
	return null
func run():
	set_meta("shadepi_admin_testing",true)
	for kind in ["server","electrical"]:
		var image: Image = (Tech.SERVER if kind=="server" else Tech.ELECTRICAL).get_image()
		check(image.get_size()==Vector2i(1536,1024),"eight actual source cells are imported for "+kind)
		for frame in 8:
			var source := Vector2i(frame%4*384,frame/4*512)
			check(image.get_pixelv(source+Vector2i(5,5)).a<0.02 and image.get_pixelv(source+Vector2i(378,505)).a<0.02,"real transparent exterior in every source frame")
			check(image.get_pixelv(source+Vector2i(Tech.FEET[kind])-Vector2i(0,3)).a>0.8,"whole cabinet includes its registered lower foot contact")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w.restore_dressing_state({})
	w._enter(w.Beat.HANGAR)
	w.set_process(false)
	var p := device(w,"spare_server")
	check(p.animated_technology() and p.is_processing() and p.sprite.texture==Tech.SERVER,"normal live rack uses the actual mechanical source")
	var footprint: Rect2 = p.footprint()
	var base: Vector2 = p.sprite.position
	var frames := {}
	for i in 24:
		p._process(0.04)
		frames[p.sprite.frame] = true
	check(frames.size()==4 and p.sprite.position.is_equal_approx(base) and p.footprint()==footprint,"four true idle phases keep the shell and collision footprint fixed")
	w.menu_open = true
	var clock: float = p.technology_clock
	p._process(0.2)
	check(p.technology_clock==clock,"menu pause freezes technology clock")
	w.close_menu()
	w.raven.position = w._target()
	w.interact()
	check(w.terminal!=null and w.terminal_devices.size()==1 and p.operation=="waiting" and p.sprite.frame==4,"actual energy-bus interaction addresses its explicit connected rack")
	clock = p.technology_clock
	p._process(0.2)
	check(p.technology_clock==clock,"modal puzzle freezes the machinery instead of running behind the deck")
	check(preload("res://tests/terminal_solver.gd").complete(w) and w.point_index==1,"real puzzle callback still progresses immediately")
	check(p.operation=="success" and w.terminal_devices.is_empty(),"accepted operation starts the result sequence and releases modal references")
	p._process(0.2)
	check(p.sprite.frame==5,"success contains the real latch/transfer intermediate image")
	p._process(0.2)
	check(p.sprite.frame==6,"result reaches its green confirmation frame")
	p._process(0.8)
	check(p.operation=="idle" and p.sprite.frame<4,"confirmation ends in ordinary operation")
	p.take_damage(1)
	p._process(0.02)
	p.take_damage(1)
	p._process(0.3)
	check(p.sprite.position.is_equal_approx(p.base_sprite_position),"repeated hits never accumulate horizontal shell drift")
	p.take_damage(p.max_health)
	check(p.health==0 and p.collision_layer==0 and not p.is_processing() and p.sprite.hframes==1,"destroyed rack stops the fan/status animation and uses the existing wreck")
	check(w.save_game() and w.load_game() and device(w,"spare_server").health==0 and not device(w,"spare_server").is_processing(),"saved destruction does not revive a machine or its animation")
	w._enter(w.Beat.HANGAR,0,0)
	w.raven.position = w._target()
	w.interact()
	check(w.terminal!=null and w.terminal_devices.is_empty() and preload("res://tests/terminal_solver.gd").complete(w),"destroyed optional status hardware never blocks the story puzzle")
	w._enter(w.Beat.GARAGE,0,1)
	w.player.position = w._target()
	w.raven.position = w._target()+Vector2(-28,10)
	w.interact()
	p = device(w,"tool_case")
	check(p.operation=="waiting" and p.sprite.texture==Tech.ELECTRICAL,"garage decoder drives the correct connected cabinet rather than nearest decoration")
	var panel = w.terminal
	panel.puzzle.filter = panel.puzzle.filter_target
	for i in panel.puzzle.WORDS.size():
		if panel.puzzle.WORDS[i]!=panel.puzzle.secret: panel.puzzle.guess(i)
		if panel.puzzle.failed: break
	for i in 2: await process_frame
	check(panel.puzzle.failed and p.sprite.frame==7,"actual decoder failure produces the cabinet fault image")
	panel.finish(false)
	check(p.operation=="fault" and w.terminal==null,"failed session closes without committing a story point")
	p._process(0.9)
	check(p.operation=="idle","temporary fault clears safely")
	w.interact()
	w.cancel_terminal()
	check(p.operation=="idle" and w.terminal_devices.is_empty(),"ordinary cancellation is a clean disconnect, not a false success")
	w.interact()
	panel = w.terminal
	w._enter(w.Beat.ROOF)
	panel.finished.emit(true)
	check(w.terminal_devices.is_empty() and w.beat==w.Beat.ROOF,"late old-panel completion cannot color replacement hardware or progress the next chapter")
	p = device(w,"backup_generator")
	p.take_damage(p.max_health/2)
	check(not p.animated_technology() and p.sprite.hframes==1 and p.collision_layer==1,"damaged cabinet keeps the existing damaged sprite and solid footprint")
	w.queue_free()
	await process_frame
	print("TECHNOLOGY PROPS: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
