# Konsistenzauftrag · v0.35.1 · CodexAI

- **Auftrag:** Start und Einsteigen auf dem tatsächlichen Tower-Landeplatz. Erst nach dem Abheben Antriebsprobleme; danach fällt derselbe Aerodyne von oberhalb des Penthouses am Balkon vorbei und fängt sich darunter.
- **Ausgang:** `1b38723`, v0.35.0, sauber und identisch mit GitHub `main`. Alle Remote-Branches abgerufen; Entwicklungsbranches unverändert bis v0.21.3. Keine fremden Änderungen zu übernehmen.
- **Neueste Nutzervorgabe hat Vorrang:** Die v0.35.0-Balkon-Abflugfassung war räumlich falsch. Sie wird ersetzt. Penthouse-Annäherung, Hangar, Düsenrenderer und geschützte Extraktion bleiben erhalten.
- **Gesichtete Referenzen:** tatsächliches `rooftop.png` mit H-Landeplatz und Dachausgang, `tower/exterior.png` als tiefere Fassadenansicht; `aerodyne_flight.gd`/`parked_aerodyne.gd` mit gespeichertem Aufsetzpunkt, aktuelle Konsistenzregeln, Art Direction und Arbeitsvorlage.
- **Quellen:** dieselben vorhandenen HQ-Figuren, Fahrzeugzelle, Düsen und Kulissen; keine neuen Bilder nötig. Figurenkarten aus v0.35.0 bleiben gültig, Merkmale und Größen werden nicht bearbeitet.
- **Geplante Inszenierung:** Vom Dachausgang zum vorhandenen geparkten Schiff laufen, nacheinander einsteigen, abheben. Nach Schubverlust bewegt sich das Schiff über die Dachkante. Erst dann folgt der Blick auf die Fassade darunter: Schiff kommt von oben ins Bild, passiert den Balkon im freien Luftraum und fängt sich tiefer ab. Der Blickwechsel setzt denselben Schiffsknoten mit passender Bildgröße und Fallgeschwindigkeit fort.
- **Prüfung:** echte Renderer-Aufnahmen müssen den H-Landeplatz beim Start und die Fallrichtung oberhalb → unterhalb des Balkons eindeutig zeigen. Ergänzend Routen, gespeicherter Aufsetzpunkt, richtige Phasen, Pause, Skip/Laden und Export prüfen. Version/Infos überall auf v0.35.1 · CodexAI erhöhen und auf GitHub sichern.

## Umsetzung und Nachweis

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Start und Raumgeografie | `tower-landeplatz-v0351.png` zeigt den tatsächlichen Dach-Landeplatz mit Markierung, Konsole und Ausgang. Erst dort laufen beide zum Schiff und steigen ein. |
| Aufsetzpunkt und Kontakt | Abflug verwendet `aerodyne_spot - Vector2(0,20)` entsprechend dem bisherigen geparkten Schiff. Neues optionales Speicherfeld erhält den erspielten Punkt. Ältere und ungültige Felder fallen auf `PAD_WORLD` zurück. Dach-Laufwege mit 7-Pixel-Figurenradius gegen Konsole und Eingang geprüft. |
| Abheben vor Ausfall | Sichtbare eigene Startphase mit ansteigendem Schub auf dem Landeplatz. Erst im anschließenden Schritt Schubverlust und Verlassen der vorderen Dachkante. |
| Blickwechsel und Fallrichtung | Fassadenaufnahme beginnt mit dem Schiff oberhalb des Bildes. `tower-von-oben-v0351.png` zeigt seine Ankunft, `tower-unter-balkon-v0351.png` das Abfangen darunter. Derselbe Fahrzeugknoten, passende Größe/Orientierung und projizierte Anfangsgeschwindigkeit; keine neue Startposition auf dem Balkon. |
| Vollständiger Ablauf | Film `tower-flucht-v0351.webp` aus tatsächlichen Godot-Frames, Aufnahmezeitpunkte als Wiedergabezeit. Sichtbares Abheben über eine weiche vertikale Kurve vor der Vorwärtsbewegung, dann Ausfall und Fall am tieferen Balkon vorbei. Keine nachträgliche Bildmontage oder neue Spielgrafik. |
| Figuren, Material, Alpha | Vorhandene HQ-Figuren und Fluggerät bleiben erhalten. Kein neuer Atlas, keine geänderten Merkmale, Fußanker oder Filter. Düsenprojektion und anhaltbare Shaderuhr aus v0.35.0 unverändert. |
| Tastatur / Controller / Pause | Bestehende Szeneingaben unverändert. Tower-Prüfung enthält Pause, Laden und vollständiges Überspringen einschließlich der neuen Startphase. Bewegungsprüfung kontrolliert auch pausierte Düsen/Einstiegsschritte und Szenenabbruch. |
| Regressionen | **731 Prüfungen ohne Fehler**: filmische Wege/Geografie/Speicherfeld 50, Tower 42, Gameplay/Saves 383, Story 206, Aerodyne-Flug 50. Gezielt auf den geänderten Abflug und das neue Speicherfeld begrenzt; alte Prüfzahlen nicht als neu ausgeführt übernommen. |
| Export | `/tmp/shadepi-v0.35.1.pck` gebaut und außerhalb des Repositories im OpenGL-Renderer ausgeführt: **7 zusätzliche Paketprüfungen ohne Fehler** für Startposition, Speichern/Laden, Start vor Ausfall, Dachkante, Ankunft von oben, Abfangen darunter mit Düsen und Übergang zum See. Paket-Renderframe gesichtet. |
| Version / Sicherung | v0.35.1 · CodexAI in Projekt, Windows-Versionsfeldern, READMEs und CHANGELOG; verbindliche Konsistenzregeln und Archivbriefing räumlich berichtigt. GitHub-Sicherung nach Paketprüfung, keine Cloud-Veröffentlichung. |

**Sichtprüfung:** CodexAI, 9. November 2026, Godot 4.7.2 mit OpenGL/Mesa auf Linux/X11; tatsächliche 640×360-Spielbilder. Die vorherige Balkonfassung bleibt ausschließlich als historische Umsetzung erhalten.

**Unverändert / nicht betroffen:** Penthouse-Eintritt und Griff, Hangar-Laufwege, Figurenidentität, Musikpfade, HUD-/Vollbildbedienung und Wachen-/Extraktionsregeln. Keine neuen Grafikquellen erforderlich. Windows-Anzeigetreiber sind in dieser Linux-Umgebung nicht ausführbar.

**Ergebnis:** Räumlicher Fehler korrigiert, im vollständigen Ablauf gesichtet, gezielt getestet und aus dem Ressourcenpaket ausgeführt. Sicherung erfolgt mit dem zugehörigen v0.35.1-CodexAI-Commit auf `origin/main`, ohne Cloud-Veröffentlichung oder Release-Tag.
