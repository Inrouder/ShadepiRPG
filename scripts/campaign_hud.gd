extends "res://scripts/chapter_two_hud.gd"

func _ready() -> void :
	super._ready()
	menu_description.text = "Kapitel 3–7 · Der Pakt bis Der neue Orden"
	restart_button.text = "Ab Kapitel 3 neu starten"

func show_menu(title: String = "SHADEPI / KAMPAGNE") -> void :
	super.show_menu(title)

## Pause look follows the current place: Raven's deck, the order's garage,
## the ARToS aerodyne, Moriyama's tower and the lake.
func menu_theme() -> String:
	return ["raven", "raven", "raven", "order", "artos", "order", "artos", "tower", "tower", "tower", "lake", "lake"][clampi(world.beat, 0, 11)]

func _update_mode_buttons() -> void :
	resume_button.text = "Fortsetzen" if world.started else "Kampagne starten"
	load_button.text = "Kontrollpunkt laden"
	load_button.disabled = world.saved_checkpoint() < 0

func comic_texture(_key: String) -> Texture2D:
	return null

func comic_heading() -> String:
	return world.chapter_label()

func _process(delta: float) -> void :
	super._process(delta)
	mission_title.text = world.chapter_label()
	if world.beat == world.Beat.BOSS and not world.foes.is_empty() and not world.in_cinematic():
		var kenzo: PixelActor = world.foes.back()
		var window: bool = kenzo.health <= 180 and fposmod(world.clock, 3.0) <= 1.45
		boss_panel.visible = kenzo.health > 0
		boss.text = "KENZŌ MORIYAMA / %d HP\n%s" % [maxi(0, kenzo.health), "SCHULTERSERVO OFFEN · Q / RB" if window else ("Leitung gesperrt" if kenzo.health <= 180 else "Implantate aktiv")]
	if world.raven_leads():
		vitals.text = "RAVEN / NETRUNNERIN"
	if world.drive != null:
		vitals.text = "INTEGRITÄT / %d %%" % maxi(0, world.drive.health)
		health_bar.size.x = 164.0 * maxf(0.0, world.drive.health) / 100.0
		energy_bar.size.x = 0.0
		if world.drive.flight:
			_flight_hud(world.drive)
		else:
			objective.text = "Verfolger · %d %% Panzerung" % maxi(0, world.drive.armour)
			controls.text = "A/D · Lenken   W/S · Gas/Bremse   J / X · Feuer   Q / RB · Hack (Wagen/Drohne)   Leertaste / B · Granate"
			abilities.visible = not dialogue_open and not world.menu_open
			abilities.text = "Hack %.0f s    Granate %.0f s" % [world.drive.hack_cooldown, world.drive.grenade_cooldown]
	elif world.timing != null:
		controls.text = "J / X · Tippen    U / zweiter Controller · Raven    Esc / Start · Pause"
	elif world.is_combat():
		controls.text = "WASD / Stick · Bewegen    J / X · Katana    Q / RB · Ravens Hack    Leertaste / B · Dash"
	elif world.beat == world.Beat.END:
		controls.text = "Geschichte abgeschlossen · Esc / Start öffnet das Menü"
	else:
		controls.text = "WASD / Stick · Bewegen    E / A · Interagieren    Leertaste / B · Ausweichen    Esc · Menü"

## Aerodyne flight (Kapitel 6): one clear instruction per phase.
func _flight_hud(flight) -> void:
	# The calibration deck and the landing gauge carry their own readouts.
	abilities.visible = not dialogue_open and not world.menu_open and flight.phase not in ["scan", "landing", "done"]
	var km := maxf(0.0, (flight.SCAN_AT - flight.elapsed) * 0.08)
	match flight.phase:
		"canyon", "defence":
			objective.text = ("Turmabwehr · " if flight.phase == "defence" else "Tower-Anflug · ") + ("%.1f km" % km).replace(".", ",")
			controls.text = "A/D · Steuern   W/S · Schub/Bremse   Leertaste / B · Ausweichrolle"
			abilities.text = ("Rolle bereit" if flight.roll_cooldown <= 0.0 else "Rolle lädt …") + ("    Stunts: %d" % flight.near_misses if flight.near_misses > 0 else "")
		"scan":
			objective.text = "Sequenzkalibrierung · Scanner %.0f s" % flight.calibration.time_left
			controls.text = "Pfeile / WASD / Steuerkreuz · Richtung, wenn der Strahl auf dem Aerodyne liegt"
			abilities.text = "Code %d / %d    Abweichungen %d / 3" % [flight.calibration.index, flight.calibration.steps.size(), flight.calibration.errors]
		"alarm":
			objective.text = "ALARM · Neuer Scan in %.0f s" % maxf(0.0, flight.alarm_left)
			controls.text = "A/D · Steuern   Leertaste / B · Rolle durch die Laser"
			abilities.text = "Kennung abgelehnt – überleben"
		"approach":
			objective.text = "Kennung akzeptiert · Landeanflug"
			controls.text = "Leertaste / B beim Signal · Driftkurve"
			abilities.text = "Kontrollierter Drift" if flight.drifted else "Plattform voraus"
		"landing", "done":
			objective.text = "Landung · Tower-Plattform"
			controls.text = "A/D/W/S · Schatten in den Ring   J / X halten · Bremsdüsen"
			abilities.text = "Aufgesetzt: %s" % flight.touchdown if flight.touchdown != "" else ("Im Ring" if flight.pad_offset() <= 1.0 else "Ausrichten")
	if flight.engine_failed:
		objective.text = "TRIEBWERK AUS · %.1f s" % flight.repair_left
		controls.text = "J / X · Ravens Wartungsdeck    A/D / Stick · Gegenlenken"
		abilities.text = "Jumper prüfen · TX/RX kreuzen · Alpha 120 Ω"
		energy_bar.size.x = 164.0 * flight.repair_left / flight.REPAIR_SECONDS
	elif flight.restart_flash > 0:
		abilities.text = "TRIEBWERK LÄUFT · Anflug fortsetzen"
