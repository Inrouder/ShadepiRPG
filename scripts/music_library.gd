extends RefCounted

const ROOT := "res://assets/music/"
const FALLBACK := "res://assets/audio/neon-loop.wav"
const EXTENSIONS: Array[String] = ["mp3", "ogg", "wav"]
const SLOTS: Dictionary = {
	"menu": "Level",
	"fight": "Fight",
	"boss": "Boss",
	"demo": "Level",
	"chapter_1_apartment": "Level",
	"chapter_1_hunt": "Fight",
	"chapter_1_duel": "Boss",
	"chapter_1_rooftop": "Level",
	"chapter_1_rescue": "Fight",
	"chapter_1_finale": "Level",
	"chapter_2_industry": "Level2",
	"chapter_2_hideout": "Level2",
	"chapter_2_dive": "Fight",
	"chapter_2_ice_boss": "Boss",
	"chapter_2_recovery": "Level2",
	"chapter_3_pact": "Level3",
	"chapter_3_ambush": "Fight",
	"chapter_3_chase": "Fight",
	"chapter_4_garage": "Level",
	"chapter_4_hangar": "Level2",
	"chapter_5_sanctuary": "Level3",
	"chapter_5_echo": "Level3",
	"chapter_6_flight": "Level3",
	"chapter_6_tower": "Level2",
	"chapter_6_boss": "Boss",
	"chapter_6_escape": "Level3",
	"chapter_7_lake": "menu",
	"chapter_7_finale": "menu",
}

static func candidates(section: String) -> Array[String]:
	var result: Array[String] = []
	var basename: String = SLOTS.get(section, section.replace("_", "-"))
	for extension in EXTENSIONS:
		result.append(ROOT + basename + "." + extension)
	return result

static func path_for(section: String) -> String:
	for path in candidates(section):
		if ResourceLoader.exists(path):
			return path
	return FALLBACK

static func stream_for(section: String) -> AudioStream:
	var loaded: AudioStream = load(path_for(section))
	var stream: AudioStream = loaded.duplicate()
	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = stream.data.size() / 2
	return stream

