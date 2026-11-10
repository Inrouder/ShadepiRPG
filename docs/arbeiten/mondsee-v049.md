# Mondsee, Kontaktbilder und Menügrößen · v0.49.0 · CodexAI

## Auftrag und übernommener Stand

Nutzerziel: aktuelle Änderungen berücksichtigen; Kapitel 7 mystischer im Mondschein mit Wasserreflexen und animiertem Drachenschatten, konsistente Kussanimation und passende Menügröße.

Alle Remote-Branches vor Beginn abgerufen. Lokaler Stand `03e6094` (v0.46.2) war veraltet. Main `c31a634` mit v0.47.0, v0.47.1 und v0.48.0 per Fast-forward übernommen. Entwicklungsbranch `claudehelper/v0.48.0` hat denselben Baum wie main; keine fremden Änderungen ausgelassen. Ältere Branches sind historische Stände. Neue Version v0.49.0 / Windows 0.49.0.0, CodexAI.

AGENTS/KONSISTENZ und Arbeitsvorlage, Art Direction, Original-Figurenkarten, vorherige Seequelle und Briefing Teil 7 tatsächlich berücksichtigt. Originalhelden, Menübild, Kulisse und Lore unverändert. Neue Quelle betrifft nur Kontaktposen und Drachenphasen. Ravens 160 cm, Shadepis verdecktes Gesicht und die rechte-Maske/linke-Gesicht-Handzuordnung erhalten.

## Quellen und Umsetzung

| Zweck | Quelle / Ergebnis |
| --- | --- |
| Original-Stil | `docs/stilbibel/bilder/figur-raven.png`, `figur-shadepi.png`; normale Atlanten unverändert. |
| Kontaktquelle | `poses-moon.png`, tatsächlich 1774×887, acht vollständige Einzelregionen und konstante Fußanker. Bildwerkzeugquelle nach Korrektur einer zunächst doppelt dargestellten Maske unverändert übernommen. |
| Drachenquelle | `dragon-flight.png`, 2172×724, sechs unterschiedliche 724×362-Flugphasen mit vollständigen Zellabständen. Schwache Alpharänder werden nur bei der Silhouettenabtastung ausgeblendet. |
| Herkunft | Finale Quellpfade und Layout unter `assets/story/lake/README.md`; keine programmatische PNG-Bemalung oder Vektor-Ersatzgrafik. |
| Kontaktablauf | Echte Zwischenbilder statt Alpha-Überblendung. Gehaltener Kuss bewegt sich zwischen zwei eigenen Phasen; Anker/Scale bleiben fest. |
| Mond und Wasser | Vorhandener Mond bleibt Lichtursprung; Glanzachse und Wellen unter seiner Bildposition. Shaderpolygone bleiben in der vorhandenen Seegeometrie. |
| Kino und Wiederherstellung | Spiel-HUD bei Anflug/Finale aus, Dialog/Pause erhalten. End-/Abortsignal und Kapitelbereinigung lösen Zustand; normale Körper/Schatten nicht doppelt zeichnen. |
| Menü | Gemeinsame Zeilenanordnung nach Sichtbarkeit inklusive Kapitelaktionen. Mindestbreite Anzeige, Beschreibungshöhe und Hilfe geprüft. Keine festen abweichenden Zeilenpositionen in Unterklassen. |

Rohquellen und Originalbilder vollständig erhalten. Vorherige `poses.png`, `dragon.png` und alter Blendshader sind als Referenzen markiert und vom Spieleexport ausgeschlossen. Die normale Heldenwiederherstellung aus v0.46.1 bleibt bestehen. Die aktuelle v0.48.0-Story, Pixelmarker, Umgebungsgeräusche, Towerplan und Alarmanlage erhalten.

## Sichtprüfung und Aufnahmen

Native Aufnahme mit Godot 4.7.2/OpenGL. Baseline `c31a634` in isoliertem Worktree aus demselben Repository geladen, aktueller Stand separat. Vorher-/Nachher-Kamera gleich; Figuren-/Posezustand im QA-Aufbau vorgegeben, HUD für Vergleich in beiden Ansichten ausgeblendet. Tatsächlicher Finalefilm mit automatischem Dialogfortschritt sowie alle acht Kontaktbilder und drei native Menüauflösungen aufgenommen. Keine neuen Grafiken allein für Dokumentation; Vorschau-PNGs sind echte Rendererbilder.

Die Quellenformate und Alpharänder wurden zusätzlich gelesen/vermesen, nicht per Python verändert. Körperhöhe der gesamten Kontaktpose rund 58 Weltpixel, Sohlen innerhalb 0,3 Weltpixel am gemeinsamen Anker; keine abgeschnittenen Hüte, Hände oder Haarenden. Die Hand-/Gesichtskontinuität visuell am Quellblatt und am tatsächlichen Kussbild geprüft.

## Abnahme

Aktuelle Regression und Exportprüfung abgeschlossen; Ergebnisse unten. Tests verwenden isolierte `XDG_DATA_HOME`-Verzeichnisse. Keine neue Belegung oder Audiodatei; bestehende Controller-/Tonregeln geprüft, Dummy-Audio bei Aufnahme ohne neue akustische Abnahme. Keine vollständige manuelle Kampagnen-/Windows-Abnahme.

[Bericht, PNGs und Film](../mondsee-v049.md). Keine Cloud-Veröffentlichung und kein Release-Tag.

### Aktuelle Ergebnisse

| Suite | Prüfungen | Fehler |
| --- | ---: | ---: |
| Mondsee / Menü-Geometrie | 253 | 0 |
| See-Ablauf / Kontinuität / Laden | 40 | 0 |
| Ortsatmosphäre | 134 | 0 |
| Cinematische Wege | 50 | 0 |
| Anzeige-/Skalierungsoptionen | 73 | 0 |
| Menü-/Testkontrollpunkte | 205 | 0 |
| Native Controller-Navigation / Desktop-Ausgang | 13 | 0 |
| Kern | 383 | 0 |
| Storyaudit | 206 | 0 |
| Aktueller Towerplan | 15 | 0 |
| Aktueller Umgebungston | 56 | 0 |
| **Regression gesamt** | **1.428** | **0** |
| **Export zusätzlich** | **32** | **0** |

Godot 4.7.2. Editorimport und Pack-Export ohne Skriptfehler. `/tmp/shadepi-v0.49.0.pck` aus leerem Arbeitsverzeichnis mit externem Prüfer nativ geöffnet: tatsächliche importierte Abmessungen, alle acht Kontaktregionen, sechs Phasenquelle, Originalhelden, Menüaktionen samt Hilfe, Pause, direkter Szenenabbruch und Kapitelbereinigung. Historische See-PNGs/Blendshader fehlen im Export, neue Quelle vorhanden. Die v0.48.0-Ressourcen Towerplan, Pixelmarker und Toweralarm bleiben exportiert. `PACKED MOON: 32 checks, 0 failures`.

Original-Helden, Menübild und Seekulisse bytegleich zum aktuellen Ausgang `c31a634`. Native Exportansichten `/tmp/shadepi49-packed-menu.png` und `/tmp/shadepi49-packed-lake.png` zusätzlich gesichtet. Vorher-/Nachher-PNGs im Bericht wurden aus der echten Baseline und dem neuen Stand aufgenommen; die damalige helle/falsche Kontakttextur ist keine aktuelle Stilreferenz.

Finalefilm aus 113 nativen Rendererbildern mit tatsächlichen Zeitabständen als WebP, rund 1,3 MB und damit unter der 5-MB-Grenze. Die letzten Layoutkorrekturen betreffen Beschreibungshöhe und dynamische Kapitelaktionen; Menübilder danach separat neu aufgenommen. Film zeigt unveränderte laufende Szene. Werkzeuge, Methode, Referenzen und verbleibende Grenzen stehen oben; zeitweise QA-Aufbauten und Logdateien liegen nur unter `/tmp/shadepi49-*` beziehungsweise `/tmp/shadepi-v049-*`.

Repository-Audit prüft lokale Links, Ressourcen-/Statuspfade, aktive Version und Exportgrenzen ohne Fehler. Vor Abschluss alle Remote-Branches erneut verglichen: main weiterhin `c31a634` / v0.48.0, Entwicklungsbranch v0.48.0 weiterhin baumgleich. Zwischenstand `c7b334f` gespeichert; geprüfte Änderung mit CodexAI-Vermerk auf main gesichert. Keine fremden Branches löschen und keine Cloud-Umgebung veröffentlichen.
