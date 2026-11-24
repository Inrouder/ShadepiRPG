extends Node
## v0.70.0 · CodexAI. Device language preference; never part of a story save.
signal changed
const Translator = preload("res://scripts/game_translation.gd")
const SETTINGS_PATH := "user://shadepi-language.cfg"
const LANGUAGES := ["de", "en"]
var language := "de"
var preferences_path := SETTINGS_PATH
var save_error: Error = OK
var translator: Translation

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	translator = Translator.new()
	TranslationServer.add_translation(translator)
	load_preferences()

func load_preferences(path: String = "") -> void:
	language = "de"
	var config := ConfigFile.new()
	if config.load(preferences_path if path.is_empty() else path) == OK:
		var stored: Variant = config.get_value("language", "locale", "de")
		if stored is String and stored in LANGUAGES: language = stored
	TranslationServer.set_locale(language)
	changed.emit()

func set_language(value: String) -> void:
	if value not in LANGUAGES: return
	language = value
	TranslationServer.set_locale(language)
	var config := ConfigFile.new()
	config.set_value("language", "locale", language)
	save_error = config.save(preferences_path)
	changed.emit()

func _exit_tree() -> void:
	# TranslationServer outlives the scene tree; release scripted callbacks first.
	if translator != null:
		TranslationServer.remove_translation(translator)
		translator = null
