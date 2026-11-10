# Konsistenzauftrag und Arbeitsnachweis: HQ-Dropdowns

**v0.51.1 · CodexAI · 10. November 2026.** [Bilder und Bedienung](../dropdowns-v0511.md).

## Auftrag und Ausgangslage

- **Nutzerziel:** Dropdowns im Menü, bei Kapitel-/Kontrollpunkten und in Hacks wieder öffnen und benutzen können.
- **Ausgang:** `9c39a4c`, v0.51.0, sauberer Arbeitsbaum. Alle Remote-Branches abgerufen und mit dem zuletzt bearbeiteten Stand verglichen: main aktuell, keine neueren Entwicklungsstände.
- **Umfang:** zentrale Sichtbarkeits-/Ebenenkorrektur im HQ-Renderer sowie korrektes Öffnen/Schließen der Hack-Optionen. Neue Version v0.51.1 · CodexAI; Figuren-/Grafikquellen, Rätselregeln und Full-HD-Grenze erhalten.

## Referenzen und Konsistenz

| Zweck | Tatsächlich gesichtet | Erhalten / übernommen |
| --- | --- | --- |
| HQ-Vertrag | AGENTS, KONSISTENZ, vorheriger HQ-Bericht und Renderer | Root behält Eingabe, logische 640×360 und begrenztes Spielbild |
| Dropdowns | native Anzeige-, Kapitel-, Kontrollpunkt- und Reparaturansichten vor/nach Korrektur | sichtbare Listen über dem Spielbild, bestehende Positionierung und Modalität |
| Oberflächen | bestehende UiSkin-Panels, Buttons und Pixel-Font | Hack-Popup folgt der vorhandenen Deck-Farb-/Schriftfamilie |
| Engine-Verhalten | aktuelles Godot-Viewport-Verhalten und native Probe | eingebettete Fenster: reservierte Ebene 1024 |

Keine neuen Spielgrafiken; alle PNGs im Bericht sind native Spielaufnahmen. Keine Lore, Figurengröße, Kleidung, Pose, Fuß-/Handanker oder Animation verändert. Historische verworfene Helden sind keine Quelle.

## Umsetzung

- HQ-Präsentation auf Ebene 512 statt auf der für eingebettete Fenster reservierten Ebene 1024.
- Bestehende Sichtbarkeitsmasken und HQ-Isolation bleiben unverändert. Die native Gegenprobe zeigt: Die Ebenenkollision ist die Ursache; eine zusätzliche Umschreibung von Item-Masken ist nicht nötig. Godots interne eingebettete Fensterflächen benutzen einen vollständigen Render-Layer-Maskenwert.
- Zentral für alle OptionButtons, keine Einzelkorrekturen pro Kapitel und keine zusätzlichen nativen OS-Fenster.
- Im Terminal öffnet A die Liste; offene Popup-Eingabe geht an Godot. B/Esc schließt nur die Liste, Links/Rechts bleibt die schnelle direkte Änderung. Liste übernimmt vorhandenen Deckstil.

## Nachweise

| Prüffeld | Ergebnis |
| --- | --- |
| Root / HQ | Full-HD-Grenze und getrennte Präsentation bleiben erhalten; Originalmasken während der Korrektur unverändert. |
| Native Sichtprüfung | Anzeige, Kapitel, Kontrollpunkte, drei Energie- und sieben Reparatur-Auswahlen im echten Bild überprüft. |
| Regression | 1.150 Headless-Prüfungen, 0 Fehler: Popup 64, HQ 66, Anzeige 74, Kernsystem 382, Terminal-Controller 186, Rätsel 67, Kontrollpunkte 205, Menünavigation 13, Netzavatar 52, ICE 41. |
| Native Pixelprüfung | Je 81 Prüfungen bei 640×360, 1920×1080 und 3840×2160, jeweils 0 Fehler. Alle 16 Listen: vier Anzeigeoptionen, Kapitel, Kontrollpunkte, drei Energie- und sieben Reparaturoptionen. Absichtlich wiederhergestellte Ebene 1024 wird als verdeckte Liste erkannt. Zusätzlich HQ-Lebenszyklus: 73 Prüfungen, 0 Fehler. |
| Controller / Tastatur | A öffnet, Oben/Unten wählt, A bestätigt; B schließt Liste und lässt Hack/umgebendes Menü offen. Vorhandene Links-/Rechts-Schnellwahl geprüft. |
| Export | Finalen Stand neu importiert und als Linux-PCK exportiert. Native Prüfung direkt aus `/tmp/shadepi-v0.51.1.pck`: 82 Prüfungen, 0 Fehler, einschließlich Version 0.51.1 und sichtbarer Listen. Keine Skript-/Parsefehler in Import, Export oder finalen Prüfläufen. |
| Repository | Audit: 4.333 Prüfungen, 0 Fehler; `git diff --check` sauber. Vor Sicherung alle Remote-Branches erneut abgerufen: main weiterhin `9c39a4c`, keine neuere Entwicklungsarbeit. |
| Version / Sicherung | v0.51.1 · CodexAI in Projekt, Exportfeldern und Änderungsinfos; geprüfter Stand wird auf main gesichert, ohne Tag oder Cloud-Veröffentlichung. |

**Reproduzierbare Befehle:** `/workspace/.shadepi/tools/godot --headless --script res://tests/hq_popups.gd` mit isoliertem `XDG_DATA_HOME=/tmp/shadepi-…`; für echte Pixelprüfung ohne `--headless` auf X11, optional `-- --small`, `-- --4k` oder `-- --gallery`. Der neue CI-Schritt benutzt dafür Xvfb. Die native Paketprobe verwendet dieselbe Prüfroutine als externe Datei mit `--main-pack /tmp/shadepi-v0.51.1.pck` und zusätzlichem Versionsvergleich.

**Bildbelege:** zwei native Full-HD-PNGs und 16 native 640×360-Aufnahmen als animiertes WebP (482.088 Byte, unter 5 MB). Beide PNGs visuell kontrolliert; Hack-Liste trägt den vorhandenen Pixelrahmen und ist vor dem Deck sichtbar. Keine Spiel-Assetdateien verändert.

**Sichtprüfung:** CodexAI, 10. November 2026, Godot 4.7.2, eigenes X11-Dummy-Display, OpenGL/Mesa. Die früheren Zustands-/Auswahltests erkannten die verdeckte Liste nicht; deshalb wird jetzt zusätzlich der tatsächliche Pixelbereich der geöffneten Liste geprüft. Keine Behauptung eines manuellen Komplettdurchlaufs oder nativer Windows-Hardwareprüfung.
