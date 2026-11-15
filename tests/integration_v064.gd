extends SceneTree
## v0.64.0 · CodexAI. Regressions from the whole-project audit, using real UI/controller states.
const Store = preload("res://scripts/checkpoint_store.gd")
var checks:=0
var failures:=0
func _initialize(): Engine.max_fps=90; run.call_deferred()
func check(ok: bool,label: String):
	checks+=1
	if not ok: failures+=1; push_error("FAIL: "+label)
func frames(n: int=3):
	for i in n: await process_frame
func touch(mobile,key,down: bool):
	var e:=InputEventScreenTouch.new(); e.index=1; e.position=root.get_final_transform()*mobile.surfaces[key].get_center(); e.pressed=down; Input.parse_input_event(e)
	await frames()
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"): quit(1); return
	var mobile=root.get_node("MobileControls"); mobile.enabled=true
	var w=load("res://scenes/chapter_one.tscn").instantiate(); root.add_child(w); current_scene=w
	await frames(12)
	w.open_arcade(true); await frames()
	var a=w.arcade
	check(mobile.controls.visible and w.menu_open,"menu-launched arcade exposes touch controls without starting story")
	await touch(mobile,JOY_BUTTON_A,true); await touch(mobile,JOY_BUTTON_A,false)
	check(a.screen==a.Screen.SELECT,"touch OK enters fighter select")
	await touch(mobile,JOY_BUTTON_A,true); await touch(mobile,JOY_BUTTON_A,false)
	await touch(mobile,JOY_BUTTON_A,true); await touch(mobile,JOY_BUTTON_A,false)
	check(a.screen==a.Screen.FIGHT,"both CPU fighters can be selected by touch")
	a.phase="fight"; a.cpu_think=10.0; a.fighters[1].x=550.0; await frames()
	await touch(mobile,"lt",true)
	check(a.fighters[0].state=="heavy","touch Kick performs the actual arcade kick")
	await touch(mobile,"lt",false)
	a.fighters[0].state="idle"; a.fighters[0].cool=0.0; a.fighters[0].meter=100.0
	await touch(mobile,JOY_BUTTON_Y,true)
	check(a.fighters[0].state==a.fighters[0].data.special,"touch Special performs the selected fighter special")
	await touch(mobile,JOY_BUTTON_Y,false)
	check(not mobile.labels["rt"].visible and not mobile.labels[JOY_BUTTON_RIGHT_SHOULDER].visible,"unsupported story charge/hack are absent in arcade")
	var timer: float=a.timer; var hp: float=a.fighters[0].hp
	a.pause_game("Verbindung unterbrochen"); await create_timer(0.25).timeout
	check(is_equal_approx(a.timer,timer) and a.fighters[0].hp==hp,"pause freezes timer, CPU and damage")
	check(a.pause_panel.visible and not mobile.controls.visible,"pause shows a real clickable modal instead of hidden gameplay menu")
	a.resume_button.pressed.emit(); await frames()
	check(not a.session_paused and mobile.controls.visible,"pause resumes through GUI button")
	w.menu_open=false; a.pause_game(); await frames()
	check(not mobile.controls.visible,"arcade opened from gameplay also hides local action controls while paused")
	a.resume_game()
	var net=root.get_node("NetworkSession"); net.host(0); net.world=w; net.remote=7
	net._disconnected(7); await frames()
	check(a.session_paused and a.pause_panel.visible,"host peer loss pauses the active arcade")
	net.close(); a.close(); await frames()
	w.close_menu(); w.cutscene.abort(); w.ui.clear_dialogue(); await frames()
	check(mobile.input_context=="raven" and not mobile.labels["lt"].visible,"Raven's story controls do not advertise an unavailable kick")
	var settings=root.get_node("AudioSettings"); settings.set_enabled(false)
	var w2=load("res://scenes/chapter_two.tscn").instantiate(); root.add_child(w2); current_scene=w2; w.free(); await frames(12)
	check(not w2.audio_on and not net.audio_on,"mute survives a real chapter/world change")
	net._start_playback(); check(net.audio_player.volume_db<=-79.0,"local mute also silences remote playback")
	settings.set_enabled(true); check(w2.audio_on and net.audio_player.volume_db==0.0,"audio preference propagates to story and remote player")
	net.show_lobby(); net.lobby.local_audio.pressed.emit()
	check(not w2.audio_on and net.audio_player.volume_db<=-79.0,"WLAN panel can mute this device independently")
	net.lobby.local_audio.pressed.emit(); net.lobby.hide()
	check(w2.audio_on,"WLAN local audio can be re-enabled through its button")
	net.close(); w2.free(); current_scene=null; await frames()
	var path:="user://checkpoint-probe.cfg"; var cfg:=ConfigFile.new()
	cfg.set_value("chapter_one","solo",1); cfg.set_value("chapter_one","coop",4)
	check(Store.write(cfg,path),"old chapter-one shape writes transactionally")
	cfg.set_value("chapter_one","solo",6); check(Store.write(cfg,path),"second save retains the previous checkpoint")
	var file:=FileAccess.open(path,FileAccess.WRITE); file.store_string("[broken"); file.close()
	var recovered=Store.read(path)
	check(recovered.get_value("chapter_one","solo",-1)==1 and recovered.get_value("chapter_one","coop",-1)==4,"corrupt primary restores valid backup including the other mode")
	file=FileAccess.open(path,FileAccess.WRITE); file.store_string('[chapter_one]\nsolo=999\n'); file.close()
	check(Store.read(path).get_value("chapter_one","solo",-1)==1,"parseable but invalid checkpoint also falls back")
	cfg.set_value("chapter_one","solo",7); check(Store.write(cfg,path),"recovered game can save again without replacing backup with corrupt data")
	check(Store.read(path+".bak").get_value("chapter_one","solo",-1)==1,"last valid backup remains usable after recovery")
	check(not Store.write(cfg,"user://missing-parent/checkpoint.cfg"),"write failure is reported without creating a false success")
	cfg.set_value("chapter_one","solo",99); check(not Store.write(cfg,path),"invalid in-memory state cannot replace a valid checkpoint")
	var future:=Time.get_unix_time_from_system()+3600.0
	var timed:=ConfigFile.new(); timed.set_value("chapter","section",2); timed.set_value("resume","solo_time",future)
	check(Store.write(timed,"user://shadepi-chapter-two.cfg") and Store.next_time(self)>future,"latest-checkpoint ordering survives a backwards device clock")
	await create_timer(0.2).timeout # let the audio mixer release its stopped generator
	print("INTEGRATION v0.64.0 CodexAI: %d checks, %d failures"%[checks,failures]); quit(1 if failures else 0)
