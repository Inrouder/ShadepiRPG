extends SceneTree
## v0.65.1 · CodexAI. Native isolated footage of the exterior-to-cockpit cut.
var w
const OUT := "/tmp/shadepi-v0651-frames"
func _initialize(): Engine.max_fps=30; run.call_deferred()
func frames(n: int=3):
	for i in n: await process_frame
func snap(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("/tmp/shadepi-v0651-"+name+".png")
func run():
	if DisplayServer.get_name()=="headless" or not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	set_meta("shadepi_admin_testing",true)
	root.get_node("DisplaySettings").mode=0; root.mode=Window.MODE_WINDOWED; root.size=Vector2i(1280,720)
	w=load("res://scenes/campaign.tscn").instantiate(); root.add_child(w); current_scene=w
	await frames(12); root.size=Vector2i(1280,720)
	w.fresh_entry=false; w._enter(w.Beat.ROOF); w.cutscene.abort(); w.ui.clear_dialogue(); w.close_menu(); w.ui.show(); w.set_process(false)
	var scene=load("res://scripts/outbound_flight.gd").new(); scene.world=w; w.drive_layer.add_child(scene)
	var cs=w.begin_cutscene(); scene.play(cs,cs.generation)
	DirAccess.make_dir_recursive_absolute(OUT)
	for file in DirAccess.get_files_at(OUT):
		if file.ends_with(".png"): DirAccess.remove_absolute(OUT+"/"+file)
	Engine.time_scale=2
	var index:=0; var waited:=0; var side:=false; var raven:=false; var shadepi:=false; var card:=false
	for i in 1000:
		await process_frame
		if cs.waiting_input:
			waited+=1
			if waited==10:
				if cs.speaker_label.text=="RAVEN" and not raven: await snap("cockpit-raven"); raven=true
				if cs.speaker_label.text=="SHADEPI" and not shadepi: await snap("cockpit-shadepi"); shadepi=true
			if waited>42: cs.advance(); waited=0
		if scene.stage=="nomads" and scene.crossing>0.45 and not side: await snap("side"); side=true
		if i%3==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(OUT+"/%03d.png"%index); index+=1
		if scene.stage=="two_hours_later" and cs.title_label.modulate.a>0.8 and not card: await snap("time"); card=true
		if card and cs.title_label.modulate.a<0.05: break
	print("GALLERY v0.65.1 CodexAI: side=%s raven=%s shadepi=%s time=%s frames=%d"%[side,raven,shadepi,card,index])
	Engine.time_scale=1; w.free(); current_scene=null; await frames(); quit(0 if side and raven and shadepi and card else 1)
