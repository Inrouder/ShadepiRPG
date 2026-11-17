extends SceneTree
## v0.66.0 · CodexAI. Reported pillar spawn, companion attacks, mobile guardian and tower roles.
var checks:=0
var failures:=0
func _initialize(): Engine.max_fps=180; run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok: failures+=1; push_error("FAIL: "+label)
func frames(n: int=4):
	for i in n: await process_frame
func freeze(w):
	w.set_process(false); w.player.set_physics_process(false); w.raven.set_physics_process(false)
	for threat in w.threats: threat.set_process(false)
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	set_meta("shadepi_admin_testing",true)
	var two=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(two);current_scene=two
	two.cutscene.abort(); two._enter(two.Section.DIVE,1); two.cutscene.abort(); two.close_menu(); two.set_coop(true)
	# Open the real red room, discard its first wave, then inspect every second-wave spawn.
	two._open_net_layer("dive_core",func(): pass); freeze(two)
	for t in two.threats.duplicate(): two._destroy_threat(t)
	freeze(two)
	var clear:=true
	for t in two.threats: clear=clear and not two.net_layer.blocked(t.position,12)
	check(clear and two.threats.size()==4,"all red second-wave ICE spawn outside the pillar collision margin")
	# A head-on approach must route around the entire second column, not merely slide one axis.
	var virus=two.threats.back(); virus.position=two.net_layer.point(Vector2(430,218))
	two.raven.position=two.net_layer.point(Vector2(500,250));two.raven.health_floor=100
	var start: Vector2=virus.position
	var moved:=false; var penetrated:=false
	for i in 900:
		virus._process(1.0/60.0)
		moved=moved or absf(virus.position.x-start.x)>45
		penetrated=penetrated or two.net_layer.blocked(virus.position,11)
	if not moved or penetrated: print("ICE route debug ",virus.position-two.net_layer.ORIGIN," detoured=",moved," collided=",penetrated," path=",virus.route)
	check(moved and not penetrated,"ICE detours around the second column rather than freezing or crossing its solid base")
	# Real P2 drone attacks must reach a non-PixelActor receiver without runtime errors.
	for t in two.threats.duplicate():
		if t!=virus:two.threats.erase(t);t.free()
	virus.position=two.net_layer.point(Vector2(570,210)); virus.cracked=0;virus.elapsed=0
	two.raven.position=virus.position-Vector2(70,0)
	var pet=two.companion;pet.presence=0;pet.kind="";pet._process(0.1);pet.position=virus.position-Vector2(35,0)
	pet.claim(); pet.attack()
	check(virus.cracked>0 and virus in two.threats,"P2 drone shot cracks a real red ICE enemy")
	pet.attack_cooldown=0;pet.attack()
	check(virus not in two.threats and not two.net_layer.locked,"second drone shot deletes the open ICE and unlocks the cleared room")
	# Direct attacks and jamming share the digital receiver in the ordinary map as well.
	two._enter(two.Section.DIVE,2);two.cutscene.abort();two.close_menu();freeze(two)
	check(two.companion.position.distance_to(two.raven.position)<50,"P2 drone arrives beside Raven after leaving the distant red room")
	var boss=two.ice_guardian();var origin: Vector2=boss.position
	boss._process(1.0/60)
	check(boss.position.distance_to(origin)<3,"guardian movement starts continuously in its actual expanded arena bounds")
	for i in 119:boss._process(1.0/60)
	check(boss.position.distance_to(origin)>80 and not two.dive_blocked(boss.position,12),"guardian flies through the arena during warning/fire")
	check(boss.SHOT_COUNT>=7 and boss.SHOT_INTERVAL<0.42 and boss.COOLING<6.2,"salvos are denser and recur sooner")
	boss.phase=boss.Phase.COOL;boss.phase_time=0;boss.cycle_damage=0;boss.hit_cooldown=0
	var stop: Vector2=boss.position;boss._process(0.3)
	check(boss.position==stop and boss.vulnerable(),"guardian holds a reachable stationary counterattack window")
	two.companion_hit(boss,8,boss.position-Vector2(40,0))
	check(boss.health==boss.MAX_HEALTH-1,"P2 can also hit the exposed boss core from an actual nearby drone origin")
	var time: float=boss.phase_time;two.menu_open=true;boss._process(1)
	check(boss.phase_time==time and boss.position==stop,"pause freezes guardian motion and attacks")
	var zoom: float=two.ice_camera_zoom()
	var centre: Vector2=two.ice_camera_home()
	check(absf((boss.position-two.raven.position).x)*zoom<550 and absf((boss.position-two.raven.position).y)*zoom<250,"boss framing keeps both fighters inside the usable screen")
	two.menu_open=false;two._enter(two.Section.END);two.cutscene.abort();two.close_menu()
	var bath_position: Vector2=two.player.position
	two.continue_to_pact()
	check(two.in_cinematic() and two.player.position==bath_position,"chapter handover begins beside the bath instead of teleporting to chapter three")
	Engine.time_scale=6
	for i in 500:
		await process_frame
		if two.cutscene.waiting_input:two.cutscene.advance()
		if two.player.position.x<560:break
	check(two.player.position.x<560 and two.player.position.x>437,"both characters visibly walk toward the chapter-three positions")
	two._enter(two.Section.HIDEOUT);await frames(8)
	check(two.section==two.Section.HIDEOUT and current_scene==two,"loading another section aborts the pending chapter change")
	Engine.time_scale=1
	two.free();current_scene=null;await frames()
	var w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w);current_scene=w
	w.cutscene.abort();w.set_coop(true);w._enter(w.Beat.BOSS);w.cutscene.abort();w.close_menu()
	check(w.actor_is_playable(w.raven) and w.actor_input_prefix(w.raven)=="raven_" and w.companion_lead()==null,"P2 controls Raven in the Kenzo fight instead of nanites")
	w.started=true;w.player.position=Vector2(680,420);w.raven.position=Vector2(720,420)
	var p1: Vector2=w.player.position;var p2: Vector2=w.raven.position
	for foe in w.foes:foe.set_physics_process(false)
	Input.action_press("raven_move_right")
	for i in 8:await physics_frame
	Input.action_release("raven_move_right")
	check(w.raven.position.x>p2.x+4 and w.player.position==p1,"P2 movement input actually moves Raven independently in the Kenzo fight")
	var kenzo=w.foes.back();kenzo.set_physics_process(false);kenzo.exposed=3
	w.raven.position=kenzo.position-Vector2(80,0);w.raven.facing=Vector2.RIGHT;w.raven.reset_transients()
	var hp: int=kenzo.health
	Input.action_press("raven_attack")
	for i in 3:await physics_frame
	Input.action_release("raven_attack")
	if kenzo.health==hp:print("P2 shot diagnostics: attack=",w.raven.attack_time," ready=",w.is_combat()," busy=",w.is_busy()," sight=",w._line_clear(w.raven.position,kenzo.position)," target=",w.raven_shot_target(w.raven.position))
	check(kenzo.health<hp and w.raven.attack_time>0,"P2 attack input fires Raven's actual pistol at Kenzo")
	w._enter(w.Beat.ESCAPE,0,3);w.cutscene.abort();w.close_menu();w.escape_guards_cleared=true
	w._start_passages(w.WAY_OUT,func(): pass)
	w.cutscene.skip();await frames()
	check(w.in_passage() and w.coop_raven_playable() and w.companion_lead()==null,"P2 remains Raven in the post-penthouse escape corridors")
	w.skip_passages();w._enter(w.Beat.GARAGE);w.cutscene.abort();w.close_menu()
	w.bike_mode="approach";w.bike_pos=Vector2(160,210);w.garage_bike.sync()
	check(w.garage_bike.visible and w.bike_pos.x<w.GARAGE_DOOR.position.x and w.garage_bike.material.get_shader_parameter("outside_only"),"arrival bike exists off to the side and is clipped to the exterior door opening")
	if DisplayServer.get_name()!="headless":
		# Render the actual arrival Sprite + shader in a clean transparent viewport.
		var vp:=SubViewport.new();vp.size=Vector2i(1024,640);vp.transparent_bg=true
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
		vp.world_2d=World2D.new()
		w.garage_bike.reparent(vp,false);w.garage_bike.set_process(false)
		await frames(4);await RenderingServer.frame_post_draw
		check(vp.get_texture().get_image().is_invisible(),"native pixels: motorcycle outside the doorway is completely hidden")
		w.garage_door=1;w.bike_pos=Vector2(300,210);w.garage_bike.sync()
		await frames(4);await RenderingServer.frame_post_draw
		var picture: Image=vp.get_texture().get_image();var inside:=0;var outside:=0
		for y in range(640,0,-2):
			for x in range(0,1024,2):
				if picture.get_pixel(x,mini(y-1,639)).a>0.1:
					if w.GARAGE_DOOR.has_point(Vector2(x,y-1)):inside+=1
					else:outside+=1
		check(inside>20 and outside==0,"native pixels: approaching bike is visible through the opening only")
		w.bike_mode="ride";w.bike_pos=Vector2(460,350);w.garage_bike.sync()
		await frames(4);await RenderingServer.frame_post_draw
		check(not vp.get_texture().get_image().is_invisible(),"native pixels: the same motorcycle remains visible after crossing into the garage")
		w.garage_bike.reparent(w,false);vp.free()
	w.free();current_scene=null;await frames()
	var one=load("res://scenes/chapter_one.tscn").instantiate();root.add_child(one);current_scene=one
	one.cutscene.abort();one._enter_checkpoint(one.Phase.TEAM);one.cutscene.abort();one.close_menu()
	check(one.enemy.position.distance_to(one.DOWNED_SPOT)<65,"Jackal starts Shadepi's fight beside the downed Raven")
	one.phase=one.Phase.REVIVE;one._scene_revive()
	check(one.enemy.facing.dot(one.enemy.position.direction_to(one.DOWNED_SPOT))<0,"before the fight Jackal stands with his back toward Raven")
	one._enter_checkpoint(one.Phase.COMPLETE);one.cutscene.abort()
	check(not one.player.visible and one.player.position==one.SHADOW_EXIT,"chapter-one completion retains Shadepi's dark-alley departure rather than a wall perch")
	one.free();current_scene=null;await frames()
	print("REGRESSIONS v0.66.0 CodexAI: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
