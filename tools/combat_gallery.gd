extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func capture(scene: Node2D, filename: String) -> void:
	scene.ui._process(0)
	scene.effects.queue_redraw()
	scene.player.queue_redraw()
	scene.raven.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-move-" + filename + ".png")

func run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(1)
		return
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.close_menu()
	scene.set_coop(true)
	scene.stage = 2
	scene.set_gate(true)
	scene.player.position = Vector2(320, 380)
	scene.raven.position = Vector2(370, 360)
	scene.player.facing = Vector2.RIGHT
	scene.raven.facing = Vector2.RIGHT
	scene.enemy.active = false
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	scene.camera.zoom = Vector2(2, 2)
	scene.camera.position = Vector2(320, 345)
	scene.camera.force_update_scroll()
	scene.player.start_charge()
	scene.player.update_charge(0.7)
	scene.player.animate("charge", 0)
	scene.raven.animate("idle", 0)
	await capture(scene, "charge")
	scene.player.update_charge(0.5)
	scene.effects._process(0.12)
	await capture(scene, "ready")
	scene.player.release_charge()
	scene.player.animate("attack", 0.14)
	for child in scene.get_children():
		if child.get_script() == preload("res://scripts/power_projectile.gd"):
			child.advance(0.16)
	await capture(scene, "wave")
	scene.effects.charge_rings.clear()
	for child in scene.get_children():
		if child.get_script() == preload("res://scripts/power_projectile.gd"):
			child.hide()
			child.queue_free()
	scene.player.reset_transients()
	scene.player.try_kick()
	scene.player.animate("kick", 0)
	await capture(scene, "kick-windup")
	scene.player.attack_time = 0.25
	scene.player.animate("kick", 0)
	await capture(scene, "kick")
	scene.player.reset_transients()
	scene.player.animate("idle", 0)
	scene.raven.start_charge()
	scene.raven.update_charge(1.1)
	scene.raven.animate("charge", 0)
	scene.effects._process(0.15)
	await capture(scene, "raven-ready")
	scene.effects.charge_rings.clear()
	scene.raven.release_charge()
	scene.raven.animate("attack", 0.05)
	for child in scene.get_children():
		if child.get_script() == preload("res://scripts/power_projectile.gd") and child.ranged:
			child.advance(0.15)
	await capture(scene, "raven-shot")
	if "--record" in OS.get_cmdline_user_args():
		await record(scene)
	scene.queue_free()
	await process_frame
	quit()

func record(scene: Node2D) -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/shadepi-move-frames")
	var frame := 0
	for actor in [scene.player, scene.raven]:
		actor.reset_transients()
		actor.energy = 100
		actor.animate("idle", 0)
	scene.effects.charge_rings.clear()
	for actor in [scene.player, scene.raven]:
		actor.start_charge()
		for i in 30:
			actor.update_charge(0.05)
			actor.animate("charge", 0.05)
			await record_frame(scene, frame)
			frame += 1
		actor.release_charge()
		for i in 14:
			actor.attack_time = maxf(0, actor.attack_time - 0.05)
			actor.animate("attack" if actor.attack_time > 0 else "idle", 0.05)
			await record_frame(scene, frame)
			frame += 1
		if not actor.second_player:
			actor.reset_transients()
			actor.try_kick()
			for i in 14:
				actor.attack_time = maxf(0, actor.attack_time - 0.05)
				actor.animate("kick" if actor.attack_time > 0 else "idle", 0.05)
				await record_frame(scene, frame)
				frame += 1

func record_frame(scene: Node2D, frame: int) -> void:
	scene.effects._process(0.05)
	for child in scene.get_children():
		if child.get_script() == preload("res://scripts/power_projectile.gd") and not child.is_queued_for_deletion():
			if child.generation != child.source.combat_generation:
				child.queue_free()
			else:
				child.advance(0.05)
	scene.ui._process(0.05)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-move-frames/%03d.png" % frame)
