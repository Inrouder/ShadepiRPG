# Garage, Plattformfahrt und Hangar · v0.39.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

- **Ziel:** Zweiten Block der autorisierten Cinema-Roadmap umsetzen: körperliche Werkbankbetätigung, echte Entriegelungsbilder, sichtbare gemeinsame Abfahrt mit Motorrad, Andocken und Hangar-/Aerodyne-Enthüllung vor Ravens Reaktion. Danach weiterhin spielbare Reparatur; Shadepi geht zur Eindämmung voraus.
- **Ausgang:** `ced9544`, v0.38.0, sauber und gleich `origin/main`; alle Remote-Branches abgerufen und Versionen/Änderungen verglichen, übrige Entwicklungsbranches unverändert bis v0.21.3. Keine neuere fremde Arbeit offen.
- **Version:** v0.39.0 · CodexAI; Exportfelder 0.39.0.0. Fertigen Block nach Sicht-/Funktionsprüfung auf GitHub sichern; keine Cloud-Veröffentlichung.
- **Tatsächlich gesichtet:** Garage, ursprünglicher und freier Hangar, normale Figurenkarten, aktiver animierter Aerodyne, Art Direction, Konsistenzvorlage und Roman Kapitel 4. Neuere Nutzerfestlegung zum Kompensator alle sechs Tage hat Vorrang vor der älteren Roman-Ausführungsvariante.
- **Neue Quellen:** HQ-Pixelplattform mit sechs mechanischen Bildern, texturierter Schacht und vier Shadepi-Betätigungsbilder; direkte Generierung mit aktiven Figuren-/Raumreferenzen. Keine neuen Figurenmerkmale, keine unmaskierte Ansicht. Kamera, Maßstab und Bodenanker werden im tatsächlichen Renderer abgeglichen.
- **Erhalten:** Ravens Merkmale/160 cm, Shadepis Maske/Kasa/Weste; vorhandene Figuren während der Fahrt, derselbe Aerodyne wie in Flug und Abflug. Reparatur-/Kennungsrätsel, Kapitelreihenfolge und die anschließende Heiligtum-Handlung bleiben bestehen.

## Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2, tatsächlicher OpenGL-Renderer.**

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Quellen und Merkmale | Drei unverändert übernommene HQ-Pixel-PNGs mit echten Materialtexturen. Shadepis vier neue Schalterphasen behalten geschlossene Maske, Kasa, Schal, Weste und Stoffbahnen. Fahrt verwendet die normalen tatsächlichen Figuren und das vorhandene Motorrad. [Aktive Quellen](../../assets/story/hangar-discovery/README.md) |
| Spielgröße, Alpha und Kontakt | Sechs deckungsgleiche Plattformzellen mit echtem Alpha; gemeinsamer Crop erhält komplette Verriegelungskanten. Schalter-Fußanker `(380,488)` bei Maßstab 0,125. Gemessener sichtbarer Druckfinger `(531,88)` trifft das Werkbanksymbol bei `(738.875,246)`; tatsächliche Nähe im Renderer geprüft. Keine doppelte stehende Figur oder alter Lichtschatten hinter der Ersatzpose. |
| Plattform und Andocken | Beide tatsächlichen Figuren und Motorrad stehen innen; Verriegelungen bewegen sich in sechs gezeichneten Bildern. Die Wand fährt relativ zum Boden nach oben. Ein in der Prüfung gefundener Dock-Bildsprung durch unterschiedliche Raum-/Kamerabegrenzungen ist behoben: echte Garagenprojektion beim Weltkoordinatenwechsel erhalten, weiche Kamerafahrt während der Hallenöffnung. Fußposition beim Andocken numerisch geprüft. [Andockbild](../previews/hangar-andocken-v039.png). |
| Hallenmotiv und Spielwelt | Erst Hallentotale und Fahrzeug, dann Ravens Reaktion. Leere vorhandene Halle plus geschlossener Dachteil, KOBAN-TEC zuletzt. Identischer separater Aerodyne-Atlas wie in Flug/Flucht/See; vor Reparatur abgeschaltet. Kisten/Fässer versetzt, ihre IDs und gespeicherten Zustände erhalten. Plattform/Motorrad bleiben auch bei normaler Erkundung sichtbar und kollidieren passend. |
| Laufwege und Handlung | Alle drei gemeinsamen Ausstiegsabschnitte und Shadepis Abgang gegen feste Wände, Motorrad und alle Prop-Standflächen geprüft. Raven übernimmt danach die Steuerung. Kompensator alle sechs Tage und Reparatur/Kennung erhalten; zugänglicher Aerodyne-Betrachtungspunkt unterhalb des Rumpfs. |
| Tatsächlicher sichtbarer Ablauf | Letzte Aufnahme: **256 echte Renderer-Frames**, 13 markierte Ansichten, zusammenhängender 36,7-Sekunden-Ablauf vom Decoder-Erfolg bis zur normalen Hangarsteuerung. Film aus tatsächlichen Aufnahmezeiten, keine feste Abspielfrequenz erzwungen. [Bilder und Film](../hangar-entdeckung.md) |
| Bedienung, Pause, Skip | E/Enter/A weiter, Leertaste/B überspringen, Esc/Start Pause. Rohes Controller-B geprüft. Pause hält Abfahrt und Mechanismusuhr an; keine neue Tastenbelegung. Die bestehenden Atmosphärenprofile bleiben erhalten. |
| Laden, Abbruch und Altstände | Laufende Entdeckung startet nach Laden sicher erneut; abgeschlossene nicht. Direkte frische Hangareinstiege erhalten nur die Enthüllung. Alte Hangarstände ohne Feld erhalten keine erfundene laufende Szene. Vor Entfernen der Filmansicht werden die tatsächlichen Figuren zurück in `world.actors` gehängt; Kapitelwechsel während der Fahrt cancelt späte Aktionen. |
| Automatisierte Prüfungen | **841 Fälle, 0 Fehler:** neue Hangarprüfung 38, Hauptsuite 383, Storyaudit 206, Cinematic-Blocking 50, Ortsatmosphäre 134, Aerodyne-Bilder 30. Neue Hangarprüfung in GitHub-CI ergänzt. Keine doppelte Zählung wiederholter Durchläufe. |
| Exportierte Ressourcen | Linux-PCK `/tmp/shadepi-v0.39.0.pck` erstellt und im tatsächlichen Renderer gestartet. **Zehn zusätzliche Fälle, 0 Fehler:** Quellen, echter Decoder-Callback, Speichern/Laden, Skip, Figurenbesitz, gemeinsamer Rumpf, geschlossenes Raumkomposit, abgeschlossener Ladepunkt und normaler Reparaturzugang. Raumgesamtansicht und spielbarer Zustand aus dem Paket gesichtet. |
| Version und Sicherung | Projekt/READMEs 0.39.0, Windows-Datei-/Produktfelder 0.39.0.0, CHANGELOG und neue Hinweise mit CodexAI. Vor Commit alle Remote-Branches erneut abgerufen: `origin/main` weiterhin `ced9544`, keine konkurrierende neue Arbeit. Sicherungsziel `origin/main`; keine Cloud-Veröffentlichung oder Release-Markierung. |

Reproduzierbare Projektprüfungen:

```sh
godot --headless --editor --import --quit
godot --headless --script res://tests/hangar_discovery.gd
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/cinematic_blocking.gd
godot --headless --script res://tests/scene_atmosphere.gd
godot --headless --script res://tests/aerodyne_art.gd
godot --audio-driver Dummy --script res://tools/hangar_discovery_gallery.gd
godot --headless --export-pack Linux /tmp/shadepi-v0.39.0.pck
```

**Grenzen:** Galerie startet am regulären Decoder-Callback, nachdem ein QA-Helfer das Rätsel gelöst hat. Innerhalb der anschließenden Aufnahme werden die tatsächlichen Laufwege und Szenen gespielt. Kein erneut vollständiger Durchlauf aller sieben Kapitel, keine neue akustische Qualitätsprüfung (Dummy-Audio), kein nativer Windows-Programmstart. Vier Schalterbilder und sechs Verriegelungsphasen sind kein vollständiger Fahrzeug-Richtungsatlas. Echte Kurven-/Rollansichten, Motorradphasen und weitere technische Props bleiben die folgenden Cinema-Blöcke.

**Ergebnis:** Zweiter Cinema-Block vollständig umgesetzt, im Spiel und exportierten Paket gesichtet und zur Git-Sicherung fertig.
