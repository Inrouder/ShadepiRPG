extends SceneTree
## v0.67.0 · CodexAI. Scripted commands in the real game, native pixels only.
const Kombat=preload("res://scripts/arcade/neon_kombat.gd")
const OUT:="/tmp/shadepi-v067-gallery"
var g
var number:=0
func _initialize():Engine.max_fps=90;run.call_deferred()
func controls(x: int=0,y: int=0,button: String="") -> Dictionary:
	return {"held":{"left":x<0,"right":x>0,"up":y<0,"down":y>0},"pressed":{button:true} if button!="" else {}}
func fresh(a: int=1,b: int=0):
	g.start_match(a,b,true);g.phase="fight";g.banner=""
	g.fighters[0].x=240.0;g.fighters[1].x=410.0
func tick(c0: Dictionary,c1: Dictionary={}):
	if c1.is_empty():c1=controls()
	g.held.assign([c0.held,c1.held]);g.pressed.assign([c0.pressed,c1.pressed])
	g._update_fight(1.0/60);g.clock+=1.0/60
func draw():
	g.stage_node.queue_redraw();g.hud_node.queue_redraw()
	await process_frame;await RenderingServer.frame_post_draw
func snap(name: String):
	await draw();root.get_texture().get_image().save_png(OUT+"/"+name+".png")
func film(frames: int,c0: Dictionary={},c1: Dictionary={}):
	if c0.is_empty():c0=controls()
	for i in frames:
		tick(c0,c1)
		if i%4==0:
			await draw();root.get_texture().get_image().save_png(OUT+"/frames/%04d.png"%number);number+=1
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
	root.get_node("DisplaySettings").mode=0;root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(OUT+"/frames")
	for file in ([] if "--rest" in OS.get_cmdline_user_args() else DirAccess.get_files_at(OUT+"/frames")):
		if file.ends_with(".png"):DirAccess.remove_absolute(OUT+"/frames/"+file)
	g=Kombat.new();root.add_child(g);g.set_process(false)
	for i in 4:await process_frame
	if "--rest" in OS.get_cmdline_user_args():number=DirAccess.get_files_at(OUT+"/frames").size()
	else:
		g.screen=g.Screen.TITLE;await snap("title")
		fresh();await film(40)
		# Crouch, then an actual low hit against down-back.
		g.fighters[1].x=310;await film(24,controls(0,1),controls(1,1))
		tick(controls(0,1,"a"),controls(1,1));await film(9,controls(0,1),controls(1,1));await snap("low-guard");await film(45,controls(),controls(1,1))
		# Real cross-over, both fighters reorient automatically at the apex.
		fresh();g.fighters[1].x=290;tick(controls(1,-1))
		await film(24);await snap("cross-up");await film(48)
		# QCF: Raven's free signature projectile.
		fresh();tick(controls(0,1));tick(controls(1,1));tick(controls(1,0,"a"))
		await film(18);await snap("quarter-circle");await film(66)
		# DP: universal rising attack, button strength Medium.
		fresh();g.fighters[1].x=330;tick(controls(1));tick(controls(0,1));tick(controls(1,1,"b"))
		await film(10);await snap("dragon-punch");await film(58)
	# 45-frame back charge; down-back stays planted.
	fresh();await film(48,controls(-1,1));await snap("charge-ready")
	tick(controls(1,0,"c"));await film(20);await snap("charge-rush");await film(60)
	# Dedicated EX shortcut.
	fresh();g.fighters[0].meter=100;tick(controls(0,0,"d"));await film(18);await snap("special-ex");await film(66)
	g.free();await process_frame
	# Actual contextual mobile HUD over the same arcade layer.
	var mobile=root.get_node("MobileControls");mobile.enabled=true
	var w=load("res://scenes/chapter_one.tscn").instantiate();root.add_child(w);current_scene=w
	for i in 8:await process_frame
	w.open_arcade(true);g=w.arcade;g.set_process(false);fresh()
	for i in 6:await process_frame
	await snap("touch-lmhs")
	print("ARCADE GALLERY v0.67.0 CodexAI: ",number," native frames; mobile context=",mobile.input_context)
	w.free();current_scene=null;await process_frame;quit()
