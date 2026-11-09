# Technische Gegenstände · v0.42.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

- **Auftrag:** Nächsten Block der autorisierten Cinema-Roadmap umsetzen: technische Gegenstände mit eigenen Betriebs-/Zugriffsphasen und nachvollziehbarem Erfolg-/Fehlerfeedback. GitHub-Startseite und Doku-Galerie erhalten neue tatsächliche Spielaufnahmen.
- **Basis:** `5940538`, v0.41.1, lokal sauber und identisch mit `origin/main`. Alle Remote-Branches abgerufen; Versionen und unveränderte Entwicklungsstände bis v0.21.3 verglichen. Keine neuere fremde Arbeit.
- **Aktive Quellen:** `assets/world/hq/props.png`, `prop_art.gd`, `world_prop.gd`, tatsächliche Layouts in `world_dressing.gd`, Art Direction und Objektmaßstab. Kasten/Server bleiben dieselben gebrauchten technischen Geräte, Bodenanker und Standflächen erhalten. Keine neuen Figuren oder Lore.
- **Umfang:** Zuerst Schaltkasten und Serverschrank als kompletter gezielter Block. Vorhandene passende Geräte und ihre beschädigten/zerstörten Quellen erhalten. Betrieb und tatsächlichen Zugriff unterscheiden, kein beliebiges weit entferntes Dekorgerät als Storyterminal ausgeben. Bildquellen brauchen echte transparente Ränder, feste Gehäuse und bewegte mechanische Details.
- **Version:** v0.42.0 · CodexAI, Windows-Datei-/Produktfelder 0.42.0.0. Geprüften Block auf GitHub sichern; keine Cloud-Veröffentlichung.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Quelle / Material / Raster | Zwei direkt generierte unverändert kopierte HQ-Pixelquellen, je acht 384×512-Zellen im 1536×1024-Blatt. Dunkles Metall und vorhandene Gerätemerkmale erhalten. Tatsächlich andere Lüfterwinkel, Mess-/Relaisstellungen; keine reinen Helligkeitskopien, keine programmgesteuerte Bemalung. [Quellenvertrag](../../assets/world/technology/README.md) |
| Fußkontakt / Größe / Alpha | Komplette Gehäuse mit echten Alpha-Rändern. Bodenpunkt an vorderer Gehäusemitte gemessen, nicht an tieferer rechter Perspektivkante: Kasten `(195,444)`, Rack `(210,477)`. Sichtbare Größe neben normalen Figuren und dem bisherigen Objekt im Renderer verglichen. Collider und Layoutpositionen erhalten; neue Gehäuse bewegen sich nicht als Ganzes. [Spielansicht](../previews/technik-betrieb-v042.png), [Vergleichstafel](../previews/technik-posen-v042.png) |
| Zugriff und Status | Explizite Layout-/Kontext-/ID-Zuordnung statt nächster Dekoration. Kasten/Rack sind verbundene optionale Statusgeräte; vorhandene Konsole und Storycallback bleiben maßgeblich. Wartestand 4 im geöffneten Deck; Übernehmen 4→5→6→Betrieb, Alarm 7. Gewöhnlicher Abbruch trennt ohne falschen Erfolg. |
| Schaden / Drift | Unterhalb bzw. bei halben Lebenspunkten vorhandene beschädigte Quelle, bei Tod vorhandene Trümmer ohne Betriebsanimation und Kollision. Beim Atlaswechsel Raster und Basisposition zurücksetzen. Wiederholte Treffer driften nicht in den Bodenanker. Zerstörte Statushardware sperrt das Storyrätsel nicht. [Schadensbilder](../technik-gegenstaende.md) |
| Tatsächliche Szenen | Neuer Gerätebetrieb im Versteck gesichtet. Energiebus über echte Interaktion und Rätselcallback, sieben Rackphasen 0–6 im tatsächlichen Renderer erreicht. Decoder durch echte Fehlversuche gesperrt, Störanzeige sowie Treffer-/Trümmerübergang aufgenommen. Letzter Film **27 tatsächliche Frames, 4,06 Sekunden** nach realen Aufnahmezeitpunkten. [Bilder und Film](../technik-gegenstaende.md) |
| Controller und Pause | Unveränderte E/Enter/A-Bedienung, bestehende Controller-Reihe mit 186 Fällen. Menü und Terminal halten Geräteuhren an; Wartungsstand bleibt während des Decks fest. Ambienter Betrieb darf in normalen Dialog-/Filmszenen weiterlaufen. Keine neue Tastenbelegung oder zusätzliche Partikeldichte. |
| Laden / Wechsel / Abbruch | Gesundheit und Trümmer mit bestehenden Objekt-IDs gespeichert. Vorübergehende Zugriffsreferenzen werden gelöst; Generationsticket und Objektgültigkeit verhindern späte Rückmeldung auf einen anderen Raum. Keine neuen dauerhaften Speicherfelder. Tests und Galerie starten mit frischen Objekten, isolierte Admin-/XDG-Teststände statt Nutzerspielständen. |
| Automatisierte Prüfungen | **1.069 Fälle, 0 Fehler:** neue Technikprüfung 55, Hauptsuite 383, Storyaudit 206, Terminalregeln 67, Controller 186, Ortsatmosphäre 134, Hangarentdeckung 38. Neue Technikprüfung in GitHub-CI. Nach Korrektur der Quellenanker gezielt wiederholt; keine Doppelzählung. |
| Exportierte Ressourcen | Linux-PCK `/tmp/shadepi-v0.42.0.pck` im echten Renderer gestartet. **Zehn zusätzliche Fälle, 0 Fehler:** beide Quellen, Live-Rack, tatsächliche Energieinteraktion, Modalpause, Erfolgs-Callback/Bild, Zerstörung, gespeicherte Gesundheit, Kasten im nächsten Raum und Kapitelbereinigung. Bestätigungsbild für die Sichtprüfung am Gerät kurz angehalten. |
| Doku und Sicherung | Neue PNG-Vorschau direkt auf der GitHub-Startseite und neuer Abschnitt in `docs/README.md`, vorhandene Galerien erhalten. Quellen, Stilbibel, Konsistenzregeln und Roadmap aktualisiert. Projekt/READMEs 0.42.0, Exportfelder 0.42.0.0, neue Hinweise und Commit-Titel CodexAI. Alle Remote-Branches vor Commit erneut abgerufen: `origin/main` unverändert `5940538`, übrige Entwicklungsbranches ebenfalls unverändert. Sicherungsziel `origin/main`. |

Reproduzierbare Projektprüfungen:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/technology_props.gd
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/terminal_puzzles.gd
godot --headless --script res://tests/terminal_controller.gd
godot --headless --script res://tests/scene_atmosphere.gd
godot --headless --script res://tests/hangar_discovery.gd
godot --audio-driver Dummy --script res://tools/technology_pose_gallery.gd
godot --audio-driver Dummy --script res://tools/technology_gallery.gd
godot --headless --export-pack Linux /tmp/shadepi-v0.42.0.pck
```

**Grenzen:** Galerie nutzt QA-Positionierung/Kamera und automatische Rätsellösung; Decoderfehler entstehen durch tatsächliche falsche Kandidaten. Kein neuer vollständig manuell gespielter Durchlauf aller Kapitel, kein nativer Windows-Programmstart und keine akustische Qualitätsprüfung (Dummy-Audio). Automaten, allgemeine Türmechanik, weitere Fahrzeug-/Cockpitbilder und Kapitel-1-Inszenierung bleiben Folgeblöcke.

**Ergebnis:** Erster technischer Prop-Block abgeschlossen, im tatsächlichen Spiel und Export geprüft, mit direkten GitHub-Bildvorschauen dokumentiert und zur Git-Sicherung fertig.
