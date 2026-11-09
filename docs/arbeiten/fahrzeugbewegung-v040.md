# Fahrzeugbewegung · v0.40.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

- **Auftrag:** Nächsten Fahrzeugblock der autorisierten Cinema-Roadmap umsetzen: echte Kurvenansichten des Aerodyne, eigene Schräglagen und Brems-/Federungsposen des Motorrads. Vorhandene mechanische Kabinenbilder und Spielregeln erhalten.
- **Basis:** `557f731`, v0.39.0, sauber und identisch mit `origin/main`. Alle Remote-Branches abgerufen, Versionen und tatsächliche unveränderte Entwicklungsstände bis v0.21.3 verglichen; keine neuere fremde Arbeit.
- **Referenzen tatsächlich gesichtet:** aktueller Aerodyne-Atlas, HQ-Fahrzeugatlas (Motorrad/Verfolger/Frachtdrohne), Raven-/Shadepi-Karten, Art Direction, Konsistenzregeln und Fahrzeug-/Objektkarte. Keine Comicquelle behauptet. Motorrad behält Shadepi vorne und Raven hinten; Merkmale, Kostüm und Raven 160 cm erhalten.
- **Umfang:** Neue HQ-Pixelquellen für Kurvenlage und Fahrwerks-/Körperbewegung; gemeinsame feste Rumpf-/Rad-/Sitzanker. Neue Posen müssen bei normaler Spielgröße gegen vorhandene Quellen geprüft werden. Steuerung und Kollisionsregeln unverändert, FX-Ursprünge passend zur Ansicht.
- **Nicht Teil dieses Blocks:** neue Story, Ersatz der See-Kontaktposen, andere Figurenkostüme oder pauschale Neuerstellung aller Fahrzeuge/Props. Verfolger-/Drohnenphasen und weitere Cinema-Szenen bleiben als nächste Schritte beschrieben.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Quellen und Herkunft | Zwei aktive, unverändert kopierte HQ-Pixel-PNGs. Aerodyne-Erstquelle hatte eine weiße/transluzente Matte und wurde gezielt per Bildwerkzeug korrigiert; keine programmgesteuerte Freistellung. Motorrad direkt aus aktuellem HQ-Fahrzeugatlas und beiden Figurenkarten generiert. Keine andere Maske, generischen Fahrer oder neuen Kostüme. |
| Tatsächliches Raster / Silhouette | Aerodyne 1536×1024, sechs 512er-Zellen. Motorrad tatsächlich 1254×1254 mit 418er-Zellen statt des angefragten größeren Rasters; keine unnötige Hochskalierung. Sechs Bank-Zellen haben transparente Ecken und vollständig erhaltene Ränder. Acht aktive Motorradposen, neunte Schuss-Entwurfszelle nicht aktiv. [Quellenverträge](../../assets/vehicles/motorcycle/README.md) |
| Spielgröße und Material | Normale Verfolgung/Flug und zusätzliche Renderer-Tafel verglichen. Motorrad 78/418 mit ungefähr dem vorherigen sichtbaren Radstand; Kasa, Haare, rote Maschine und Cyan-Detaillierung bleiben lesbar. Keine glatten Vektorgrafiken. [Vergleich und Film](../fahrzeugbewegung.md) |
| Feste Kontakte / FX | `REAR` hält den tatsächlichen hinteren Reifenkontakt in jeder verwendeten Pose fest. Pro Bild zwei Auspuffkontakte. `BANK_ANCHORS`/`BANK_NOZZLES` registrieren Cockpit und Motoren; alle zwölf Düsenzentren auf opakem Quellrumpf geprüft. Triebwerksrauch folgt ebenfalls der neuen Düse. Kabinenöffnung setzt Rumpf und FX sofort zur geraden Quelle zurück. |
| Phasen statt Geisterbilder | Frühe Mischdarstellung verschiedener Silhouetten wirkte durchsichtig; verworfen. Aktive Umsetzung zeigt klare Pixelphasen für gerade/leicht/stark, Bremse und Federung. Die vorhandenen mechanischen Triebwerksbilder laufen bei geradem Flug weiterhin. |
| Kamera und Storykontinuität | Banklage separat vom bisherigen Heading. Bestehende Wege, Landeplatzstart, Fall am Balkon vorbei, Abfangen und See-Landung erhalten. Beide Figuren bleiben in den bisherigen Ein-/Ausstiegsreihenfolgen; Kuss-/Maskenhände nicht geändert. Keine neuen Storyzeilen. |
| Native Spielansichten | **130 Motorrad- und 128 Flugframes** mit echten Aufnahmeabständen zu Filmen kodiert. Tatsächliche See-Ankunft bis `parked` durchlaufen, eigene Bankphase gesichtet. Tower-Flucht separat vollständig bis See durchlaufen: **125 echte Renderer-Frames**, Abfangen/Explosion im Bild geprüft. Galerie verwendet Schutz-/QA-Einstellungen, keinen behaupteten vollständigen Kampfsieg. |
| Controller / Pause / Laden | Rohes Stick-X links/rechts und Stick-Y bremsen steuern die tatsächliche Fahrintegration und passenden Bilder. Menüpause friert Motorrad-/Fluguhr und Bankzustand ein. Laden baut eine gerade Ausgangspose auf; Kapitelwechsel entfernt den Bank-Rig bei erhaltenen normalen Figuren. Vorhandene B-/Tastaturbelegung unverändert. Neue Prüf-/Galerieskripte nutzen isolierte Admin-Teststände. |
| Automatisierte Prüfungen | **856 Fälle, 0 Fehler:** neue Fahrzeugbewegung 45, Fahraktion 60, Aerodyne-Flug 50, mechanische Aerodyne-Bilder 30, Cinematic-Blocking 50, See-Sequenz 32, Hauptsuite 383, Storyaudit 206. Nach Kontakt-/Rauchkorrekturen betroffene Reihen gezielt wiederholt, ohne Doppelzählung. Neue Fahrzeugprüfung in GitHub-CI. |
| Exportierte Ressourcen | Linux-PCK `/tmp/shadepi-v0.40.0.pck` erstellt und mit tatsächlichem Renderer gestartet. **Zehn zusätzliche Fälle, 0 Fehler:** importierte Quellen, Motorradkurve/Bremse, Flugkurve/Düsen, Laden, filmischer Rig, offene Kabine, sofortige Rückstellung ihrer FX-Anker und Kapitelbereinigung. Motorrad-/Flugbilder direkt aus dem Paket gesichtet. |
| Version / Sicherung | Projekt/READMEs 0.40.0, Windows-Datei-/Produktfelder 0.40.0.0; neue Änderungsinfos und Referenzen CodexAI. Alle Remote-Branches vor Abschluss erneut abgerufen: `origin/main` weiterhin `557f731`, übrige Branches unverändert. Sicherungsziel `origin/main`; keine Cloud-Veröffentlichung oder Release-Markierung. |

Reproduzierbare Projektprüfungen:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/vehicle_motion.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/aerodyne_flight.gd
godot --headless --script res://tests/aerodyne_art.gd
godot --headless --script res://tests/cinematic_blocking.gd
godot --headless --script res://tests/lake_sequence.gd
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --audio-driver Dummy --script res://tools/vehicle_pose_gallery.gd
godot --audio-driver Dummy --script res://tools/vehicle_motion_gallery.gd
godot --audio-driver Dummy --script res://tools/tower_departure_film.gd
godot --headless --export-pack Linux /tmp/shadepi-v0.40.0.pck
```

**Grenzen:** Native Aufnahmen mit Dummy-Audio; keine neue akustische Qualitätsprüfung oder nativer Windows-Programmstart. Kein erneut vollständig manuell gespielter Durchlauf aller sieben Kapitel. Die Ausweichrolle verwendet neue Bankbilder plus geringe perspektivische Kompression; ein vollständiger 360°-Unterseitenzyklus fehlt weiterhin. Der zusätzliche Motorrad-Schussentwurf ist kein fertiger Schusszyklus und bleibt unbenutzt. Verfolger-/Drohnenbilder, zusätzliches Fahrwerk und Cockpit-Zwischenphasen sind nächste eigenständige Roadmap-Blöcke.

**Ergebnis:** Erster Fahrzeugbewegungsblock abgeschlossen, im tatsächlichen Renderer und exportierten Paket geprüft, dokumentiert und zur Git-Sicherung fertig.
