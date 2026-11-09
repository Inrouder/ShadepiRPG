extends SceneTree
## v0.44.0 · CodexAI. Resume selection, real scene changes and every test checkpoint.
const Resume = preload("res://scripts/checkpoint_resume.gd")
const Points = preload("res://scripts/test_checkpoints.gd")
const Admin = preload("res://scripts/admin_tools.gd")
var checks := 0
var failures := 0
func _initialize(): run.call_deferred()
func check(ok: bool,msg: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: "+msg)
func fixture(index: int,state: Variant,time: float,testing: bool = false,coop: bool = false):
	var cfg := ConfigFile.new()
	if index==0: cfg.set_value("chapter_one","coop" if coop else "solo",state)
	elif index==1: cfg.set_value("chapter","section",state)
	else: cfg.set_value("campaign","beat",state)
	if time>=0:cfg.set_value("resume","coop_time" if index==0 and coop else "solo_time",time)
	var path: String = Resume.FILES[index]
	if testing:path=path.replace("user://shadepi-","user://shadepi-admin-")
	check(cfg.save(path)==OK,"fixture saved")
func clear_files():
	for file in Resume.FILES:
		for path in [file,file.replace("user://shadepi-","user://shadepi-admin-")]:
			if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
func run():
	if not OS.get_user_data_dir().begins_with("/tmp/shadepi-"):
		push_error("Run with an isolated XDG_DATA_HOME=/tmp/shadepi-menu-tests directory; real player saves must never be used.")
		quit(1)
		return
	clear_files()
	check(Resume.latest(self).is_empty(),"no fabricated checkpoint on a fresh installation")
	fixture(0,1,10)
	fixture(1,2,20)
	fixture(2,7,30)
	check(Resume.latest(self).state==7 and Resume.latest(self).scene.ends_with("campaign.tscn"),"latest resumes across chapter boundaries")
	fixture(2,"invalid",40)
	check(Resume.latest(self).scene.ends_with("chapter_two.tscn"),"corrupt newest state falls back to last valid file")
	fixture(2,99,40)
	check(Resume.latest(self).state==2,"out-of-range latest state is excluded")
	fixture(0,6,-1)
	check(Resume.latest(self).scene.ends_with("chapter_one.tscn"),"old checkpoints without metadata use their file modification time")
	check(Resume.latest(self,true).is_empty(),"solo checkpoints never masquerade as a co-op slot")
	fixture(0,4,60,false,true)
	check(Resume.latest(self,true).state==4,"co-op selection uses the co-op checkpoint")
	fixture(2,10,999,true)
	set_meta(Admin.SESSION_KEY,true)
	check(Resume.latest(self).state==10 and "admin-" in Resume.latest(self).file,"test sessions use only separate test saves")
	remove_meta(Admin.SESSION_KEY)
	check(not "admin-" in Resume.latest(self).file,"normal resume excludes the newer test file")
	fixture(0,1,10)
	fixture(1,2,20)
	fixture(2,7,30)
	var w = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(w)
	current_scene = w
	check(w.ui.quit_button.is_visible_in_tree() and w.ui.load_button.text=="Letzten Kontrollpunkt laden" and not w.ui.load_button.disabled,"opening menu exposes desktop and latest resume")
	check(Resume.load_latest(w),"cross-scene latest request accepted")
	await scene_changed
	w = current_scene
	check(w.scene_file_path.ends_with("campaign.tscn") and w.beat==7 and not has_meta(Resume.REQUEST),"ready consumes request and loads actual tower checkpoint")
	check(not w.menu_open,"resume immediately enters the saved game")
	w.menu_open = true
	w.ui.show_menu()
	check(w.ui.quit_button.is_visible_in_tree(),"desktop option also exists in pause")
	var unique := {}
	check(Points.request(self,"invalid-checkpoint")==ERR_INVALID_PARAMETER,"unknown checkpoint id rejected before changing scene")
	check(not has_meta(Points.REQUEST),"invalid request leaves no pending route")
	Engine.max_fps = 240
	for row in Points.ENTRIES:
		var id: String = row[0]
		check(not unique.has(id),"unique checkpoint id "+id)
		unique[id]=true
		check(Points.request(self,id)==OK,"request "+id)
		await scene_changed
		w = current_scene
		w.cutscene.abort()
		check(Admin.is_test_session(self) and not has_meta(Points.REQUEST),"isolated checkpoint consumed "+id)
		var state: int = w.phase if row[1]==1 else w.section if row[1]==2 else w.beat
		check(state==row[3] and w.started,"safe authored state reached "+id)
		if id=="hunt-mid" or id=="hunt-east":check(w.encounter.section_index==row[5],"arcade section entered directly "+id)
		if id in ["relay2","relay3"]:check(w.relay_index==row[5],"relay entered directly "+id)
		if id=="memory2":check(w.echo_ready and w.memory_attack_complete and not w.memory_sacrifice_complete,"memory 2 has only the preceding memory completed")
		if id=="memory3":check(w.echo_ready and w.memory_attack_complete and w.memory_sacrifice_complete and not w.memory_legacy_complete,"memory 3 has its own compatible prerequisite flags")
		if id=="extraction":check(w.tower_stage==0 and not w.escape_guards_cleared and w.kenzo_body!=null,"extraction begins with living defeated Kenzo and pending defense")
		if id.begins_with("escape-"):check(w.tower_stage==2 and w.escape_guards_cleared,"later escape checkpoints have extraction completed")
		if id=="ice-bath":check(not w.spray_ready,"bath preparation does not inherit future rescue items")
		if id=="lake-arrival":check(w.lake_scene_pending,"arrival can be tested without replaying flight")
		w.set_process(false)
		await process_frame
	check(Points.entries(6).size()==8 and Points.entries(0).is_empty(),"chapter-scoped catalogue")
	w.menu_open = true
	w.ui.show_menu()
	w.ui._toggle_admin_panel()
	w.admin_flags["unlock_all"] = true
	w.ui._refresh_admin_controls()
	check(not w.ui.admin_checkpoint_button.disabled and w.ui.admin_checkpoint_picker.item_count==7,"checkpoint controls enabled alongside chapter unlock")
	w.ui.admin_chapter_picker.select(5)
	w.ui.admin_chapter_picker.item_selected.emit(5)
	check(w.ui.admin_checkpoint_picker.item_count==8,"chapter selector repopulates checkpoint choices")
	w.ui.admin_checkpoint_picker.select(4)
	w.ui.admin_checkpoint_button.pressed.emit()
	await scene_changed
	w=current_scene
	check(w.beat==9 and w.tower_stage==0,"actual checkpoint button enters Raven's defense sequence")
	w.cutscene.abort()
	check(FileAccess.get_modified_time(Resume.FILES[2])>0,"normal save still exists after all test jumps")
	var cfg := ConfigFile.new();cfg.load(Resume.FILES[2])
	check(cfg.get_value("campaign","beat")==7,"all test jumps leave the normal tower save unchanged")
	w.free()
	await process_frame
	clear_files()
	print("MENU CHECKPOINTS: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
