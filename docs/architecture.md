# Aufbau der Testszene

`scenes/main.tscn` lädt `scripts/main.gd`. Der Szenenaufbau erfolgt bewusst im Code, damit Positionen, Kollisionen und Ressourcen nachvollziehbar bleiben.

| Datei | Verantwortung |
| --- | --- |
| `world_data.gd` | Weltgrenzen, Gebäude, Objekte und Interaktionspunkte; gemeinsame Geometrie für Szene, Speichervalidierung und Erreichbarkeitstests |
| `pixel_actor.gd` | PNG-Spritesheet, Richtung, Animationsauswahl, Schatten und Material |
| `player.gd` | Bewegung, Angriffskombination, Energie, Ausweichen, Tarnung und Schaden |
| `enemy.gd` | Angriffsvorbereitung, Vorstoß, Erholung, Hackstatus und Tod |
| `combat_rules.gd` | Trefferkegel, Reichweite und Panzerungsschaden |
| `main.gd` | Zusammenspiel, Missionszustände, Kollisionen, Kamera, Audio und Interaktionen |
| `hud.gd` | Anzeigen, Dialoge und Start-/Pausenmenü |
| `effects.gd` | Begrenzte Partikel, Klingenspuren, Regen und Dampf |
| `save_service.gd` | Größen- und Schema-Prüfung, temporäres Schreiben und Backup-Wiederherstellung |

Missionszustände: `0` Raven ansprechen; `1` Terminal; `2` Kampf; `3` Daten sichern; `4` freies Erkunden nach Abschluss. Ein gespeicherter Zustand muss mit dem Lebensstand des Gegners und einer begehbaren Spielerposition übereinstimmen.

Die Hauptgrafik ist eine statische Rastertextur. Bewegliche Akteure und Requisiten werden nach Y sortiert. Kollisionen liegen in Ebene 1, Akteure in Ebene 2. Strahlen für Nahkampf und Hacks beachten nur Hindernisse. Effekte sind auf 128 Partikel und 16 Ausweichspuren begrenzt. Es laufen sechs lokale Lichtquellen; die Szene verwendet keine teuren Vollbildreflexionen.

Für einen echten Screenshot kann der Editor-Binary mit `-- --capture` gestartet werden. Dieser Modus platziert die Figuren für das Bild, rendert die tatsächliche Szene und speichert `docs/screenshot.png`. Er verändert keinen Spielstand.
