extends SceneTree
## v0.50.0 · CodexAI. Real arena / salvo / dodge / core / retry contract.
const Orb = preload("res://scripts/ice_orb.gd")
var checks := 0
var failures := 0
var w
func _initialize(): run.call_deferred()
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)
func freeze(node: Node):
	node.set_process(false); node.set_physics_process(false)
	for child in node.get_children(): freeze(child)
func tick(boss, seconds: float):
	for i in ceili(seconds * 60): boss._process(1.0 / 60.0)
func orb(origin: Vector2, direction: Vector2):
	var b = Orb.new(); b.world=w; b.owner_boss=w.ice_guardian(); b.position=origin; b.direction=direction
	w.actors.add_child(b);b.owner_boss.bolts.append(b);b.set_physics_process(false)
	return b
func pad(button: JoyButton, pressed: bool):
	var event=InputEventJoypadButton.new();event.device=0;event.button_index=button;event.pressed=pressed
	Input.parse_input_event(event);Input.flush_buffered_events()
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Use isolated /tmp/shadepi- XDG_DATA_HOME");quit(1);return
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w.cutscene.abort();w._enter(w.Section.DIVE,2);w.ui.clear_dialogue();w.started=true;w.close_menu();freeze(w)
	await physics_frame;await process_frame
	var boss=w.ice_guardian()
	check(boss!=null and w.threats.size()==1,"boss has its own encounter, no surprise virus at the core")
	check(w.ice_map_size()==Vector2(1536,960),"larger arena is world geometry, not only a camera zoom")
	check(w.camera.limit_right==1536 and w.camera.limit_bottom==960,"camera reaches expanded arena")
	check(w.raven.position==w.ICE_START and not w.dive_blocked(w.raven.position,12),"saved relay 3 starts safely in front of guardian")
	check(w._target()==w.RELAYS[2]*1.5,"final relay aligns with resized source platform")
	check(w.MusicLibrary.path_for(w.music_section).ends_with("Boss.mp3"),"guardian uses boss music")
	check(boss.visual.texture.resource_path.ends_with("ice-guardian-combat.png") and boss.visual.hframes==4 and boss.visual.vframes==2,"eight actual guardian animation frames loaded")
	var poses=[]
	for frame in 8:
		var im=boss.visual.texture.get_image()
		var region=Rect2i(roundi((frame%4)*im.get_width()/4.0),roundi((frame/4)*im.get_height()/2.0),int(im.get_width()/4.0),int(im.get_height()/2.0))
		poses.append(hash(im.get_region(region).get_data()))
	check(poses.size()==8 and poses[1]!=poses[2] and poses[3]!=poses[4] and poses[5]!=poses[6],"wind-up fire recoil cooling impact are distinct source pixels")
	w.raven.position=boss.position-Vector2(50,0);w.raven.facing=Vector2.RIGHT
	w.raven_shot();check(boss.health==8 and not boss.vulnerable(),"normal attack cannot crack closed boss shell")
	w.special_hit(boss,62,w.raven,false);check(boss.health==8,"power shot cannot bypass salvo")
	check(not w.raven_hack(),"hack cannot skip protected phase")
	var before=boss.phase_time;w.menu_open=true;boss._process(3)
	check(boss.phase_time==before and boss.bolts.is_empty(),"pause freezes animation and salvo timers")
	w.menu_open=false
	tick(boss,1.3);check(boss.bolts.is_empty() and boss.phase==boss.Phase.AIM,"full visible warning precedes any projectile")
	tick(boss,0.1);check(boss.phase==boss.Phase.FIRE and boss.bolts.size()==3,"first fan has three moving balls")
	var locked=boss.aim;w.raven.position+=Vector2(0,120)
	tick(boss,2.3);check(boss.aim==locked,"salvo stays locked rather than tracking evasive player")
	check(boss.bolts.size()==15 and boss.phase==boss.Phase.COOL,"five volleys end in explicit cooling window")
	boss.clear_bolts();check(boss.bolts.is_empty(),"projectiles have bounded tracked lifecycle")
	# Cover resolves before a player behind it, even in a single large frame.
	var cover:Rect2=w.ice_cover()[1]
	w.raven.position=Vector2(cover.position.x-35,cover.get_center().y)
	var b=orb(Vector2(cover.end.x+80,w.raven.position.y),Vector2.LEFT)
	var health=w.raven.health;b.advance(2)
	check(b.spent and w.raven.health==health,"solid data wall intercepts swept balls before player behind it")
	w.raven.position=Vector2(cover.position.x-8,cover.get_center().y)
	b=orb(Vector2(cover.end.x+80,w.raven.position.y),Vector2.LEFT);b.advance(2)
	check(w.raven.health==health,"cover also protects a player pressed close to its back edge")
	w.raven.position=Vector2(1100,500);w.raven.invulnerable=0
	b=orb(Vector2(1250,500),Vector2.LEFT);b.advance(1)
	check(w.raven.health==health-20 and b.spent,"exposed player is hit once despite a long frame")
	health=w.raven.health;w.raven.reset_transients()
	check(w.raven.try_dash(Vector2.UP),"Raven can dodge in the ICE arena")
	b=orb(w.raven.position+Vector2(50,0),Vector2.LEFT);b.advance(0.4)
	check(w.raven.health==health,"dash invulnerability avoids crossing orb")
	# Same real input actions in this Raven-led solo chapter: B dodge, X attack.
	var devices:Array[int]=[0]
	w.gamepads.assign(devices,false);w.raven.reset_transients();w.raven.energy=100
	pad(JOY_BUTTON_B,true);w.raven._physics_process(1.0/60.0)
	check(w.raven.dash_time>0 and w.raven.invulnerable>0,"controller B triggers Raven's actual dodge, not scene skip")
	pad(JOY_BUTTON_B,false);await process_frame
	w.raven.reset_transients();boss.phase=boss.Phase.COOL;boss.cycle_damage=0;boss.hit_cooldown=0
	w.raven.position=boss.position-Vector2(55,0);w.raven.facing=Vector2.RIGHT
	var before_pad=boss.health
	pad(JOY_BUTTON_X,true);w.raven._physics_process(1.0/60.0)
	check(w.raven.attack_time>0 and boss.health==before_pad-1,"controller X fires close hand strike into open core")
	pad(JOY_BUTTON_X,false);await process_frame
	boss.health=8;boss.hit_cooldown=0
	# Normal aim uses the original hand attack. Open core requires close approach.
	w.raven.reset_transients();boss.phase=boss.Phase.COOL;boss.phase_time=0;boss.cycle_damage=0
	w.raven.position=boss.position-Vector2(120,0);w.raven.facing=Vector2.RIGHT
	w.raven_shot();check(boss.health==8,"distant shots cannot farm open core from cover")
	w.raven.position=boss.position-Vector2(55,0)
	w.raven_shot();check(boss.health==7,"close hand strike hits exposed core")
	w.raven_shot();check(boss.health==7,"hit cooldown prevents double-counted contacts")
	boss.hit_cooldown=0;w.raven_shot();check(boss.health==6 and not boss.vulnerable(),"two strikes close the core and demand retreat")
	boss.hit_cooldown=0;w.raven_shot();check(boss.health==6,"mashing attack cannot bypass next salvo")
	tick(boss,2.1);check(boss.phase==boss.Phase.AIM and not boss.vulnerable(),"retreat is followed by another visible warning")
	# Q/RB only lengthens a real opening once per round.
	boss.phase=boss.Phase.COOL;boss.phase_time=3;boss.cycle_damage=0
	w.hack_cooldown=0;check(w.raven_hack() and boss.phase_time<3,"optional near-core hack extends cooling")
	var extended=boss.phase_time;w.hack_cooldown=0;w.raven_hack();check(boss.phase_time==extended,"extension is bounded to one per cycle")
	# Correct melee-strength charged hit and eventual defeat, bullets cleaned up.
	boss.hit_cooldown=0;w.special_hit(boss,62,w.raven,false);check(boss.health==4,"charged close hit consumes a full opening")
	for cycle in 2:
		boss.phase=boss.Phase.COOL;boss.cycle_damage=0;boss.hit_cooldown=0
		w.special_hit(boss,62,w.raven,false)
	check(boss.health==0 and boss.phase==boss.Phase.DEFEATED and boss.bolts.is_empty(),"zero health plays defeat and stops attacks")
	boss._process(0.9);check(w.threats.is_empty(),"defeat releases final download only after animation")
	w.raven.position=w._target();w.ice_cycle=0;w.interact()
	check(w.dive_hold>0,"existing final download follows victory")
	w._enter(w.Section.DIVE,2);freeze(w);boss=w.ice_guardian()
	check(boss.health==8 and w.raven.position==w.ICE_START,"retry restores full encounter and safe spawn")
	w.autosave();check(w.load_game() and w.relay_index==2 and w.ice_guardian().health==8,"old relay checkpoint shape remains loadable")
	freeze(w);await physics_frame;await process_frame
	boss=w.ice_guardian();b=orb(Vector2(1200,460),Vector2.LEFT)
	w._enter(w.Section.RECOVERY);freeze(w);await process_frame
	check(not is_instance_valid(b) and w.ice_guardian()==null,"leaving arena removes sibling projectiles")
	check(w.camera.limit_right==1024 and w.camera.limit_bottom==640 and w.camera.zoom==Vector2.ONE,"real room bounds restored after dive")
	check(w.raven.visual.texture.resource_path.ends_with("raven.png"),"normal original Raven preserved")
	w.free();await process_frame
	print("ICE BOSS: %d checks, %d failures" % [checks,failures]);quit(1 if failures else 0)
