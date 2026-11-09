# Konsistenzauftrag · v0.36.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

- **Nutzerziel:** Epischer Landeanflug zum See und sichtbares Aussteigen; romantischer Moment, kurzer Drachenschatten über dem Wasser und mystisches Leuchten. Raven nimmt Shadepis Maske ab und küsst ihn; ihre Hand verdeckt sein Gesicht, das zu keinem Zeitpunkt vollständig erkennbar sein darf.
- **Ausgang:** `8b7e1e4`, v0.35.1, sauber und identisch mit GitHub `main`; alle Remote-Branches abgerufen, andere Entwicklungsbranches unverändert bis v0.21.3. Keine fremde Arbeit zu übernehmen.
- **Geltende Quellen:** Aktuelle Konsistenzregeln/Stilbibel, tatsächlich gesichtete Raven-/Shadepi-Bildkarten, aktive HQ-Helden, `lakeside.png`, bestehender Aerodyne-/Düsenrenderer und Originalroman Kapitel 7. Der nicht hochgeladene Comic ist keine gesichtete Quelle; maßgeblich ist die konkrete Nutzerbeschreibung der Handverdeckung.
- **Erhalten:** Raven 160 cm, schwarze Haare mit blauen Spitzen, rote Augen, goldenes Septum, schwarzer Cyan-Anzug mit roten Schulterzeichen; Shadepis Kasa, segmentierte Maske, Schal, Weste und dunkle Stoffbahnen. Keine neue bestätigte Gesichtsgestaltung. Aufnahme in den Orden und freiwillige Entscheidung bleiben vor dem Maskenmoment erhalten.
- **Umfang:** Anflug und Landung auf trockenem freiem Uferboden, Aussteigen mit vorhandenen Laufsprites; eigene HQ-Kontaktposen für Hände/Maskenabnahme/Kuss/Umarmung. Neue separat freigestellte Drachenquelle nach dem vorhandenen Menümotiv als kurz sichtbarer Schatten, auf die Wasserfläche beschränkt; ortsgebundenes Leuchten. Keine Vektor-Ersatzfiguren, kein Porträt, keine Comicseite als Spielszenenersatz.
- **Technik und Abnahme:** Spielgröße und Fuß-/Handkontakt neben normalen Sprites vergleichen. Szenenuhr für FX; Pause, Ton/Bildstil, Skip, Laden und Abbruch prüfen. Neue Ressourcen im Export prüfen. Version/README/CHANGELOG mit v0.36.0 · CodexAI aktualisieren und nach Fertigprüfung auf GitHub sichern.

## Quellen und Grafikbriefing

| Zweck | Tatsächlich gesichtete Quelle | Übernommene Merkmale |
| --- | --- | --- |
| Figuren | `docs/stilbibel/bilder/figur-shadepi.png`, `figur-raven.png`, aktive Heldenatlanten | Kasa-Breite, Maske, dunkle Weste/Stoffbahnen; Ravens Cyan-Konturen, schwarze/blaue Haare und rote Schulterzeichen |
| Story | Originalroman Kapitel 7 und neues [Archivbriefing](../universum/teil-7/README.md) | Aufnahme vor dem Kuss; Ravens Hand verdeckt das Gesicht gemäß neuer Vorgabe |
| Kulisse | Aktives `lakeside.png` und `painted_world.gd` | Mondlicht, texturierte Uferfläche, echte Wasserkontur |
| Fahrzeug | `cinematic_aerodyne.gd`, `cinematic_motion.gd` | HQ-Schiff und gemeinsame Düsenprojektion; stetige Annäherung, Abbremsen, Aufsetzen |
| Drache | Weißer Drache im aktiven `assets/menu/start-city.png` | Östliche Drachensilhouette; neue transparente Quelle erforderlich, da nur ins Menübild eingebacken vorhanden |

Die Kontaktposen durchlaufen Händehalten → Maskenabnahme → Kuss → maskierte Umarmung. Aktiver Atlas: 1536×1024, vier Zellen à 768×512, echte Transparenz. Fußanker `(300,488)`, Maßstab `0.125`; daraus etwa 59 Weltpixel für Shadepi und 54 für Raven in der geneigten Kontaktpose. Lineare Abtastung entspricht den normalen HQ-Helden. Hände, Hut und abgewandter Kopf verdecken die Gesichtszüge in beiden maskenlosen Zellen; keine zusätzliche unmaskierte Kopfquelle. Eigene Bodenschatten ersetzen die ausgeblendeten normalen Figurenschatten. Eine erste Studie wurde vor Einbau wegen zu schmalem Kasa und zu kleiner Raven überarbeitet. Der aktive Atlas wurde neben den normalen Figuren geprüft.

## Umsetzung und Abnahme

**Sichtprüfung: CodexAI, 9. November 2026, Godot 4.7.2 mit tatsächlichem OpenGL-Renderer.** Die Aufnahmen zeigen die aktive Spielszene, keine Zeichnung als Ersatz für einen Rendernachweis.

| Prüffeld | Tatsächliches Ergebnis | Nachweis |
| --- | --- | --- |
| Spielgröße, Material und Alpha | Neue Quelle neben beiden normalen Helden bei gleicher Kamera verglichen; dunkle Rüstung, breiter Kasa, Ravens Kostüm und vollständige Haare erhalten. Vier Zellränder transparent, Körperdeckkraft vorhanden. | `lake_gallery.gd`, Atlas und normale Nachbarsprites im Renderer gesichtet |
| Landung und Fußkontakt | Parkpunkt `(225,430)`, gesamte Standfläche trocken. Kabinenausstieg rechts neben den hinteren Triebwerken; beide vollständig sichtbar, kein Weg durch die Düsen. | [Anflug](../previews/see-anflug-v036.png), [Aussteigen](../previews/see-ausstieg-v036.png) |
| Gesicht und Kontakt | Maskenabnahme und Kuss im Spiel einzeln gesichtet; die Gesichtszüge bleiben hinter Hand, Kasa und Kopfwendung verborgen. Schlussumarmung wieder mit Maske. | [Maskenmoment](../previews/see-maske-v036.png), [Kuss](../previews/see-kuss-v036.png) |
| Vollständiger Ablauf und FX | Anflug, Landung, Aussteigen, Ufergang, vier Ritualschritte und Finale durchlaufen. 505 echte Filmframes; Ankunft und Finale als getrennte durchgehende Clips, ohne die QA-Positionswechsel zwischen Ritualpunkten. Schatten über Wasser, danach wieder verschwunden. | [Inszenierung und beide Filme](../see-finale.md) |
| Controller / Tastatur | Vorhandene E/Enter/A-Dialogbedienung; neuer Test mit rohem Controller-B überspringt die Ankunft. Vier Ritualpunkte weiterhin in bisheriger Reihenfolge. | `tests/lake_sequence.gd`, bestehende Eingabeprüfungen |
| Pause, Bildstil, Ton | Menü hält Szenenuhr und Lichtanstieg an; reduzierter Bildstil dämpft das Leuchten. Vorhandene Musikzuordnung und stummgeschalteter Tonpfad erhalten. Native Sichtprüfung mit Dummy-Audio, keine akustische Qualitätsabnahme behauptet. | Szenentests und Renderer; Musikressourcen unverändert |
| Laden, Skip und Abbruch | Unterbrochene Szenen starten erneut; abgeschlossene nicht. Legacy-Endstand erhält Finale einmal. Kapitelwechsel entfernt Seeobjekte und setzt Sichtbarkeit, Deckkraft und Tiefenreihenfolge zurück. | 32 neue Szenenprüfungen |
| Gezielte Regressionen | 920 Prüfungen, 0 Fehler: See 32, Hauptsuite 383, Story 206, Atmosphäre 134, Tower 42, Inszenierung 50, Anzeige 73. | Alle sieben Skripte mit `godot --headless --script res://tests/<name>.gd`; neue Seeprüfung im GitHub-Build |
| Exportierte Ressourcen | Linux-PCK exportiert und mit tatsächlichem Renderer gestartet; acht zusätzliche Prüfungen, 0 Fehler. Ankunft, Skip, Ufer-Kontrollpunkt, Finale, beide importierten Quellen, Kontakt-/Wassershader und Kapitelwechsel geprüft. Kuss aus dem Paket gerendert und gesichtet. | `godot --headless --export-pack Linux …`; `godot --main-pack … --script …` in isoliertem Benutzerdatenverzeichnis |
| Version und Änderungsinfo | `project.godot`, beide Windows-Felder, beide READMEs und CHANGELOG stimmen auf v0.36.0 überein; neue Hinweise ausdrücklich CodexAI. | Versionsvergleich, `git diff --check`, lokale Dokumentationslinks |

**Ergebnis:** Umsetzung und gezielte Abnahme abgeschlossen. Der gemeinsame Git-Commit umfasst Quellcode, aktive PNG-/Importressourcen, Prüfszenen, Versionshinweise, Archiv und echte Spielaufnahmen; Sicherungsziel ist `origin/main`. Keine Veröffentlichung der Cloud-Umgebung oder Release-Tags.

**Grenzen:** Der Comic liegt nicht vor; die konkrete neue Nutzerbeschreibung ist maßgeblich. Windows-Programmdatei und Audio wurden hier nicht nativ geprüft. Kein neuer Name oder Kanon zur Identität des Drachen.
