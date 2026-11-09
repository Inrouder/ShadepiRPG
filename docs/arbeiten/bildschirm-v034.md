# Konsistenzauftrag und Arbeitsnachweis · v0.34.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgangslage

- **Nutzerziel:** 16:9-Vollbild und Fenstervollbild, mitwachsendes Spielbild statt kleinem Bild im größeren Fenster; 1080p und höhere Ausgabe.
- **Ausgangscommit:** `2b563278575203c36c0de3ae1d8db125fc201255`, v0.33.0, sauberer Branch `work`, identisch mit `origin/main`.
- **Aktualität:** Alle Remote-Branches vor Beginn und nochmals vor Sicherung abgerufen. Die Entwicklungsbranches enden bei v0.21.3; keine neuere fremde Arbeit oder lokale Änderungen zu übernehmen. Kein erzwungener Reset/Push.
- **Betroffen:** `project.godot`, Anzeige-Autoload und -Dialog, gemeinsames HUD samt Kapitel-Hinweisen, Controller-Cancelbindung, Prüfungen, Dokumentation und Versionsfelder.
- **Umfang:** Ausgabe-/Fensterverhalten und entsprechende Bedienung. Keine Welt-, Figuren-, Story-, Kampf- oder Musikänderung. Keine Cloud-Veröffentlichung.
- **Neue Version:** **v0.34.0 · CodexAI**, einschließlich Windows-Datei-/Produktversion 0.34.0.0 und beider READMEs.

## Referenzen und unveränderte Merkmale

Figuren-IDs, Anatomie, Archiv- und Storymerkmale sind bei reiner Ausgabe-Skalierung nicht zu bearbeiten. Verbindliche Regeln, Stilbibel und Art Direction gelesen; vorhandene UI-/Menüreferenzen und die echten Spielansichten betrachtet.

| Zweck | Tatsächlich verwendeter Pfad / Referenz | Übernahme |
| --- | --- | --- |
| Projektstandard | `KONSISTENZ.md`, `docs/stilbibel/README.md`, `docs/stilbibel/artdirection.md` | HQ-Pixelstil, Spielgröße, keine Ersatzfiguren. |
| Spiel- und Menügröße | `project.godot`, `scripts/hud.gd`, `tools/menu_gallery.gd` | Logische 640×360, HQ-Menü in Fensterauflösung, Gameplay im Pixel-Viewport. |
| Pixel-UI | `docs/pixel-ui.md`, `scripts/ui_skin.gd`, `assets/ui/` | Vorhandene Fonts, texturierte Stahlrahmen, Fokus und Farben pro Kapitel. |
| Zusätzliche Kapitelknöpfe | `chapter_hud.gd`, `chapter_two_hud.gd`, `campaign_hud.gd` | Anzeige neben Ton statt Überschneidung mit Fortschritts-/Kapitelwahl. |
| Reale Größenreferenz | Native Aufnahmen in `docs/bildschirm/`, weitere unter `/tmp/shadepi-display/` | Figurengröße relativ zur Welt, HUD-Ränder und unverzerrtes 16:9. |

Keine historische Grafik als neue Stilvorgabe verwendet. Alle Quellgrafiken wiederverwendet; die neuen PNGs sind tatsächliche Bildschirmnachweise, keine Spiel-Assets. Full-HD-/4K-Ausgabe bedeutet Skalierung vorhandener Pixelgrafik, keine erfundenen zusätzlichen Grafikdetails.

## Grafik- und Animationsbriefing

Keine neuen Figurenposen, Kontaktanimationen, Atlanten, Masken, Haare, Stoffbewegungen oder Fahrzeuge. Zellformate, Transparenz, Weltmaßstab, Fuß-/Sitz-/Hand-/Mündungsanker und deren individuelle Filter bleiben erhalten. Nur die finale Window-Transformation verändert die Ausgabegröße; Kameraausschnitt und Seitenverhältnis bleiben 640:360. Regen und bestehende Animationen laufen wie bisher; die Optionen öffnen innerhalb der vorhandenen Spielpause.

Der Dialog verwendet eigene feste UI-Koordinaten mit vorhandenen Pixelrahmen und Farben. Modus, Fenstergröße und Skalierung erhalten eine geschlossene Fokusfolge. B/Esc schließt zuerst Listen und danach den Dialog. F11 bei fokussierter Fenstergröße verschiebt den Fokus auf Modus, wenn das Feld im Vollbild deaktiviert wird. Bei Szenenwechsel bleibt nur die zentrale Anzeigepräferenz bestehen; kein offenes Dialogfenster.

## Abnahme

| Prüfpunkt | Ergebnis und Beleg |
| --- | --- |
| Aktive Quellen und Merkmale | Nur vorhandene Grafikquellen; native Menü-/Gameplay-Aufnahmen zeigen dieselben Figuren und Räume. |
| Spielgröße, Material, Abtastung | 640×360-Spielbasis, `VIEWPORT` in Spiel/Pause und `CANVAS_ITEMS` im Hauptmenü. Godot-Transformationen mit höchstens einem physischen Rundungspixel Abweichung geprüft. |
| Alpha/Silhouette und Kontaktanker | Keine Grafikmutation; im Full-HD-Spiel und 4K-Vollbild gesichtet. |
| Animation und Pause | Reale Menü-/Spielaufnahmen einschließlich Regen; Pausenmenü mit kapitelgerechtem Pixelthema gesichtet. Vorhandene Flug-/Heiligtum-/Towerabläufe bleiben durch Regressionstests abgedeckt. |
| Controller/Tastatur/Maus | Rohe Eingabeereignisse: skalierter Klick, D-Pad, A, B, Listenabbruch, Esc, F11, Alt+Enter, Tastaturwiederholung, Fokus bei Moduswechsel. |
| Bildstil/Ton | Vorhandene Schalter und Qualitätsrenderer erhalten; Ton und Anzeige teilen sich eine Zeile, Kapitelknöpfe behalten ihren Platz. |
| Laden/Abbruch/Szenenwechsel | Defekte Präferenzen und getrennte Speicherung geprüft; Autoload bleibt beim Kapitelwechsel, Dialog bleibt geschlossen. Spielstände und Kapitelkontrollpunkte durch bestehende Prüfreihen validiert. |
| Automatisierte Prüfungen | **967 Prüfungen ohne Fehler**: Anzeige 73, Gameplay/Saves 383, Terminal-Controller 186, Tower 42, Story 206, Heiligtum 27, Flug 50. Neue Anzeigenprüfung im GitHub-Build. |
| Echte Bildschirmprüfung | **16 zusätzliche Desktop-Prüfungen ohne Fehler**, insgesamt **983**. Physische 1920×1080-, 2560×1440-, Monitor-eingepasste 4K-Fenster sowie beide nativen 3840×2160-Vollbildmodi. 1920×1000 nutzt volle Höhe; Ultrawide/4:3 zusätzlich per tatsächlicher Window-Transformation geprüft. |
| Normaler Start | Normale Hauptszene ohne Galerie-Script auf frischem Benutzerpfad gestartet: X11-Clientfenster tatsächlich 3840×2160 an Position 0,0. |
| Export | Linux-Ressourcenpaket `/tmp/shadepi-v0.34.0.pck` gebaut und außerhalb des Repositories mit `--headless --main-pack … --quit-after 30` fehlerfrei gestartet. Autoload und Anzeige-HUD werden aus dem exportierten Paket geladen. Keine neue Release-Veröffentlichung. |
| Version und Sicherung | v0.34.0 · CodexAI; Git-Push gemäß dauerhafter Nutzerfreigabe nach Prüfung. |

**Sichtprüfung durch:** CodexAI, 9. November 2026 (Europe/Berlin), Godot 4.7.2 mit OpenGL/Mesa auf Linux/X11, xfwm4, 4K-Desktop.

**Einschränkung:** Windows-Anzeigetreiber hier nicht ausführbar. Native Fenster-/Vollbildprüfungen erfolgten unter Linux. Exklusives Vollbild hängt von der Betriebssystemunterstützung ab. Die hochauflösende Ausgabe fügt Gameplay-Assets keine neuen Quellpixel hinzu.

**Ergebnis:** Ausgabe und Bedienung fertig, gesichtet und im Ressourcenpaket gestartet. Änderungen werden mit dem zugehörigen v0.34.0-CodexAI-Commit auf `origin/main` gesichert.
