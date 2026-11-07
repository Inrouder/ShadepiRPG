# Shadepi · Echos in Neon

**2D-Action-RPG · v0.20.6 · Godot 4.7.2 · Windows / Linux · Einzelspieler und Lokal-Koop**

Ein spielbares Cyberpunk-Abenteuer nach **„Shadepi – Im Schatten des Raben“** mit sieben Kapiteln, gemalten Spielwelten, illustrierten Sprites für Raven, Shadepi und die Gegner sowie zerstörbarer Umgebung.

[**Spiel herunterladen (GitHub Actions)**](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) · [**Quellcode als ZIP**](https://github.com/Inrouder/ShadepiRPG/archive/refs/heads/main.zip) · [**Versionen**](CHANGELOG.md) · [**Spieleranleitung**](Spiel-README.md)

## Spielen

1. Den **neuesten erfolgreichen** Lauf unter [Actions → Test and build Shadepi](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) öffnen.
2. Das Artefakt **ShadepiRPG-Windows** oder **ShadepiRPG-Linux** herunterladen und vollständig entpacken (für Actions-Artefakte kann eine GitHub-Anmeldung nötig sein).
3. Unter Windows `Shadepi-Echos-in-Neon.exe` bzw. unter Linux `Shadepi-Echos-in-Neon.x86_64` starten. Eine Godot-Installation ist dafür nicht erforderlich.

Im Spiel gibt es ein Startmenü mit Einzelspieler und Lokal-Koop, eine gemeinsame Kamera und getrennte Kapitel-Kontrollpunkte. Details zu Tastatur, Controllern, Kampf, Speicherständen und Kapiteln stehen in der [Spieleranleitung](Spiel-README.md).

**Arcade-Kampfabschnitte:** Ravens Jagd, Shadepis Rettungsweg, der Hinterhalt und die Aufzugwachen bieten mehrere Gegnerwellen mit gesperrten Ausgängen, kurzen Pausen und Abschnitts-Kontrollpunkten. [Ablauf, Umfang und Entwicklung](docs/arcade-wellen.md).

**Neue Kampfbewegungen:** Aufladbarer Katana-Schlag mit Energiewelle, Kick und Ravens aufgeladener Pistolenschuss. [Steuerung und animierte Vorschau](docs/kampfbewegungen.md).

**Ravens Terminal-Aufgaben:** Matrix-Hacks, Passwort-Decoder, Schaltungsnetz mit Active ICE, Wellen-Synchronisation und Jumper-Reparatur ersetzen einfache Zugriffe an acht Storypunkten. [Steuerung, Vorschau und Aufgaben](docs/ravens-terminals.md).

**Kartenkorrekturen:** Das Versteck hat passende Möbelproportionen; Bingo Street geht mit durchgehender Bodenkante in die Gasse über. [Vergleich im Spiel](docs/karten-proportionen.md).

Das Startmenü zeigt die detailliert gemalten HQ-Figuren Shadepi in Bereitschaftshaltung und Raven mit Tablet nach den aktuellen Figurenreferenzen vor einer Neonstadt mit weißem Drachen. Figuren und Dach bleiben fest verankert; die Maus verschiebt oder verformt sie nicht. Ravens Haarspitzen und Shadepis Umhangränder wehen sanft im Wind. Passende Größe, Tiefenstaffelung und Kontaktschatten verankern beide auf der vorderen Plattform. Regen, Flugverkehr, Wasserreflexe und Neonlicht beleben die Szene. Die Menüknöpfe reagieren auf Maus und Controller-Fokus. Dazu läuft die Musik des Finales am See. [Vorschau und technische Hinweise](docs/live-startmenue.md).

## Geschichte und Spielumfang

- **Kapitel 1:** Ravens Jagd auf Chrome Jackal, Shadepis Eingreifen und gemeinsamer Kampf.
- **Kapitel 2:** Industriegebiet, Ravens Versteck, Kühlsystem, Deep Dive und ICE-Abwehr.
- **Kapitel 3–5:** Pakt, Hinterhalt, Fahrzeugverfolgung, Hangar, Heiligtum und Erinnerungssequenzen.
- **Kapitel 6–7:** Anflug, Tower, Konfrontation mit Kenzō, Aufzugwachen, Flucht und Abschluss am See.

Die Spielwelt nutzt **16 gemalte Kulissen** aus `assets/world/painted/`. Wände und verdeckende Bildteile sind in `scripts/painted_world.gd` abgestimmt. Zerstörbare Objekte, die sechs zugeordneten Musikstücke, HQ-Sprites und die Original-Keyframes sind im Repository enthalten.

Die Musik wechselt passend zwischen Hauptmenü, Erkundung, normalen Kämpfen und Bosskämpfen. Die vollständige Zuordnung und Hinweise zum Austauschen der MP3-Dateien stehen unter [Musik austauschen](assets/music/README.md).

## Neu in v0.20.6 · 7. November 2026 · ClaudeHelper

- Releases mit Windows- und Linux-Paket lassen sich unter **Actions → Test and build Shadepi → Run workflow** mit einem Versions-Tag veröffentlichen.

## Neu in v0.20.5 · 7. November 2026 · ClaudeHelper

- **Pixelart-Menüs und Hack-Oberflächen:** Rahmen, Titelleisten, Buttons, Codezellen, Regler und sechs Ziel-Embleme (Rabe, Schakal, Weißer Drache, ARToS, Moriyama-Tower, See) im Pixelwright-Studio gezeichnet, 1:1 im 640×360-Raster. Gebürsteter Stahl mit Plattennähten und Nieten, Neonkanten, Status-LEDs; keine Vektorgrafik mehr.
- **Passend zur Szene:** Terminals übernehmen Farbe und Emblem des Zielsystems; das Pausenmenü wechselt mit Kapitel und Ort. Der Szenenhintergrund bleibt verpixelt und eingefärbt sichtbar.
- **Pixelschriften:** „Shadepi Pixel“ (aus Jersey 10, OFL) mit ergänzten Pixel-Pfeilen und -Symbolen, dazu Silkscreen für Titel und Codes.
- Fußleiste der Terminals ohne Überlappung; Garagen-Terminal heißt korrekt „Zugangscode des Ordens“. [Übersicht und Quellen](docs/pixel-ui.md).

![Pixel-Skins](docs/ui-pixel-skins.png)

## Neu in v0.20.4 · 7. November 2026 · CodexAI

- Verbindliche Grafikvorgabe in den Projektregeln gesichert: neue Grafiken als detailreiche HQ-Pixelart mit Materialtexturen, Tiefenwirkung und abgestimmter Pixeldichte. Keine einfachen Vektorgrafiken als Ersatz.
- Dokumentations- und Versionspflege; bestehende Grafiken und Spielmechaniken wurden dabei nicht verändert.

## v0.20.3 · 7. November 2026 · CodexAI

- HQ-Figuren-PNG im gemalten Spielstil: dieselben charakteristischen Merkmale, jetzt mit detaillierten Materialien, Regentropfen und Cyan-/Magenta-Kantenlicht.
- Hauptscreen rendert PNGs und Menüschrift in Fensterauflösung, auch in Full HD. Beim Spielen und Pausieren gilt wieder das ursprüngliche Spielraster.
- Mehrschichtiger Regen, Sprühnebel, animierte Wasserreflexe, Lichtstrahlen und sanftes Drachenlicht. Technische Menükonturen und Lichtakzente passen zum Nightwing-Design.
- Figuren und Füße bleiben fest verankert; keine Maus-Parallax. „Reduziert“ deaktiviert die zusätzlichen Shader, Wind und Menülichtanimation.
- [Full-HD-Vorschau und animierter Eindruck](docs/live-startmenue.md).
- Geprüft: 372 Gameplay-, 67 Terminal-/Integrations- und 154 Controller-Prüfungen ohne Fehler. Full-HD-Rendering, skalierter Mausklick, UI-Fokus sowie Haupt-/Pausenmenü im OpenGL-Renderer kontrolliert.

## v0.20.2 · 7. November 2026 · ClaudeHelper

- Gemeinsamen Stand von CodexAI (Menü, Nightwing-Hacks, Controller-Hilfe) und ClaudeHelper (Zwischensequenzen, Kampfgefühl, Verfolgungsjagd, Garageneinfahrt) gegengeprüft: alle acht Prüfreihen mit 1.188 Prüfungen fehlerfrei, Menü, Terminals, Zwischensequenzen, Kampf und Verfolgung zusätzlich gerendert und angesehen.
- Ältere Entwicklungsbranches (v0.13.1 bis v0.14.0) sind vollständig in `main` aufgegangen; es fehlt keine Arbeit.
- Kennzeichnungsregel für beide Bearbeiter in `AGENTS.md` ergänzt.

## v0.20.1 · 7. November 2026 · CodexAI

- GitHub-Entwicklungsstand `claudehelper/v0.20.0` übernommen: Kampfgefühl, Deep-Dive-Korrekturen, Apartmentmaßstab, Verfolgungsjagd und Garageneinfahrt.
- Menüverbesserungen und Controller-bedienbare Nightwing-Hacks mit den neueren Änderungen zusammengeführt.
- Vor Arbeitsbeginn werden sämtliche Remote-Branches geprüft, bevor der passende Stand übernommen wird.
- Zusammengeführten Stand mit allen acht automatisierten Prüfreihen kontrolliert: 1.188 Prüfungen, keine Fehler.

## v0.20.0 · 7. November 2026 · ClaudeHelper

- **Actionreichere Motorrad-Verfolgung:** freies Lenken und **Gas/Bremse (W/S)** – nach vorn fahren für Tempo und Abstand, zurückfallen für Hack und Granaten. Kampfdrohnen werfen Minen und lassen sich kapern und in den Verfolger steuern.
- **Straßenobjekte im Spielstil:** Betonbarrieren mit Warnlichtern, brennende Wracks, Ölspuren, Neon-Turbostreifen und Drohnenminen statt Holzkisten.
- **Einfahrt in die Garage:** Das Rolltor fährt hoch, das Motorrad rollt herein und **bleibt auf der Plattform stehen**; danach beginnt das Level. [Details](docs/verfolgungsjagd.md)

## v0.19.0 · 7. November 2026 · ClaudeHelper

- **Kampfgefühl:** Trefferstopp, Rückstoß und Zucken, Kamerastoß, gerichtete Funken, aufspringende Schadenszahlen, Kombozähler, K.O.-Animation, Ausfallschritt und Zielhilfe für Shadepi, Zielhilfe für Ravens Pistole, roter Blitz bei eigenen Treffern. [Details](docs/kampf-feedback.md)
- **Deep Dive:** ICE fliegt nicht mehr durch Wände, Schüsse rasten ein, ein Treffer knackt die Schale, der nächste löscht das ICE.
- **Ravens Apartment** im richtigen Maßstab: Das Bild wird nicht mehr auf 640 × 640 gestaucht, Möbel passen zu den Figuren. ![Apartment](docs/apartment-proportionen.png)
- **Kapitel 2:** Shadepi springt im Storyverlauf nicht mehr zum Eingang zurück.

## v0.18.3 · 7. November 2026 · CodexAI

- Ravens Hacks mit einheitlicher Nightwing-Ansicht, Cyan-/Gold-Akzenten und deutlich sichtbarer Auswahl überarbeitet.
- Controller: Steuerkreuz und linker Stick navigieren; A betätigt Felder und Knöpfe. Links/Rechts ändern Regler und Steckplätze, LB/RB erreichen alle verfügbaren Bedienelemente.
- Jede Aufgabe erklärt Ziel und nächste Schritte. Y / F1 öffnet ein pausierendes Handbuch; Start pausiert, B schließt Hilfe oder Terminal. Erfolgreiche Hacks werden weiterhin mit Übernehmen bestätigt.

- Prüfung: 154 Controller-, 67 Terminal-/Integrations- und 351 Gameplay-Prüfungen bestanden; Darstellung im Godot-Renderer geprüft.

## v0.18.2 · 7. November 2026 · CodexAI

- Menüfiguren proportional in die vordere Plattform eingepasst; Raven etwas zurückversetzt, beide Fußpaare mit Kontaktschatten innerhalb der Dachkante.
- Sanfter Wind an Ravens Haarspitzen und Shadepis freien Umhangrändern. Gesichter, Körper, Hände, Waffen und Füße bleiben ruhig; keine Mausverschiebung.
- „Reduziert“ schaltet den Figurenwind ab. Bestehende Figurenreferenzen und Menüillustration bleiben die Grundlage.
- 351 Gameplay-/Menüprüfungen bestanden; zwei gerenderte Windphasen bestätigen bewegte Haar-/Stoffenden bei pixelgleichen Gesichtern und Füßen.

## v0.18.1 · 7. November 2026 · CodexAI

- Menüfiguren nach den neuen Nutzerreferenzen: Shadepi in Bereitschaftshaltung mit segmentierter Maske und Raven mit Tablet.
- Mausverschiebung und Figurenverformung entfernt; Regen, Flugverkehr und Licht bleiben animiert.
- Hauptmenü spielt dieselbe Musik wie das See-Finale (`Level.mp3`). Tower und Story bleiben unverändert.
- 329 Gameplay-/Menüprüfungen bestanden; Darstellung im Godot-Renderer kontrolliert. Versionsangaben einschließlich Windows-Export und Spieleranleitung vereinheitlicht.

## v0.18.0 · 6. November 2026 · ClaudeHelper

- **Echte Zwischensequenzen statt Comic-Einblendungen:** Alle Storydialoge der Kapitel 1–7 laufen jetzt im Spiel – mit Kamerafahrten, laufenden Figuren, Kinobalken, Kapitel-Titelkarten und Untertiteln. Die unpassenden Comicbilder sind entfernt.
- **Texte nach der Romanfassung** „Shadepi im Schatten des Raben“ aus dem Archiv, inklusive der Enthüllung, dass Kenzō das Massaker am Orden mit Militechs Minotauren inszeniert hat.
- **Neu inszeniert u. a.:** Ravens Morgen, Shadepis Ankunft im Industriegebiet und die drei Schläge, Fragment und Deep Dive, der Schwur, der Pakt, der Hinterhalt, die Garage und der Abstieg ins Sanktuarium, der Landeanflug, das Penthouse nach dem Roman, Explosion und See.
- **Fehler behoben:** Kampfhinweise nur noch in Kampfphasen, Hinweise verschwinden beim Szenenwechsel, Zielmarker während Szenen ausgeblendet, Kapitel-1-Titel „Echos in Neon und Schatten“.
- **Archiv Teil 4:** Heiligtum-Dossier, Raven-Akte und Romanfassung als PDF und Text.

## v0.17.0 · 6. November 2026 · ClaudeHelper

- **Storyfix Kapitel 6:** Die Aufzugwachen kommen jetzt erst **nach** dem Kampf gegen Kenzō – sein Totmannschalter ruft sie ins Penthouse. Der Fluchttimer startet erst nach der letzten Welle. Alte Spielstände bleiben ladbar.
- **Gescriptete Zwischensequenzen im Spiel:** Kinobalken, Kamerafahrten, laufende Figuren, Untertitel und Überspringen mit Leertaste/B. Neu inszeniert: Jackals Auftritt, Shadepis Sprung vom Dach, Ravens Konfrontation mit Kenzō samt Shadepis Auftauchen aus dem Tarnfeld, Kenzōs Ende, das Ritual am See und das Finale.
- **Boss-Anzeige für Kenzō** mit Hinweis auf das Hackfenster am Schulterservo.
- **Lore-Korrektur:** „Orden des Weißen Drachen“ einheitlich geschrieben.

[Zwischensequenzen](docs/zwischensequenzen.md)

## v0.16.0 · 6. November 2026

- **Ravens Terminal-Minigames:** Fünf unterschiedliche Rätselmechaniken an acht Storypunkten, darunter Matrix-Hacking, Passwort-Decoder, Leitungsnetz mit ICE, Signalabgleich und Jumper-Reparatur.
- **Erweiterte Kämpfe:** Aufladbare Katana-Energiewelle, Kick und Ravens aufgeladener Pistolenschuss mit passenden HQ-Kampfposen.
- **Längere Arcade-Abschnitte:** Zusätzliche Gegnerwellen, Abschnittssperren und Kontrollpunkte bei Jagd, Rettungsweg, Hinterhalt und Aufzugwachen.
- **Interaktives Hauptmenü:** Neonstadt mit Parallax-Bewegung, Wind in Haaren und Schal, Regen und Reflexionen sowie Maus-/Controller-Fokus.
- **Levelkorrekturen:** Ravens Position an der Dachkante, maßstabsgerechtes Versteck und verbesserter Übergang von Bingo Street zur Gasse.
- **Prüfungen:** Neue automatisierte Tests für Terminal-Regeln, Kampfbewegungen und Arcade-Wellen im bestehenden GitHub-Build. Ein erfolgreicher Build von v0.16.0 ist noch nicht bestätigt.

[Terminal-Rätsel](docs/ravens-terminals.md) · [Kampfbewegungen](docs/kampfbewegungen.md) · [Arcade-Wellen](docs/arcade-wellen.md) · [Startmenü](docs/live-startmenue.md)

## Änderungen in v0.15.0

- Alle neun zerstörbaren Requisitentypen in gemaltem HQ-Stil, jeweils intakt, beschädigt und zerstört; auch die festen Demo-Requisiten nutzen die neuen Grafiken.
- HQ-Aerodyne, Motorrad mit beiden Figuren, Verfolgerwagen und Drohnen.
- Tower-Anflug: rechtes Triebwerk fällt aus, Rauch und Schräglage. Raven repariert es jetzt über das **Jumper-Wartungsdeck**; **J / X** öffnet das Deck nach Abbruch erneut. Danach **Q / RB** für die Gleiterkennung.
- Verfolgungsjagd mit träger Lenkung, Einschlagfunken, Mündungsfeuer, Granatenexplosionen, fliegenden Trümmern, Rückstoß und Verfolgerrauch.

[Grafiken, Ablauf und Testhinweise](docs/hq-welt-und-fahrzeuge.md).

## Godot-Projekt entwickeln

`project.godot` mit **Godot 4.7.2 Standard** öffnen, Ressourcenimport abwarten und mit **F5** starten (Compatibility-Renderer; kein C#).

| Bereich | Verzeichnis / Datei |
| --- | --- |
| Einstieg und Kapitel | `scenes/`, `scripts/chapter_one.gd`, `scripts/chapter_two.gd`, `scripts/campaign.gd` |
| Gemalte Level | `assets/world/painted/`, `scripts/painted_world.gd` |
| Requisiten und Sound | `assets/world/`, `assets/audio/`, `assets/music/`, `scripts/world_dressing.gd` |
| Charaktere und Gegner | `assets/sprites/heroes/`, `assets/sprites/npcs/` |
| Editierbare Originalposen | `tools/hero_sources/`, `tools/npc_sources/` |
| Animationen zusammensetzen | `tools/compile_heroes.py`, `tools/compile_npcs.py` |
| Eigene Charaktergrafiken | `assets/custom/` |
| Tests und Export | `tests/`, `.github/workflows/build.yml`, `export_presets.cfg` |

**Verstecktes Testmenü:** Im Hauptmenü **Strg+Umschalt+F10** drücken oder fünfmal auf den Menütitel klicken. Dort können alle Kapitel freigeschaltet, Unsterblichkeit, One-Hit-K.O., unendliche Energie und weitere Testhilfen aktiviert werden. Eine Test-Sitzung speichert in separaten Kontrollpunktdateien. [Anleitung zum Testmenü](docs/admin-testmodus.md).

Zum Bearbeiten von Figuren siehe [Figuren bearbeiten](docs/figuren-bearbeiten.md), [Helden-Sprites](docs/helden-sprites.md) und [NPC-Sprites](docs/npc-sprites.md). Weitere technische Hinweise: [Architektur](docs/architecture.md).

**Bereinigte Sprite-Struktur (v0.13.2):** Alle Szenen laden die HQ-Atlanten direkt aus `assets/sprites/heroes/` und `assets/sprites/npcs/`. Die alten Pixel-Zwischendateien sind entfernt. `scripts/sprite_assets.gd` bietet weiterhin eigene Grafiken unter `assets/custom/` an und unterstützt dabei auch ältere selbst erstellte Pixelraster. `npm run assets` erzeugt nur noch Licht und Basissounds – keine Figuren, Hintergründe oder App-Symbole.

## Qualitätssicherung und Builds

Der Workflow importiert die Assets, führt Gameplay-, Story- und NPC-Tests durch und exportiert Windows und Linux. Bei einem **Versionstag** wird zusätzlich ein Release mit Windows- und Projekt-ZIP erzeugt.

Lokale Testbefehle (aus dem Projektordner):

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/arcade_waves.gd
godot --headless --script res://tests/combat_moves.gd
godot --headless --script res://tests/npc_dive_visuals.gd
```

Für **v0.13.1** sind 501 automatisierte Prüfungen ohne Fehler dokumentiert. Für die direkte HQ-Einbindung von **v0.13.2** laufen dieselben Gameplay-, Story- und NPC-Tests im GitHub-Workflow; ein vollständiger manueller Spieldurchlauf wird dadurch nicht ersetzt. [Prüfbericht und Einschränkungen](docs/v0.13.1-fehlerpruefung.md). Der [GitHub-Build des Standes v0.13.1](https://github.com/Inrouder/ShadepiRPG/actions/runs/42095527700) wurde erfolgreich abgeschlossen.

## Hintergrund und Lizenzhinweise

Die Quellen wurden ursprünglich aus einer Windows-Fassung rekonstruiert und mit Original-Keyframes ergänzt. Die [Wiederherstellungsnotiz](docs/v0.12.0-wiederherstellung.md) erklärt Herkunft und Grenzen der Medien. Hinweise zu Godot-Lizenzen stehen in `docs/GODOT-LICENSE.txt` und `docs/GODOT-COPYRIGHT.txt`.
