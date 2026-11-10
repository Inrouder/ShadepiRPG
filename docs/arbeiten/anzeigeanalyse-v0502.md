# Konsistenzauftrag und Arbeitsnachweis: Anzeigeanalyse

**v0.50.2 · CodexAI · 10. November 2026.** [Befund und Vergleiche](../anzeigequalitaet-v0502.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** analysieren, ob die hochauflösenden Texturen durch optimierte Anzeige besser zur Geltung kommen können.
- **Ausgang:** `617abe2`, v0.50.1; Arbeitsbaum sauber. Alle Remote-Branches abgerufen und mit dem zuletzt bearbeiteten Stand verglichen. `origin/main` aktuell; ältere Entwicklungsbranches enthalten keinen neueren Produktionsstand. Vor Sicherung erneut alle Branches abgerufen: `main` unverändert `617abe2`.
- **Umfang:** Analyse-/Aufnahmewerkzeug und Dokumentation mit Versionsvermerk v0.50.2 · CodexAI. Kein neuer Produktionsmodus, keine Änderungen an Spielgrafiken, Laufzeitfiltern, HUD, Figuren oder Story.

## Referenzen

| Zweck | Tatsächlich geprüft / angesehen | Übernommen |
| --- | --- | --- |
| Rendering | `project.godot`, `display_settings.gd`, `display_panel.gd`, `pixel_actor.gd`, `sprite_assets.gd`, `atmosphere.gdshader` | tatsächlicher Pfad von Quellpixeln über Weltmaßstab und Renderziel bis zur Ausgabe |
| Vorhandene Figuren | Original-Raven/Shadepi und ihre aktive Darstellung, Atlasraster und Hand-/Kontaktposen | Identität, Körpergröße, Kostüm und Anker unverändert |
| Szenen | aktuelle Versteck-, ICE- und Seeansicht; neue native Vergleichspaare tatsächlich gesichtet | gleiche Komposition, gleicher Zoom und gleiche Figurenposition pro Paar |
| Regeln | AGENTS, KONSISTENZ, Art Direction, Arbeitsvorlage und Repository-Status | Pixelstil und Originalquellen erhalten, keine simple Ersatzgrafik oder KI-Hochskalierung |

Keine neue Grafikgenerierung. Die vergleichenden PNGs sind physische Fensteraufnahmen beziehungsweise unveränderte Ausschnitte daraus. Kein Screenshot wurde für den nativen Vergleich nachträglich hochgerechnet oder geschärft.

## Durchführung

- `tools/display_quality_probe.gd` auf eigenem Xorg-Dummy-Display in 1920×1080 gestartet, isoliertes `XDG_DATA_HOME=/tmp/shadepi-display-quality`.
- Acht Fälle: Versteck in 720p und 1080p, ICE und See in 1080p; jeweils bisheriger Viewport-Pfad gegen direktes Canvas-Rendering. Vergleichseinstellungen nur im Testprozess, keine Nutzerpräferenzen gespeichert.
- Gleiche Quellbilder, logische 640×360-Größe, Kamerapositionen, Zoom und Akteurpositionen. Animationen für die Standbilder fixiert. Auslesbares Renderbild und echte Fenstergröße unabhängig gemessen.
- Screenshot-Fallback ImageMagick `import -window`; 640×360-Details direkt per Godot `Image.get_region`, ohne Resampling. Wechselvergleich verlustfrei aus diesen sechs Detailbildern erzeugt, keine neue Spieltextur.
- Alle 130 vorhandenen PNG-Importe auf Kompressionsmodus und Importgrößenlimit untersucht: verlustfrei, unlimitiert. Atlasgröße und Einzelbildgröße ausdrücklich unterschieden.

## Nachweise und Grenzen

| Prüffeld | Ergebnis |
| --- | --- |
| Reale Fenster- und Rendermaße | 40 native Prüfpunkte ohne Fehler; [Messdaten](../analysen/anzeige-v0502.json). |
| Framing / Anker | Beide Modi zeigen pro Paar dieselbe physische Akteurposition und denselben Kamerazoom. |
| Sichtprüfung | Detailgewinn an Heldentexturen, Requisiten und ICE-Metall; weiterhin Originalgrafiken. See- und Kontaktpose zusätzlich verglichen. |
| Bekannte Begleitpunkte | Bloom-Radius hängt an Renderpixeln; harte Schattenanteile werden deutlicher. Bewegungsflimmern und GPU-Leistung sind vor einem produktiven HQ-Modus zu prüfen. |
| Eingabe / Controller | Kein Produktions-Eingabepfad verändert; neue Gesteuertheit nicht behauptet. |
| Laufzeit / Export | Keine neue Runtime-Ressource außer Versionsmetadaten. Analysewerkzeug, Messdaten und Vorschauen werden durch bestehende Exportfilter ausgeschlossen. |
| Regression / Audit | 40 native Vergleichspunkte, 73 bestehende Anzeigeprüfungen und fehlerfreier Headless-Start. Repository-Audit ohne Fehler. Kein erneuter vollständiger Spieldurchlauf für Dokumentation. |
| Version / Sicherung | project/export/README/Spiel-README/Manifest auf v0.50.2 · CodexAI; nach Prüfung auf GitHub sichern. |

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2, X11, OpenGL-Kompatibilität, Mesa llvmpipe. Die Aufnahmen belegen die Darstellung, nicht die Bildrate auf einer Spieler-GPU. Kein globaler Qualitätsmodus ohne Folgeauftrag aktiviert.


## Reproduktion und Sicherung

```sh
# Eigener nativer Desktop mit mindestens 1920×1080, Linux/X11:
XDG_DATA_HOME=/tmp/shadepi-display-quality godot --audio-driver Dummy --script res://tools/display_quality_probe.gd
XDG_DATA_HOME=/tmp/shadepi-display-validation godot --headless --script res://tests/display_settings.gd
python3 tools/audit_repository.py
```

Messdaten, direkte PNG-Vergleiche und der verlustfreie Wechselvergleich werden versioniert; Filmgröße 990.672 Bytes. Das Werkzeug und sämtliche Analysedateien liegen in den bestehenden `tools/*`-/`docs/*`-Exportausschlüssen. Produktionsdateien unter `scripts/`, `shaders/`, `assets/` und `scenes/` sind gegenüber `617abe2` unverändert.

**Ergebnis:** Analyse abgeschlossen; HQ-Pfad als nachvollziehbarer, sichtgeprüfter Vorschlag dokumentiert. Keine Cloud-Veröffentlichung, kein Release-Tag und keine neuen Nutzerpräferenzen angelegt.
