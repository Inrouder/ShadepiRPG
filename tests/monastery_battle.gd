extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+label)
func make_scene() -> Node2D:
	var scene = load("res://scenes/memories/attack.tscn").instantiate()
	scene.autoplay = false
	root.add_child(scene)
	return scene
func free_route(scene: Node2D,a: Vector2,b: Vector2) -> bool:
	var circle := CircleShape2D.new()
	circle.radius = 7
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.collision_mask = 1
	var samples := maxi(1,ceili(a.distance_to(b)/4))
	for i in samples+1:
		query.transform = Transform2D(0,a.lerp(b,float(i)/samples))
		if not scene.get_world_2d().direct_space_state.intersect_shape(query).is_empty(): return false
	return true
func run() -> void:
	var scene = make_scene()
	await physics_frame
	for actor in scene.residents.slice(0,4):
		for direction in [Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT,Vector2.UP]:
			actor.facing = direction
			actor.animate("idle",0)
			var frames := {}
			var scales := {}
			for i in 4:
				actor.animate("walk",0.0 if i==0 else 1.0/9.0+0.0001)
				frames[actor.frame_key] = true
				scales[actor.visual.scale] = true
				check(actor.visual.texture.atlas==actor.WALK,"walking uses the new transparent pixel atlas")
				check(actor.last_foot.length()<0.01,"walking contact stays on the physical ground anchor")
			check(frames.size()==4,"each resident direction has four distinct gait frames")
			check(scales.size()==1,"gait frames preserve body scale")
	for actor in [scene.squad[1],scene.squad[2],scene.squad[3],scene.squad[4],scene.bots[0]]:
		var scales := {}
		for state in ["guard","windup","strike","recover","hurt","kneel","fall","dead"]:
			actor.animate(state,0)
			scales[actor.visual.scale] = true
			check(actor.visual.texture.atlas==actor.COMBAT and actor.last_foot.length()<0.01,"combat and collapse use anchored source poses")
		check(scales.size()==1,"collapse does not normalize a prone body into an oversized actor")
	for actor in [scene.squad[4],scene.bots[0]]:
		actor.animate("shoot",0)
		check(actor.frame_key=="combat_2","gunfire starts in the contact frame")
		actor.animate("shoot",0.3)
		check(actor.frame_key=="combat_0","muzzle flash ends instead of remaining lit between shots")
	scene.queue_free()
	await process_frame
	await story()
	await cancellation()
	await mid_battle_skip()
	print("MONASTERY BATTLE: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
func story() -> void:
	var scene = make_scene()
	var completed: Array[bool] = []
	scene.finished.connect(func(ok: bool): completed.append(ok))
	scene.play.call_deferred()
	var old_scale := Engine.time_scale
	var old_cap := Engine.max_fps
	Engine.time_scale = 12
	Engine.max_fps = 120
	var paused := false
	var bad_routes := {}
	var last := {}
	var seen := {}
	for frame in 1800:
		await process_frame
		for actor in scene.squad+scene.bots:
			if last.has(actor) and actor.position!=last[actor] and not free_route(scene,last[actor],actor.position):
				bad_routes[actor.identity+" "+str(actor.position)] = true
			last[actor] = actor.position
		seen[scene.phase] = true
		if scene.phase=="oni_protection" and not paused:
			paused = true
			scene.toggle_pause()
			var positions: Array = scene.squad.map(func(a): return a.position)
			var clock: float = scene.map.elapsed
			var events: Array = scene.battle.events.duplicate()
			for i in 4: await process_frame
			check(scene.squad.map(func(a): return a.position)==positions and scene.map.elapsed==clock and scene.battle.events==events,"pause freezes the actual protection scene and battle progression")
			scene.toggle_pause()
		if scene.cutscene.waiting_input: scene.cutscene.advance()
		if scene.closed: break
	Engine.time_scale = old_scale
	Engine.max_fps = old_cap
	check(scene.closed and completed==[true],"complete battle returns exactly one successful completion")
	check(paused,"full playback reaches Oni's protection scene")
	check(bad_routes.is_empty(),"all cinematic battle paths avoid solid scenery: "+str(bad_routes.keys()))
	check(scene.battle.events==["wave_1_start","wave_1_clear","wave_2_start","oni_protected","oni_fallen","wave_2_clear","wave_3_start","mg_cover","heavy_fallen","wave_3_clear","retreat"],"three finite waves and authored protection deaths retain story order")
	check(scene.squad[1].fallen and scene.squad[4].fallen,"Oni and heavy warrior fall in their protection moments")
	check(not scene.squad[0].fallen and not scene.squad[2].fallen and not scene.squad[3].fallen,"Shadepi, Ly and robot-headed warrior survive")
	check(scene.bots.size()==9 and scene.bots.all(func(a): return a.fallen),"three separate waves leave nine disabled bots without resurrection")
	check(scene.residents.all(func(a): return not a.visible),"all civilians finish the evacuation")
	check(seen.has("wave_1") and seen.has("wave_2") and seen.has("wave_3") and seen.has("oni_fallen") and seen.has("mg_last_stand") and seen.has("retreat"),"all major battle phases are actually played")
	for actor in [scene.squad[1],scene.squad[4]]:
		actor.animate("idle",1)
		check(actor.animation_name=="dead" and actor.collision_layer==0,"fallen ally remains prone and cannot be revived by an idle pose")
	scene.queue_free()
	await process_frame
func reach_second_wave(scene: Node2D) -> void:
	for i in 1000:
		await process_frame
		if scene.cutscene.waiting_input: scene.cutscene.advance()
		if scene.phase=="wave_2": return

func cancellation() -> void:
	var scene = make_scene()
	var completed: Array[bool] = []
	scene.finished.connect(func(ok: bool): completed.append(ok))
	Engine.time_scale = 16
	Engine.max_fps = 120
	scene.play.call_deferred()
	await reach_second_wave(scene)
	check(scene.phase=="wave_2" and not scene.squad[1].fallen,"abort test reaches the actual second wave before Oni falls")
	scene.cancel()
	var events: Array = scene.battle.events.duplicate()
	var count: int = scene.bots.size()
	for i in 4: await process_frame
	check(scene.closed and not scene.completed and completed==[false] and events==scene.battle.events and scene.bots.size()==count,"aborting an active wave stops later bots and deaths without completion")
	Engine.time_scale = 1
	Engine.max_fps = 0
	scene.queue_free()
	await process_frame

func mid_battle_skip() -> void:
	var scene = make_scene()
	var completed: Array[bool] = []
	scene.finished.connect(func(ok: bool): completed.append(ok))
	Engine.time_scale = 16
	Engine.max_fps = 120
	scene.play.call_deferred()
	await reach_second_wave(scene)
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_B
	event.pressed = true
	check(scene.handle_event(event),"controller B is accepted during an active wave")
	check(scene.closed and completed==[true] and scene.squad[1].fallen and scene.squad[4].fallen and not scene.squad[3].fallen,"mid-battle skip resolves the canonical end state exactly once")
	check(scene.bots.size()==9 and scene.battle.events.back()=="retreat","skip completes all finite waves and the retreat without hanging")
	Engine.time_scale = 1
	Engine.max_fps = 0
	scene.queue_free()
	await process_frame
