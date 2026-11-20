extends SceneTree
## v0.67.1 · CodexAI. Reproduce low-frame-rate attacks and session reset failures.
const Kombat=preload("res://scripts/arcade/neon_kombat.gd")
var g
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func controls(button: String=""):
	g.held.assign([{},{}]);g.pressed.assign([{button:true} if button!="" else {},{}])
func fresh(index: int=0):
	g.start_match(index,0 if index==1 else 1,true);g.phase="fight";g.banner=""
	g.fighters[0].x=280.0;g.fighters[1].x=330.0;controls()
func capture(name: String):
	if DisplayServer.get_name()=="headless" or not "--capture" in OS.get_cmdline_user_args():return
	g.stage_node.queue_redraw();g.hud_node.queue_redraw()
	await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v0671-"+name+".png")
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
	root.size=Vector2i(1280,720)
	g=Kombat.new();root.add_child(g);g.set_process(false)
	for i in 4:await process_frame
	for dt in [1.0/15,0.10,0.25]:
		fresh();var hp: float=g.fighters[1].hp;controls("a");g._update_fight(dt)
		if dt<g.MOVES.light.start:controls();g._update_fight(dt)
		check(g.fighters[1].hp==hp-float(g.fighters[0].data.light),"Light reaches its contact window at dt="+str(dt))
	fresh(1);g.fighters[1].x=530;g.fighters[0].meter=100;controls("d");g._update_fight(0.25)
	check(g.shots.size()==1,"Raven emits exactly one projectile across a 250 ms frame")
	check(g.fighters[0].meter==50,"substeps do not duplicate the EX button or its energy cost")
	await capture("slow-frame")
	fresh();g.cpu_plan={"dir":-1.0,"block":0.4,"jump":true}
	g.start_match(0,1,false);g.phase="fight"
	var cpu: Dictionary=g._cpu_controls(0)
	check(not cpu.held.left and not cpu.held.right and not cpu.held.down and not cpu.held.up,"new match clears movement/guard inherited from the old CPU plan")
	fresh();controls("a");g._update_fight(1.0/60);var time: float=g.timer
	g.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(g.session_paused,"losing application focus pauses the active fight")
	var x: float=g.fighters[0].x;g._process(0.2)
	check(g.timer==time and g.fighters[0].x==x,"backgrounding freezes the fight instead of allowing CPU attacks")
	await capture("focus-pause")
	g.resume_game();check(not g.session_paused,"explicit resume returns to the same fight")
	g.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(g.session_paused,"Android application suspension also pauses arcade")
	g.resume_game();fresh();var before: float=g.timer;g._update_fight(1.0)
	check(is_equal_approx(before-g.timer,0.25),"a long OS stall advances at most 250 ms instead of simulating an unseen second")
	g.free();await process_frame
	print("ARCADE REGRESSIONS v0.67.1 CodexAI: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
