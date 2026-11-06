extends RefCounted

const Painted = preload("res://scripts/painted_world.gd")

enum Beat{PACT, AMBUSH, CHASE, GARAGE, HANGAR, ECHO, FLIGHT, ROOF, BOSS, ESCAPE, LAKE, END}
const TITLES: = ["DER PAKT", "DIE HÖHLE DES DRACHEN", "EINE VERBINDUNG AUS FEUER UND FLEISCH", "DIE RACHE", "DER NEUE ORDEN"]
const CHAPTERS: = [3, 3, 3, 4, 4, 5, 6, 6, 6, 6, 7, 7]
const LEVEL_ART: = [
	Painted.ART.hideout, 
	Painted.ART.ambush, 
	Painted.ART.ambush, 
	Painted.ART.garage, 
	Painted.ART.hangar, 
	Painted.ART.chamber, 
	Painted.ART.rooftop, 
	Painted.ART.rooftop, 
	Painted.ART.suite, 
	Painted.ART.suite, 
	Painted.ART.lakeside, 
	Painted.ART.lakeside, 
]
const OBJECTIVES: = [
	"Towerplan prüfen · %d / 3", "Hinterhalt überleben · %d / %d", "Verfolger ausschalten", 
	"Geheimes Werkbanksymbol finden", "Aerodyne vorbereiten · %d / 3", "Mit Raven sprechen", 
	"Den Tower erreichen", "Landekennung und Tür hacken · %d / 2", "Kenzō ausschalten", 
	"Daten sichern und zum Aerodyne", "Raven zum Wasser folgen", "Geschichte abgeschlossen", 
]
const POINTS: = [
	[Vector2(498, 333), Vector2(498, 333), Vector2(498, 333)], [Vector2(920, 380)], [],
	[Vector2(738, 323), Vector2(865, 382)], [Vector2(306, 340), Vector2(542, 410), Vector2(795, 324)], [Vector2(486, 310), Vector2(606, 310), Vector2(709, 318)],
	[], [Vector2(310, 340), Vector2(818, 365)], [], [Vector2(345, 325), Vector2(592, 350), Vector2(858, 366), Vector2(914, 397)], 
	[Vector2(615, 390), Vector2(655, 400), Vector2(695, 420), Vector2(735, 440)], [],
]
