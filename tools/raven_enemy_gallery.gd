extends SceneTree
func _initialize() -> void: run.call_deferred()
func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-combat-"+name+".png")
func run() -> void:
	if DisplayServer.get_name() == "headless": quit(1); return
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	world.close_menu()
	world.stage = 1
	world.process_mode = Node.PROCESS_MODE_DISABLED
	world.ui.root.hide()
	world.effects.rain = false
	world.player.hide()
	world.enemy.hide()
	world.raven.position = Vector2(300,380)
	world.raven.facing = Vector2.RIGHT
	world.camera.zoom = Vector2(2,2)
	world.camera.position = Vector2(365,350)
	world.camera.force_update_scroll()
	world.raven.attack_time = 0.22
	world.raven_shot()
	world.effects._process(0.035)
	await capture("pistol")
	world.raven.hide()
	var names := ["punk-1","punk-2","punk-3","punk-4","shooter-visor","shooter-violet","jackal","kenzo"]
	var foes := []
	world.camera.zoom = Vector2(1,1)
	world.camera.position = Vector2(450,340)
	world.camera.force_update_scroll()
	for i in 8:
		var foe = load("res://scripts/enemy.gd").new()
		world.add_child(foe)
		foe.setup(load("res://assets/sprites/npcs/"+names[i]+".png"),world)
		foe.set_physics_process(false)
		foe.position = Vector2(210+(i%4)*150,310+(i/4)*115)
		foe.facing = Vector2.RIGHT
		foe.attack_direction = Vector2.RIGHT
		foe.shot_range = 130 if i in [1,4,5] else 0
		foe.active = true
		foes.append(foe)
	for phase in 3:
		for foe in foes:
			foe.windup = 0.35 if phase == 0 else 0
			foe.attack_visual_time = 0.4 if phase == 1 else 0.12
			foe.animate("idle" if phase==0 else "attack",0)
		await capture(["windup","contact","recovery"][phase])
	if "--animate" in OS.get_cmdline_user_args():
		for frame in 36:
			var t := frame/18.0
			var phase := fposmod(t,1.4)
			for foe in foes:
				foe.windup = maxf(0,0.7-phase)
				foe.attack_visual_time = maxf(0,0.444-maxf(0,phase-0.7))
				foe.animate("idle" if phase<0.7 or phase>1.144 else "attack",1.0/18)
			await capture("enemy-frame-%02d"%frame)
	world.queue_free()
	await process_frame
	var dive = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(dive)
	dive._enter(dive.Section.DIVE,1)
	dive.ui.clear_dialogue()
	dive.ui.root.hide()
	dive.process_mode = Node.PROCESS_MODE_DISABLED
	dive.raven.position = Vector2(250,420)
	dive.raven.facing = Vector2.RIGHT
	for threat in dive.threats: threat.position = Vector2(410,430)
	dive.camera.zoom = Vector2(2,2)
	dive.camera.position = Vector2(310,395)
	dive.camera.force_update_scroll()
	dive.raven.attack_time = 0.22
	dive.raven_shot()
	dive.effects._process(0.06)
	await capture("lightning")
	dive.queue_free()
	await process_frame
	quit()
