extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error("FAIL: "+label)
func make_scene() -> Node2D:
	var scene=load("res://scenes/memories/sacrifice.tscn").instantiate()
	scene.autoplay=false
	root.add_child(scene)
	return scene
func run() -> void:
	var scene=make_scene()
	await physics_frame
	await physics_frame
	check(scene.squad.map(func(a): return a.identity)==["shadepi","robot","ly"] and scene.bots.is_empty() and scene.residents.is_empty(),"only the three survivors appear in memory two")
	check(scene.map.background_texture==scene.RUINS,"same monastery uses its later ruined variant")
	check(not scene.tank.visible and not scene.tank.destroyed,"Minotaur starts intact, before its entrance")
	var scales := {}
	for state in ["idle","walk","fire","hurt","critical","collapse","wreck"]:
		scene.tank.animate(state,0.15)
		var pose: Dictionary=scene.tank.frames[scene.tank.frame_index]
		var source_point=Vector2(pose.anchor[0],pose.anchor[1])-scene.tank.visual.texture.get_size()*0.5
		check(scene.tank.visual.to_global(source_point).distance_to(scene.tank.global_position)<0.01,"mech atlas stance is attached to its real floor point")
		scales[scene.tank.visual.scale]=true
	check(scales.size()==1,"mech keeps its scale during collapse")
	scene.tank.animate("fire",0)
	scene.tank.animate("fire",0.2)
	check(scene.tank.frame_index==0,"mech muzzle flash is transient")
	var ly=scene.squad[2]
	for state in ["charge_draw","charge_arm","charge_leap","charge_attach","charge_brace"]:
		ly.animate(state,0)
		check(ly.visual.texture.atlas==ly.CHARGE_ART,"Ly uses the matching original white costume in charge poses")
		var pose: Dictionary=ly.charge_data[int(ly.frame_key.get_slice("_",1))]
		var source_point=Vector2(pose.anchor[0],pose.anchor[1])-ly.visual.texture.get_size()*0.5
		check(ly.visual.to_global(source_point).distance_to(ly.global_position)<0.01,"Ly charge pose has a consistent measured contact")
	ly.carrying=true
	ly.animate("idle",0)
	var frames := {}
	for i in 2:
		ly.animate("walk",0.126)
		frames[ly.frame_key]=true
	check(frames.size()==2,"running with charge alternates actual leg poses")
	var image=scene.tank.ART.get_image()
	check(image.get_pixel(0,0).a<0.05 and ly.CHARGE_ART.get_image().get_pixel(0,0).a<0.05,"sprite backgrounds are actually transparent")
	scene.queue_free()
	await process_frame
	await survival_controls()
	await full_story()
	await mid_scene_controls()
	await integration()
	print("SACRIFICE MEMORY: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
func clear_route(scene: Node2D,actor: PixelActor,a: Vector2,b: Vector2) -> bool:
	var query:=PhysicsShapeQueryParameters2D.new()
	query.collision_mask=1
	query.exclude=[actor.get_rid()]
	if actor==scene.tank:
		var shape:=RectangleShape2D.new()
		shape.size=scene.tank.FOOTPRINT.size
		query.shape=shape
	else:
		var shape:=CircleShape2D.new()
		shape.radius=7
		query.shape=shape
	var count:=maxi(1,ceili(a.distance_to(b)/4))
	for i in count+1:
		query.transform=Transform2D(0,a.lerp(b,float(i)/count))
		if not scene.get_world_2d().direct_space_state.intersect_shape(query).is_empty(): return false
	return true
func full_story() -> void:
	var scene=make_scene()
	var finished: Array[bool]=[]
	scene.finished.connect(func(ok: bool): finished.append(ok))
	var old_scale:=Engine.time_scale
	Engine.time_scale=12
	Engine.max_fps=120
	scene.play.call_deferred()
	var seen := {}
	var lines := {}
	var last := {}
	var bad_paths := {}
	var pause_checked:=false
	var attachment_seen:=false
	for frame in 1600:
		await process_frame
		seen[scene.phase]=true
		if scene.phase=="survival": scene.battle.invulnerable=1.0
		for actor in scene.squad+[scene.tank]:
			if last.has(actor) and last[actor]!=actor.position and actor.collision_mask!=0 and not clear_route(scene,actor,last[actor],actor.position): bad_paths[actor.identity+str(actor.position)]=true
			last[actor]=actor.position
		if scene.phase=="decision" and not pause_checked:
			pause_checked=true
			scene.toggle_pause()
			var clock: float=scene.map.elapsed
			var positions: Array=scene.squad.map(func(a): return a.position)
			var events: Array=scene.events.duplicate()
			for i in 4: await process_frame
			check(clock==scene.map.elapsed and positions==scene.squad.map(func(a): return a.position) and events==scene.events,"pause freezes decision and sacrifice progression")
			scene.toggle_pause()
		if scene.phase=="attached" and not attachment_seen:
			attachment_seen=true
			check(scene.charge.visible and scene.charge.position==scene.tank.weak_point() and scene.squad[2].visible and not scene.squad[2].fallen,"Ly remains with the attached charge before detonation")
		if scene.cutscene.waiting_input:
			lines[scene.cutscene.line_label.text]=true
			scene.cutscene.advance()
		if scene.closed: break
	Engine.time_scale=old_scale
	Engine.max_fps=0
	check(scene.completed and finished==[true],"full second memory completes exactly once")
	check(scene.battle.elapsed==scene.Survival.DURATION and not scene.battle.dead,"normal story reaches the full survival timer before Lys sacrifice")
	check(pause_checked and attachment_seen,"decision and mounted charge actually play")
	check(bad_paths.is_empty(),"ground movement avoids map and mech footprint: "+str(bad_paths.keys()))
	check(scene.events==["arrival","minotaur_arrives","survival_started","survival_resolved","armour_holds","servo_exposed","charge_armed","ly_commits","charge_attached","detonation","ly_fallen","minotaur_destroyed","survivors_hold"],"Lys sacrifice destroys the Minotaur in the intended causal order")
	check(lines.has("Nein! Ly, nicht!") and lines.has("Verzeih mir, Bruder. FÜR DEN ORDEN!"),"both confirmed lines are spoken on screen")
	check(scene.squad[2].fallen and not scene.squad[2].visible and not scene.charge.visible,"Ly remains at the detonation and cannot escape or respawn")
	check(not scene.squad[0].fallen and not scene.squad[1].fallen,"Shadepi and robot-headed warrior survive without inventing another death")
	scene.tank.animate("fire",1)
	check(scene.tank.destroyed and scene.tank.animation_name=="wreck" and scene.tank.collision_layer==0,"disabled Minotaur remains a wreck")
	check(seen.has("survival") and seen.has("defence") and seen.has("weak_point") and seen.has("mount") and seen.has("detonation") and seen.has("aftermath"),"all narrative phases actually render")
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
	world._enter(world.Beat.ECHO,0,1,true,true,false)
	world.ui.clear_dialogue()
	world.raven.position=world.Painted.ECHO_POINTS[1]
	var home: Vector2=world.raven.position
	world.player.health=73
	world.raven.energy=43
	world.interact()
	var scene=world.memory_scene
	world.interact()
	await process_frame
	check(scene!=null and scene==world.memory_scene and world.point_index==1 and world.memory_anchor==1,"second anchor opens one isolated second memory")
	check(world.music_section=="boss" and world.is_busy() and world.get_world_2d()!=scene.get_world_2d(),"Boss.mp3 plays while the present remains isolated and frozen")
	await pad(JOY_BUTTON_START)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(world.memory_scene==null and world.point_index==1 and not world.memory_sacrifice_complete,"controller abort preserves the second node")
	world.interact()
	scene=world.memory_scene
	await process_frame
	await pad(JOY_BUTTON_B)
	check(world.memory_scene==null and world.point_index==2 and world.memory_attack_complete and world.memory_sacrifice_complete,"controller skip completes only the second anchor once")
	check(world.raven.position==home and world.player.health==73 and world.raven.energy>=43 and world.raven.energy<45 and world.music_section=="chapter_5_echo","return preserves present vitals, position and music")
	check(world.load_game() and world.point_index==2 and world.memory_sacrifice_complete,"new save resumes after the second memory without replaying it")
	var config:=ConfigFile.new()
	var path: String=world.Admin.checkpoint_path(world.SAVE,self)
	config.load(path)
	config.erase_section_key("campaign","memory_sacrifice_complete")
	config.save(path)
	check(world.load_game() and world.point_index==1 and world.memory_attack_complete and not world.memory_sacrifice_complete,"older point-2 save resumes at new memory two while keeping first memory complete")
	config.set_value("campaign","memory_sacrifice_complete","invalid")
	config.save(path)
	check(world.load_game() and world.point_index==1 and not world.memory_sacrifice_complete,"invalid save field does not skip the second memory")
	world.raven.position=world.Painted.ECHO_POINTS[1]
	world.interact()
	scene=world.memory_scene
	world._enter(world.Beat.ROOF)
	scene.finished.emit(true)
	check(world.beat==world.Beat.ROOF and world.point_index==0 and world.memory_scene==null,"stale second memory signal cannot advance the tower")
	world.queue_free()
	await process_frame

func mid_scene_controls() -> void:
	for skip in [false,true]:
		var scene=make_scene()
		var finished: Array[bool]=[]
		scene.finished.connect(func(ok: bool): finished.append(ok))
		Engine.time_scale=16
		Engine.max_fps=120
		scene.play.call_deferred()
		for frame in 1000:
			await process_frame
			if scene.phase=="survival": scene.battle.invulnerable=1.0
			if scene.cutscene.waiting_input: scene.cutscene.advance()
			if scene.phase=="mount": break
		check(scene.phase=="mount" and not scene.squad[2].fallen,"controller test reaches the actual chassis jump before the sacrifice")
		if skip:
			var event:=InputEventJoypadButton.new()
			event.button_index=JOY_BUTTON_B
			event.pressed=true
			scene.handle_event(event)
			check(scene.closed and scene.completed and finished==[true] and scene.tank.destroyed and scene.squad[2].fallen,"controller skip during the leap resolves the sacrifice exactly once")
		else:
			scene.cancel()
			var events: Array=scene.events.duplicate()
			for i in 4: await process_frame
			check(scene.closed and not scene.completed and finished==[false] and not scene.tank.destroyed and not scene.squad[2].fallen and scene.events==events,"abort during the jump stops pending detonation and leaves the node incomplete")
		Engine.time_scale=1
		Engine.max_fps=0
		scene.queue_free()
		await process_frame

func key_event(scene: Node2D,key: Key,pressed: bool = true) -> void:
	var event:=InputEventKey.new()
	event.keycode=key
	event.pressed=pressed
	scene.handle_event(event)

func survival_scene() -> Node2D:
	var scene=make_scene()
	scene.cutscene.begin()
	scene.phase="survival"
	scene.tank.show()
	scene.tank.position=Vector2(780,400)
	scene.battle=scene.Survival.new(scene)
	scene.battle.start()
	return scene

func survival_controls() -> void:
	var scene=survival_scene()
	await physics_frame
	var fight=scene.battle
	check(fight.health==100 and fight.DURATION==45 and not fight.dead,"survival starts with local health and a finite 45-second timer")
	var start: Vector2=scene.squad[0].position
	key_event(scene,KEY_D)
	for i in 8: await physics_frame
	key_event(scene,KEY_D,false)
	check(scene.squad[0].position.x>start.x+5,"keyboard movement actually controls historical Shadepi")
	check(fight.direction()==Vector2.ZERO,"released movement does not remain held")
	var button:=InputEventJoypadButton.new()
	button.button_index=JOY_BUTTON_B
	button.pressed=true
	scene.handle_event(button)
	check(fight.dodge_time>0 and not scene.cutscene.skipping,"B dodges during combat without skipping the memory")
	var hp: int=fight.health
	fight.damage(29)
	check(fight.health==hp,"dodge invulnerability avoids actual damage")
	fight.invulnerable=0
	fight.damage(18)
	check(fight.health==hp-18 and fight.invulnerable>0,"unprotected hits consume local health and grant brief hit protection")
	var time: float=fight.elapsed
	var position: Vector2=scene.squad[0].position
	key_event(scene,KEY_ESCAPE)
	for i in 5: await physics_frame
	check(fight.elapsed==time and scene.squad[0].position==position and not fight.hud.visible,"pause freezes player, timer, attacks and combat HUD")
	key_event(scene,KEY_ESCAPE)
	check(fight.hud.visible and fight.direction()==Vector2.ZERO,"resume restores HUD without stuck movement")
	fight.dodge_time=0
	fight.attack_cooldown=0
	scene.squad[0].position=Vector2(685,400)
	scene.squad[0].facing=Vector2.RIGHT
	for i in 4:
		fight.attack_cooldown=0
		key_event(scene,KEY_J)
	check(fight.hit_count==4 and fight.stun>0 and not scene.tank.destroyed,"real melee contacts stagger but cannot kill the armoured Minotaur")
	fight.clear_warning()
	fight.elapsed=16
	fight.tick(0.001)
	fight.begin_volley()
	check(fight.stage==1 and fight.targets.size()==3,"middle phase locks three visible impact targets")
	fight.clear_warning()
	fight.elapsed=32
	fight.tick(0.001)
	fight.begin_volley()
	check(fight.stage==2 and fight.targets.size()==5 and fight.warning<0.6,"final phase raises pressure with five targets and shorter warnings")
	fight.invulnerable=0
	fight.resolve_volley()
	check(fight.health<hp-18,"telegraphed volley damages a player remaining on its locked target")
	fight.invulnerable=0
	fight.damage(999)
	check(fight.dead and not scene.closed and not scene.completed,"death never awards the memory or triggers Lys sacrifice early")
	time=fight.elapsed
	for i in 3: await physics_frame
	check(fight.elapsed==time,"timer stops at defeat")
	key_event(scene,KEY_E)
	check(not fight.dead and fight.health==100 and fight.elapsed==0 and fight.targets.is_empty(),"retry resets timer, local vitals and all pending attacks")
	key_event(scene,KEY_SPACE)
	check(fight.dodge_time>0 and not scene.cutscene.skipping,"Space is also a dodge, never an accidental skip")
	var motion:=InputEventJoypadMotion.new()
	motion.axis=JOY_AXIS_LEFT_Y
	motion.axis_value=0.8
	scene.handle_event(motion)
	check(fight.direction().y>0.7,"controller stick drives historical combat")
	scene.cancel()
	check(not fight.running and scene.closed and not scene.completed,"leaving combat clears battle without completing the node")
	scene.queue_free()
	await process_frame
	# Exercise normal production skip from inside combat, through the pause UI.
	scene=make_scene()
	Engine.time_scale=16
	Engine.max_fps=120
	scene.play.call_deferred()
	for i in 400:
		await process_frame
		if scene.cutscene.waiting_input: scene.cutscene.advance()
		if scene.phase=="survival": break
	check(scene.phase=="survival","story hands control to the player before the sacrifice")
	scene.toggle_pause()
	scene.ui.buttons[1].pressed.emit()
	check(scene.closed and scene.completed and scene.tank.destroyed and scene.squad[2].fallen and not scene.battle.running,"pause-menu skip during combat resolves the fixed sacrifice exactly once")
	Engine.time_scale=1
	Engine.max_fps=0
	scene.queue_free()
	await process_frame
