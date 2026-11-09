# Blutspritzer und Bodenlachen · v0.46.0 · CodexAI

## Auftrag und Ausgangslage

Nutzerziel: Blut spritzt bei Gegnertreffern und bleibt als Blutlache auf dem Boden. Ausgang `41fef63`, v0.45.0, lokal sauber. Alle Remote-Branches abgeglichen; main aktuell, andere bekannte Branches höchstens v0.21.3. Keine fremden Änderungen zu übernehmen. Umfang: reale Treffer menschlicher `Enemy`-Gegner einschließlich Cyberware-Träger; digitale Gegner und Erinnerungs-Bots/Mechs behalten ihre technische Effektfamilie. Keine neue Trefferregel, Figurenpose oder Handlung.

AGENTS, KONSISTENZ, Art Direction, UI-/FX-Referenz und Arbeitsvorlage gelesen. Gesichtet: `docs/stilbibel/bilder/effekte.png`, `figur-punk-1.png` sowie neue Gameplay-Ansichten v0.45.0. Übernommen: strukturierte Pixelcluster, kleine Weltgröße neben rund 58 Pixel hohen Helden, dunkle Cyberpunk-Materialfarben und feste Bodenebene. Figurenidentität, Raven 160 cm und Shadepis verdecktes Gesicht unverändert.

## Grafik und Integration

Neue Bildwerkzeugquelle `/workspace/generated_images/exec-5c9452d9-ade2-410b-9230-e39c73b06bd6.png`, unverändert nach `assets/fx/blood/atlas.png` kopiert. Tatsächlich 1774×887, 4×2 registrierte Regionen: vier Spritzphasen oben; kleine Flecken und frische/große/gesetzte Lachen unten. Transparenz und Pixelkanten, keine Vektor-Ersatzzeichnung. Ursprung jeder Spritzphase eigens registriert. Weltmaßstab: Spritzer ungefähr 15–43 Pixel breit, größere Lache ungefähr 42×15 Pixel; keine bildfüllenden roten Effekte. Nearest.

Treffer → gerichtete Körper-Spritzfolge → ballistische Tropfen → Bodenflecken. Todeslache folgt kurz dem tatsächlichen Leichenrutschen, wächst dann ortsfest und dunkelt ab. Bodenebene oberhalb Kulisse, unter Figuren; Luftlage separat. Echter positiver Schaden nötig, keine Blutmenge bei Block, Nullschaden oder wiederholtem Treffen eines Toten. Gegner aus Datenräumen und nicht-Enemy-Roboter erzeugen keinen Blut-Effekt. Keine Helden-Bluteffekte angefordert.

Effekte nur kosmetisch, keine Kollision/Spielstandsänderung. Mengen begrenzt, nahe kleine Flecken zusammengeführt, Lebenszeit 90 Sekunden einschließlich 12 Sekunden Ausblenden. Reduzierter Bildstil verringert Spritzer/Tropfen/Lachen; Pause und Terminal halten alle Uhren an. Abschnittswechsel/Laden über `set_dressing` leert beide Ebenen und alle Daten. Ton und Controllerbelegung nicht betroffen; vorhandene Trefferklänge und Eingaben bleiben gleich.

## Abnahme und Sicherung

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Quellen / Identität | Eine neue unveränderte FX-Quelle; keine Figuren-/Storyänderungen. [Quellregionen](../../assets/fx/blood/README.md). |
| Größe / Material / Transparenz | Im tatsächlichen Kapitel-1-Renderer neben normalen Figuren und nassem Asphalt verglichen; Pixelkanten und burgundene Schatten lesbar. Quelle 1774×887, Nearest. |
| Kontakt / voller Ablauf | Körperursprung, vier Spritzphasen, fallende Tropfen, Leichenrutschen, Wachstum und ortsfeste Bodenlage geprüft. Native Vorher-/Nachher-PNGs bei derselben Kamera und Film mit 154 echten Renderer-Aufnahmen. |
| Controller / Tastatur / Ton | Keine neue Eingabe, UI oder Klangänderung; bestehende Kampfwege und Trefferwerte bleiben aktiv. Kein neuer Hörtest, Dummy-Audio für Aufnahme. |
| Pause / Terminal / Bildstil | Regression friert Tropfen und Lebenszeiten im Menü/Terminal ein; Reduziert mit geringeren Mengen geprüft und aufgenommen; ein Wechsel begrenzt auch bereits vorhandene Effekte sofort. |
| Abbruch / Laden / Neustart | `set_dressing`, `restore_dressing_state` und Demo-Niederlage leeren sämtliche Blutdaten, keine gespeicherten Dekorspuren. |
| Export | Neues PNG und neues Skript aus exportiertem PCK in leerem Arbeitsverzeichnis geladen; zwölf Prüfungen und nativer OpenGL-Render. |
| Version / Doku | 0.46.0 / Windows 0.46.0.0, CodexAI, Changelog, Root-/Doku-PNG-Vorschauen und Stilreferenz fortgeschrieben. |

### Aktuelle Prüfläufe

Godot 4.7.2, isolierte `XDG_DATA_HOME`-Verzeichnisse; keine echten Spielstände als Fixtures.

| Suite | Prüfungen | Fehler |
| --- | ---: | ---: |
| Blut-FX `tests/blood_fx.gd` | 29 | 0 |
| Kern `tests/run.gd` | 383 | 0 |
| Raven-/Gegnerkampf | 292 | 0 |
| Arcade-Wellen | 246 | 0 |
| Tower-Ablauf | 42 | 0 |
| **Regression gesamt** | **992** | **0** |
| Exportpaket zusätzlich | 12 | 0 |

Editorimport und Linux-Pack-Export ohne Skriptfehler, `/tmp/shadepi-v0.46.0.pck`. Externes Prüfskript außerhalb des Projekts: Version, tatsächliche importierte Atlasgröße, Ebenen, echte Treffer, Richtungs-/Körperanker, Tropfenlandung in 60 Simulationsschritten, Todeslache, kein wiederholtes Blut am Toten, Pause, Reduziert, Kontrollpunktbereinigung und nativer Renderer. `PACKED BLOOD: 12 checks, 0 failures`. Ein erster Exportprüflauf erwartete eine komplette ballistische Flugbahn nach einem einzigen 0,8-Sekunden-Integrationsschritt; die Prüfung simuliert nun echte 60-Hz-Schritte wie das Spiel. Kein hierfür passend gemachter Quellcodewechsel.

Logs temporär unter `/tmp/shadepi-v046-*.log`; Aufnahmeprogramm [blood_gallery.gd](../../tools/blood_gallery.gd). Eigener Xorg-Dummy-Renderer, keine Paketinstallation nötig. Film-QA platziert echte Gegner und löst deren echte Schadensfunktion aus, kein vollständig manuell erspielter Kampf. Keine neue akustische Abnahme.

**Sichtprüfung:** CodexAI, 9. November 2026 (Europe/Berlin). Die vorhandene helle Trefferaufhellung im Spritzbild ist nur der kurze Spiel-Trefferblitz. Bei der Aufnahme in den freien Straßenbereich versetzt, damit keine Figur im Container steht. Körper, Stoff und Rüstung nicht verändert.

**Grenzen:** Bodenblut ist temporärer kosmetischer Zustand, kein neues Speicher-/Fußabdruck-/Wundsystem. Reale Helden werden durch diesen Auftrag nicht mit Blut-FX ergänzt. Kein pauschaler Austausch bestehender anderer Kampf-FX. Der Film zeigt natives Verhalten bei gezielter QA-Vorbereitung und eine Auswahl der Aufnahmen.

**Sicherung:** Alle Remote-Branches vor Beginn und vor Push abgeglichen: `main` weiterhin `41fef63`, übrige bekannte Branches unverändert. Geprüfte Fassung auf GitHub `main` gesichert. Keine Veröffentlichung der Cloud-Umgebung und kein Release-Tag.

