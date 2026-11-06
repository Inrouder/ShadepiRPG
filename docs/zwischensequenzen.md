# Zwischensequenzen (seit v0.17.0)

Neben den Comic-Seiten gibt es jetzt **im Spiel inszenierte Szenen**: Die Kamera fährt, Figuren laufen und reagieren, Untertitel erscheinen in Kinobalken. Die Comic-Seiten bleiben für Kapitelübergänge und Rückblicke erhalten.

**Bedienung:** E / Enter / A blättert weiter · Leertaste / B überspringt die restliche Szene · Esc / Start pausiert.

| Kapitel | Szene | Inhalt |
| --- | --- | --- |
| 1 | Jackals Auftritt | Kamera zwischen Raven und Jackal, er tritt aus dem Schatten; Raven steckt sich in seine Panzerung ein. |
| 1 | Shadepis Landung | Sprung vom Dach in die Wartungsgasse, Aufprall, kurze Warnung an die Gang. |
| 6 | Penthouse | Raven betritt das Penthouse, Shadepi folgt im Tarnfeld. Kenzō dreht sich um, geht auf sie zu – Shadepi enttarnt sich und schlägt ihn zurück. |
| 6 | Kenzōs Ende | Shadepi tritt zurück; Raven beendet es mit ihren kybernetischen Fäden. Totmannschalter, Alarm, die Aufzugtüren öffnen sich – erst jetzt kommen die Wachen. |
| 7 | Ritual am See | Raven und Shadepi gehen gemeinsam ans Wasser (kein Teleport mehr), jeder Schritt mit eigener Kameraeinstellung. |
| 7 | Finale | Maskenkodex: Shadepi zeigt sein Gesicht nur Ordensgeschwistern – Raven ist jetzt eine. Überblendung, Titelkarte „Der Orden des Weißen Drachen ist wiedergeboren“. |

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

Weitere Schritte: `wait`, `pose` (idle/walk/attack/hurt), `release`, `drop` (Sprung von oben), `fade`, `title`. Seiteneffekte gehören in `cs.do(...)` oder den `end`-Callback: Wird die Szene durch Kontrollpunkt, Neustart oder Kapitelwahl abgebrochen, laufen sie nicht mehr. Überspringen führt alle Schritte sofort und in Reihenfolge aus.

Vorschau: `xvfb-run godot --rendering-driver opengl3 --script res://tools/cutscene_gallery.gd` speichert Einzelbilder unter `/tmp/shadepi-cutscene-*.png`.
