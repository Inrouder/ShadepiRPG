extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+label)
func run() -> void:
	var world = load("res://scenes/main.tscn").instantiate()
	root.add_child(world)
	world.close_menu()
	world.stage = 2
	world.set_coop(true)
	world.process_mode = Node.PROCESS_MODE_DISABLED
	world.raven.position = Vector2(250,350)
	for i in 8:
		world.raven.facing = Vector2.from_angle(i*PI/4)
		world.effects.weapon_traces.clear()
		world.raven_shot()
		var trace: Dictionary = world.effects.weapon_traces.back()
		check(trace.from.is_equal_approx(world.raven.attack_attachment(false)), "pistol flash starts at the authored muzzle in octant %d" % i)
		check(not trace.electric and trace.from.distance_to(world.raven.position)>28, "pistol is distinct from a ground-centered energy ray")
		check(world.raven.attack_attachment(true).distance_to(trace.from)>0.5, "hand and muzzle have separate anchors")
	for name in ["punk-1","punk-2","punk-3","punk-4","shooter-visor","shooter-violet","jackal","kenzo"]:
		var foe = load("res://scripts/enemy.gd").new()
		world.add_child(foe)
		foe.setup(load("res://assets/sprites/npcs/"+name+".png"),world)
		foe.set_physics_process(false)
		for direction in 8:
			foe.facing = Vector2.from_angle(direction*PI/4)
			foe.attack_direction = foe.facing
			foe.windup = 0.3
			foe.animate("idle",0)
			check(foe.combat_phase == "windup" and foe.visual.texture == foe.base_texture,"windup uses existing identity pose")
			foe.windup = 0
			foe.attack_visual_time = 0.4
			foe.animate("attack",0)
			check(foe.combat_phase=="contact" and foe.visual.texture is AtlasTexture, name+" has directional contact pose")
			foe.attack_visual_time = 0.12
			foe.animate("attack",0)
			check(foe.combat_phase=="recovery" and foe.visual.texture==foe.base_texture, "recovery lowers the arm with a distinct original pose")
		foe.hack()
		foe.animate("hurt",0)
		check(foe.visual.texture==foe.base_texture and foe.visual.hframes==8,"interrupt restores original atlas")
		foe.reset_fight(20)
		foe.take_damage(4,foe.position+Vector2.LEFT*20)
		check(world.combat_audio.last_event.contains("enemy_hurt_"),"damage has a pain grunt")
		var serial: int = world.combat_audio.serial
		foe.take_damage(4,foe.position+Vector2.LEFT*20)
		check(world.combat_audio.serial == serial,"rapid pain sounds are rate limited")
		foe.take_damage(100,foe.position+Vector2.LEFT*20)
		check(world.combat_audio.last_event.contains("enemy_death_"),"lethal damage selects death groan")
		check(foe.body_material.get_shader_parameter("flash") == 0.0, "corpse does not remain stuck in a white hit flash")
		serial = world.combat_audio.serial
		foe.take_damage(10)
		check(world.combat_audio.serial == serial,"corpse cannot repeat death groan")
		foe.reset_fight(20)
		check(foe.visual.texture==foe.base_texture and foe.visual.rotation==0,"checkpoint resets pose and corpse tween")
		foe.queue_free()
	var dive = load("res://scenes/chapter_two.tscn").instantiate()
	root.add_child(dive)
	dive._enter(dive.Section.DIVE,1)
	dive.ui.clear_dialogue()
	dive.process_mode = Node.PROCESS_MODE_DISABLED
	dive.effects.weapon_traces.clear()
	dive.raven.facing = Vector2.RIGHT
	dive.raven_shot()
	var bolt: Dictionary = dive.effects.weapon_traces.back()
	check(bolt.electric and bolt.from.is_equal_approx(dive.raven.attack_attachment(true)),"Deep Dive lightning starts in Raven's hand")
	for i in 8:
		dive.raven.facing = Vector2.from_angle(i*PI/4)
		dive.raven.attack_time = 0.22
		dive.raven_attack_fx(dive.raven.position+dive.raven.facing*100, true)
		check(dive.raven.visual.texture == dive.raven.HAND_CAST and dive.effects.weapon_traces.back().from.is_equal_approx(dive.raven.attack_attachment(true)), "open-hand lightning anchor works in every octant")
	dive.power_attack(dive.raven)
	for child in dive.get_children():
		if child.get_script() == preload("res://scripts/power_projectile.gd"):
			check(child.electric and (child.position+child.visual_offset).is_equal_approx(dive.raven.attack_attachment(true)),"charged lightning starts at hand too")
	for kind in ["enemy_attack_0","enemy_attack_1","enemy_hurt_0","enemy_hurt_1","enemy_hurt_2","enemy_death_0","enemy_death_1","enemy_death_2","pistol","electric"]:
		var stream: AudioStream = load("res://assets/audio/"+kind+".wav")
		check(stream != null and stream.get_length() > 0.1,"original combat audio loads: "+kind)
	world.queue_free()
	dive.queue_free()
	await process_frame
	print("RAVEN / ENEMY COMBAT: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
