extends RefCounted
## v0.64.0 · CodexAI. Transactional CFG checkpoints; old enum values and mode fields stay intact.
const FORMAT := 1
const LIMIT := 1024 * 1024

static func valid(config: ConfigFile) -> bool:
	if config.get_sections().is_empty(): return false
	var version: Variant=config.get_value("storage","format",0)
	if not version is int or version<0 or version>FORMAT: return false
	if config.has_section("chapter_one"):
		var found := false
		for mode in ["solo","coop"]:
			if config.has_section_key("chapter_one",mode):
				var value: Variant=config.get_value("chapter_one",mode)
				if not value is int or value not in [0,1,4,6,7]: return false
				found=true
		return found
	if config.has_section("chapter"):
		var value: Variant=config.get_value("chapter","section",-1)
		return value is int and value in range(6)
	if config.has_section("campaign"):
		var value: Variant=config.get_value("campaign","beat",-1)
		return value is int and value in range(12)
	return false

static func _candidate(path: String) -> ConfigFile:
	if not FileAccess.file_exists(path): return null
	var file := FileAccess.open(path,FileAccess.READ)
	if file==null: return null
	var size:=file.get_length(); file.close()
	if size<1 or size>LIMIT: return null
	var config:=ConfigFile.new()
	# A damaged user file is an expected recovery case, not an engine fault.
	var reporting:=Engine.print_error_messages; Engine.print_error_messages=false
	var error:=config.load(path); Engine.print_error_messages=reporting
	return config if error==OK and valid(config) else null

static func read(path: String) -> ConfigFile:
	for candidate in [path,path+".bak"]:
		var config:=_candidate(candidate)
		if config!=null: return config
	return ConfigFile.new()

static func _stage(config: ConfigFile, path: String) -> bool:
	var file:=FileAccess.open(path,FileAccess.WRITE)
	if file==null: return false
	file.store_string(config.encode_to_text()); file.flush()
	var success:=file.get_error()==OK; file.close()
	return success and _candidate(path)!=null

static func write(config: ConfigFile, path: String) -> bool:
	if not valid(config): return false
	config.set_value("storage","format",FORMAT)
	# A failed stage or backup never touches the current primary checkpoint.
	if not _stage(config,path+".tmp"): return false
	var previous:=_candidate(path)
	if previous!=null:
		if not _stage(previous,path+".bak.tmp"): return false
		if DirAccess.rename_absolute(path+".bak.tmp",path+".bak")!=OK: return false
	return DirAccess.rename_absolute(path+".tmp",path)==OK

static func next_time(tree: SceneTree) -> float:
	# Keep latest-checkpoint ordering stable even if the device clock moves backwards.
	var stamp:=Time.get_unix_time_from_system()
	for file in ["user://shadepi-chapter-one.cfg","user://shadepi-chapter-two.cfg","user://shadepi-campaign.cfg"]:
		var config:=read(preload("res://scripts/admin_tools.gd").checkpoint_path(file,tree))
		for key in ["solo_time","coop_time"]:
			var value: Variant=config.get_value("resume",key,0.0)
			if (value is int or value is float) and is_finite(float(value)) and value>=stamp: stamp=float(value)+1.0
	return stamp
