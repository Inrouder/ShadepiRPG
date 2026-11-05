# Versionshinweise

## v0.13.1 – Story, Kapitel und Szenen · 5. November 2026

- Story-Ausgänge starten das folgende Kapitel am Anfang, auch bei älteren abgeschlossenen Spielständen. Menü-Fortsetzen lädt weiterhin den gespeicherten Kontrollpunkt; ungültige Dateien schalten keine Kapitel frei.
- Startposition in Kapitel 2 aus der Autokollision verschoben; Gesundheit, Energie und Hackbereitschaft werden bei der Wiederherstellung zurückgesetzt. Niederlagen außerhalb des Deep Dive führen ebenfalls zum Kontrollpunkt.
- Erinnerungsraum erhält einen definierten Einstieg; falsche Echos führen zum echten Erinnerungsanker zurück.
- Ravens Hackreichweite wird von Raven aus gemessen. Der bewaffnete Ganggegner in Kapitel 1 benutzt Fernangriffe. Der Dachsprung stellt den Fußpunkt der HQ-Grafik korrekt wieder her.
- Überarbeitete Hinterhalt-, Tower-, Rückkehr- und Fluchtdialoge; erklärter Zeitsprung zum nächsten Abend. Das Notfallprotokoll erklärt die Überlastung anstelle nie gelegter Sprengsätze. Fernzugriff und Dachausgang entsprechen den Fluchtaktionen im Penthouse.
- Towerplan wird am Arbeitsterminal geprüft; kontextbezogene Steuerungshinweise. Lange Dialoge werden ohne Textverlust aufgeteilt; HUD-Breiten und mehrzeilige Hinweise angepasst.
- Wassergrenze folgt dem gemalten Ufer. Ritual und Schlusspositionen liegen auf begehbarem Land. Keine Frachtkisten am See, kein Getränkeautomat im Heiligtum oder Penthouse.
- 501 Prüfungen erfolgreich (241 Gameplay, 240 Story/Geometrie/HUD, 20 digitale NPCs). Story-Prüfung in den GitHub-Workflow aufgenommen; Renderübersicht visuell kontrolliert.

[Detaillierter Prüfbericht und Grenzen](docs/v0.13.1-fehlerpruefung.md)

## v0.13.0 – HQ-NPCs · 5. November 2026

- Acht illustrierte humanoide NPC-Atlanten mit acht Blickrichtungen; zwei neue digitale Gegnergrafiken.
- Neue Schuss-/Rundumschlag-Animationen bei unverändertem Kampftiming.
- Originalposen, reproduzierbares Packwerkzeug und NPC-Anleitung enthalten.
- 239 Spieltests und 20 digitale Gegnerprüfungen unter Windows erfolgreich; Godot-Galerie visuell geprüft.
- 32 Ausgangsposen je humanoider Figur werden für die Animationsfelder wiederholt; keine 256 unabhängig gezeichneten Frames.


## v0.12.0 – wiederhergestellter Quellstand auf GitHub

**4. November 2026** · [Upload 3d4b2c4](https://github.com/Inrouder/ShadepiRPG/commit/3d4b2c492ded8a656a2311997781de6d027e1e34)

### Spiel und Medien

- Illustrierte HQ-Sprites für Raven und Shadepi mit acht Blickrichtungen sowie Lauf- und Angriffsanimationen.
- Originale Schlüsselposen und `tools/compile_heroes.py` zur Bearbeitung der Heldenatlanten.
- Die vorherigen Ausbaustufen mit 16 gemalten Kulissen, abgestimmter Kollisions-/Vordergrunddarstellung und zerstörbaren Requisiten sind enthalten.
- Kapitel 1–7, Solo-/Koop-Steuerung, Controller-Unterstützung und Spielstände bleiben Teil des Projekts.

### Wiederherstellung und Sicherung

- Alle 25 Spielskripte dekompiliert und alle 105 importierten Ressourcen konvertiert.
- Originaldateien aus dem separaten HQ-Archiv ergänzt.
- Alle 243 Dateien des bereitgestellten Projekts auf GitHub nachgewiesen; 242 stimmen mit dem lokal geprüften Stand überein. Die neu serialisierte Projektkonfiguration nennt 0.12.0.
- README, Projektaufbau, Bearbeitungshinweise und Wiederherstellungsbericht aktualisiert.

### Prüfung und Grenzen

- Lokale Rekonstruktion unter Windows mit Godot 4.7.2: **177 Prüfungen, 0 Fehler**, erfolgreicher Starttest.
- [GitHub-Test- und Buildlauf des Uploads](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900): **erfolgreich**, einschließlich Windows-/Linux-Export und Linux-Starttest.
- 30 Ressourcen von GDRE als verlustbehaftet konvertiert eingestuft. Ursprüngliche Medienquellen und nicht exportierte Entwicklungsdateien sind nicht vollständig rekonstruierbar.
- Kein vollständiger manueller Spieldurchlauf. Die früher genannten 301 Tests gelten nicht als Testzahl dieser Rekonstruktion.
- Der Quellstand auf `main` und die Actions-Artefakte sind vorhanden. Ein eigenständiger GitHub Release ist ein zusätzlicher Veröffentlichungsschritt.

[Ausführlicher Wiederherstellungsbericht](docs/v0.12.0-wiederherstellung.md)

## Entwicklungsschritte vor der Wiederherstellung

Diese Zuordnung stammt aus den bisherigen Entwicklungsberichten; sie bezeichnet keine nachträglich angelegten Git-Tags oder separat geprüften Releases.

| Version | Schwerpunkt |
| --- | --- |
| v0.11.0 | 16 gemalte Levelkulissen, abgestimmte Kollisionen und Vordergrundwände |
| v0.10.0 | Zerstörbare Kisten, Straßenlaternen, Autos, Fässer und weitere Requisiten |
| v0.9.0 | Comicgerechte Kapitelinszenierung |
| v0.7.0 | Vorheriger GitHub-Quellstand vor der Rückführung des v0.12-Projekts |
