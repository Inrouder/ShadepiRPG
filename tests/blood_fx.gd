extends SceneTree
## v0.46.0 · CodexAI: actual damage eligibility, grounded decals and bounded paused FX.
var checks := 0
var failures := 0
func _initialize() -> void:run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error("FAIL: "+label)
func run() -> void:
	set_meta("shadepi_admin_testing",true)
	var w=load("res://scenes/main.tscn").instantiate()
	root.add_child(w)
	w.close_menu()
	w.process_mode=Node.PROCESS_MODE_DISABLED
	w.stage=2
	var blood=w.blood_effects
	var foe=w.enemy
	foe.position=Vector2(620,420)
	foe.reset_fight(100)
	foe.armoured=true
	foe.take_damage(12,foe.position+Vector2.LEFT*50)
	check(blood.sprays.is_empty() and blood.drops.is_empty() and blood.stains.is_empty(),"blocked armour produces no blood")
	foe.armoured=false
	foe.min_health=100
	foe.take_damage(12)
	check(blood.sprays.is_empty(),"zero effective damage produces no blood")
	foe.min_health=0
	foe.take_damage(12,foe.position+Vector2.LEFT*50)
	check(blood.sprays.size()==1 and blood.sprays[0].d==Vector2.RIGHT,"actual hit sends blood away from the attacker")
	check(blood.sprays[0].p==foe.position+Vector2(0,-28),"impact originates at the body instead of its feet")
	check(blood.drops.size()>0 and blood.stains.is_empty(),"drops begin airborne and leave no premature death pool")
	blood._process(0.10)
	var state=blood.drops.duplicate(true)
	w.menu_open=true;blood._process(2.0)
	check(blood.drops==state,"menu pause freezes blood motion and lifetime")
	w.menu_open=false
	w.terminal=CanvasLayer.new();blood._process(2.0)
	check(blood.drops==state,"terminal freezes blood motion and lifetime")
	w.terminal.free();w.terminal=null
	for i in 60:blood._process(1.0/60.0)
	check(blood.drops.is_empty() and not blood.stains.is_empty(),"falling droplets land as floor spatter")
	check(blood.floor_layer.z_index<0 and blood.floor_layer.z_index>w.get_node("PaintedAlley").z_index and blood.air_layer.z_index>0,"puddles are above ground, below actors; sprays are separate")
	check(blood.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST,"new artwork retains pixel sampling")
	blood.clear()
	foe.take_damage(200,foe.position+Vector2.RIGHT*60)
	check(blood.stains.size()==1 and blood.stains[0].variant==2,"lethal damage creates a spreading pool")
	check(blood.sprays[0].d==Vector2.LEFT,"opposite attack reverses the spray")
	var count: int=blood.sprays.size()
	foe.take_damage(200)
	check(blood.sprays.size()==count,"dead enemies never emit repeated blood")
	foe.position+=Vector2(7,0)
	blood._process(0.2)
	check(blood.stains[0].p==foe.global_position.round(),"fresh death pool follows the actual corpse slide")
	blood._process(0.3)
	var point: Vector2=blood.stains[0].p
	foe.position+=Vector2(50,0);blood._process(0.1)
	check(blood.stains[0].p==point and blood.stains[0].follow==null,"settled pool stays anchored to the floor")
	blood.clear()
	for quality in [2,0]:
		w.visual_quality=quality
		blood.clear()
		for i in 160:blood.hit(foe,Vector2.RIGHT,35,true)
		check(blood.sprays.size()<=(6 if quality==0 else blood.MAX_SPRAYS),"spray budget respects quality")
		check(blood.drops.size()<=(24 if quality==0 else blood.MAX_DROPS),"drop budget respects quality")
		check(blood.stains.size()<=(16 if quality==0 else blood.MAX_STAINS),"floor budget remains bounded")
		blood._process(92.0)
		check(blood.stains.is_empty() and blood.drops.is_empty() and blood.sprays.is_empty(),"expired effects release all records")
	w.visual_quality=2
	for i in 80:blood.hit(foe,Vector2.RIGHT,40,true)
	w.visual_quality=0;blood._process(0)
	check(blood.sprays.size()<=6 and blood.drops.size()<=24 and blood.stains.size()<=16,"switching quality trims existing effects immediately")
	blood.hit(foe,Vector2.RIGHT,20,true)
	w.set_dressing("demo")
	check(blood.stains.is_empty() and blood.sprays.is_empty() and blood.drops.is_empty(),"checkpoint or scene dressing clears all blood")
	blood.hit(foe,Vector2.RIGHT,20,true)
	w.restore_dressing_state({})
	check(blood.stains.is_empty() and blood.drops.is_empty(),"loading saved dressing clears unsaved decals")
	blood.hit(foe,Vector2.RIGHT,20,true)
	w.player_defeated()
	check(blood.sprays.is_empty() and blood.stains.is_empty(),"demo defeat resets old-fight blood before checkpoint resume")
	w.close_menu()
	var digital=Node2D.new();w.add_child(digital)
	w.register_hit(digital,10,Vector2.RIGHT,false)
	check(blood.sprays.is_empty(),"digital and non-Enemy targets retain technical feedback")
	check(blood.ART.get_width()==1774 and blood.ART.get_height()==887,"exportable atlas uses actual source dimensions")
	w.queue_free()
	await process_frame
	print("BLOOD FX: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
