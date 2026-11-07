extends RefCounted
## Terminal rules are independent of presentation and world progression.

const CATALOG := {
	"jackal": ["matrix", "CHROME JACKAL / TORSCHLEUSE", false],
	"garage": ["decoder", "GARAGE / ZUGANGSCODE DES ORDENS", false],
	"power": ["routing", "HANGAR / ENERGIEBUS", false],
	"transponder": ["matrix", "AERODYNE / PRÜF-ICE", true],
	"roof_signal": ["signal", "DACHTERMINAL / FUNKKENNUNG", false],
	"penthouse": ["decoder", "PENTHOUSE / SICHERHEITSTÜR", true],
	"charge": ["signal", "AUFZUG / SPERRLADUNG", true],
	"repair": ["jumper", "AERODYNE / NOTREPARATUR", false],
}
const WORDS := ["SIGNAL", "SIEGEL", "SICHER", "SILBER", "SENSOR", "SENDET"]
const PINS := ["TX", "RX", "GND", "VCC", "DATA"]
const SOCKETS := ["—", "VCC", "GND", "TX", "RX", "DATA"]
const RESISTORS := [20, 40, 60, 80, 100]
const DIRECTIONS := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
var context: String
var kind: String
var title: String
var hard := false
var solved := false
var failed := false
var status := "Verbindung bereit."
var clock := 0.0
var flash := 0.0
var cells: Array = []
var buffer: Array = []
var used: Array = []
var goals: Array = []
var capacity := 4
var cursor := -1
var column_turn := true
var attempts := 4
var secret := "SIGNAL"
var filter := 0
var filter_target := 64
var removed: Array = []
var guessed: Array = []
var helpers: Array = []
var history := ""
var masks: Array = []
var infected: Array = [0]
var powered := false
var rate := 1
var input_a := false
var input_b := false
var gate := "AND"
var ice_clock := 0.0
var stability := 0.0
var signal_values: Array = [1, 1, 0]
var signal_target: Array = [3, 3, 5]
var noise := false
var wiring: Array = [0, 0, 0, 0, 0]
var resistors: Array = [0, 0]
var leds: Array = [false, false, false, false, false]

func _init(id: String = "jackal") -> void:
	context = id
	var config: Array = CATALOG[id]
	kind = config[0]
	title = config[1]
	hard = config[2]
	if kind == "matrix":
		var codes := ["1E", "55", "BD", "E9"]
		for i in 25:
			cells.append(codes[(i * 7 + i / 5) % 4])
		# Guaranteed path: row 0 → column 1 → row 2 → column 3 → row 4.
		for pair in [[1, "BD"], [11, "E9"], [13, "55"], [23, "1E"], [20, "BD"]]:
			cells[pair[0]] = pair[1]
		goals = [["BD", "E9", "55"]]
		if hard:
			goals.append(["55", "1E", "BD"])
			capacity = 5
	elif kind == "decoder":
		secret = "SILBER" if hard else "SIGNAL"
		filter_target = 38 if hard else 64
	elif kind == "routing":
		# W→E entry at 4, detour through gate 10, W→E exit at 7.
		masks = [3, 5, 6, 9, 5, 9, 3, 12, 6, 6, 5, 3, 3, 10, 9, 12]
	elif kind == "signal" and hard:
		signal_target = [4, 2, 3]
	elif kind == "jumper":
		attempts = 3

func available() -> bool:
	return not solved and not failed

func legal(index: int) -> bool:
	if index < 0 or index >= 25 or index in used or not available():
		return false
	if cursor < 0:
		return index < 5
	return index % 5 == cursor % 5 if column_turn else index / 5 == cursor / 5

func has_sequence(sequence: Array) -> bool:
	for start in range(buffer.size() - sequence.size() + 1):
		if buffer.slice(start, start + sequence.size()) == sequence:
			return true
	return false

func select_hex(index: int) -> void:
	if not legal(index):
		return
	used.append(index)
	buffer.append(cells[index])
	if cursor >= 0:
		column_turn = not column_turn
	cursor = index
	solved = true
	for goal in goals:
		solved = solved and has_sequence(goal)
	if solved:
		status = "Daemons geladen. Zugriff freigegeben."
	elif buffer.size() >= capacity:
		fail("Puffer voll. Sequenz unvollständig – erneut versuchen.")
	else:
		status = "Nächster Wert: gleiche %s." % ("Spalte" if column_turn else "Zeile")

func filter_locked() -> bool:
	return absi(filter - filter_target) <= 4

static func likeness(a: String, b: String) -> int:
	var result := 0
	for i in mini(a.length(), b.length()):
		result += int(a[i] == b[i])
	return result

func guess(index: int) -> void:
	if not available() or not filter_locked() or index in removed or index in guessed:
		return
	guessed.append(index)
	var word: String = WORDS[index]
	var score := likeness(word, secret)
	history = "%s → %d / 6 gleich\n" % [word, score] + history
	if score == 6:
		solved = true
		status = "Passwort bestätigt. Türsteuerung freigegeben."
	else:
		attempts -= 1
		status = "Ähnlichkeit %d / 6 · %d Versuche übrig." % [score, attempts]
		flash = 0.5
		if attempts <= 0:
			fail("Sitzung gesperrt. Neue Verbindung möglich.")

func helper(name: String) -> void:
	if not available() or name in helpers:
		return
	helpers.append(name)
	if name == "reset":
		attempts = 4
		status = "<RESET> gefunden: Versuche wiederhergestellt."
	else:
		for i in WORDS.size():
			if WORDS[i] != secret and i not in removed and i not in guessed:
				removed.append(i)
				break
		status = "[DUD] gefunden: falscher Eintrag entfernt."

static func gate_output(type: String, a: bool, b: bool) -> bool:
	match type:
		"AND": return a and b
		"OR": return a or b
		"XOR": return a != b
		"NOT": return not a
	return false

func rotate(index: int) -> void:
	if not available() or index in infected:
		return
	var mask: int = masks[index]
	masks[index] = ((mask << 1) & 15) | (mask >> 3)
	stability = 0.0

func neighbors(index: int) -> Array:
	var result: Array = []
	var p := Vector2i(index % 4, index / 4)
	for d in 4:
		var next: Vector2i = p + DIRECTIONS[d]
		if next.x < 0 or next.x > 3 or next.y < 0 or next.y > 3:
			continue
		var n := next.y * 4 + next.x
		if (masks[index] & (1 << d)) and (masks[n] & (1 << ((d + 2) % 4))):
			result.append(n)
	return result

func connected() -> Array:
	var seen: Array = [4] if (masks[4] & 8) else []
	var i := 0
	while i < seen.size():
		for n in neighbors(seen[i]):
			if n not in seen:
				seen.append(n)
		i += 1
	return seen

func route_valid() -> bool:
	# A signal must actually travel through the logic gate before reaching OUT.
	if not (masks[4] & 8) or not (masks[7] & 2) or not gate_output(gate, input_a, input_b):
		return false
	var queue: Array = [[4, false]]
	var visited: Array = []
	while not queue.is_empty():
		var state: Array = queue.pop_front()
		if state in visited:
			continue
		visited.append(state)
		if state[0] == 7 and state[1]:
			return true
		for n in neighbors(state[0]):
			queue.append([n, state[1] or n == 10])
	return false

func check_wiring() -> void:
	if not available():
		return
	var expected := ["RX", "TX", "GND", "VCC", "DATA"]
	solved = true
	for i in 5:
		leds[i] = SOCKETS[wiring[i]] == expected[i]
		solved = solved and leds[i]
	var ohms: int = RESISTORS[resistors[0]] + RESISTORS[resistors[1]]
	solved = solved and ohms == 120
	if solved:
		status = "Alle LEDs grün · Alpha 120 Ω · Triebwerk startbereit."
	else:
		attempts -= 1
		flash = 0.7
		status = "Funken / Alarm! Pinbelegung und Alpha prüfen. %d Versuche." % attempts
		if attempts <= 0:
			fail("Schutzschaltung ausgelöst. Platine zurücksetzen.")

func fail(message: String) -> void:
	failed = true
	status = message
	flash = 0.7

func tick(delta: float) -> void:
	# Substeps preserve timers and ICE order even during a slow render frame.
	var remaining := maxf(0, delta)
	while remaining > 0.00001 and available():
		var step := minf(remaining, 0.05)
		_step(step)
		remaining -= step
	flash = maxf(0, flash - delta)

func _step(delta: float) -> void:
	clock += delta
	if kind == "routing" and powered:
		var flow := connected()
		if rate > 1 and 10 in flow:
			fail("Überlast an Knoten 10 (max. 1×). Verbindung geschmolzen.")
			return
		ice_clock += delta
		if ice_clock >= 1.4:
			ice_clock -= 1.4
			for node in infected.duplicate():
				for next in neighbors(node):
					if next not in infected:
						infected.append(next)
		for node in infected:
			if node in flow or node == 7:
				fail("Active ICE hat den Datenbus erreicht. Neu verbinden.")
				return
		stability = stability + delta if route_valid() else 0.0
		status = "Datenfluss stabil: %.1f / 3 s · ICE isolieren!" % stability
		if stability >= 3.0:
			solved = true
			status = "Datenbus stabil. Energieversorgung freigegeben."
	elif kind == "signal":
		noise = fposmod(clock, 6.0) > 4.7
		if hard and int(clock / 12.0) != int((clock - delta) / 12.0):
			signal_target[2] = (signal_target[2] + 1) % 8
		stability = stability + delta if signal_values == signal_target and not noise else 0.0
		status = "Störimpuls – Signal beobachten." if noise else "Phase Lock: %.1f / 1.2 s" % stability
		if stability >= 1.2:
			solved = true
			status = "Phase Lock bestätigt. Kanal gesichert."
