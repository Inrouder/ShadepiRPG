extends SceneTree
## v0.48.0 · ClaudeHelper: Umgebungsgeräusche pro Ort, Stufen und Speicherung.
var checks := 0
var failures := 0
const Ambient = preload("res://scripts/ambient_audio.gd")
const Profiles = preload("res://scripts/atmosphere_profiles.gd")

func _initialize() -> void: run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func run() -> void:
	for key: String in Ambient.LOOPS:
		var stream: AudioStreamWAV = Ambient.LOOPS[key]
		check(stream.get_length() > 10.0 and stream.mix_rate == 22050, "loop %s is a 22 kHz loop over ten seconds" % key)
	for profile: String in Ambient.MIX:
		check(profile in Profiles.KEYS, "ambience profile %s matches an existing atmosphere profile" % profile)
		for layer: Array in Ambient.MIX[profile]:
			check(Ambient.LOOPS.has(layer[0]) and layer[1] <= -14.0, "%s uses a known, quiet loop (%s %.0f dB)" % [profile, layer[0], layer[1]])
	for place in ["hideout", "hangar", "rooftop", "suite", "lakeside", "dive"]:
		check(not Ambient.MIX.get(place, []).is_empty(), "%s has its own ambience" % place)
	var w = load("res://scenes/campaign.tscn").instantiate()
	root.add_child(w)
	await process_frame
	check(w.ambience != null and w.ui.ambient_button != null, "campaign builds ambience and its menu button")
	var before: int = w.ambience.level
	w.cycle_ambient_level()
	check(w.ambience.level == (before + 1) % 3 and w.ui.ambient_button.text.ends_with(Ambient.LEVELS[w.ambience.level]), "menu cycles Aus / Leise / Normal and labels it")
	var config := ConfigFile.new()
	check(config.load(w.VISUAL_SETTINGS) == OK and config.get_value("audio", "ambient", -1) == w.ambience.level, "ambience level is stored beside the visual preset")
	w.cycle_visual_quality()
	config = ConfigFile.new()
	config.load(w.VISUAL_SETTINGS)
	check(config.get_value("audio", "ambient", -1) == w.ambience.level, "changing the visual preset keeps the ambience setting")
	w.ambience.set_level(2)
	w.fresh_entry = false
	w._enter(w.Beat.LAKE)
	for i in 4: await process_frame
	check(w.ambience.current == "lakeside" and w.ambience.targets[0] > -80.0, "lake beat targets the lake loop")
	w.ambience.set_level(0)
	for i in 3: await process_frame
	check(w.ambience.targets[0] <= -80.0, "level Aus silences every layer")
	w.queue_free()
	await process_frame
	print("AMBIENT AUDIO: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
