extends SceneTree
const Pilot=preload("res://tools/legacy_pilot.gd")
var checks:=0
var failures:=0
func _initialize() -> void: run.call_deferred()
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error("FAIL: "+label)
func make_scene() -> Node2D:
	var scene=load("res://scenes/memories/legacy.tscn").instantiate()
	scene.autoplay=false
	root.add_child(scene)
	return scene
func run() -> void:
	var scene=make_scene()
	check(scene.squad.size()==1 and scene.squad[0].identity=="shadepi" and scene.tanks.size()==2,"Shadepi alone faces two Minotaurs; no fallen companions return")
	check(scene.map.background_texture==scene.INTERIOR and scene.map.get_script()==scene.InteriorMap,"third memory uses its own temple interior, not the courtyard map")
	await physics_frame
	await physics_frame
	check(not scene.map.breached and scene.map.door_frame==0 and blocked(scene,Vector2(940,335)),"closed temple door has a real blocking footprint")
	check(not blocked(scene,Vector2(620,465)),"old courtyard column does not remain as an invisible indoor obstacle")
	check(blocked(scene,Vector2(550,240)),"rear wall and base shaft cannot be crossed from the nave")
	check(scene.tanks.all(func(t): return not t.visible and t.collision_layer==0),"mechs wait outside the closed entry without invisible indoor colliders")
	scene.map.breach_step(0.5)
	check(scene.map.door_frame==2 and not scene.map.breached,"damaged door stays closed until the final break phase")
	scene.map.breach_step(1)
	await physics_frame
	check(scene.map.breached and scene.map.door_frame==3 and not blocked(scene,Vector2(940,335)),"breach opens the physical threshold as well as the artwork")
	var door_image=scene.map.DOOR.get_image()
	check(door_image.get_pixel(384,256).a>0.5 and door_image.get_pixel(1152,768).a<0.05,"door atlas has opaque closed panels and a genuinely transparent breached opening")
	var scales:={}
	for i in 8:
		scene.tableau.set_frame(i)
		var data: Dictionary=scene.tableau.frames[i]
		var point=Vector2(data.anchor[0],data.anchor[1])-scene.tableau.sprite.texture.get_size()*0.5
		check(scene.tableau.sprite.to_global(point).distance_to(scene.tableau.global_position)<0.01,"support/rest/collapse source contact matches the physical placement")
		scales[scene.tableau.sprite.scale]=true
	check(scales.size()==1,"seated and collapsed poses retain body scale")
	check(scene.Figure.ART.get_image().get_pixel(0,0).a<0.05 and scene.TRANSFER.get_image().get_pixel(0,0).a<0.05,"figure and energy sources have true transparency")
	scene.cutscene.begin()
	scene.battle=scene.FinalBattle.new(scene)
	scene.battle.start()
	var battle=scene.battle
	var player=scene.squad[0]
	for tank in scene.tanks: tank.show()
	player.show()
	player.position=Vector2(712,350)
	player.facing=Vector2.RIGHT
	for i in 4:
		battle.attack_cooldown=0
		battle.attack()
	check(battle.boss_health==[56,168] and battle.boss_stun[0]>0 and battle.boss_stun[1]==0,"katana damage and four-hit stagger belong to the struck mech only")
	for i in 2:
		battle.attack_cooldown=0
		battle.attack()
	battle.tick(0.51)
	check(scene.tanks[0].destroyed and not scene.tanks[1].destroyed and not battle.won,"destroying one mech cannot finish the encounter")
	battle.tick(46)
	check(not battle.won,"elapsed time cannot replace defeating both Minotaurs")
	battle.invulnerable=0
	battle.damage(100)
	var time: float=battle.elapsed
	battle.tick(5)
	check(battle.dead and battle.elapsed==time,"defeat stops battle progression")
	var retry:=InputEventJoypadButton.new()
	retry.button_index=JOY_BUTTON_A
	retry.pressed=true
	scene.phase="final_battle"
	scene.handle_event(retry)
	check(not battle.dead and battle.health==100 and battle.boss_health==[168,168] and scene.tanks.all(func(t): return not t.destroyed),"controller retry restores both bosses and local life")
	check(not scene.events.has("minotaur_0_destroyed"),"failed attempt does not leave a canonical destroyed-boss event")
	battle.begin_volley()
	var first: int=battle.pending_tank
	battle.clear_warning()
	battle.begin_volley()
	check(battle.pending_tank!=first,"both living bosses participate in alternating telegraphed fire")
	var targets: Array=battle.targets.duplicate()
	player.position+=Vector2(60,0)
	check(battle.targets==targets,"warning locks targets instead of tracking the player unfairly")
	battle.invulnerable=0
	battle.dodge_cooldown=0
	battle.dodge()
	battle.damage(50)
	check(battle.health==100,"dodge protects against the incoming hit")
	battle.held[KEY_D]=true
	scene.toggle_pause()
	var elapsed: float=battle.elapsed
	var warning: float=battle.warning
	battle.tick(5)
	check(battle.elapsed==elapsed and battle.warning==warning and battle.direction()==Vector2.ZERO,"pause freezes attacks and clears held movement")
	scene.toggle_pause()
	battle.finish()
	scene.queue_free()
	await process_frame
	await full_story()
	await battle_exit_controls()
	await integration()
	print("LEGACY MEMORY: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
func full_story() -> void:
	var scene=make_scene()
	var completed: Array[bool]=[]
	scene.finished.connect(func(ok: bool): completed.append(ok))
	Engine.time_scale=5
	Engine.max_fps=120
	scene.play.call_deferred()
	var seen:={}
	var lines: Array[String]=[]
	var transfer_pause:=false
	var breach_pause:=false
	var promise_checked:=false
	for frame in 2400:
		await process_frame
		seen[scene.phase]=true
		if scene.phase=="promise" and not promise_checked:
			promise_checked=true
			check(not scene.map.breached and scene.tanks.all(func(t): return not t.visible),"master conversation is inside the protected temple before the enemy break-in")
		if scene.phase=="temple_breach" and scene.map.door_frame==1 and not breach_pause:
			breach_pause=true
			scene.toggle_pause()
			var door: int=scene.map.door_frame
			var clock: float=scene.map.elapsed
			for i in 8: await process_frame
			check(door==scene.map.door_frame and clock==scene.map.elapsed and not scene.map.breached,"pause freezes the actual break-in before the threshold opens")
			scene.toggle_pause()
		if scene.phase=="transfer" and not transfer_pause:
			transfer_pause=true
			scene.toggle_pause()
			var index: int=scene.transfer_frame
			var clock: float=scene.map.elapsed
			for i in 8: await process_frame
			check(scene.transfer_frame==index and scene.map.elapsed==clock and not scene.transferred,"pause freezes the actual energy transfer")
			scene.toggle_pause()
		if scene.cutscene.waiting_input:
			lines.append(scene.cutscene.line_label.text)
			scene.cutscene.advance()
		if scene.phase=="final_battle" and scene.battle!=null:
			Pilot.step(scene)
			if scene.battle.dead: break
		if scene.closed: break
	Engine.time_scale=1
	Engine.max_fps=0
	check(scene.completed and completed==[true],"real input-driven two-boss battle reaches complete memory exactly once")
	check(scene.transferred and scene.exhausted and scene.tableau.frame_index==7 and scene.tableau.visible and not scene.squad[0].fallen,"Shadepi receives the sanctuary and collapses without a death flag")
	check(scene.tanks.all(func(t): return t.destroyed) and scene.battle.hit_count>=12,"both bosses are destroyed through actual melee hits")
	var text=" ".join(lines)
	check(text.contains("oberste Priorität") and text.contains("Ich werde es mit meinem Leben beschützen") and text.contains("Danke für alles, Meister"),"confirmed master/hero promises are shown on screen")
	check(scene.events.find("vow")<scene.events.find("transfer_received") and scene.events.find("transfer_received")<scene.events.find("both_destroyed") and scene.events.find("both_destroyed")<scene.events.find("shadepi_collapsed"),"transfer, final fight and collapse occur in causal order")
	check(breach_pause and scene.events.find("transfer_received")<scene.events.find("temple_door_breached") and scene.events.find("temple_door_breached")<scene.events.find("minotaur_0_entered") and scene.events.find("minotaur_0_entered")<scene.events.find("minotaur_1_entered") and scene.events.find("minotaur_1_entered")<scene.events.find("last_stand"),"sanctuary transfer precedes the physical breach and both ordered entries")
	check(seen.has("transfer") and seen.has("two_minotaurs") and seen.has("final_battle") and seen.has("stillness"),"all required scene phases are actually played")
	scene.queue_free()
	await process_frame
func pad(button: JoyButton) -> void:
	for pressed in [true,false]:
		var event:=InputEventJoypadButton.new()
		event.device=77
		event.button_index=button
		event.pressed=pressed
		Input.parse_input_event(event)
		await process_frame
func integration() -> void:
	var world=load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.ECHO,0,2,true,true,true,false)
	world.ui.clear_dialogue()
	world.raven.position=world.Painted.ECHO_POINTS[2]
	var home: Vector2=world.raven.position
	world.player.health=71
	world.raven.energy=43
	world.interact()
	var scene=world.memory_scene
	world.interact()
	await process_frame
	check(scene!=null and scene==world.memory_scene and world.memory_anchor==2,"third anchor opens exactly one isolated third scene")
	check(world.is_busy() and scene.get_world_2d()!=world.get_world_2d(),"present remains frozen in a separate physics world")
	await pad(JOY_BUTTON_START)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(world.memory_scene==null and world.point_index==2 and not world.memory_legacy_complete,"controller abort does not complete the third node")
	world.interact()
	scene=world.memory_scene
	await process_frame
	await pad(JOY_BUTTON_B)
	check(world.memory_scene==null and world.memory_legacy_complete and world.beat==world.Beat.ECHO and world.cutscene.running,"skip completes the third node then starts Raven's return conversation")
	check(world.raven.position==home and world.player.health==71 and world.raven.energy>=43 and world.raven.energy<45,"third memory preserves present position and vitals")
	check(world.load_game() and world.point_index==2 and world.memory_legacy_complete and world.memory_sacrifice_complete,"third completion survives loading without replaying the fight")
	var config:=ConfigFile.new()
	var path: String=world.Admin.checkpoint_path(world.SAVE,self)
	config.load(path)
	config.erase_section_key("campaign","memory_legacy_complete")
	config.save(path)
	check(world.load_game() and world.point_index==2 and not world.memory_legacy_complete and world.memory_sacrifice_complete,"older chapter-five save preserves both earlier memories and offers the new third one")
	config.set_value("campaign","memory_legacy_complete","invalid")
	config.save(path)
	check(world.load_game() and not world.memory_legacy_complete,"malformed new save flag does not skip the third memory")
	world.raven.position=world.Painted.ECHO_POINTS[2]
	world.interact()
	scene=world.memory_scene
	world._enter(world.Beat.ROOF)
	scene.finished.emit(true)
	check(world.beat==world.Beat.ROOF and world.point_index==0 and world.memory_scene==null,"stale third-memory signal cannot advance the tower")
	world.queue_free()
	await process_frame

func battle_exit_controls() -> void:
	for skip in [false,true]:
		var scene=make_scene()
		var completed: Array[bool]=[]
		scene.finished.connect(func(ok: bool): completed.append(ok))
		Engine.time_scale=12
		Engine.max_fps=120
		scene.play.call_deferred()
		for frame in 1200:
			await process_frame
			if scene.cutscene.waiting_input: scene.cutscene.advance()
			if scene.phase=="final_battle" and scene.battle!=null: break
		check(scene.phase=="final_battle" and scene.battle.running,"exit-control test reaches real two-boss gameplay")
		var start:=InputEventJoypadButton.new()
		start.button_index=JOY_BUTTON_START
		start.pressed=true
		scene.handle_event(start)
		var down:=InputEventJoypadButton.new()
		down.button_index=JOY_BUTTON_DPAD_DOWN
		down.pressed=true
		scene.handle_event(down)
		if not skip: scene.handle_event(down)
		var confirm:=InputEventJoypadButton.new()
		confirm.button_index=JOY_BUTTON_A
		confirm.pressed=true
		scene.handle_event(confirm)
		for i in 3: await process_frame
		check(scene.closed and completed==[skip] and scene.completed==skip and not scene.battle.running and scene.exhausted==skip,"controller pause menu can skip or abort during the final battle without a stuck encounter")
		Engine.time_scale=1
		Engine.max_fps=0
		scene.queue_free()
		await process_frame

func blocked(scene: Node2D,point: Vector2) -> bool:
	var shape:=CircleShape2D.new()
	shape.radius=7
	var query:=PhysicsShapeQueryParameters2D.new()
	query.shape=shape
	query.collision_mask=1
	query.transform=Transform2D(0,point)
	return not scene.get_world_2d().direct_space_state.intersect_shape(query).is_empty()
