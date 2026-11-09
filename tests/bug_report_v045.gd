extends SceneTree
## v0.45.0 · CodexAI. Actual frame registration and reported sequence regressions.
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok: bool,msg: String):
	checks+=1
	if not ok:
		failures+=1
		push_error("FAIL: "+msg)
func bbox(t: Texture2D) -> Rect2i:
	var image: Image=t.get_image()
	var lo:=Vector2i(image.get_width(),image.get_height());var hi:=Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a>0.4:
				lo=lo.min(Vector2i(x,y));hi=hi.max(Vector2i(x+1,y+1))
	return Rect2i(lo,hi-lo)
func finish(w):
	for i in 2000:
		await process_frame
		if w.cutscene.waiting_input:w.cutscene.advance()
		if not w.cutscene.running:return
	check(false,"scene completes")
func run():
	set_meta("shadepi_admin_testing",true)
	Engine.max_fps=240
	var w=load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	w._enter_checkpoint(w.Phase.HUNT)
	w.cutscene.abort()
	w.set_process(false)
	for actor in [w.player,w.raven]:
		actor.set_physics_process(false)
		check(actor.visual.texture.resource_path in ["res://assets/sprites/heroes/raven.png","res://assets/sprites/heroes/shadepi.png"],"gameplay hero uses the user-requested original source")
		for direction in [Vector2.DOWN,Vector2.UP,Vector2.RIGHT,Vector2.LEFT,Vector2(-1,-1),Vector2(1,-1),Vector2(-1,1),Vector2(1,1)]:
			actor.facing=direction
			actor.animate("idle",0)
			actor.reset_visual_pose()
			for i in 8:
				actor.animate("walk",1.0/9.0)
				check(actor.visual.scale==Vector2.ONE*0.5,"original scale remains stable through every walk direction and phase")
				check(absf(actor.visual.position.y+(152.0-80.0)*actor.visual.scale.y)<0.05,"original foot baseline stays anchored")
				check(actor.cast_shadow.frame==actor.visual.frame and actor.visual.hframes==8 and actor.visual.vframes==32,"original eight-phase atlas and shadow stay synchronized")
	for kind in ["raven","shadepi"]:
		check(FileAccess.get_sha256("res://assets/sprites/heroes/"+kind+".png")==FileAccess.get_sha256("res://assets/sprites/heroes/backup-v0441/"+kind+".png"),"old original has an exact backup for "+kind)
	w._enter_checkpoint(w.Phase.RESCUE)
	w.cutscene.abort()
	check(w.raven.external_pose and w.raven.reaction.frame==2 and not w.raven.visual.visible,"Raven is genuinely lying down in the rescue checkpoint")
	w._raven_rejoins()
	check(not w.raven.external_pose and w.raven.visual.visible,"rejoining clears the grounded pose")
	w.enemy.health=1;w.enemy.min_health=0
	w.enemy.take_damage(100,w.player.position)
	check(w.enemy.external_pose and w.enemy.reaction.mode=="death","Jackal receives a real death sequence")
	w.enemy.reaction._process(0.9)
	check(w.enemy.reaction.frame==7 and is_zero_approx(w.enemy.visual.rotation),"Jackal ends in a body pose instead of a rotated standing sprite")
	w.cutscene.abort();w.free();await process_frame
	w=load("res://scenes/campaign.tscn").instantiate();root.add_child(w)
	w.restore_dressing_state({});w._enter(w.Beat.AMBUSH);w.cutscene.abort();w.set_process(false)
	for i in 2:
		var foe=w.foes[i];foe.set_physics_process(false)
		var stand: float=104*0.5 if i==0 else 100*0.5
		for direction in [Vector2.DOWN,Vector2.UP,Vector2.LEFT,Vector2.RIGHT]:
			foe.facing=direction;foe.attack_direction=direction;foe.attack_visual_time=0.35
			foe.animate("attack",0.15)
			var height: float=bbox(foe.visual.texture).size.y*foe.visual.scale.y
			check(height<stand*1.15 and height>stand*0.8,"blue/violet contact image matches ordinary body height")
			foe.animate("walk",0.1)
			check(foe.visual.texture==foe.base_texture and foe.visual.vframes==32 and foe.visual.scale==Vector2.ONE*0.5,"shooter always restores the complete normal texture transform")
	for kind in ["electrical","server"]:
		var p=preload("res://scripts/world_prop.gd").new();p.setup(w,"qa-"+kind,kind,Vector2(600,420));w.actors.add_child(p)
		var t:=AtlasTexture.new();t.atlas=p.sprite.texture;t.region=Rect2(0,0,384,512)
		var before: float=bbox(t).size.y*p.sprite.scale.y
		var footprint: Rect2=p.footprint()
		p.take_damage(p.max_health/2+1)
		var after: float=bbox(p.sprite.texture).size.y*p.sprite.scale.y
		check(absf(before-after)<0.2 and p.sprite.hframes==1 and p.footprint()==footprint,"damaged technical body keeps its actual visible height and collision")
		p.queue_free()
	w._enter(w.Beat.CHASE);w.cutscene.abort();w.admin_flags["god_mode"]=true
	var drive=w.drive
	drive.completed.emit()
	check(w.beat==w.Beat.CHASE and w.drive==drive,"premature vehicle completion cannot skip an undefeated pursuer")
	drive.armour=0;drive._process(0.01);drive._process(0.8)
	check(w.beat==w.Beat.CHASE,"victory keeps the vehicle visible for the actual exit")
	drive._process(3.1);w.cutscene.skip();await finish(w)
	check(w.beat==w.Beat.GARAGE,"confirmed victory reaches garage after cinematic transition")
	w.cutscene.skip();await finish(w)
	w.player.position=w._target();w.interact()
	check(w.terminal!=null and w.point_index==0,"first console interaction opens the decoder directly")
	check(preload("res://tests/terminal_solver.gd").complete(w),"one console decode begins the descent")
	w.cutscene.skip();await finish(w)
	check(w.beat==w.Beat.HANGAR,"garage has no return trip to its console after boarding")
	w._enter(w.Beat.ECHO,0,0,false,false,false,false,2)
	w.cutscene.abort();w.SanctuaryStory.aftermath(w)
	Engine.time_scale=8
	var recovery:=false
	for i in 2000:
		await process_frame
		if w.raven.external_pose and is_instance_valid(w.raven.reaction) and w.raven.reaction.frame==3:
			recovery=true;break
	check(recovery,"memory aftermath visibly holds Raven's dazed recovery pose")
	w.cutscene.abort()
	check(not w.raven.external_pose and w.raven.visual.visible,"aborting the aftermath restores the normal actor")
	w._enter(w.Beat.LAKE);w._ritual_step()
	for i in 2000:
		await process_frame
		if w.cutscene.waiting_input:break
	check(w.raven.facing.dot((w.player.position-w.raven.position).normalized())>0.95,"Raven faces Shadepi during the lakeside conversation")
	w.cutscene.abort();w.free();await process_frame
	w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w._enter(w.Section.HIDEOUT);w.cutscene.abort();w._scene_hideout();Engine.time_scale=5
	var query:=PhysicsShapeQueryParameters2D.new();var shape:=CircleShape2D.new();shape.radius=6.8;query.shape=shape;query.collision_mask=1
	var clipped:=false;var moved:=0
	for i in 2500:
		await physics_frame
		if w.cutscene.waiting_input:w.cutscene.advance()
		query.transform=Transform2D(0,w.raven.position)
		if w.raven.velocity.length()>0.1:moved+=1
		var hits=w.get_world_2d().direct_space_state.intersect_shape(query,1)
		if not hits.is_empty():
			if not clipped:print("CLIP ",w.raven.position," collider ",hits[0].collider," pos ",hits[0].collider.position)
			clipped=true
		if not w.cutscene.running:break
	check(not clipped,"actual Raven approach never enters the trolley or another solid")
	w.cutscene.abort();w.free();await process_frame
	print("BUG REPORT v045: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
