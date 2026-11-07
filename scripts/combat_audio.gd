extends Node
## Dedicated voice pool: death groans cannot be swallowed by weapon SFX.
var channels: Array[AudioStreamPlayer] = []
var serial := 0
var last_event := ""
func _ready() -> void:
	for i in 4:
		var player := AudioStreamPlayer.new()
		player.volume_db = -11
		add_child(player)
		channels.append(player)
func voice(kind: String, enabled: bool, boss: bool = false) -> void:
	serial += 1
	var count := 2 if kind == "attack" else 3
	last_event = "res://assets/audio/enemy_%s_%d.wav" % [kind, serial % count]
	if not enabled: return
	var selected: AudioStreamPlayer = channels[serial % channels.size()]
	for channel in channels:
		if not channel.playing:
			selected = channel
			break
	selected.stream = load(last_event)
	selected.pitch_scale = (0.84 if boss else 1.0) + randf_range(-0.05,0.05)
	if DisplayServer.get_name() != "headless" and AudioServer.get_driver_name() != "Dummy": selected.play()
func stop() -> void:
	for channel in channels: channel.stop()
