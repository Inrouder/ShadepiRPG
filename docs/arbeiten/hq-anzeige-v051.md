# Konsistenzauftrag und Arbeitsnachweis: HQ bis Full HD

**v0.51.0 · CodexAI · 10. November 2026.** [Bilder, Film und Bedienung](../hq-anzeige-v051.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** 1920×1080 nativ ermöglichen, einen HQ-Anzeigemodus einbauen und Ausgaben oberhalb Full HD nur vergrößern. Bilder bei Bedarf skalieren.
- **Ausgang:** `93ede9c`, v0.50.2, Arbeitsbaum sauber. Alle Remote-Branches abgerufen und verglichen; main aktuell, keine neueren Entwicklungsstände. Fremde Spiel-/Tower-/See-/ICE-Änderungen erhalten.
- **Umfang:** wählbarer, gespeicherter HQ-Modus mit Full-HD-Grenze und klassischer Rückfalloption; keine neuen Grafikquellen und keine PNG-Vergrößerung nötig. Version v0.51.0 · CodexAI.

## Referenzen und unveränderte Merkmale

| Zweck | Tatsächlich gesichtet | Übernommen |
| --- | --- | --- |
| Figuren und Kontakt | aktive Original-Raven/Shadepi, bestehende HQ-Analysebilder und neue native Versteckansichten | Körpermaß, Kostüm, Masken-/Haarform, Atlasraster, unveränderte Fuß- und Handanker |
| Darstellungsregeln | AGENTS, KONSISTENZ, Stilbibel/FX, Arbeitsvorlage, vorherige Anzeigeanalyse | HQ-Pixelquellen besser ausgeben, kein flacher Ersatzkörper und keine verworfenen Helden |
| Renderer | DisplaySettings/Panel, Godot Window-/Viewport-Verhalten, eigener Prototyp mit gemeinsamem Canvas | logische 640×360 behalten, echter begrenzter Renderpfad statt bloßer Änderung der Fenstergröße |
| Effekte und Kontakt | Atmosphärenshader und vorhandene `assets/world/light.png` | Bloomradius in Weltgröße, weicher Fußkontakt aus vorhandener Textur |

Raven bleibt 160 cm, Shadepis Gesicht/Maske unverändert. Alle Originalhelden, Sonderposen und Quellbilder bleiben bytegleich. Es wurden weder KI-Grafiken erzeugt noch Bilddateien bearbeitet. Dokumentationsbilder sind direkte Godot-/Fensteraufnahmen.

## Architektur und Grafik

- Originale Nodes bleiben am Root-Viewport; dadurch bleiben Szenenwechsel, Kameras, Physik, Audio, Mauspositionen und GUI-Fokus erhalten. Keine Szenenmigration und kein duplizierter Spielzustand.
- `hq_renderer.gd` teilt nur die Render-Canvases mit einem SubViewport: physische Bildgröße höchstens 1920×1080, logische Größe 640×360. Sichtbare CanvasLayers behalten Reihenfolge und Transform; bei Verbergen/Entfernen werden die RIDs gelöst.
- Root zeichnet im HQ-Modus nur den Präsentationspass. Reserviertes Sichtbarkeitsbit trennt ihn vom Quellbild, sodass keine rekursive Bildschirmtextur entsteht. Material ist unbeleuchtet; kein zweites Abdunkeln des fertigen Spielbilds.
- Größere Ausgaben vergrößern das fertige Full-HD-Bild mit Nearest. Im klassischen Modus werden Zielbild und geteilte Canvases freigegeben und die bisherige Sichtbarkeitsmaske wiederhergestellt.
- Bloom-Schrittweite multipliziert die tatsächliche Renderdichte. Individuelle Spritefilter, Skalierungen und Anker bleiben erhalten; der physische Kontaktfleck verwendet die vorhandene radiale Textur.
- HQ ist Standard bei neuen/älteren Einstellungen ohne HQ-Feld. Eine explizite gespeicherte klassische Auswahl bleibt erhalten. Fehlerhafte Präferenztypen werden abgefangen.

## Nachweise

| Prüffeld | Ergebnis |
| --- | --- |
| Native Bildprüfung | Full-HD-Originalhelden, weicher Kontakt, Haupt-/Pausenoptionen, ICE-Gitter und Gehbilder gesichtet. 48 Filmframes, 130.612 Bytes. |
| 4K-Grenze | Physischer 3840×2160-Desktop; Fensteraufnahme in 3840×2160 und Spielbild in 1920×1080. Vollständiger RGB-Vergleich der auf jedem zweiten Ausgabepixel abgetasteten 4K-Aufnahme gegen das Quellbild identisch (mittlerer/maximaler Fehler 0). |
| Maus / Controller | Umschalten im laufenden Menü, B-Schließreihenfolge, A-Auswahl, Weltpositionen und Fokus unverändert; echte native und Headless-Eingabeprüfungen. |
| Laufzeit / Kino | Guardian/Netz bleiben beim Moduswechsel, neue/unsichtbare Kinoebenen und entfernte Kapitel-Canvases korrekt; bestehende Szenenrouten bleiben unangetastet. |
| Relevante Regressionen | Abschlusszählung wird nach dem finalen Lauf ergänzt. |
| Export | Finaler Paketnachweis folgt vor Sicherung. |
| Version / Sicherung | v0.51.0 · CodexAI in Projekt-/Exportfeldern und Versionsinfos; Git-Sicherung nach Prüfung. |

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2, eigenes X11-Dummy-Display mit 3840×2160/30 Hz, Mesa llvmpipe. Keine native Windows-Hardwareprüfung oder FPS-Zusage behauptet. Die gemeinsame Godot-Viewport-/Eingabe-API bleibt erhalten; Windows-Versionsfelder werden mitgeführt.
