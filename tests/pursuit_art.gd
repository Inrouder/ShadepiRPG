extends SceneTree
## v0.41.0 · CodexAI. Source alpha, shot contact, independent rotors and game lifecycle.
const Car = preload("res://scripts/pursuit_car_art.gd")
const Drone = preload("res://scripts/cargo_drone_art.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool,message: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+message)
func axis(value: float):
	var e := InputEventJoypadMotion.new()
	e.device = 77
	e.axis = JOY_AXIS_LEFT_X
	e.axis_value = value
	Input.parse_input_event(e)
	await process_frame
	await process_frame
func run():
	set_meta("shadepi_admin_testing",true)
	var car := Car.ATLAS.get_image()
	var drone := Drone.ATLAS.get_image()
	check(car.get_size()==Vector2i(1254,1254) and drone.get_size()==Vector2i(1254,1254),"actual atlas sizes define 418/627 crops rather than requested nominal sizes")
	for i in 9:
		var origin := Vector2i(Car.region(i).position)
		check(car.get_pixelv(origin+Vector2i(5,5)).a<0.02 and car.get_pixelv(origin+Vector2i(410,410)).a<0.02,"complete car pose has genuinely transparent gutters")
		check(car.get_pixelv(origin+Vector2i(Car.MUZZLES[i])).a>0.8,"registered muzzle belongs to the actual opaque gun, pose "+str(i))
	for i in 4:
		var origin := Vector2i(Drone.region(i).position)
		check(drone.get_pixelv(origin+Vector2i(5,5)).a<0.02,"drone exterior remains transparent")
		for hub in Drone.HUBS:
			check(drone.get_pixelv(origin+Vector2i(hub)).a>0.85,"fixed rotor hub lies on the same opaque center in every frame")
		check(drone.get_pixelv(origin+Vector2i(Drone.RELEASE)).a>0.85,"cargo release contact belongs to the actual fuselage")
	var different := false
	for p in [Vector2i(134,93),Vector2i(170,134),Vector2i(500,93)]:
		var diff := drone.get_pixelv(p)-drone.get_pixelv(p+Vector2i(627,0))
		different = different or absf(diff.r)+absf(diff.g)+absf(diff.b)+absf(diff.a)>0.02
	check(different,"rotor source pixels actually change while hub registration remains fixed")
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	w._enter(w.Beat.CHASE)
	w.set_process(false)
	w.drive.set_process(false)
	w.admin_flags["god_mode"] = true
	var d = w.drive
	d.next_hazard = 999
	d.next_drone = 999
	d.armour = 40
	d._fire_pursuer()
	var muzzle: Vector2 = Car.muzzle(d.car_position(),d.car_frame())
	check(d.car_frame()==6 and d.rear_shots.size()==2 and d.rear_shots[0].distance_to(muzzle)<0.01 and d.rear_shots[1].distance_to(muzzle)<0.01,"damaged-car rounds both start on the visible recoiling barrel")
	d._advance_rear_shots(0.03,-999)
	check(d.rear_shots[1].x>d.rear_shots[0].x and d.rear_shots[1].y==d.rear_shots[0].y,"second round fans out after leaving the same muzzle")
	d._advance_rear_shots(1,999)
	check(d.rear_shots.is_empty() and d.rear_shot_vx.is_empty(),"shot removal keeps movement metadata aligned")
	w.menu_open = true
	var recoil: float = d.car_recoil
	var clock: float = d.fx_clock
	d._process(0.1)
	check(d.car_recoil==recoil and d.fx_clock==clock,"pause freezes recoil and the independent rotor clock")
	w.close_menu()
	d._process(0.14)
	check(d.car_frame()==7,"actual recoil timer returns through the recovery pose")
	d._process(0.2)
	check(d.car_recoil==0,"recovery finishes without a persistent gun pose")
	var devices: Array[int] = [77]
	w.gamepads.assign(devices,false)
	await axis(0.8)
	d.drones.append({"p":Vector2(d.x,92),"state":"hover","t":0.1,"drops":0,"spin":0.0})
	var event := InputEventJoypadButton.new()
	event.device = 77
	event.button_index = JOY_BUTTON_RIGHT_SHOULDER
	event.pressed = true
	d.set_process(true)
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	d.set_process(false)
	check(d.drones[0].state=="hacked","raw controller RB retains Raven's drone capture")
	event.pressed = false
	Input.parse_input_event(event)
	await axis(0)
	d.drones.clear()
	d.drones.append({"p":Vector2(320,92),"state":"hover","t":1.4,"drops":0,"spin":0.0})
	d._advance_bike_world(0.001)
	var release: Vector2 = Drone.release_point(d.drones[0].p,Vector2(50,50))
	check(d.objects.back().k=="mine" and d.objects.back().p.distance_to(release)<0.01,"mines leave the registered cargo port")
	check(w.save_game() and w.load_game() and w.drive.car_recoil==0 and w.drive.rear_shots.is_empty(),"loading a chase rebuilds clean transient poses and shot metadata")
	w._enter(w.Beat.FLIGHT)
	check(w.drive.DroneArt.ATLAS==Drone.ATLAS,"flight cargo obstacles share the same animated drone source")
	w._enter(w.Beat.GARAGE)
	check(w.drive==null and w.player.get_parent()==w.actors,"chapter transition removes vehicle state and preserves normal actors")
	w.queue_free()
	await process_frame
	print("PURSUIT ART: %s checks, %s failures"%[checks,failures])
	quit(1 if failures else 0)
