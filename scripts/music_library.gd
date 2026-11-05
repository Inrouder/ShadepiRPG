extends RefCounted

const ROOT := "res://assets/music/"
const FALLBACK := "res://assets/audio/neon-loop.wav"
const EXTENSIONS: Array[String] = ["mp3", "ogg", "wav"]
const SLOTS: Dictionary = {
	"menu": "menu",
	"demo": "demo",
	"chapter_1_apartment": "chapter-1-apartment",
	"chapter_1_hunt": "chapter-1-hunt",
	"chapter_1_duel": "chapter-1-duel",
	"chapter_1_rooftop": "chapter-1-rooftop",
	"chapter_1_rescue": "chapter-1-rescue",
	"chapter_1_finale": "chapter-1-finale",
	"chapter_2_industry": "chapter-2-industry",
	"chapter_2_hideout": "chapter-2-hideout",
	"chapter_2_dive": "chapter-2-dive",
	"chapter_2_recovery": "chapter-2-recovery",
	"chapter_3_pact": "chapter-3-pact",
	"chapter_3_ambush": "chapter-3-ambush",
	"chapter_3_chase": "chapter-3-chase",
	"chapter_4_garage": "chapter-4-garage",
	"chapter_4_hangar": "chapter-4-hangar",
	"chapter_5_sanctuary": "chapter-5-sanctuary",
	"chapter_5_echo": "chapter-5-echo",
	"chapter_6_flight": "chapter-6-flight",
	"chapter_6_tower": "chapter-6-tower",
	"chapter_6_boss": "chapter-6-boss",
	"chapter_6_escape": "chapter-6-escape",
	"chapter_7_lake": "chapter-7-lake",
	"chapter_7_finale": "chapter-7-finale",
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

