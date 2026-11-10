# Konsistenzauftrag und Arbeitsnachweis: HQ bis Full HD

**v0.51.0 · CodexAI · 10. November 2026.** [Bilder, Film und Bedienung](../hq-anzeige-v051.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** 1920×1080 nativ ermöglichen, einen HQ-Anzeigemodus einbauen und Ausgaben oberhalb Full HD nur vergrößern. Bilder bei Bedarf skalieren.
- **Ausgang:** `93ede9c`, v0.50.2, Arbeitsbaum sauber. Alle Remote-Branches abgerufen und verglichen; main aktuell, keine neueren Entwicklungsstände. Fremde Spiel-/Tower-/See-/ICE-Änderungen erhalten. Vor Sicherung erneut alle Branches abgerufen: `origin/main` unverändert `93ede9c`.
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
- Root-Texturfilter, Wiederholung, Pixel-Snapping und 2D-HDR-Zustand werden ausdrücklich auf das Spielbild übertragen; SubViewport-Standardwerte würden sonst Linearfilter und deaktiviertes Pixel-Snapping einführen.
- Bloom-Schrittweite multipliziert die tatsächliche Renderdichte. Individuelle Spritefilter, Skalierungen und Anker bleiben erhalten; der physische Kontaktfleck verwendet die vorhandene radiale Textur.
- HQ ist Standard bei neuen/älteren Einstellungen ohne HQ-Feld. Eine explizite gespeicherte klassische Auswahl bleibt erhalten. Fehlerhafte Präferenztypen werden abgefangen.

## Nachweise

| Prüffeld | Ergebnis |
| --- | --- |
| Native Bildprüfung | Full-HD-Originalhelden, weicher Kontakt, Haupt-/Pausenoptionen, ICE-Gitter und Gehbilder gesichtet. 48 Filmframes, 132.886 Bytes. |
| 4K-Grenze | Physischer 3840×2160-Desktop; Fensteraufnahme in 3840×2160 und Spielbild in 1920×1080. Vollständiger RGB-Vergleich der auf jedem zweiten Ausgabepixel abgetasteten 4K-Aufnahme gegen das Quellbild identisch (mittlerer/maximaler Fehler 0). |
| Maus / Controller | Umschalten im laufenden Menü, B-Schließreihenfolge, A-Auswahl, Weltpositionen und Fokus unverändert; echte native und Headless-Eingabeprüfungen. |
| Laufzeit / Kino | Guardian/Netz bleiben beim Moduswechsel, neue/unsichtbare Kinoebenen und entfernte Kapitel-Canvases korrekt; bestehende Szenenrouten bleiben unangetastet. |
| Relevante Regressionen | 2.255 Headless-Checks ohne Fehler: HQ 66, Anzeige 74, Core 382, Terminalcontroller 186, Terminalrätsel 67, Kino 50, Raven/Gegner 292, Atmosphäre 134, See 40, Story 206, Netzavatar 52, ICE 41, Kontrollpunkte 205, Menünavigation 13, See/Menü 253, Kampfaktionen 68, Eisbad 49, Fehlerbericht 21, Umgebungston 56. Zusätzlich 73 native HQ-Checks einschließlich tatsächlicher Mauspositionierung und 4K-Pixelvergleich ohne Fehler. |
| Export | Linux-PCK `/tmp/shadepi-v0.51.0.pck` nativ mit 23 zusätzlichen Checks ohne Fehler gestartet: Ressourcen, Default-HQ, tatsächliches Full-HD-Target auf 4K, Root-Präsentation, Bloom, Originalhelden, GUI, Kino/Abbruch, klassischer Rückfall und kleinere HQ-Ausgabe. Entwicklungsdateien ausgeschlossen. |
| Version / Sicherung | v0.51.0 · CodexAI in Projekt-/Exportfeldern und Versionsinfos; Implementierung in `ec8a5ad` zwischengesichert; abschließender Prüf-/Exportnachweis wird als eigener Commit auf main gesichert. |

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2, eigenes X11-Dummy-Display mit 3840×2160/30 Hz, Mesa llvmpipe. Keine native Windows-Hardwareprüfung oder FPS-Zusage behauptet. Die gemeinsame Godot-Viewport-/Eingabe-API bleibt erhalten; Windows-Versionsfelder werden mitgeführt.


## Reproduktion

```sh
XDG_DATA_HOME=/tmp/shadepi-hq-tests godot --headless --script res://tests/hq_display.gd
# Auf eigenem nativen Desktop mit 3840×2160:
XDG_DATA_HOME=/tmp/shadepi-hq-native godot --audio-driver Dummy --script res://tests/hq_display.gd
XDG_DATA_HOME=/tmp/shadepi-hq-gallery godot --audio-driver Dummy --script res://tools/hq_display_gallery.gd
python3 tools/audit_repository.py
godot --headless --export-pack Linux /tmp/shadepi-v0.51.0.pck
```

Der Paketprüfer liegt außerhalb des Repositorys unter `/tmp/shadepi51-pack.gd`; seine 23 Prüfungen sind zusätzlich gezählt. Physische Fotos stammen aus dem eigenen 4K-Desktop (`xrandr`: 3840×2160/30 Hz); eine anfänglich abgeschnittene Aufnahme auf einem zu kleinen Dummy-Modus wurde verworfen und durch maßgeprüfte vollständige Bilder ersetzt. Der finale Renderer und die Bildaufnahmen übernehmen Pixel-Snapping und Filter ausdrücklich vom Projekt.

**Ergebnis:** Auftrag umgesetzt und sicht-/exportgeprüft. Kein Cloud-Publish oder Release-Tag angelegt; PNG-Originale und verworfene Heldenarchive nicht verändert. Gesamter manueller Story-Durchlauf und native Windows-Hardwaremessung wurden nicht behauptet.
