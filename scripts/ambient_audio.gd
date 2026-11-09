extends Node
## v0.48.0 · ClaudeHelper: leise Umgebungsgeräusche pro Ort.
## Hängt an den vorhandenen Atmosphäre-Profilen (atmosphere_profile()) und legt bis zu
## zwei synthetisierte Loops übereinander (tools/ambient/generate_ambient.py).
## Eigene Stufe Aus / Leise / Normal, unabhängig von Musik und Effekten.

const LOOPS := {
	"rain": preload("res://assets/audio/ambient_rain.wav"),
	"city": preload("res://assets/audio/ambient_city.wav"),
	"vent": preload("res://assets/audio/ambient_vent.wav"),
	"lake": preload("res://assets/audio/ambient_lake.wav"),
	"net": preload("res://assets/audio/ambient_net.wav"),
}
## Profil → [[Loop, Lautstärke in dB], …]. Fehlende Profile bleiben still.
const MIX := {
	"alley": [["rain", -17.0], ["city", -22.0]],
	"street": [["rain", -17.0], ["city", -22.0]],
	"ambush": [["rain", -16.0], ["city", -23.0]],
	"rooftop": [["rain", -15.0], ["city", -20.0]],
	"apartment": [["rain", -24.0], ["city", -28.0]],   # Regen hinter Glas
	"suite": [["rain", -25.0], ["city", -27.0]],
	"industry": [["city", -18.0], ["vent", -28.0]],
	"hideout": [["vent", -21.0]],
	"garage": [["vent", -22.0], ["rain", -30.0]],
	"hangar": [["vent", -19.0]],
	"chamber": [["vent", -26.0]],
	"compensator": [["vent", -23.0], ["net", -28.0]],
	"dive": [["net", -16.0]],
	"memory": [["net", -22.0]],
	"lakeside": [["lake", -15.0]],
}
const LEVELS := ["Aus", "Leise", "Normal"]
const LEVEL_DB := [-80.0, -7.0, 0.0]

var world: Node
var level := 2
var current := ""
var players: Array[AudioStreamPlayer] = []
var targets: Array[float] = [-80.0, -80.0]

func _ready() -> void:
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.volume_db = -80.0
		add_child(player)
		players.append(player)
	for stream: AudioStreamWAV in LOOPS.values():
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = int(stream.get_length() * stream.mix_rate)

func can_play() -> bool:
	return DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy"

func layers_for(profile: String) -> Array:
	return MIX.get(profile, [])

func set_level(value: int) -> void:
	level = clampi(value, 0, LEVELS.size() - 1)
	current = ""   # Lautstärken beim nächsten Bild neu anwenden

func _process(delta: float) -> void:
	var profile: String = world.atmosphere_profile() if world != null and world.audio_on else ""
	if profile != current:
		current = profile
		var layers := layers_for(profile)
		for i in players.size():
			var player := players[i]
			if i < layers.size() and level > 0:
				var stream: AudioStream = LOOPS[layers[i][0]]
				if player.stream != stream:
					player.stream = stream
					player.volume_db = -80.0
					if can_play(): player.play()
				targets[i] = layers[i][1] + LEVEL_DB[level]
			else:
				targets[i] = -80.0
	# Weiche Überblendung beim Ortswechsel statt harter Schnitte.
	for i in players.size():
		var player := players[i]
		player.volume_db = move_toward(player.volume_db, targets[i], delta * 40.0)
		if player.volume_db <= -79.0 and targets[i] <= -79.0 and player.playing:
			player.stop()
			player.stream = null
