extends SceneTree
## v0.33.0 · CodexAI: real damage, protected transfer, persistent phase ordering.
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func finish(w) -> void:
	for i in 12:
		if w.cutscene.running: w.cutscene.skip()
		await process_frame
func disable_foes(w) -> void:
	for f in w.foes: f.set_physics_process(false)
func run() -> void:
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	Engine.max_fps = 240
	Engine.time_scale = 12
	w.fresh_entry = true
	w._enter(w.Beat.BOSS)
	var grabbed := false
	for i in 600:
		await process_frame
		if is_instance_valid(w.tower_grip):
			grabbed = true
			check(w.tower_grip.mode=="grip" and not w.raven.visual.visible and not w.foes.back().visual.visible,"physical grab replaces both sprites with the contact pose")
			check(w.player.cloaked,"Shadepi remains concealed when Kenzō first grabs Raven")
			break
		if w.cutscene.waiting_input: w.cutscene.advance()
	check(grabbed,"unskipped opening visibly reaches the grab")
	await finish(w)
	check(w.tower_grip==null and not w.player.cloaked and w.raven.visual.visible,"intervention releases Raven and clears contact artwork")
	var boss = w.foes.back()
	boss.set_physics_process(false)
	boss.take_damage(1000)
	check(boss.subdued and boss.health==0 and boss.death_tween==null,"combat depletion disables Kenzō without calling death/fall")
	await process_frame
	await process_frame
	check(w.beat==w.Beat.ESCAPE and w.tower_stage==0 and w.kenzo_body.health==1,"boss loss creates a living paralyzed prisoner")
	check(w.tower.tableau.mode=="kneel" and not w.kenzo_body.visible,"only the bruised kneeling source pose is shown")
	await finish(w)
	disable_foes(w)
	w.tower.set_process(false)
	check(w.tower.active and not w.escape_guards_cleared and w.encounter.living()==2,"extraction starts the first real guard wave")
	check(not w.raven.visual.visible and w.tower.tableau.mode=="extract","Raven has a fixed extraction pose")
	var anchor: Vector2 = w.raven.position
	w._update_raven_follower(2)
	check(w.raven.position==anchor,"Raven cannot follow Shadepi away from the transfer")
	w.player.position = Vector2(200,420)
	check(w.combat_target(Vector2(500,400))==w.raven,"guards can target Raven even in single-player")
	check(not w.raven_hack(),"Raven cannot simultaneously hack guards and extract data")
	check(w._target()==Vector2.ZERO,"escape consoles cannot bypass unfinished protection")
	w._complete_point()
	check(w.point_index==0 and w.tower_stage==0,"direct point completion cannot bypass extraction")
	var timer: float = w.countdown
	w._process(5)
	check(w.countdown==timer,"escape timer starts after extraction and execution")
	w.tower._process(1)
	var elapsed: float = w.tower.elapsed
	w.menu_open = true
	w.tower._process(4)
	check(w.tower.elapsed==elapsed,"pause freezes transfer progress")
	w.close_menu()
	w.cutscene.begin()
	w.tower._process(4)
	check(w.tower.elapsed==elapsed,"dialogue freezes transfer progress")
	w.cutscene.abort()
	w.raven.invulnerable = 0
	w.raven.take_damage(16,w.raven.position+Vector2(20,0))
	check(w.tower.hits==1,"an actual enemy hit is counted")
	w.raven.take_damage(16,w.raven.position+Vector2(20,0))
	check(w.tower.hits==1,"invulnerability prevents duplicate hit counting")
	w.tower._process(0.81)
	w.raven.take_damage(16,w.raven.position+Vector2(20,0))
	check(w.tower.hits==2,"a second distinct hit is counted")
	w.tower._process(0.81)
	w.raven.take_damage(16,w.raven.position+Vector2(20,0))
	check(w.tower.failed,"the third distinct hit fails the extraction")
	await process_frame
	await process_frame
	check(w.menu_open and w.beat==w.Beat.ESCAPE and w.tower_stage==0,"failure offers retry of extraction, not the boss")
	check(w.tower.hits==0 and w.tower.elapsed==0 and w.encounter.wave_index==0,"retry resets hits, progress and waves together")
	check(w.kenzo_body.health==1,"retry never kills the prisoner")
	w.close_menu()
	disable_foes(w)
	w.tower.set_process(false)
	w.raven.invulnerable = 0
	w.raven.take_damage(16,w.raven.position)
	check(w.save_game() and w.load_game(),"protection checkpoint saves and loads")
	disable_foes(w)
	w.tower.set_process(false)
	check(w.tower.hits==0 and w.encounter.wave_index==0 and not w.cutscene.running,"load restarts protection without replaying capture or boss")
	w.tower.completed_waves()
	check(w.tower_stage==0 and w.kenzo_body.health==1,"clearing guards cannot finish before transfer is ready")
	w.tower._process(w.tower.TRANSFER_SECONDS)
	await process_frame
	check(w.tower_stage==1 and w.kenzo_body.health==1 and w.cutscene.running,"completed transfer enters resolution with Kenzō still alive")
	check(w.save_game() and w.load_game() and w.tower_stage==1,"secured-data checkpoint survives loading during resolution")
	check(w.encounter==null and w.cutscene.running,"secured transfer is not repeated after loading resolution")
	var truth: Array[String] = []
	for i in 1000:
		await process_frame
		if w.cutscene.waiting_input:
			truth.append(w.cutscene.line_label.text)
			w.cutscene.advance()
		if w.tower_stage==2 and not w.cutscene.running: break
	var dialogue := " ".join(truth)
	check(dialogue.contains("inszeniert") and dialogue.contains("Auftraggeber") and dialogue.contains("Begründung fehlt"),"data confirms orchestration while motive and client remain unresolved")
	check(dialogue.contains("Zusammen"),"Raven explicitly joins the continuing search")
	check(w.kenzo_body.health==0 and w.tower.tableau.mode=="dead" and w.escape_guards_cleared,"Raven destroys Kenzō only after transfer is secured")
	check(w.point_index==1 and w.countdown>58 and w.raven.visual.visible,"escape starts at the charge console with Raven released")
	w.point_index = 3
	w._complete_point()
	check(w.tower_stage==3 and is_instance_valid(w.tower_departure),"roof exit starts visible departure instead of jumping to lake")
	check(w.load_game() and w.tower_stage==3 and is_instance_valid(w.tower_departure),"loading departure restarts the cinematic without replaying extraction")
	var departure = w.tower_departure
	var clock_before: float = departure.clock
	w.menu_open = true
	departure._process(1)
	check(departure.clock==clock_before,"pause freezes departure effects and engine animation")
	w.close_menu()
	var events: Array = []
	departure.tree_exiting.connect(func(): events.assign(departure.events))
	await finish(w)
	check(events==["run","board","tip","fall","ignition","blast","clear"],"departure preserves boarding, fall, ignition and explosion order even when skipped")
	check(w.beat==w.Beat.LAKE,"departure reaches the lake only after the escape sequence")
	w._enter(w.Beat.ESCAPE,0,1)
	w.escape_guards_cleared = true
	w.save_game()
	var cfg := ConfigFile.new()
	cfg.load(w.Admin.checkpoint_path(w.SAVE,self))
	cfg.erase_section_key("campaign","tower_stage")
	cfg.save(w.Admin.checkpoint_path(w.SAVE,self))
	check(w.load_game() and w.tower_stage==2 and w.kenzo_body.health==0,"old post-guard saves resume safely after the new extraction")
	check(w.Painted.HANGAR_BRAND.get_width()>0,"replacement KOBAN-TEC source is loaded")
	w.queue_free()
	await process_frame
	Engine.time_scale = 1
	print("TOWER SEQUENCE: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
