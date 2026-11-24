extends SceneTree
## v0.70.0 · CodexAI. Real UI language switching, save roundtrip and story boundaries.
const Terminal = preload("res://scripts/terminal_ui.gd")
var checks := 0
var failures := 0
var language: Node
var world: Node

func _initialize(): run.call_deferred()
func check(ok: bool, detail: String):
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + detail)

func pad(button: JoyButton):
	for pressed in [true, false]:
		var event := InputEventJoypadButton.new()
		event.button_index = button; event.device = 77; event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func run():
	language = root.get_node("LanguageSettings")
	language.preferences_path = "user://language-validation.cfg"
	DirAccess.remove_absolute(language.preferences_path)
	language.load_preferences()
	check(language.language == "de", "new preference defaults to German")
	var bad := ConfigFile.new()
	for invalid in [9, true, "fr", "", ["en"]]:
		bad.set_value("language", "locale", invalid); bad.save(language.preferences_path)
		language.load_preferences()
		check(language.language == "de", "invalid locale safely defaults to German")
	language.set_language("en")
	check(language.save_error == OK and TranslationServer.get_locale() == "en", "English applied and saved")
	language.set_language("fr")
	check(language.language == "en", "unsupported selection cannot change preference")
	language.language = "de"; language.load_preferences()
	check(language.language == "en", "English survives preference reload")
	for pair in [
		["Zurück zum Desktop", "Quit to desktop"],
		["Modus · Einzelspieler", "Mode · Single player"],
		["Umgebung: Leise", "Ambience: Low"],
		["KAPITEL 3 / DER PAKT", "CHAPTER 3 / THE PACT"],
		["Wachen ausschalten · 5 übrig", "Eliminate the guards · 5 left"],
		["Verfolger · 10 % Panzerung", "Pursuer · 10 % armor"],
		["Etappe 1/3 · Stadt · Wagen 72 %", "Stage 1/3 · City · Car 72 %"],
		["Kenzō · 123 / 360 HP · Hackfenster", "Kenzō · 123 / 360 HP · Hack window"],
		["Rauschfilter-Frequenz  [47]", "Noise filter frequency  [47]"],
		["CHROME JACKAL / 120 von 240 HP\nIMPLANTATE GESTÖRT", "CHROME JACKAL / 120 of 240 HP\nIMPLANTS DISRUPTED"],
		["Signalqualität: 87 % · Versuche: 3\nSIGNAL → 1 / 6 gleich\nSENSOR → 2 / 6 gleich\n", "Signal quality: 87 % · Attempts: 3\nSIGNAL → 1 / 6 matching\nSENSOR → 2 / 6 matching\n"],
		["SHADEPI GEWINNT", "SHADEPI WINS"],
		["IM SCHATTEN DES RABEN  ·  V0.70.0", "IN THE RAVEN'S SHADOW  ·  V0.70.0"],
		["Verfolger · 10 % Panzerung\nMit Raven sprechen", "Pursuer · 10 % armor\nTalk to Raven"],
		["Test-Kontrollpunkt: Versteck · Gespräch", "Test checkpoint: Hideout · Conversation"]
	]:
		check(GameText.t(pair[0]) == pair[1], "localized output: " + pair[0])
	# Formatting before/after localization must agree, including zero padding and %%.
	var catalog: Translation = language.translator.CATALOG
	var format_spec := RegEx.new(); format_spec.compile("%[-+ 0#]*[0-9]*(?:\\.[0-9]+)?[dsf]")
	for source_key in catalog.get_message_list():
		var source := String(source_key)
		var fields := format_spec.search_all(source)
		if fields.is_empty(): continue
		var fixed := format_spec.sub(source, "", true).replace("%%", "%")
		if fixed.length() < 3: continue
		var values: Array = []; var english: Array = []
		for field in fields:
			var kind: String = field.get_string().right(1)
			values.append("bereit" if kind == "s" else (17 if kind == "d" else 2.5))
			english.append("ready" if kind == "s" else (17 if kind == "d" else 2.5))
		var expected_text := String(catalog.get_message(source_key)) % english
		check(GameText.t(source % values) == expected_text, "formatted catalog message: " + source)
	for stable in ["SICHER", "SIGNAL", "BD", "E9", "TX", "GND", "lake-shore", "Drake Gatnom", "Swifty Dex", "Tahiro Crow", "Shame Ly"]:
		check(GameText.t(stable) == stable, "puzzle code/identity preserved: " + stable)
	var display := root.get_node("DisplaySettings")
	display.preferences_path = "user://language-display-validation.cfg"
	display.set_mode(0); display.set_resolution(0)
	world = load("res://scenes/chapter_one.tscn").instantiate()
	root.add_child(world); world.set_process(false)
	var devices: Array[int] = [77]; world.gamepads.assign(devices, false)
	await process_frame
	var options = world.ui.display_panel
	world.ui.show_menu(); world.ui._open_display_panel()
	check(options.visible and options.language_select.selected == 1, "English picker available in main-menu options")
	var native_label := Label.new()
	native_label.text = "Zurück zum Desktop"; native_label.size = Vector2(500, 30)
	root.add_child(native_label); await process_frame
	var english_width: float = native_label.get_minimum_size().x
	var expected := native_label.get_theme_font("font").get_string_size("Quit to desktop", HORIZONTAL_ALIGNMENT_LEFT, -1, native_label.get_theme_font_size("font_size")).x
	check(absf(english_width - expected) < 2.0, "native Label shapes English, retaining German source text")
	options.language_select.grab_focus()
	await pad(JOY_BUTTON_A)
	check(options.language_select.get_popup().visible, "controller opens language dropdown")
	await pad(JOY_BUTTON_DPAD_UP); await pad(JOY_BUTTON_A)
	check(language.language == "de" and options.visible, "controller switches to German without closing options")
	await process_frame
	check(native_label.text == "Zurück zum Desktop" and native_label.get_minimum_size().x != english_width, "existing Label returns immediately to German")
	await pad(JOY_BUTTON_A); await pad(JOY_BUTTON_DPAD_DOWN); await pad(JOY_BUTTON_A)
	check(language.language == "en", "controller switches back to English")
	await pad(JOY_BUTTON_A); await pad(JOY_BUTTON_B)
	check(options.visible and not options.language_select.get_popup().visible, "B closes only the language popup")
	var source := "Ich muss schon mal hoch in mein Versteck. Zum Kompensator. Das ist alle sechs Tage nötig."
	var pages: Array[String] = world.cutscene._pages(source)
	check(" ".join(pages).contains("every six days"), "cinematic text translated before pagination")
	world.ui.dialogue([["SHADEPI", source]])
	check(world.ui.dialogue_text.text.begins_with("I need"), "ordinary dialogue starts in English")
	language.set_language("de")
	check(world.ui.dialogue_text.text.begins_with("Ich muss"), "current dialogue reflows without replaying story actions")
	world.ui.clear_dialogue()
	var director = world.begin_cutscene()
	director.say("SHADEPI", source)
	check(director.waiting_input, "cinematic is waiting on its first spoken page")
	language.set_language("en")
	check(director.line_label.text.begins_with("I need") and director.waiting_input, "current cinematic line reflows on locale switch")
	director.abort()
	options.dismiss(); world.started = true; world.ui.show_menu(); world.ui._open_display_panel()
	check(options.visible and options.language_select.selected == 1, "same options available in pause menu")
	options.mode_select.disabled = true
	options.present("raven")
	check(root.gui_get_focus_owner() == options.language_select, "language remains focusable when display mode is disabled on mobile")
	options.mode_select.disabled = false
	options.dismiss()
	for context in ["jackal", "garage", "power", "roof_signal", "repair"]:
		var terminal := Terminal.new(); terminal.context = context; root.add_child(terminal)
		await process_frame
		check(terminal.apply_button.tr(terminal.apply_button.text) == "Apply", context + " native hack UI is English")
		var guide := String(Terminal.GUIDES[terminal.puzzle.kind])
		check(GameText.t(guide).begins_with("1  ") and not GameText.t(guide).contains("Wähle"), context + " instructions translated")
		terminal.queue_free(); await process_frame
	language.set_language("de")
	check(GameText.t("Wachen ausschalten · 5 übrig") == "Wachen ausschalten · 5 übrig", "German formatted source preserved")
	var path: String = language.preferences_path
	language.preferences_path = "user://missing-language-directory/preference.cfg"; language.set_language("en")
	check(language.save_error != OK and language.language == "en", "save failure is reported without undoing language choice")
	language.preferences_path = path
	language.set_language("de"); DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(display.preferences_path)
	native_label.queue_free(); world.queue_free(); await process_frame
	print("Localization: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
