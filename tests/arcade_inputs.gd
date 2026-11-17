extends SceneTree
## v0.67.0 · CodexAI. Commands, charge timings, 8-way movement and cross-ups.
const Parser=preload("res://scripts/arcade/fighter_input.gd")
const Kombat=preload("res://scripts/arcade/neon_kombat.gd")
class PadArcade extends "res://scripts/arcade/neon_kombat.gd":
	func _pad_for(index: int) -> int:return 77+index

var checks:=0
var failures:=0
var g
func _initialize():Engine.max_fps=180;run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+label)
func direction(p,code: int,face: int=1,dt: float=1.0/60):
	var x:=posmod(code-1,3)-1
	var y:=1 if code<4 else -1 if code>6 else 0
	p.sample(x,y,face,dt)
func sequence(p,pattern: Array,face: int=1):
	for code in pattern:direction(p,code,face)
func controls(x: int=0,y: int=0,button: String="") -> Dictionary:
	return {"held":{"left":x<0,"right":x>0,"up":y<0,"down":y>0},"pressed":{button:true} if button!="" else {}}
func fresh(index: int=0):
	g.hitstop=0;g.start_match(index,(index+1)%10,true);g.phase="fight";g.banner=""
	g.fighters[0].x=240.0;g.fighters[1].x=480.0
func tick(c0: Dictionary,c1: Dictionary={},dt: float=1.0/60):
	if c1.is_empty():c1=controls()
	g.held.assign([c0.held,c1.held]);g.pressed.assign([c0.pressed,c1.pressed])
	g._update_fight(dt)
func pad_button(index: int,button: JoyButton,down: bool):
	var e:=InputEventJoypadButton.new();e.device=77+index;e.button_index=button;e.pressed=down
	Input.parse_input_event(e);await process_frame;g._poll()
func pad_axis(index: int,axis: JoyAxis,value: float):
	var e:=InputEventJoypadMotion.new();e.device=77+index;e.axis=axis;e.axis_value=value
	Input.parse_input_event(e);await process_frame;g._poll()
func read_pad(index: int):
	g._control(index,{"held":g.held[index],"pressed":g.pressed[index]})
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):quit(1);return
	var p=Parser.new()
	for item in [[[2,3,6],1,"quarter"],[[2,6],1,"quarter"],[[2,5,3,5,6],1,"quarter"],[[6,2,3],1,"dragon"],[[6,2,6],1,"dragon"],[[6,2,3,6],1,"dragon"],[[2,1,4],-1,"quarter"],[[4,2,1],-1,"dragon"]]:
		p.reset();sequence(p,item[0],item[1]);check(p.take_motion()==item[2],"motion "+str(item[0])+" facing "+str(item[1]))
	p.reset();sequence(p,[2,3,6]);check(p.take_motion()=="quarter","first command accepted")
	sequence(p,[5,6]);check(p.take_motion()=="","neutral/repress cannot reuse consumed motion history")
	p.reset();sequence(p,[2,8,6]);check(p.take_motion()=="","an intervening up direction is not a quarter circle")
	p.reset();direction(p,2)
	for i in 30:direction(p,5)
	direction(p,6);check(p.take_motion()=="","old commands expire")
	for held_frames in [44,45,50]:
		p.reset()
		for i in held_frames:direction(p,4)
		direction(p,6)
		check(p.take_motion()==("charge_forward" if held_frames>=45 else ""),"horizontal charge threshold %d frames"%held_frames)
	p.reset()
	for i in 45:direction(p,6,-1)
	direction(p,4,-1);check(p.take_motion()=="charge_forward","back charge and forward release mirror when facing left")
	p.reset()
	for i in 45:direction(p,1,-1)
	# Down-left is forward while facing left; it charges down but never back.
	direction(p,8,-1);check(p.take_motion()=="charge_up","down charge releases upward")
	p.reset()
	for i in 46:direction(p,4)
	p.set_facing(-1);direction(p,4,-1)
	check(p.take_motion()=="","a cross-up cannot convert an old back charge into a free forward release")
	p.reset()
	for i in 45:direction(p,4)
	for i in 14:direction(p,5)
	direction(p,6);check(p.take_motion()=="","charge release times out")
	for i in 300:direction(p,2 if i%2 else 6)
	check(p.count==p.CAPACITY and p.ring.size()==p.CAPACITY,"direction ring has a hard memory limit")
	p.reset();check(p.count==0 and p.charge_fraction()==0,"reset discards history and charge")
	g=PadArcade.new();root.add_child(g);g.set_process(false)
	for i in 4:await process_frame
	fresh();var f: Dictionary=g.fighters[0]
	tick(controls(1,-1));var vx: float=f.air_vx
	for i in 12:tick(controls(-1,0))
	check(f.y<0 and f.vx==vx and f.x>240,"forward jump keeps its launch direction despite opposite air input")
	var target: float=240+vx*(-2*g.JUMP/g.GRAVITY)
	for i in 100:
		if f.y>=0:break
		tick(controls())
	check(absf(f.x-target)<0.2 and f.y==0,"fixed forward jump returns to its analytic arc endpoint")
	for dir in [-1,0,1]:
		fresh();f=g.fighters[0];tick(controls(dir,-1));check(f.vy<0 and signf(f.air_vx)==dir,"eight-way up gives fixed back/neutral/forward jump %d"%dir)
	for rate in [30,60,144]:
		fresh();f=g.fighters[0];tick(controls(1,-1),{},1.0/rate)
		for i in rate:
			if f.y>=0:break
			tick(controls(),{},1.0/rate)
		check(absf(f.x-(240+150*1.05*(-2*g.JUMP/g.GRAVITY)))<0.2,"fixed arc endpoint at %d fps"%rate)
	fresh();f=g.fighters[0];f.x=260;g.fighters[1].x=300;tick(controls(1,-1))
	for i in 30:tick(controls())
	check(f.x>g.fighters[1].x and f.face==-1 and g.fighters[1].face==1,"a real jumping cross-up passes the pushbox and turns both fighters in the air")
	fresh();tick(controls(0,1));f=g.fighters[0]
	check(f.state=="crouch" and not f.blocking and g.pose_index(f)==15,"down crouches with a real drawn low pose and does not block by itself")
	fresh();tick(controls(-1,1));f=g.fighters[0]
	check(f.crouching and f.blocking and f.vx==0,"down-back holds a stationary low guard")
	fresh();tick(controls(-1,0));f=g.fighters[0]
	check(f.blocking and f.x<240 and f.state=="walk","back retreats while preparing a standing guard")
	for button in ["a","b","c"]:
		fresh();tick(controls(0,0,button));check(g.fighters[0].state=={"a":"light","b":"medium","c":"heavy"}[button],"four-button normal "+button)
	fresh(1);tick(controls(0,1));tick(controls(1,1));tick(controls(1,0,"a"));f=g.fighters[0]
	check(f.state=="shot" and f.meter==0 and f.command.begins_with("236"),"meter-free QCF invokes Raven's signature")
	fresh();tick(controls(1,0));tick(controls(0,1));tick(controls(1,1,"b"));f=g.fighters[0]
	check(f.state=="rise" and f.vy<0 and f.command.begins_with("623"),"DP has priority and starts its rising attack")
	fresh()
	for i in 45:tick(controls(-1,1))
	tick(controls(1,0,"c"));check(g.fighters[0].state=="rush","charged back release starts the rush")
	fresh()
	for i in 45:tick(controls(0,1))
	tick(controls(0,-1,"a"));check(g.fighters[0].state=="rise" and g.fighters[0].vy<0,"vertical charge starts a rising move before normal jump")
	fresh();tick({"held":{"up":true,"down":true},"pressed":{"up":true}})
	check(g.fighters[0].y==0,"opposite vertical directions neutralize instead of causing a jump")
	fresh(1);f=g.fighters[0];f.meter=100;tick(controls(0,0,"d"))
	check(f.state=="shot" and f.meter==50 and f.strength>1,"S is a stronger energy-cost EX shortcut")
	# Proper high/low guard mix-ups, using actual contact resolution.
	for spec in [["mid",false,true],["mid",true,true],["low",false,false],["low",true,true],["overhead",false,true],["overhead",true,false]]:
		fresh();f=g.fighters[0];var other: Dictionary=g.fighters[1]
		f.x=280;other.x=330
		g._control(1,controls(1,1 if spec[1] else 0))
		g._begin(f,"light",1,false);f.attack_height=spec[0]
		var hp: float=other.hp;g._land(0,10,false)
		check(is_equal_approx(hp-other.hp,2.0 if spec[2] else 10.0),"guard "+str(spec))
	fresh();f=g.fighters[0];var other: Dictionary=g.fighters[1]
	f.x=340;f.y=-60;other.x=320;f.face=1;other.face=-1;other.guard_x=1
	g._sync_facing()
	check(f.face==-1 and other.face==1 and not other.blocking,"cross-up immediately flips both sprites and invalidates holding old back")
	g.inputs[0].reset();sequence(g.inputs[0],[2,1,4],-1)
	check(g.inputs[0].take_motion()=="quarter","mirrored quarter circle works after crossing sides")
	fresh(1);g.hitstop=0.1
	tick(controls(0,1));tick(controls(1,1));tick(controls(1,0,"a"))
	check(g.fighters[0].state=="idle" and g.fighters[0].buffer=="shot","motion is buffered during hitstop without advancing the action")
	g.hitstop=0;tick(controls());check(g.fighters[0].state=="shot","buffered motion starts after hitstop")
	fresh()
	for i in 45:tick(controls(-1,1))
	g.pause_game();g.resume_game()
	check(g.inputs[0].charge_fraction()==0 and g.inputs[0].count==0,"pause clears motion/charge history")
	# Actual Godot joypad events: both players, all face buttons and mirrored stick motion.
	for index in 2:
		for spec in [[JOY_BUTTON_X,"light"],[JOY_BUTTON_Y,"medium"],[JOY_BUTTON_B,"heavy"],[JOY_BUTTON_A,"shot"]]:
			g.start_match(1,1,true);g.phase="fight";g.hitstop=0
			g.fighters[index].meter=100
			g._poll() # discard scripted held state before receiving a real button edge
			await pad_button(index,spec[0],true);read_pad(index)
			check(g.fighters[index].state==spec[1],"real joypad player %d button %d"%[index+1,spec[0]])
			check(g.fighters[1-index].state=="idle","other player stays idle")
			await pad_button(index,spec[0],false)
		g.start_match(1,1,true);g.phase="fight"
		await pad_axis(index,JOY_AXIS_LEFT_Y,1.0);read_pad(index)
		await pad_axis(index,JOY_AXIS_LEFT_X,1.0 if index==0 else -1.0);read_pad(index)
		await pad_axis(index,JOY_AXIS_LEFT_Y,0.0);read_pad(index)
		await pad_button(index,JOY_BUTTON_X,true);read_pad(index)
		check(g.fighters[index].state=="shot" and g.fighters[index].command.begins_with("236"),"real analog QCF mirrored for player %d"%(index+1))
		await pad_button(index,JOY_BUTTON_X,false);await pad_axis(index,JOY_AXIS_LEFT_X,0.0)
	g.free();await process_frame
	print("ARCADE INPUTS v0.67.0 CodexAI: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)
