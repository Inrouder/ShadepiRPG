# Konsistenzauftrag: Begleiter und Arcade · v0.61.0 · CodexAI

**15. November 2026.** Nutzerauftrag: aktuellen verlängerten Spielstand prüfen, Koop-Begleiter neu generieren, für alle wählbaren Arcade-Kämpfer eigene Kampfposen einbauen und einfache Vektor-Assets durch passende HQ-Pixelquellen ersetzen.

Ausgang: sauberer Stand `cdefd39`; alle GitHub-Branches abgerufen. Aktuellster gemeinsamer Stand `4f35af7`, v0.60.3, per Fast-forward übernommen; alle neuen ClaudeHelper-Branches bis v0.60.3 verglichen. Bestehende längere Etappen, Durchgangsräume und Tower-Korrekturen bleiben erhalten.

Gesichtete Quellen: AGENTS, KONSISTENZ, Art Direction, Figurenkarten aller zehn Arcade-IDs, aktive Front-/Seitenzellen, Begleiter-Spielaufnahme v0.53, Arcade-Code und Bedienung, aktuelle Fahrhindernisse. Originalhelden werden nicht ersetzt. Die verworfenen v0.45-Sprites sind keine Quelle. Keine neue Lore oder Figuren ergänzt.

Neue Quellen entstehen mit dem Bildgenerator: separate 4×4-Arcade-Posenblätter pro Figur, Drohnen-/Nanitenphasen und Requisiten/FX. Originalausgaben bleiben als Herstellungsquellen in `tools/art-v061/sources/`, außerhalb des Spieleexports. Anschließende Verarbeitung beschränkt sich auf Ausschnitte, transparente Ränder, Registrierung und Atlasbau, keine programmatisch gezeichneten Ersatzkörper.

Zu erhalten: Shadepis Kasa, geschlossene rote Linsenmaske und dunkle Taktikausrüstung; Raven mit schwarzen/blauen Haaren, Cyan-Nähten, roten Schulterzeichen und 160-cm-Identität; individuelle Haarfarben, Kostüme und Cyberglieder aller Gegner. Begleiter bleibt kompakte schwarze Cyan-Drohne beziehungsweise weißer, beim Angriff roter Nanitenschwarm. Kampagnenmaßstab, Eingaben, Solo-Passivität und Koop-Zuordnung erhalten.

Geplant: echte Block-/Sprung-/Treffer-/K.O.-Bilder; Faust-, Kick- und Spezialposen mit zeitlich passendem Kontakt; registrierte Fußbasis und gespiegelt korrekte Mündungs-/Handanker. Arcade nutzt eigene größere Darstellung. Kein Drehen eines stehenden Sprites als Niederschlag. Bei Abbruch gehen Eingabe, Begleiter und Mission unverändert zurück.

## Umsetzung und Nachweise

Alle dreizehn Generatorausgaben unverändert gesichert. Der Packer fand für sämtliche Quellen leere Trenner; ausladende Spezialposen brauchten breitere Zellen. Deshalb sind die finalen Zellen 512×320 statt eines zu engen universellen Quadrats. Pro Figur ein Maßstab; Sohlenanker (224,288), keine Normalisierung einer liegenden oder kauernden Pose auf Standhöhe. Tatsächliche Ausschnitte, Platzierung und Faktoren stehen in `assets/arcade/fighters/atlas.json`. Hand-/Mündungsanker der fünf Fernkämpfer an nativen Auslösebildern kontrolliert, Spiegelung zusätzlich getestet.

| Prüffeld | Ergebnis / Beleg |
| --- | --- |
| Aktive Identität | Alle zehn Figurenkarten und aktive Original-Front-/Seitenansichten verglichen. Kampagnenhelden bytegleich zu `4f35af7`, keine verworfene v0.45-Quelle benutzt. Kasa, geschlossene Maske, Raven-Kostüm und individuelle Gegnermerkmale erhalten. |
| Material und Maßstab | Native Full-HD-Godot-Bilder; große eigene Arcade-Darstellung, Begleiter neben Originalhelden und Automat neben Raven. Neu sind generierte Metall-/Stoff-/Beton-/Öltexturen, keine programmatisch gezeichneten Ersatzfiguren. |
| Vollständige Silhouetten | `python3 tools/sprites/audit_atlases.py`: **0 sichtbare Fehler**, alle neuen Posen und FX in den Katalog aufgenommen. Keine übergreifenden Nachbarn oder abgeschnittenen Körper. |
| Kontakt / Verlauf | Alle zehn Figuren mit Faust, Kick, Spezial, Block und K.O. im nativen Renderer gesichtet; zusätzlich vollständige gezeichnete Folgen in der Quelle. 216 native Simulationsbilder zeigen sechs Kampfpaare mit Ausholen, Kontakt, Rücknahme, Rückstoß und Kombos. Hand/Mündung bei Raven, Grün, Violett und beiden Wachen kontrolliert. Drohnenstrahl folgt dem neuen Unterlauf und dem Schweben. |
| Controller / Tastatur | Neuer Test verwendet echte `InputEventJoypadButton`-Ereignisse mit isoliertem virtuellem Pad für Faust, Kick, Spezial, Sprung und Block. Bestehender Arcade-Test spielt Tastaturwahl, Duell, Treffer/Block, CPU, Rundensieg und Rückweg. Keine physische Gamepad-Hardwareprüfung behauptet. |
| Pause / Abbruch / Solo-Koop | Begleiter-Pause, Leine, passive Solo-Rolle, Padbindung und Koop über Kapitel erfolgreich geprüft. Arcade-Abbruch löscht Kämpfer und Geschosse, Rückkehr zur unveränderten Mission geprüft. Ton und Bildstilpfade werden weiterverwendet; keine Musik-/Szenenregel geändert. |
| Automatisierte Regression | **1.083 Headless-Prüfungen, 0 Fehler**: Arcade-Art 266, Arcade 56, Begleiter 24, Begleiter-Eingabe 41, Koop-Kapitel 76, Koop-Kampagne 23, Fahraktion 76, Durchgänge 69, Kernsystem 386, HQ 66. |
| Native Prüfung | Neue Arcade-Suite auf X11/Mesa: **266 Prüfungen, 0 Fehler**. Native Figurenwahl, fünf Auslöseansichten, Dachdrohne, weiße/rote Naniten, Schutzsignal, Hallenautomat und Straßenobjekte gesichtet. |
| Export | Finaler Import und Linux-PCK-Export ohne Skript-/Parsefehler. Externe native Prüfroutine direkt aus `/tmp/shadepi-v0.61.0.pck`: **277 Prüfungen, 0 Fehler**. Alle aktiven HQ-Ressourcen vorhanden; alte kleine Referenzen sowie `tools`-/Doku-Quellen nicht im Spielpaket. JSON-Anker im Paket tatsächlich geladen. |
| Dokumentation | Neue PNGs in Root-README und Doku-Einstieg. Film vollständig dekodiert: **189 WebP-Frames, 17.999 ms, 3.614.918 Byte**; 216 native Aufnahmen, identische Bilder beim Kodieren zusammengefasst. Quellen-/Werkzeug-/Stilreferenzen und Statusmanifest nachgeführt. |
| Version / Sicherung | v0.61.0 · CodexAI in Projekt, Windows-Feldern, README, Spielanleitung, Manifest und Changelog. Zwischencommit `9e774f7`; vor finaler Sicherung alle Remote-Branches erneut abgerufen, main weiterhin `4f35af7`, keine neueren fremden Änderungen. Git-Push nach Abschluss, kein Release-Tag und keine Cloud-Veröffentlichung. |

**Reproduzieren:** `/workspace/.shadepi/tools/godot --headless --script res://tests/arcade_art.gd` mit `XDG_DATA_HOME=/tmp/shadepi-…`; für echte Bilder ohne `--headless` auf X11, optional `-- --gallery` oder `-- --small`. Die neue CI-Prüfung liegt nach dem Ressourcenimport. Bestehende Suiten werden ebenfalls in separaten Testverzeichnissen ausgeführt. `tools/art-v061/gallery.gd` und `film.gd` schreiben native Aufnahmen ausschließlich nach `/tmp`.

**Sichtprüfung:** CodexAI, 15. November 2026, Godot 4.7.2, eigenes X11-Dummy-Display, OpenGL/Mesa. Film und PNGs kontrolliert. Keine vollständige manuelle Story- oder native Windows-Hardwareabnahme. Keine neuen Lore-Fakten, globale Steuerungsänderung oder geänderten Speicherstand-Enums.
