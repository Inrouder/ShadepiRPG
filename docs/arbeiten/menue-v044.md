# Menü und Kontrollpunktauswahl · v0.44.0 · CodexAI

> **Versionsbezogener Nachweis · Einordnung v0.46.2 · CodexAI:** Bilder, Befehle und Prüfzahlen gelten für den im Titel genannten Arbeitsstand. [Aktueller Repository-Status](../repository-status.md); keine pauschale Abnahme der heutigen Version.

## Auftrag und Ausgangslage
Nutzerauftrag: sichtbarer Fußkontakt auf dem Menüvorsprung, Zurück zum Desktop, letzten Kontrollpunkt laden sowie gezielte Kontrollpunktauswahl im Cheat-Menü. Ausgang `7e397f9`, v0.43.0; sauberer Arbeitsbaum. Alle Remote-Branches abgerufen und Versionsfelder verglichen: main aktuell, Entwicklungsbranches höchstens v0.21.3. Keine fremde Arbeit überschrieben.

## Referenzen und Briefing
AGENTS, KONSISTENZ, Art Direction, UI-/FX-Stilbibel und Auftragsvorlage gelesen. Tatsächlich gesichtet: `docs/startmenue.png`, aktive transparente `assets/menu/start-heroes-hq.png`, bestehende Menü-/Schattenlogik. Keine neuen Figuren, keine veränderten Merkmale oder Proportionen: Raven 160 cm, Shadepis Maske geschlossen. Bestehende Figurenebene wiederverwenden; Schatten als Bodeneffekt mit festen Sohlenankern und passender Dachverdeckung, ohne Mausdrift. Pixelrahmen, Schriften und Controller-Fokus erhalten. Vorher/Nachher im nativen Renderer prüfen.

## Geplanter Umfang und Sicherheit
Letzten gültigen Kontrollpunkt über Kapitelgrenzen nach Speicherzeit laden; alte Dateien ohne Zeitmetadaten über Dateizeit unterstützen. Vorhandene lokalen Laden-Funktionen und Speicherfelder erhalten. Test-Kontrollpunkte ausschließlich über vorhandenen separaten Admin-Dateiraum; gültige vorgegebene Zustände statt beliebiger Teleportation. Kontrollpunktwahl an vorhandene Kapitelwahl anbinden. Desktop-Schaltfläche in allen Spielmenüs, kein neuer Release-/Cloud-Publish.

## Umsetzung und Abnahme

| Prüffeld | Ergebnis und Beleg |
| --- | --- |
| Quellen und Merkmale | Vorhandene Menü-PNGs und Figurenmeshes vollständig erhalten; keine neuen Grafiken generiert. Neue Shader-Ebene ist ein Bodeneffekt. Raven bleibt 160 cm, Shadepis geschlossene Maske unverändert. |
| Sohlen und Material | `boot_contacts()` registriert vier feste Quell-UV-Sohlen mit Ravens vorhandener Pivot-/Scale-/Offset-Transformation. Enger dunkler Kern mit weichem Auslauf, Bodenreflexe darunter sichtbar, vordere Dachkante begrenzt. |
| Bewegung und Sichtbarkeit | Keine neue Maus- oder Körperbewegung. HQ und reduzierter Stil besitzen denselben Bodenkontakt. Native Bildabnahme am 9. November 2026 durch CodexAI. |
| Pixelvergleich | Tatsächliches Full-HD-Rendererbild bei festem Szenentakt mit/ohne Kontaktebene: linke Ansicht nur in x189–737 / y895–958 verändert. Je Sohlenbereich etwa 1.049–1.492 sichtbar abgedunkelte Pixel; keine Änderungen an Köpfen oder Körpern. |
| UI und Skalierung | Bestehende Pixelrahmen/Schriften für Lade-/Desktop-Aktionen. Neues Footerformat passt unter den Menürahmen. Desktop-Schaltfläche in Kapitel 1, 2 und Kampagne vorhanden. Display-Suite prüft Vollbild, Fenster und Auflösungen bis 4K. |
| Maus / Tastatur / Controller | Native Menügalerie prüft Full-HD-Mauskoordinaten und Fokus. Neue Navigationstestfolge mit synthetischen physischen Joypad-Ereignissen: Kapitel-/Kontrollpunktliste öffnen, auswählen, starten; B schließt Liste vor Testfenster, Start hält Hauptmenü pausiert. Desktop-Aktion beendet tatsächlich den Testprozess. Kein physisches Gamepad angeschlossen. |
| Laden / Kompatibilität | Optionales präzises Zeitfeld je Slot; ältere Dateien über Änderungszeit. Neuester gültiger Kontrollpunkt über tatsächlichen Szenenwechsel geladen. Fehlende, falsche Typen und unzulässige Zustände berücksichtigt. Solo/Koop in Kapitel 1 und die bisherigen Einzelspielerstände in 2–7 erhalten. |
| Normale / Test-Dateien | Nur innerhalb des vorhandenen separaten Admin-Dateiraums testen. Alle 40 Einträge durchlaufen; normaler Tower-Spielstand bleibt unverändert. Fixture-Test verweigert Ausführung außerhalb eines isolierten `/tmp/shadepi-…`-Datenverzeichnisses. GitHub-CI erzeugt dafür ein eigenes temporäres XDG-Verzeichnis. |
| Direkte Storyzustände | Memory-2/3 besitzen nur die jeweils vorherigen Abschlussflags. Extraktion startet mit lebendem besiegtem Kenzō und aktiver Abwehr; Fluchtpunkte mit abgeschlossener Extraktion. Jagdabschnitte und Relais direkt anwählbar. Keine normalen Charakterbewegungen oder Kampfinhalte ersetzt. |
| Ton und Pause | Musikzuordnung unverändert. Menü und Testfenster halten das Spiel wie bisher an; Galerie mit Dummy-Audio, keine neue akustische Bewertung. |

## Automatisierte Prüfungen

| Suite | Prüfungen / Fehler |
| --- | --- |
| `tests/run.gd` | 383 / 0 |
| `tests/menu_checkpoints.gd` | 205 / 0 |
| `tests/menu_navigation.gd` | 13 / 0, headless **und zusätzlich nativ**, im Gesamtwert einmal gezählt |
| `tests/display_settings.gd` | 73 / 0 |
| `tests/story_audit.gd` | 206 / 0 |
| `tests/chapter_one_intro.gd` | 52 / 0 |
| `tests/tower_sequence.gd` | 42 / 0 |
| `tests/sanctuary_story.gd` | 27 / 0 |
| **Gezielte Regression** | **1.001 / 0** |
| Eigenständiges Exportpaket | **10 / 0** |

Datei-Fixtures sicher getrennt ausführen, zum Beispiel:

```sh
XDG_DATA_HOME=/tmp/shadepi-menu-tests-local godot --headless --script res://tests/menu_checkpoints.gd
XDG_DATA_HOME=/tmp/shadepi-menu-nav-local godot --headless --script res://tests/menu_navigation.gd
```

## Export, Aufnahmen und Sicherung

Godot-Import und Linux-Ressourcenexport erfolgreich: `/tmp/shadepi-v0.44.0.pck`. Externer Prüfer `/tmp/shadepi-v044-pack-check.gd` startet aus dem leeren Verzeichnis `/tmp/shadepi-v044-packed`, lädt neue Schattenressource und Menüaktionen, prüft Zeitmetadaten sowie echte direkte Einstiege in Erinnerung 3 und Extraktion. Desktop-Schaltfläche beendet auch den Paketlauf. Tatsächliches Exportbild `/tmp/shadepi-v044-packed-menu.png`. Kein neuer nativer Installer, Tag oder veröffentlichter Release erstellt.

[Sieben PNG-Spielaufnahmen einschließlich Vergleich und Film](../menue-kontrollpunkte.md); direkt eingebettete Vorschauen in Root-README und Doku-Galerie. Aufnahmeprogramm `tools/menu_checkpoint_gallery.gd`: 115 Bilder, tatsächliche Zeitabstände, Full-HD-Standbilder und 1280×720-Menüfilm; der gestartete Towerabschnitt rendert im normalen 640×360-Spielraster. Der Schattenvergleich schaltet ausschließlich die neue Kontaktebene aus und ist als Diagnosebild gekennzeichnet. Galerie und native Controller-/Maus-/Fokusprüfungen mit OpenGL/Mesa.

Alle Remote-Branches vor Beginn und vor Sicherung erneut abrufen/vergleichen; Ausgang main v0.43.0, frühere Entwicklungsbranches höchstens v0.21.3. Versionsfelder 0.44.0 / Windows 0.44.0.0, CodexAI-Vermerk und Änderungen dokumentiert. Sicherungsziel GitHub main; keine Cloud-Veröffentlichung.

**Ergebnis:** Menüwünsche umgesetzt, alle 40 Test-Einstiege und Laden/Beenden geprüft. Die nächste Cinema-Arbeit bleibt Kapitel 3; dieser Menüauftrag nimmt keine weiteren Storyänderungen vorweg.
