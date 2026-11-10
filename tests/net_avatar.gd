extends SceneTree
## v0.50.1 · CodexAI. Every pose uses its original alpha; effect has chapter lifetime.
var checks:=0
var failures:=0
func _initialize():run.call_deferred()
func check(ok:bool,message:String):
	checks+=1
	if not ok:failures+=1;push_error("FAIL: "+message)
func freeze(node:Node):
	node.set_process(false);node.set_physics_process(false)
	for child in node.get_children():freeze(child)
func run():
	var w=load("res://scenes/chapter_two.tscn").instantiate();root.add_child(w)
	w.cutscene.abort()
	for relay in 3:
		w._enter(w.Section.DIVE,relay);w.ui.clear_dialogue();w.started=true;w.close_menu();freeze(w)
		check(w.raven.body_material.shader==w.NET_AVATAR,"all net relays activate the wire silhouette")
		check(w.raven.visual.texture.resource_path.ends_with("raven.png"),"wire effect reuses original Raven rather than an invented figure")
		check(not w.raven.cast_shadow.visible and not w.raven.light_occluder.visible,"virtual avatar does not cast a physical body shadow")
		for direction in 8:
			w.raven.facing=Vector2.from_angle(direction*PI/4);w.raven.animate("walk",.12);w._sync_net_avatar(.1)
			var cell:Vector2=Vector2(w.raven.visual.frame_coords)/Vector2(w.raven.visual.hframes,w.raven.visual.vframes)
			var lower:Vector2=w.raven.body_material.get_shader_parameter("cell_min")
			check(lower.x>=cell.x and lower.y>=cell.y and w.raven.visual.material==w.raven.body_material,"each walk direction retains shader and safe current-cell sampling")
		w.raven.attack_time=.22;w.raven.animate("attack",0);w._sync_net_avatar(.1)
		check(w.raven.visual.texture==w.raven.HAND_CAST and w.raven.visual.material==w.raven.body_material,"open-hand attack retains actual hand art and lattice")
		var upper:Vector2=w.raven.body_material.get_shader_parameter("cell_max")
		check(upper.x<=1 and upper.y<=1 and w.raven.body_material.get_shader_parameter("source_step")==Vector2.ONE/w.raven.visual.scale.abs(),"special pose reads correct atlas and retains world-pixel grid spacing")
		var time:float=w.net_avatar_clock;w.menu_open=true;w._sync_net_avatar(5)
		check(w.net_avatar_clock==time,"menu freezes scanning clock")
		w.menu_open=false;w._sync_net_avatar(.2);check(is_equal_approx(w.net_avatar_clock,time+.2),"scan resumes without jump")
		check(w.raven.body_material.get_shader_parameter("actor_origin")==w.raven.global_position,"grid is anchored to avatar not background")
	w._enter(w.Section.HIDEOUT);freeze(w)
	check(w.raven.body_material.shader==w.NORMAL_AVATAR and w.raven.cast_shadow.visible,"leaving net restores physical sprite shader and shadow")
	check(w.raven.light_occluder.visible and w.raven.modulate==Color.WHITE,"physical body no longer inherits hologram tint or light state")
	w._enter(w.Section.DIVE,2);freeze(w);w.autosave();check(w.load_game() and w.raven.body_material.shader==w.NET_AVATAR,"relay checkpoint restores hologram without changing save format")
	w._enter(w.Section.RECOVERY);freeze(w)
	check(w.raven.body_material.shader==w.NORMAL_AVATAR,"ice-bath recovery cannot inherit net shader")
	if DisplayServer.get_name() != "headless": await check_render(w.NET_AVATAR)
	w.free();await process_frame
	print("NET AVATAR: %d checks, %d failures"%[checks,failures]);quit(1 if failures else 0)

func check_render(shader:Shader):
	var view=SubViewport.new();view.size=Vector2i(256,256);view.transparent_bg=true;view.world_2d=World2D.new();view.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(view)
	var sprite=Sprite2D.new();sprite.texture=load("res://assets/sprites/heroes/raven.png");sprite.hframes=8;sprite.vframes=32;sprite.frame=17;sprite.scale=Vector2.ONE*1.5;sprite.position=Vector2(128,128);view.add_child(sprite)
	for i in 3: await process_frame
	await RenderingServer.frame_post_draw
	var base:Image=view.get_texture().get_image()
	var material=ShaderMaterial.new();material.shader=shader;material.set_shader_parameter("actor_origin",Vector2(128,236));material.set_shader_parameter("source_step",Vector2.ONE/1.5)
	var cell=Vector2(sprite.frame_coords)/Vector2(8,32);var texel=Vector2.ONE/sprite.texture.get_size()
	material.set_shader_parameter("cell_min",cell+texel*.5);material.set_shader_parameter("cell_max",cell+Vector2(1.0/8,1.0/32)-texel*.5);sprite.material=material
	for i in 3:await process_frame
	await RenderingServer.frame_post_draw
	var net:Image=view.get_texture().get_image();var body:=0;var wires:=0;var holes:=0;var escaped:=0;var cyan:=0
	for y in 256:
		for x in 256:
			var original=base.get_pixel(x,y);var pixel=net.get_pixel(x,y)
			if original.a<.01 and pixel.a>.02:escaped+=1
			if original.a>.9:
				body+=1
				if pixel.a>.5:wires+=1
				if pixel.a<.15:holes+=1
				if pixel.g>pixel.r*1.5 and pixel.b>pixel.r*1.5:cyan+=1
	check(body>1000 and wires>body*.25,"native image contains a readable luminous body grid")
	check(holes>body*.15,"native body has transparent spaces between wires")
	check(escaped==0,"native grid never paints outside Raven's actual source alpha")
	check(cyan>body*.8,"native silhouette uses net cyan rather than physical skin/clothing colors")
	view.free()
