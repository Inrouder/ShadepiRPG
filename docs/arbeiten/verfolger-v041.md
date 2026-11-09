# Verfolger und Frachtdrohne · v0.41.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

- **Auftrag:** Nächsten autorisierten Cinema-Roadmap-Block umsetzen: Verfolgerwagen mit Lenk-, Federungs-/Ramm- und Geschützrückstoßbildern; Frachtdrohne mit vier echten Rotorphasen.
- **Basis:** `0df587a`, v0.40.0, sauber und identisch mit `origin/main`. Alle Remote-Branches samt Versionen und tatsächlichen unveränderten Änderungen verglichen; übrige Entwicklungsstände weiterhin bis v0.21.3. Keine fremde neue Arbeit zu übernehmen.
- **Gesichtete Quellen:** aktive HQ-Fahrzeugquelle `assets/world/hq/vehicles.png`, Autobahnkulisse, neue Motorrad-/Aerodyne-Spieltafel, Art Direction, Konsistenzvorlage und Fahrzeugkarte. Wagen behält vier Räder, dunkle Panzerung, Cyan-Scheibe, Dachgeschütz und rote Rücklichter. Drohne behält orangen Frachtkörper und vier Rotor-Ringe. Keine neue Fahrzeugidentität oder Lore.
- **Grafikbriefing:** tatsächliche Reifen-/Rumpf-/Mündungsanker pro Wagenbild, feste Rotorzentren je Drohnenphase; hochwertige transparente Pixelquellen mit realer Materialtiefe. Keine eingebrannten Mündungsblitze oder Schatten. Tatsächliches Quellraster messen und in normaler Spielgröße abnehmen.
- **Umfang:** Schuss-FX folgen der sichtbaren Geschützmündung, Minenabwurf dem Frachtkörper; Schaden, Schusstempo, Feuerintervalle, Zielmuster und Hackregeln bleiben erhalten; Schussursprung und sichtbarer Fächerweg werden passend zur Mündung korrigiert. Gehackte Drohne darf weiterhin als Ganzes trudeln, der Rotorlauf wird davon unabhängig geführt. Bestehende Motorrad-/Aerodyne- und Storyszenen erhalten.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Aktive Quellen / Herkunft | Zwei direkt generierte HQ-Pixelquellen unverändert übernommen. Tatsächliche Raster statt nomineller Generatorausgabe verwendet: 1254×1254 jeweils, Wagenzelle 418, Drohnenzelle 627. Keine neue Fahrzeugidentität, keine programmgesteuerte Bemalung oder Freistellung. [Quellenvertrag](../../assets/vehicles/pursuit/README.md) |
| Material, Alpha und Größe | Dunkle Metallpanzerung, Scheibe, Rücklichter und Dachgeschütz sowie oranger Frachtkörper mit vier Ringen bleiben erhalten. Echte Alpha-Ränder und vollständige Fahrzeuge geprüft; sichtbarer Wagen ungefähr 47×82 statt des früheren kürzeren 44×64. Vergleich in Spielgröße und tatsächlicher Verfolgung gesichtet. [Techniktafel](../previews/verfolger-posen-v041.png) |
| Kontakte und Verdeckung | Rumpf-/Mündungsregistrierung pro Wagenpose. Gerade und zurückgezogene Geschützmündung zusätzlich als markierte Nahansicht geprüft: [beide Kontaktpunkte ×4](../previews/verfolger-muendung-v041.png). Vier feste Rotorzentren und Frachtabwurfkontakt in allen Quellphasen auf dem tatsächlichen Körper geprüft. Keine eingebrannten Schüsse oder falsche Matte. |
| Handlung und Fahrzeugzustände | Lauf-/Lenkgeschwindigkeit, Road-Uhr, Rammwarnung und Schusstimer wählen die neuen Bilder. Rückstoß: eingezogen → Rücklauf → Normalphase. Gewolltes Trudeln der gehackten Drohne getrennt vom Rotorlauf. Luftfrachter verwenden dieselbe Quelle; bewaffnete Tower-Sentries bleiben eigene Objekte. |
| Schüsse und Abwurf | Beide Geschosse des beschädigten Wagens entstehen am zurückgezogenen Lauf. Der zweite fächert auf den bisherigen 16-Pixel-Zielabstand; Schadenswert, vertikales Tempo und Intervalle bleiben gleich. Bewegungsmetadaten werden mit Geschossen entfernt. Vorhandenes Pixel-Mündungsfeuer ersetzt den runden Verfolger-Blitz und bleibt an der bewegten Mündung; Minen und Abwurfimpuls am Frachtkontakt. |
| Native Abläufe | Letzte Aufnahme **154 tatsächliche Renderer-Frames**, 22,3 Sekunden reale Aufnahmeabstände; alle neun Wagen- und alle vier Rotorbilder erreicht. Schuss, Rammstoß, Hover, Abwurf und Hack als sechs markierte Ansichten geprüft. [Film und Spielbilder](../verfolger-animationen.md). QA-Schutz und erhaltene Verfolgerpanzerung, Hack nach gezielter Positionierung; kein behaupteter vollständiger Kampfsieg. |
| Controller / Pause / Qualität | Rohes RB-Ereignis löst Ravens Drohnenhack über die tatsächliche Fahrzeugverarbeitung aus. Pause hält Rückstoß und Rotoruhr an; keine neuen Tasten. Vorhandene Bildstil-/Partikelgrenzen unverändert, Kernanimation bleibt bei allen Qualitätsstufen sichtbar. |
| Laden und Kapitelwechsel | Neuer Fahrknoten startet ohne altes Rückstoßbild oder alte Geschoss-/Driftdaten. Kapitelwechsel entfernt die Fahrzeuginstanz bei erhaltenen Weltfiguren. Keine neuen dauerhaften Save-Felder nötig; neue Tests/Galerie nutzen isolierte Admin-Teststände. |
| Automatisierte Prüfungen | **799 Fälle, 0 Fehler:** neue Verfolger-/Rotorprüfung 55, Fahraktion 60, Aerodyne-Flug 50, bisherige Fahrzeugbewegung 45, Hauptsuite 383 und Storyaudit 206. Neue Reihe im GitHub-Build. Keine Doppelzählung gezielter Wiederholungen. |
| Exportierte Ressourcen | Linux-PCK `/tmp/shadepi-v0.41.0.pck` erstellt und mit tatsächlichem Renderer gestartet. **Neun zusätzliche Fälle, 0 Fehler:** beide Quellen, gemeinsame Schussmündung, bestehender Pixelblitz, sichtbarer Fächerweg, Frachtabwurf, Pause, Laden, Luftfrachtquelle und Kapitelbereinigung. Schuss-/Luftfrachtansicht aus dem Paket gesichtet. |
| Version und Sicherung | Projekt/aktuelle READMEs 0.41.0, Windows-Datei-/Produktfelder 0.41.0.0; neue Hinweise, Quellen und Commit-Titel CodexAI. Alle Remote-Branches vor Abschluss erneut abgerufen, `origin/main` weiterhin `0df587a`, übrige unverändert. Sicherungsziel `origin/main`; keine Cloud-Veröffentlichung oder Release-Markierung. |

Reproduzierbare Projektprüfungen:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/pursuit_art.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/aerodyne_flight.gd
godot --headless --script res://tests/vehicle_motion.gd
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --audio-driver Dummy --script res://tools/pursuit_pose_gallery.gd
godot --audio-driver Dummy --script res://tools/pursuit_gallery.gd
godot --headless --export-pack Linux /tmp/shadepi-v0.41.0.pck
```

**Grenzen:** Dummy-Audio, keine neue akustische Qualitätsprüfung und kein nativer Windows-Programmstart. Kein erneut vollständig manuell gespielter Durchlauf aller sieben Kapitel. Ursprünge/Fächerweg sind visuell korrigiert; die Projektilverfolgung bleibt das vorhandene vereinfachte Fahrkampfsystem. Neue Aerodyne-Fahrwerks-/Unterseiten-/Cockpit-Zwischenbilder und technische Props sind weitere Roadmap-Blöcke.

**Ergebnis:** Zweiter Fahrzeugblock abgeschlossen, in normaler Spielgröße und exportiertem Paket geprüft, mit Quellen-/Kontaktregeln dokumentiert und zur Git-Sicherung fertig.
