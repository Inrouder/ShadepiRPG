extends "res://scripts/hud.gd"

const COMIC := {
	"stadt": preload("res://assets/comic/stadt.jpg"),
	"apartment": preload("res://assets/comic/apartment.jpg"),
	"niederlage": preload("res://assets/comic/niederlage.jpg"),
	"dach": preload("res://assets/comic/dach.jpg"),
	"jackal": preload("res://assets/comic/jackal.jpg"),
	"rettung": preload("res://assets/comic/rettung.jpg"),
	"begegnung": preload("res://assets/comic/begegnung.jpg"),
}

var comic_panel: Panel
var comic_art: TextureRect
var comic_fade: Tween

func _ready() -> void:
	super._ready()
	mission_title.text = "KAPITEL 1 / ECHOS IN NEON"
	menu_description.text = "Kapitel 1 · Ravens Jagd\nLokal-Koop beginnt mit Ravens Rückkehr."
	menu_help.position.y = 279
	menu_help.text = "Controller · Stick / Steuerkreuz und A"
	restart_button.text = "Kapitel 1 neu starten"
	comic_panel = panel(Rect2(0, 0, 640, 360))
	root.move_child(comic_panel, dialogue_panel.get_index())
	comic_art = TextureRect.new()
	comic_art.position = Vector2(26, 25)
	comic_art.size = Vector2(588, 191)
	comic_art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	comic_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	comic_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	comic_panel.add_child(comic_art)
	var title := label_at("SHADEPI / IM SCHATTEN DES RABEN", Vector2(0, 6), Vector2(640, 16), comic_panel, 10, Color("83d3e0"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	comic_panel.hide()

func show_menu(title: String = "KAPITEL 1") -> void:
	menu_title.text = title
	requested_coop = world.chapter_coop
	_update_mode_buttons()
	menu.show()
	resume_button.grab_focus()

func _update_mode_buttons() -> void:
	var mode := "Lokal-Koop" if requested_coop else "Einzelspieler"
	mode_button.text = "Modus · " + mode
	resume_button.text = "Fortsetzen" if world.started and world.chapter_coop == requested_coop else "Kapitel 1 starten"
	load_button.text = "Kontrollpunkt laden"
	load_button.disabled = world.saved_checkpoint(requested_coop) < 0

func _start_new() -> void:
	world.chapter_coop = requested_coop
	world.new_game()

func start_selected() -> void:
	if world.started and world.chapter_coop == requested_coop:
		world.close_menu()
	else:
		_start_new()

func clear_dialogue() -> void:
	dialogue_lines.clear()
	dialogue_open = false
	dialogue_done = Callable()
	dialogue_panel.hide()
	comic_panel.hide()

func advance_dialogue() -> void:
	comic_art.texture = COMIC.get(dialogue_lines[0][2], null) if not dialogue_lines.is_empty() else null
	comic_panel.visible = comic_art.texture != null
	if comic_fade != null:
		comic_fade.kill()
	if comic_panel.visible:
		comic_art.modulate.a = 0.35
		comic_fade = create_tween()
		comic_fade.tween_property(comic_art, "modulate:a", 1.0, 0.22)
	super.advance_dialogue()

func _process(delta: float) -> void:
	super._process(delta)
	comic_panel.visible = dialogue_open and comic_art.texture != null and not world.menu_open
	dialogue_panel.visible = dialogue_open and not world.menu_open
	if world.raven_leads():
		vitals.text = "RAVEN / %03d   EN %03d" % [world.raven.health, roundi(world.raven.energy)]
		health_bar.size.x = 164.0 * world.raven.health / 100.0
		energy_bar.size.x = 164.0 * world.raven.energy / 100.0
		if world.gamepads.shadepi_device < 0:
			controls.text = "WASD / Pfeile  Bewegen     Maus / J  Schuss     Leertaste  Ausweichen     Esc  Menü"
	if world.raven_leads() and world.gamepads.shadepi_device >= 0:
		controls.text = "Linker Stick  Bewegen     Rechter Stick  Zielen     X  Schuss     B  Ausweichen"
	elif world.coop and world.raven_joined:
		controls.text = "Raven · Rechter Stick / X oder rechte Maustaste / U     Shadepi · J / linke Maustaste"
	match world.phase:
		world.Phase.APARTMENT:
			objective.text = "Kopfgeld / Chrome Jackal"
		world.Phase.HUNT:
			if world.gate_open:
				objective.text = "Betritt den Wartungshof"
			elif world._guards_left() > 0:
				objective.text = "Folge der Spur · %d Punks übrig" % world._guards_left()
			else:
				objective.text = "Folge der Spur zur Schleuse"
		world.Phase.DUEL:
			objective.text = "Halte durch. Dein Hack läuft."
		world.Phase.ROOFTOP:
			objective.text = "Signal verloren"
		world.Phase.RESCUE:
			objective.text = "Finde Raven" if world.gate_open else "Besiege die Wachen in der Wartungsgasse"
		world.Phase.REVIVE:
			objective.text = "Hör Raven zu"
		world.Phase.TEAM:
			objective.text = "Schaltet Jackals Implantate aus" if world.raven_joined else "Bring Jackal auf halbe Stärke"
		world.Phase.EPILOGUE:
			objective.text = "Der Auftrag danach"
		world.Phase.COMPLETE:
			objective.text = "Kapitel 1 abgeschlossen"
	abilities.visible = abilities.visible and world.phase in [world.Phase.DUEL, world.Phase.RESCUE, world.Phase.TEAM]
	if world.phase == world.Phase.DUEL:
		var remaining := ceili(world.DUEL_DURATION - world.duel_time)
		boss.text = "CHROME JACKAL / %d HP\n%s" % [world.enemy.health, "GEGENHACK" if world.counter_warning else "Panzerung undurchdringlich"]
		abilities.text = "NETRUNNING / Handshake in %02d s     Leertaste / B  Ausweichen" % remaining
	elif world.phase == world.Phase.TEAM:
		boss.text = "CHROME JACKAL / %d von %d HP\n%s" % [world.enemy.health, world.enemy.max_health, "IMPLANTATE GESTÖRT" if world.enemy.exposed > 0 else "Panzerung aktiv"]
	if world.phase == world.Phase.RESCUE or (world.phase == world.Phase.TEAM and not world.raven_joined):
		var cloak := "%.0fs" % world.player.cloak_cooldown if world.player.cloak_cooldown > 0.0 else "bereit"
		abilities.text = "C / Y  Tarnfeld: %s" % cloak
