extends SceneTree

const Threat = preload("res://scripts/dive_threat.gd")

class Target:
	extends Node2D
	var damage := 0
	func take_damage(amount: int, _origin: Vector2) -> void:
		damage += amount

class TestWorld:
	extends Node2D
	var busy := false
	var raven: Target
	func is_busy() -> bool:
		return busy

var checks := 0
var failures := 0

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	var world := TestWorld.new()
	world.raven = Target.new()
	world.add_child(world.raven)
	root.add_child(world)
	for is_guardian in [false, true]:
		var threat = Threat.new()
		threat.guardian = is_guardian
		threat.world = world
		threat.position = Vector2(500, 350)
		world.raven.position = Vector2(510, 350)
		world.add_child(threat)
		threat.set_process(false)
		check(threat.visual.texture.resource_path.ends_with("ice-guardian.png" if is_guardian else "dive-virus.png"), "each digital enemy loads its own HQ art")
		var texture_size: Vector2 = threat.visual.texture.get_size()
		check(texture_size.x >= 1024 and texture_size.x == texture_size.y, "digital source is square and at least 1024 pixels wide")
		check(threat.visual.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "digital enemy source has transparency")
		check(threat.visual.show_behind_parent and threat.visual.z_index == 0, "attack telegraphs remain above the artwork without moving it below the world background")
		var before_position: Vector2 = threat.position
		var before_scale: Vector2 = threat.visual.scale
		world.busy = true
		threat._process(0.25)
		check(threat.elapsed == 0.0 and threat.position == before_position and threat.visual.scale == before_scale, "menus pause movement, attack timers and artwork pulse together")
		world.busy = false
		threat._process(0.1)
		check(threat.visual.scale != before_scale, "artwork pulse resumes with gameplay")
		var threshold := 1.35 if is_guardian else 1.18
		threat.elapsed = threshold - 0.001
		check(not threat.vulnerable(), "enemy stays protected before the existing recovery window")
		threat.elapsed = threshold
		check(threat.vulnerable(), "existing recovery window still opens at its original threshold")
		threat._update_visual()
		check(threat.visual.modulate != Color.WHITE, "vulnerability also changes the artwork tint")
		world.raven.damage = 0
		threat.position = Vector2(500, 350)
		world.raven.position = Vector2(500, 350)
		if is_guardian:
			threat.elapsed = 1.19
			threat._process(0.02)
			threat._process(0.02)
			check(world.raven.damage == 26, "guardian beam hits once when crossing the original fire time")
		else:
			threat.elapsed = 0.85
			threat.direction = Vector2.ZERO
			threat._process(0.01)
			threat._process(0.01)
			check(world.raven.damage == 22, "virus lunge hits once per attack")
		threat.free()
	world.free()
	print("NPC DIVE VISUAL TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
