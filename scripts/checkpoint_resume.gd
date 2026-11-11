extends RefCounted
## v0.44.0 · CodexAI. Cross-chapter resume without changing old checkpoint payloads.
const Admin = preload("res://scripts/admin_tools.gd")
const REQUEST := "shadepi_resume_request"
const FILES := ["user://shadepi-chapter-one.cfg","user://shadepi-chapter-two.cfg","user://shadepi-campaign.cfg"]

static func latest(tree: SceneTree, coop: bool = false) -> Dictionary:
	var winner := {}
	for i in FILES.size():
		if coop and i>0: continue # Chapters 2–7 currently use their single-player slot.
		var path: String = Admin.checkpoint_path(FILES[i],tree)
		var cfg := ConfigFile.new()
		if cfg.load(path)!=OK: continue
		var value: Variant
		if i==0: value = cfg.get_value("chapter_one","coop" if coop else "solo",-1)
		elif i==1: value = cfg.get_value("chapter","section",-1)
		else: value = cfg.get_value("campaign","beat",-1)
		if not value is int: continue
		if (i==0 and not value in [0,1,4,6,7]) or (i==1 and not value in range(6)) or (i==2 and not value in range(12)): continue
		var time: Variant = cfg.get_value("resume","coop_time" if i==0 and coop else "solo_time",float(FileAccess.get_modified_time(path)))
		if not (time is int or time is float) or not is_finite(float(time)):
			time = float(FileAccess.get_modified_time(path))
		if winner.is_empty() or float(time)>=winner.time:
			winner = {"scene":Admin.scene_for_chapter(i+1),"coop":coop if i==0 else false,"time":float(time),"file":path,"state":value}
	return winner

static func load_latest(world: Node2D, coop: bool = false) -> bool:
	var tree := world.get_tree()
	world.remember_coop_session(coop)   # v0.54.2 · ClaudeHelper: gewählter Modus gilt auch nach dem Laden
	var entry := latest(tree,coop)
	if entry.is_empty():
		world.toast("Kein gültiger Kontrollpunkt für diesen Modus vorhanden.")
		return false
	if world.scene_file_path==entry.scene:
		return world.load_game(entry.coop)
	tree.set_meta(REQUEST,entry)
	var error := tree.change_scene_to_file(entry.scene)
	if error!=OK:
		tree.remove_meta(REQUEST)
		world.toast("Kontrollpunkt konnte nicht geöffnet werden (%d)."%error)
	return error==OK

static func consume(world: Node2D) -> bool:
	var tree := world.get_tree()
	var entry: Variant = tree.get_meta(REQUEST,{})
	if not entry is Dictionary or entry.get("scene","")!=world.scene_file_path: return false
	tree.remove_meta(REQUEST)
	if not world.load_game(bool(entry.get("coop",false))):
		world.toast("Kontrollpunkt ist nicht mehr verfügbar.")
	return true
