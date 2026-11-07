extends RefCounted
## Sequenzkalibrierung: Raven overlays the copied glider ID of Kenzō's flyer on
## the tower scanner. The scan beam sweeps over the Aerodyne; each code step
## locks only while the beam lies on the hull (the bright window) and with the
## shown direction. Wrong input costs sync; missing the window only costs time.

const DIRS := ["left", "up", "right", "down"]
const ARROWS := ["←", "↑", "→", "↓"]
const CODES := ["K7", "M0", "RY", "4A", "Ω9", "Z3", "N1", "X8"]
const WINDOW := 0.16
const MAX_ERRORS := 3

var steps: Array[Dictionary] = []
var index := 0
var errors := 0
var marker := 0.0
var direction := 1.0
## Sweeps per second; every locked step speeds the beam up a little.
var speed := 0.55
var time_left := 16.0
var state := "run"   # run | done | failed
var feedback := "Strahl abwarten …"
var feedback_time := 0.0
var lock_flash := 0.0
var error_flash := 0.0
var passed_window := false

func _init(seed_value: int = 77, length: int = 5) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var codes := CODES.duplicate()
	for i in length:
		var code: String = codes.pop_at(rng.randi_range(0, codes.size() - 1))
		steps.append({"dir": rng.randi_range(0, 3), "code": code, "w0": rng.randf_range(0.38, 0.7), "locked": false})

func current() -> Dictionary:
	return steps[mini(index, steps.size() - 1)]

func window() -> Vector2:
	var w0: float = current().w0
	return Vector2(w0, w0 + WINDOW)

func in_window() -> bool:
	var w := window()
	return marker >= w.x and marker <= w.y

func progress() -> float:
	return float(index) / steps.size()

func tick(delta: float) -> String:
	if state != "run":
		return ""
	time_left = maxf(0.0, time_left - delta)
	lock_flash = maxf(0.0, lock_flash - delta)
	error_flash = maxf(0.0, error_flash - delta)
	feedback_time = maxf(0.0, feedback_time - delta)
	var was_inside := in_window()
	marker += direction * speed * delta
	# The beam sweeps down and back up again (ping-pong), like a scanner.
	if marker >= 1.0:
		marker = 2.0 - marker
		direction = -1.0
	elif marker <= 0.0:
		marker = -marker
		direction = 1.0
	var event := ""
	if was_inside and not in_window():
		_say("Verpasst – nochmal")
		event = "missed"
	if time_left <= 0.0:
		state = "failed"
		_say("Zeit abgelaufen!")
		event = "failed"
	return event

## Returns "lock", "done", "wrong", "early" or "" (ignored).
func press(dir_index: int) -> String:
	if state != "run":
		return ""
	if not in_window():
		return _error("Zu früh / zu spät!", "early")
	if dir_index != int(current().dir):
		return _error("Falsch: %s erwartet" % ARROWS[int(current().dir)], "wrong")
	current().locked = true
	index += 1
	lock_flash = 0.35
	speed += 0.07
	if index >= steps.size():
		state = "done"
		_say("Kennung komplett!")
		return "done"
	_say("%s eingerastet" % steps[index - 1].code)
	return "lock"

func _error(text: String, kind: String) -> String:
	errors += 1
	error_flash = 0.4
	_say(text)
	if errors >= MAX_ERRORS:
		state = "failed"
		_say("ABGELEHNT!")
		return "failed"
	return kind

func _say(text: String) -> void:
	feedback = text
	feedback_time = 1.6
