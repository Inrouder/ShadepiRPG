extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error('FAIL: '+label)
func free_at(map: Node2D,point: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = 7
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1
	query.transform = Transform2D(0,point)
	return map.get_world_2d().direct_space_state.intersect_shape(query).is_empty()
func route(map: Node2D,a: Vector2,b: Vector2) -> bool:
	var samples := ceili(a.distance_to(b)/4)
	for i in samples+1:
		if not free_at(map,a.lerp(b,float(i)/maxi(1,samples))): return false
	return true
func run() -> void:
	var scene = load('res://scenes/memories/attack.tscn').instantiate()
	scene.autoplay = false
	root.add_child(scene)
	await physics_frame
	await physics_frame
	check(scene.squad.size()==5 and scene.residents.size()==8,'Shadepi, four warriors and eight residents are separate actors')
	for actor in scene.squad+scene.residents:
		check(free_at(scene.map,actor.position),'initial actor position has floor clearance')
		for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
			actor.facing = direction
			actor.animate('walk',0.16)
			check(actor.visual.texture != null and actor.visual.frame>=0,'directional movement has art')
	for i in scene.residents.size():
		var start: Vector2 = scene.residents[i].position
		var turn := Vector2(82,330+(i/4)*160)
		check(route(scene.map,start,turn) and route(scene.map,turn,Vector2(82,268)),'resident escape route avoids walls and props')
	for i in scene.squad.size():
		check(route(scene.map,scene.squad[i].position,Vector2(565 if i==0 else 530-i*34,376+(i%2)*62)),'formation path avoids collisions')
	for actor in scene.squad:
		if actor.identity=="shadepi": continue
		for facing in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2(1,1).normalized(),Vector2(-1,-1).normalized()]:
			actor.facing = facing
			for state in ["idle","walk"]:
				actor.animate(state,0.16)
				var direction: int = actor.OCTANT_ROWS[posmod(roundi(facing.angle()/(PI/4)),8)]
				var key: String = actor.frame_key.get_slice("_",0)
				if actor.frame_key.begins_with("run_a"): key="run_a"
				elif actor.frame_key.begins_with("run_b"): key="run_b"
				var data: Dictionary = actor.catalog[actor.identity][key][direction]
				var feet := Vector2(data.anchor[0],data.anchor[1])-Vector2(actor.visual.texture.get_size())*0.5
				check(actor.visual.to_global(feet).distance_to(actor.global_position)<0.1,"sprite foot anchor stays on its physical floor point")
	check(not free_at(scene.map,Vector2(82,200)),"evacuation doorway does not allow walking through the upper building")
	var hero: PixelActor = scene.squad[0]
	hero.position = Vector2(620,430)
	for i in 25:
		hero.velocity = Vector2(0,90)
		hero.move_and_slide()
		await physics_frame
	check(hero.position.y<451,'standing column has a real blocking footprint')
	check(not free_at(scene.map,Vector2(400,560)),'foreground parapet cannot be crossed')
	scene.map.impact(Vector2(850,310))
	scene.toggle_pause()
	var clock: float = scene.map.elapsed
	scene.map._process(0.5)
	check(scene.map.elapsed==clock,'pause freezes fire and bomb FX')
	scene.toggle_pause()
	scene.map._process(1)
	check(scene.map.impacts.is_empty(),'bomb effects expire')
	scene.queue_free()
	await process_frame
	await integration()
	print('MONASTERY MEMORY: %d checks, %d failures'%[checks,failures])
	quit(1 if failures else 0)

func pad(button: JoyButton) -> void:
	for pressed in [true,false]:
		var event := InputEventJoypadButton.new()
		event.device = 77
		event.button_index = button
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func integration() -> void:
	var world = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(world)
	world._enter(world.Beat.ECHO,0,0,true,false)
	world.ui.clear_dialogue()
	world.raven.position = world.Painted.ECHO_POINTS[0]
	world.raven.energy = 43
	world.player.health = 79
	var home: Vector2 = world.raven.position
	world.interact()
	var panel = world.memory_scene
	world.interact()
	await process_frame
	check(panel != null and world.memory_scene==panel and world.point_index==0,"first anchor opens one isolated memory and defers progress")
	check(world.is_busy() and panel.get_world_2d()!=world.get_world_2d(),"present is frozen; historical physics is isolated")
	await pad(JOY_BUTTON_START)
	check(panel.menu_open,"controller Start pauses memory")
	var clock: float = panel.map.elapsed
	panel.map._process(1)
	check(clock==panel.map.elapsed and world.raven.energy==43,"embedded pause freezes FX and present vitals")
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_DPAD_DOWN)
	await pad(JOY_BUTTON_A)
	check(world.memory_scene==null and world.point_index==0,"controller can abort memory without completing anchor")
	check(world.raven.position==home and world.raven.energy>=43 and world.raven.energy<45 and world.player.health==79,"abort preserves present position and vitals")
	world.interact()
	panel = world.memory_scene
	await process_frame
	check(panel.cutscene.running,"memory replay starts after abort")
	await pad(JOY_BUTTON_B)
	check(world.memory_scene==null and world.point_index==1 and world.memory_attack_complete,"controller skip commits first anchor exactly once")
	check(world.raven.position==home and world.raven.energy>=43 and world.raven.energy<45 and world.player.health==79 and world.music_section=="chapter_5_echo","completion preserves present actors and restores memory music")
	world.point_index = 0
	world.echo_ready = false
	world.memory_attack_complete = false
	check(world.load_game() and world.point_index==1 and world.echo_ready and world.memory_attack_complete,"saved first memory resumes in memory chamber without replaying synchronization")
	world.point_index = 0
	world.memory_attack_complete = false
	world.raven.position = world.Painted.ECHO_POINTS[0]
	world.interact()
	panel = world.memory_scene
	world._enter(world.Beat.ROOF)
	panel.finished.emit(true)
	check(world.memory_scene==null and world.beat==world.Beat.ROOF and world.point_index==0,"old memory signal cannot advance another chapter")
	world.queue_free()
	await process_frame
