# Kapitel 1 inszenieren · v0.43.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgangslage
Fortsetzung der Cinema-Roadmap: sichtbare Auftragsannahme, Ausrüstungsprüfung und erster Shadepi-Auftritt. Ausgang: `4a971c5`, v0.42.0. Alle Remote-Branches abgerufen: main unverändert am neuesten Stand, bekannte Entwicklungsbranches höchstens v0.21.3. Keine lokalen/fremden Änderungen vorhanden. Kapitel-1-Kämpfe und Kontrollpunktformat erhalten.

## Referenzen
AGENTS.md, KONSISTENZ.md, Stilbibel/Art Direction, Figurenkarten Raven und Shadepi, Welten sowie Auftragsvorlage gelesen. Tatsächlich betrachtete PNGs: `docs/stilbibel/bilder/figur-raven.png`, `figur-shadepi.png`, aktive Kulissen `assets/world/painted/apartment.png` und `rooftop.png`. Roman Kapitel 1 in Archiv Teil 4: Raven nimmt Jackals Kopfgeld an; Shadepi beobachtet die Stadt und greift später ein. Keine neue Prämienhöhe oder Erklärung des Auftraggebers erfinden.

## Grafikbriefing
Neue echte transparente HQ-Pixelposen: Raven greift zum Terminal, bestätigt, prüft Pistole und verstaut sie; Shadepi kauert/beobachtet auf dem Sims, landet und richtet sich auf. Schwarze Materialien statt bronzener Körnung, Raven 160 cm ohne erfundene Größe Shadepis. Körperhöhe gegen normalen Helden kalibrieren, Boden-/Handpunkte je Quellzelle registrieren, linear wie Nachbarsprite. Normale Körper/Schatten bei Ersatzpose vollständig ausblenden und bei Abbruch wiederherstellen. Fensterlose Spezialansicht nur für Dachzwischenschnitt, keine Änderung der Spielkarte. Keine Vektorersatzfiguren; vorhandene Kulissen wiederverwenden.

## Umsetzung und Nachweis

- **Aktive Figuren und Materialien:** acht neue Kontaktbilder, vorhandene Helden und Kulissen. Sichtabgleich im nativen Godot/OpenGL-Renderer am 9. November 2026 durch CodexAI. Raven 160 cm, Schwarz/Cyan/Rot und schwarze/blaue Haare; Shadepis Kasa, geschlossene segmentierte Maske und dunkle Weste/Stoffbahnen erhalten. Kein menschliches Gesicht erfunden.
- **Quelle/Raster/Alpha:** unveränderte transparente PNG-Quelle 1774×887, vollständige Silhouetten und pro Zelle registrierte Füße. Leere Ecken Alpha <0,02, keine Matte-/Freistellshader. Quellreferenzen und alle acht Kontakte im [Asset-README](../../assets/story/chapter-one/README.md).
- **Maßstab/Kontakt:** 0,149; Raven im Stand ungefähr 58,9 Weltpixel gegenüber den üblichen 57–59. Terminalhand trifft `apartment_point(160,240)`; Kamera auf tatsächliche Wohnraumgrenzen begrenzt. Normalen Körper, Kontakt-/Wurfschatten und Occluder gemeinsam verstecken; vorherigen Sichtbarkeitszustand wiederherstellen. Kein zusätzlicher doppelter Schatten während Ersatzposen. Auf dem Dach eigener Kamerafaktor 1,8. Bestehende Skyline links ohne Konzernlogo/Landeplatz; keine neue Tower-Spielkarte.
- **Ablauf und FX:** Monitor bestätigen → Pistole prüfen → holstern → Türweg → Shadepis Blick über die Stadt. Nach Bedrohung zweiter Gegenschnitt → tiefe Sprunglandung → Wasserspritzer → Aufrichten → bekannte Rettungswellen. Keine als Kniebeuge gedrehte Standfigur. Zwei Kauerbilder sind begrenzte Schlüsselbilder, keine vollständige Windanimation. Bestehenden Regen-/Bildstil verwenden, keine neuen Vektorkulissen.
- **Steuerung/Pause/Ton:** bestehende E/Enter/A-Weiter-, Leertaste/B-Überspringen- und Esc/Start-Pausenbelegung. Neuer Test hält Kontakt-/Landephase über mehrere Pauseframes; Basis-Suite umfasst bestehende Controllerpfade. Kein physischer Controller angeschlossen und keine neue Hardwareabnahme behauptet. Galerie mit Dummy-Audio; vorhandene Hack-/Metall-/Aufprallklänge wiederverwendet, kein neuer Soundentwurf.
- **Laden/Abbruch/Speicher:** Abbrüche an Angebot, Pistolenprüfung, Dach und vor dem Aufprall geprüft. Generationstickets nach jedem await; wartende Regisseurschritte bei Abbruch wecken. Nachfolgende Jagd-/Team-/Rettungsstände werden nicht verspätet verändert. Kontrollpunktformat unverändert, vorhandene Spielstände kompatibel.

| Prüfung | Ergebnis |
| --- | --- |
| `tests/run.gd` | 383 / 0 Fehler |
| `tests/chapter_one_intro.gd` | 52 / 0 Fehler, kein Ressourcenrest beim Ende |
| `tests/story_audit.gd` | 206 / 0 Fehler |
| `tests/arcade_waves.gd` | 246 / 0 Fehler |
| `tests/cinematic_blocking.gd` | 50 / 0 Fehler |
| `tests/ice_bath.gd` | 49 / 0 Fehler |
| `tests/hangar_discovery.gd` | 38 / 0 Fehler |
| `tests/lake_sequence.gd` | 32 / 0 Fehler |
| `tests/tower_sequence.gd` | 42 / 0 Fehler |
| `tests/sanctuary_story.gd` | 27 / 0 Fehler |
| **Gezielte Regression gesamt** | **1.125 / 0 Fehler** |
| Exportiertes Paket | **10 / 0 Fehler**, Version, Quelle, Filmschritte und Bereinigung |

Eigenständiges Linux-Ressourcenpaket `/tmp/shadepi-v0.43.0.pck` mit Godot exportiert und aus einem leeren Arbeitsverzeichnis gestartet. Der externe Prüfer `/tmp/shadepi-v043-pack-check.gd` lädt die gepackten Bilder/Skripte, überspringt den Auftakt bis zur ersten Welle, durchläuft den Monitorzugriff, zeigt die Dachansicht und prüft die Landung samt Rücksetzung. Native Exportaufnahme `/tmp/shadepi-v043-packed-offer.png`. Kein neuer nativer Installer oder veröffentlichter Release erstellt.

## Bildnachweise und Sicherung

[Bericht mit vier nativen PNG-Aufnahmen und zwei WebP-Filmen](../kapitel1-auftakt.md). Root-README und zentrale Doku-Galerie betten die PNGs direkt ein. Aufnahmeprogramm `tools/chapter_one_gallery.gd`; jüngster Durchlauf 124 Auftakt- und 57 Rettungsbilder mit tatsächlichen Zeitabständen. Zweiter Clip setzt per QA den vorherigen Kampf auf die Bedrohung; kein vollständiger manuell erspielter Durchgang aller Kapitel behauptet.

Version 0.43.0, Windows 0.43.0.0, CodexAI-Vermerk und Änderungsinfos konsistent. Alle Remote-Branches vor Beginn und vor Sicherung erneut verglichen: main v0.42.0 (`4a971c5`), übrige Entwicklungsbranches höchstens v0.21.3. Neue Arbeit auf diesem Stand; keine fremden Änderungen überschrieben. Git-Push auf main erfolgt nach abschließender Link-/Versionsprüfung; keine Cloud-Veröffentlichung.

**Ergebnis:** Kapitel-1-Block fertig und visuell geprüft. Nächster vorgemerkter Cinema-Block: Kapitel 3, Pakt und Planung; verbleibende Zwischenbilder stehen ausdrücklich in der Roadmap.
