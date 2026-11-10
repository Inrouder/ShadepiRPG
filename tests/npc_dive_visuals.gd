extends SceneTree
const Threat = preload("res://scripts/dive_threat.gd")
const Guardian = preload("res://scripts/ice_guardian.gd")
class Target:
	extends Node2D
	var damage := 0
	func take_damage(amount: int, _origin: Vector2): damage += amount
class TestWorld:
	extends Node2D
	var busy := false
	var raven: Target
	func is_busy() -> bool: return busy
var checks := 0
var failures := 0
func _initialize():run.call_deferred()
func check(ok: bool, message: String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+message)
func run():
	var world=TestWorld.new();world.raven=Target.new();world.add_child(world.raven);root.add_child(world)
	for is_guardian in [false,true]:
		var threat:Node2D=Guardian.new() if is_guardian else Threat.new()
		threat.world=world;threat.position=Vector2(500,350);world.raven.position=Vector2(510,350);world.add_child(threat);threat.set_process(false)
		check(threat.visual.texture.resource_path.ends_with("ice-guardian-combat.png" if is_guardian else "dive-virus.png"),"active digital enemies load their respective HQ source")
		var size:Vector2=threat.visual.texture.get_size()
		check(size.x>=1024 and (size.x==size.y*2 if is_guardian else size.x==size.y),"atlas and single-image source dimensions match runtime")
		check(threat.visual.texture.get_image().detect_alpha()!=Image.ALPHA_NONE,"true transparency")
		check(threat.visual.show_behind_parent,"warnings remain above enemy artwork")
		var before:Vector2=threat.visual.position;var elapsed:float=threat.visual_elapsed
		world.busy=true;threat._process(.25)
		check(threat.visual.position==before and threat.visual_elapsed==elapsed,"pause freezes animation with attack clock")
		world.busy=false;threat._process(.1)
		check(threat.visual_elapsed>elapsed,"animation resumes with gameplay")
		if is_guardian:
			check(not threat.vulnerable(),"new guardian starts with protected wind-up")
			threat.phase=threat.Phase.COOL;threat._update_visual()
			check(threat.vulnerable() and threat.atlas_frame==5,"new guardian exposes cyan core only during cooling")
			threat.cycle_damage=2;threat._update_visual()
			check(not threat.vulnerable() and threat.atlas_frame==4,"retreat closes core visibly")
		else:
			threat.elapsed=1.179;check(not threat.vulnerable(),"virus original window unchanged")
			threat.elapsed=1.18;check(threat.vulnerable(),"virus opens at existing timing")
			threat.elapsed=.85;threat.direction=Vector2.ZERO;threat._process(.01);threat._process(.01)
			check(world.raven.damage==22,"virus lunge still hits once")
		threat.free()
	world.free();print("NPC DIVE VISUAL TESTS: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
