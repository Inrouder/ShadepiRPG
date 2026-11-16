extends SceneTree
## v0.65.0 · CodexAI. Look-ahead, grounded garage, physical rollover and moonlit story continuity.
const View=preload("res://scripts/vehicle_view.gd")
const Car=preload("res://scripts/pursuit_car_art.gd")
const Outbound=preload("res://scripts/outbound_flight.gd")
var checks:=0
var failures:=0
func _initialize(): Engine.max_fps=180; run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok: failures+=1; push_error("FAIL: "+label)
func frames(n: int=3):
	for i in n: await process_frame
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	set_meta("shadepi_admin_testing",true)
	if DisplayServer.get_name()!="headless":
		root.get_node("DisplaySettings").mode=0; root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	var w=load("res://scenes/campaign.tscn").instantiate(); root.add_child(w); current_scene=w
	w.fresh_entry=false; w._enter(w.Beat.CHASE); w.cutscene.abort(); w.close_menu(); w.ui.clear_dialogue()
	var drive=w.drive; drive.set_process(false)
	var visible: Rect2=drive.transform.affine_inverse()*Rect2(0,0,640,360)
	check(visible.is_equal_approx(View.FRAME) and visible.size.y>360,"motorcycle sees a genuine larger field with an extra 90 world units ahead")
	drive.next_hazard=0; drive.next_drone=999; drive._process(0.01)
	check(not drive.hazards.is_empty() and drive.hazards[0].y<View.FRAME.position.y,"new obstacles enter from beyond the wider visible edge")
	drive.hazards.clear(); drive.hazards.append(Vector2(drive.x,-60)); var hp: int=drive.health
	drive.next_hazard=999; drive._process(0.01)
	check((drive.transform*drive.hazards[0]).y>0 and drive.health==hp,"an obstacle ahead of the old screen is visible without an early collision")
	if DisplayServer.get_name()!="headless":
		await frames(12); root.size=Vector2i(1280,720); await frames()
		await RenderingServer.frame_post_draw
		var before: Image=root.get_texture().get_image()
		w.actors.hide(); await frames(); await RenderingServer.frame_post_draw
		var after: Image=root.get_texture().get_image(); var changed:=0
		for y in range(210,620,4):
			for x in range(4,110,4):
				var a:=before.get_pixel(x,y); var b:=after.get_pixel(x,y)
				if absf(a.r-b.r)+absf(a.g-b.g)+absf(a.b-b.b)>0.08: changed+=1
		check(changed<5,"expanded scene fully covers its side strips; underlying heroes cannot bleed through")
		w.actors.show()
	var image: Image=Car.ROLL.get_image()
	check(image.get_size()==Vector2i(1536,1024),"six real side/undercarriage source cells are registered")
	for i in 6:
		var rect:=Rect2i(i%3*512,i/3*512,512,512)
		var edge:=true
		for x in range(rect.position.x,rect.end.x,8):
			edge=edge and image.get_pixel(x,rect.position.y).a<0.1 and image.get_pixel(x,rect.end.y-1).a<0.1
		check(edge,"roll cell %d has transparent gutters"%i)
	drive.stage=2; drive.armour=0; drive.objects.clear(); drive.drones.clear(); drive.hazards.clear(); drive._process(0.01)
	var completed:={"value":false}; drive.completed.connect(func(): completed.value=true)
	var saw_underside:=false; var saw_blast:=false; var exited_before_end:=false
	Input.action_press("move_right")
	for i in 65:
		drive._process(0.1)
		if drive.car_dead<drive.CAR_BLAST_AT and drive.car_roll_frame>=4: saw_underside=true
		if drive.car_dead>=drive.CAR_BLAST_AT and drive.white_flash>0: saw_blast=true
		if not completed.value and drive.bike_y<View.FRAME.position.y-60: exited_before_end=true
	check(saw_underside and saw_blast,"the car reaches its underside before exploding")
	Input.action_release("move_right")
	check(completed.value and exited_before_end and is_equal_approx(drive.x,320.0),"heroes ride completely out of frame before the garage transition")
	w.cutscene.abort()
	var texture_size:=Vector2(1586,991)
	var world_y: float=w.GARAGE_DOOR.end.y-12.0
	var samples: Array[float]=[]
	for amount in [0.25,0.55,1.0]:
		var source: Rect2=w.garage_street_source(amount,texture_size)
		var top: float=w.GARAGE_DOOR.end.y-w.GARAGE_DOOR.size.y*amount
		samples.append(source.position.y+(world_y-top)/(w.GARAGE_DOOR.size.y*amount)*source.size.y)
	check(is_equal_approx(samples[0],samples[1]) and is_equal_approx(samples[1],samples[2]),"asphalt sample at a fixed point stays fixed while the door lifts")
	w._enter(w.Beat.FLIGHT); w.cutscene.abort(); w.close_menu(); var flight=w.drive; flight.set_process(false)
	check((flight.transform.affine_inverse()*Rect2(0,0,640,360)).size.is_equal_approx(Vector2(800,450)),"flight shares the wider look-ahead field")
	check((flight.transform*flight.overlay.transform).is_equal_approx(Transform2D.IDENTITY),"scanner and flight instructions retain screen size")
	flight._start_landing()
	check(flight.transform.is_equal_approx(Transform2D.IDENTITY) and flight.overlay.transform.is_equal_approx(Transform2D.IDENTITY),"landing retains its registered original screen/camera handover")
	w._enter(w.Beat.ROOF); w.cutscene.abort(); w.close_menu(); w.ui.clear_dialogue()
	var scene:=Outbound.new(); scene.world=w; w.drive_layer.add_child(scene)
	var craft: Node=scene.vehicle
	var cs=w.begin_cutscene(); var ticket: int=cs.generation
	scene.play(cs,ticket)
	Engine.time_scale=6
	var saw_raven:=false; var saw_shadepi:=false; var paused_once:=false
	for i in 1800:
		await process_frame
		if cs.waiting_input:
			if cs.speaker_label.text=="RAVEN": saw_raven=true
			if cs.speaker_label.text=="SHADEPI": saw_shadepi=true
			if not paused_once:
				w.menu_open=true; var clock: float=scene.clock; await frames(5)
				check(scene.clock==clock,"desert flight and camp effects pause with the menu")
				w.menu_open=false; paused_once=true
			cs.advance()
		if scene.events.has("two_hours_later") and cs.title_label.modulate.a>0.65: break
	check(scene.events.has("city") and scene.events.has("nomads") and saw_raven and saw_shadepi,"city, nomads and both requested speakers appear in order")
	check(scene.events.has("two_hours_later") and cs.title_label.text=="ZWEI STUNDEN SPÄTER" and cs.title_label.modulate.a>0.65,"the time jump is visible before chapter seven")
	if DisplayServer.get_name()!="headless":
		w.menu_open=true; await frames(2); await RenderingServer.frame_post_draw
		var card: Image=root.get_texture().get_image(); var ink:=0
		for y in range(270,400,2):
			for x in range(180,1100,2):
				var pixel:=card.get_pixel(x,y)
				if pixel.r>0.4 and pixel.g>0.4 and pixel.b>0.4: ink+=1
		check(ink>100,"two-hours card is actually visible above the black fade in native pixels")
		card.save_png("/tmp/shadepi-v065-two-hours.png"); w.menu_open=false
	var last_camp: Vector2=scene.background_rect().position+scene.FIRES[2]/Vector2(scene.background.get_size())*scene.background_rect().size
	check(scene.crossing==1.0 and scene.craft.x>last_camp.x,"scripted flight passes the last nomad camp even with immediate dialogue confirmation")
	check(scene.vehicle==craft and scene.background!=null,"the same registered aircraft is retained through the outbound flight")
	w.fresh_entry=true; w._enter(w.Beat.LAKE); scene.free(); await frames()
	check(w.beat==w.Beat.LAKE and w.lake_sequence!=null and w.lake_scene_pending,"scene replacement aborts the old flight and preserves lake arrival")
	Engine.time_scale=1; w.free(); current_scene=null; await frames()
	print("CINEMA v0.65.0 CodexAI: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
