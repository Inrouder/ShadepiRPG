# Zwischensequenzen (seit v0.17.0, vollständig ab v0.18.0)

Die gesamte Story läuft als **im Spiel inszenierte Szenen**: Die Kamera fährt, Figuren laufen und reagieren, Untertitel erscheinen in Kinobalken, Kapitel beginnen mit Titelkarten. Comic-Einblendungen gibt es seit v0.18.0 nicht mehr. Textgrundlage ist die Romanfassung in [Archiv Teil 4](universum/teil-4/README.md).

**Bedienung:** E / Enter / A blättert weiter · Leertaste / B überspringt die restliche Szene · Esc / Start pausiert.

| Kapitel | Szenen |
| --- | --- |
| 1 | Ravens Morgen im Apartment, Shadepi über den Dächern · Jackals Auftritt · Jackal über Raven, Shadepi beobachtet · Sprung in die Wartungsgasse · Shadepi erreicht Raven · Erste Begegnung, Telefon „1-2-3-4“, Datenkarte, Sprung aufs Dach |
| 2 | Landung im Industriegebiet · drei Schläge an der Stahltür · Ravens Versteck · Minotaurus-Fragment · Deep Dive · Rückkehr mit 85 % Eindämmung · Schwur |
| 3 | Der Pakt und Ravens Vergangenheit · Der Plan (Landeplatz, Kennung, Wachen eine Etage tiefer) · Hinterhalt vor dem Versteck · Motorrad |
| 4 | Ankunft an der Garage · Abstieg ins Sanktuarium · Hangar und Aerodyne |
| 5 | Mensch oder Metall – Shadepi erzählt vom Massaker · Eindämmung bricht · Raven sieht seine Erinnerungen |
| 6 | Prophezeiung und ARToS-Start · Landung auf dem Tower, Tarnfeld · Penthouse (Romanfassung) · Kenzōs Ende und die Enthüllung · Totmannschalter und Aufzugwachen · Notfallprotokoll |
| 7 | Explosion beim Abflug · Ankunft am See · vierstufiges Ritual · Maske, Kuss, Titelkarte |

## Eigene Szenen schreiben

```gdscript
func _meine_szene() -> void:
	var cs = begin_cutscene()                 # Kinobalken, HUD aus, Welt pausiert
	await cs.camera(Vector2(600, 340), 1.2, 1.2)   # Ziel, Sekunden, Zoom
	cs.walk(player, Vector2(560, 420))        # ohne await = parallel
	await cs.walk(raven, Vector2(640, 400), 70)
	cs.face(raven, player.position)
	await cs.say("RAVEN", "Text …")           # wartet auf E / A
	cs.do(func(): effects.burst(raven.position, Color.CYAN))  # Effekte nur via do()
	await cs.flash(Color(1, 0, 0, 0.5), 0.3)
	cs.end(func(): toast("Weiter geht's"))    # Kamera zurück, danach Callback
```

Weitere Schritte: `lines` (mehrere Zeilen), `leap` (Sprungbogen), `wait`, `pose` (idle/walk/attack/hurt), `release`, `drop` (Sprung von oben), `fade`, `title`. Seiteneffekte gehören in `cs.do(...)` oder den `end`-Callback: Wird die Szene durch Kontrollpunkt, Neustart oder Kapitelwahl abgebrochen, laufen sie nicht mehr. Überspringen führt alle Schritte sofort und in Reihenfolge aus.

Vorschau: `xvfb-run godot --rendering-driver opengl3 --script res://tools/cutscene_gallery.gd` speichert Einzelbilder unter `/tmp/shadepi-cutscene-*.png`; mit `-- c6` nur Szenen eines Kapitels. Für reine Gesprächsszenen ohne Bewegung gibt es `play_lines(zeilen, fertig)`.
