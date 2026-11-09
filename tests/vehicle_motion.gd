extends SceneTree
## v0.40.0 · CodexAI. Contacts, controller response, pause and legacy cabin lifecycle.
const Air = preload("res://scripts/aerodyne_art.gd")
const Bike = preload("res://scripts/motorcycle_art.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool, message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func axis(value: float, which: JoyAxis = JOY_AXIS_LEFT_X):
	var event := InputEventJoypadMotion.new()
	event.device = 77
	event.axis = which
	event.axis_value = value
	Input.parse_input_event(event)
	await process_frame
	await process_frame
func step(d,seconds: float):
	for i in int(seconds*120): d._process(1.0/120.0)
func run():
	set_meta("shadepi_admin_testing",true)
	var air := Air.BANKS.get_image()
	var bike := Bike.ATLAS.get_image()
	check(air.get_size()==Vector2i(1536,1024) and bike.get_size()==Vector2i(1254,1254),"actual source dimensions, rather than requested nominal grid, define the crops")
	for frame in 6:
		var origin := Vector2i(Air.region(frame).position)
		check(air.get_pixelv(origin+Vector2i(5,5)).a<0.02 and air.get_pixelv(origin+Vector2i(505,505)).a<0.02,"bank source gutters contain genuine transparent pixels")
		for contact in Air.BANK_NOZZLES[frame]:
			check(air.get_pixelv(origin+Vector2i(contact)).a>0.85,"bank exhaust anchor lies on the opaque engine, frame "+str(frame))
	for frame in 8:
		var origin := Vector2i(Bike.region(frame).position)
		check(bike.get_pixelv(origin+Vector2i(Bike.REAR[frame])).a>0.85 and (Bike.REAR[frame]-Bike.anchor(frame)).is_equal_approx(Vector2(0,165)),"all used bike poses keep their actual rear-wheel contact fixed")
	for bank in [-1.0,-0.45,0.0,0.45,1.0]:
		var total := 0.0
		for layer in Air.layers(bank): total += layer[1]
		check(is_equal_approx(total,1.0) and Air.nozzles(bank).size()==2,"hull and engine anchors share a complete opaque pose")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.CHASE)
	w.set_process(false)
	w.drive.set_process(false)
	var devices: Array[int] = [77]
	w.gamepads.assign(devices,false)
	await axis(-0.9)
	step(w.drive,0.3)
	check(w.drive.velocity_x< -100 and Bike.layers(w.drive.velocity_x/250.0,false,0).back()[0]==0,"raw controller stick drives actual left bank")
	await axis(0.9)
	step(w.drive,0.6)
	check(w.drive.velocity_x>100 and Bike.layers(w.drive.velocity_x/250.0,false,0).back()[0]==4,"raw controller reverses to the corresponding right view")
	await axis(0)
	step(w.drive,0.8)
	await axis(1,JOY_AXIS_LEFT_Y)
	step(w.drive,0.2)
	check(w.drive.throttle< -0.5 and Bike.layers(0,true,0)[0][0]==5,"controller braking reaches the physical brace/fork-compression pose")
	await axis(0,JOY_AXIS_LEFT_Y)
	w.menu_open = true
	var clock: float = w.drive.fx_clock
	step(w.drive,0.3)
	check(w.drive.fx_clock==clock,"pause freezes motorcycle suspension and bank animation clock")
	w.close_menu()
	w._enter(w.Beat.FLIGHT)
	w.set_process(false)
	var d = w.drive
	d.set_process(false)
	d.engine_repaired = true
	w.gamepads.assign(devices,false)
	await axis(-0.8)
	step(d,0.3)
	check(d.visual_bank()< -0.4,"flight view follows real controller movement rather than a separate cinematic track")
	await axis(0)
	d.roll_dir = 1
	d.roll = d.ROLL_TIME*0.5
	check(d.visual_bank()>0.99,"dodge peak selects the hard bank view")
	w.menu_open = true
	clock = d.clock
	var bank: float = d.visual_bank()
	step(d,0.3)
	check(d.clock==clock and d.visual_bank()==bank,"pause freezes the flight pose and source-registered exhaust")
	w.close_menu()
	check(w.save_game() and w.load_game() and w.drive.visual_bank()==0,"loading reconstructs a clean flight pose without stale lean")
	w._enter(w.Beat.HANGAR)
	var rig = w.hangar_world.vehicle
	rig.set_pose(rig.position,0.9,0,0.7,1.0,1)
	check(rig.bank_hulls[0].visible and rig.hull.modulate.a==0,"cinematic renderer displays the actual bank source")
	var expected: Array[Vector2] = Air.nozzles(1)
	check((rig.plumes[0].position+Vector2(17,3)).distance_to(expected[0])<0.01,"cinematic exhaust follows the same banked engine registration")
	rig.set_door(1)
	check(rig.hull.frame==3 and rig.hull.modulate.a==1 and not rig.bank_hulls[0].visible,"opening the cabin restores mechanical poses without a second body")
	check((rig.plumes[0].position+Vector2(17,3)).distance_to(Air.NOZZLES[0])<0.01,"opening the cabin immediately restores the level engine anchors")
	w._enter(w.Beat.ROOF)
	check(w.hangar_world==null and w.player.get_parent()==w.actors,"chapter change frees the temporary bank rig without affecting actors")
	w.queue_free()
	await process_frame
	print("VEHICLE MOTION: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
