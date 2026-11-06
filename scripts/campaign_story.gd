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
const PANELS: = {
	"pakt": preload("res://assets/comic/pakt.jpg"), "hinterhalt": preload("res://assets/comic/hinterhalt.jpg"), 
	"jagd": preload("res://assets/comic/jagd.jpg"), "garage": preload("res://assets/comic/garage.jpg"), 
	"hangar": preload("res://assets/comic/hangar.jpg"), "echo": preload("res://assets/comic/echo.jpg"), 
	"tower": preload("res://assets/comic/tower.jpg"), "kenzo": preload("res://assets/comic/kenzo.jpg"), 
	"flucht": preload("res://assets/comic/flucht.jpg"), 
	"ankunft-see": preload("res://assets/comic/ankunft-see.jpg"), "see": preload("res://assets/comic/see.jpg"), 
}

const DIALOGUE: = {
	Beat.PACT: [
		["RAVENS VERSTECK", "Raven öffnet den Towerplan am Arbeitsterminal. Aufzug, Dachzugang und Scanner müssen geprüft werden.", "pakt"],
		["RAVEN", "Mein Vater programmierte für Arasaka. Moriyama ließ meine Eltern töten und hielt mich jahrelang fest. Ich floh und löschte meine Identität.", "pakt"], 
		["RAVEN", "Jackal war sein Bluthund. Ich wollte ihn finden, bevor er mich findet.", "pakt"], 
		["SHADEPI", "Ich suche den Auftraggeber der Minotauren. Du entscheidest, ob du mir hilfst.", "pakt"], 
		["RAVEN", "Ich helfe dir. Kenzō hat oben im Tower ein Penthouse mit privatem Landeplatz. Wir brauchen die Kennung seines Gleiters.", "pakt"], 
		["SHADEPI", "Ich weiß, wo wir einen Aerodyne herbekommen. Sein Personal ist morgen Abend eine Etage tiefer. Wir gehen übers Dach.", "pakt"], 
	], 
	Beat.AMBUSH: [
		["GASSE VOR DEM VERSTECK", "Auf dem Weg zu Shadepis Garage schneiden zwei Bewaffnete ihnen den Weg zum Motorrad ab.", "hinterhalt"],
		["SHADEPI", "Zwei Schützen in der Gasse! Nutze die Deckung zwischen uns. Raven, kannst du ihre Optik stören?", "hinterhalt"],
		["RAVEN", "Wenn du mir eine freie Verbindung verschaffst. Gib mir ein Signal.", "hinterhalt"], 
	], 
	Beat.CHASE: [
		["SHADEPI", "Aufs Motorrad! Der Wagen kommt hinter uns aus der Gasse. Festhalten!", "jagd"], 
		["RAVEN", "Du fährst. Ich decke uns nach hinten. Fahr mich auf seine Spur, damit ich seine Lenkung hacken kann.", "jagd"], 
	], 
	Beat.GARAGE: [
		["RAVEN", "Eine rostige Garage. Das ist dein Versteck?", "garage"], 
		["SHADEPI", "Sieh dir die Werkbank an. Darunter liegt der Zugang zum Sanktuarium. Raven, entschlüssle das alte Zugangsterminal.", "garage"],
	], 
	Beat.HANGAR: [
		["SHADEPI", "Schau dich um. Ich wechsle den Servo. Der Aerodyne braucht die Kennung von Kenzōs Gleiter.", "hangar"], 
		["RAVEN", "Ich prüfe den Stromkreis, kopiere die Kennung und teste das ARToS-System.", "hangar"], 
	], 
	Beat.ECHO: [
		["NACHT / SANKTUARIUM", "Der Aerodyne ist vorbereitet. In der inneren Kammer erzählt Shadepi vom Heiligtum.", "echo"],
		["SHADEPI", "Als die Minotauren das Kloster angriffen, habe ich das Heiligtum in mich aufgenommen. Seitdem lebt der Schwarm in mir.", "echo"],
		["RAVEN", "Und nach dem Angriff?", "echo"],
		["SHADEPI", "Das Kloster war verschwunden. Ich suche seitdem nach Antworten.", "echo"],
		["NACHT / SANKTUARIUM", "Die Halle wird still. Shadepis HUD schlägt an. Er muss das Heiligtum am Sessel prüfen.", "echo"],
	], 
	Beat.FLIGHT: [
		["AM NÄCHSTEN ABEND", "Nach einer Ruhepause starten Raven und Shadepi zum Tower. Kenzōs Personal ist jetzt eine Etage unter dem Penthouse.", "tower"],
		["ARTOS", "Systemstart. Parameter instabil.", "tower"], 
		["SHADEPI", "Ich halte uns zwischen den Baken. Raven, sende die kopierte Kennung, sobald der Scanner in Reichweite ist.", "tower"], 
	], 
	Beat.ROOF: [
		["RAVEN", "Die falsche Kennung hat uns bis hierher gebracht. Ich öffne die Penthouse-Tür und lenke Kenzō ab.", "tower"], 
		["SHADEPI", "Ich folge dir im Tarnfeld. Wenn es zusammenbricht, ziehe ich seine Aufmerksamkeit auf mich.", "tower"], 
	], 
	Beat.BOSS: [
		["KENZŌ MORIYAMA", "Raven. Ich habe lange nach dir gesucht.", "kenzo"], 
		["SHADEPI", "Raven, runter! Stör seine Implantate, ich halte ihn auf. Wenn er die Leitung sperrt, warte auf das Flackern am Schulterservo.", "kenzo"],
	], 
	Beat.ESCAPE: [
		["SYSTEM / NOTFALLPROTOKOLL", "Kenzōs Sicherheitssystem überlastet die Energieversorgung. Kritischer Zustand in sechzig Sekunden.", "flucht"],
		["RAVEN", "Weitere Teams im Schacht! Sichere die Daten, ich synchronisiere die Sperrladung am Aufzug. Dann die Treibstoffpumpe per Fernzugriff.", "flucht"],
	], 
	Beat.LAKE: [
		["ARTOS", "Triebwerke instabil. Neustart.", "flucht"], 
		["SHADEPI", "Halt dich fest!", "flucht"], 
		["NACHT / AUSSERHALB DER STADT", "Die Druckwelle trifft den Aerodyne. Shadepi fängt den Sturz ab und bringt sie zu einem See fern der Stadt.", "ankunft-see"], 
	], 
	Beat.END: [
		["EPILOG", "Night City schläft nie. Doch zwischen Neon und Regen wacht wieder ein Orden über das Gleichgewicht.", "see"], 
	], 
}
