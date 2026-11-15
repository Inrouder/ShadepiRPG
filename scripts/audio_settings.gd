extends Node
## v0.64.0 · CodexAI. Device preference survives chapter changes and governs remote sound too.
signal changed
const PATH := "user://shadepi-audio.cfg"
var enabled := true
var save_error: Error = OK

func _ready():
	var config:=ConfigFile.new()
	if config.load(PATH)==OK:
		var value: Variant=config.get_value("audio","enabled",true)
		if value is bool: enabled=value

func set_enabled(value: bool):
	enabled=value
	var config:=ConfigFile.new(); config.set_value("audio","enabled",enabled)
	save_error=config.save(PATH)
	changed.emit()
