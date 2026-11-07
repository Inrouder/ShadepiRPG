# Projektaufbau · v0.14.0

## Einstieg und Kapitel

`project.godot` startet `scenes/chapter_one.tscn`. Das Projekt verwendet Godot 4.7.2 Standard mit dem Compatibility-Renderer.

| Szene / Skript | Aufgabe |
| --- | --- |
| `scenes/chapter_one.tscn`, `scripts/chapter_one.gd` | Einstieg, Raven/Jackal, Shadepis Rettung und Kapitelabschluss |
| `scenes/chapter_two.tscn`, `scripts/chapter_two.gd` | Industriegebiet und Deep Dive |
| `scenes/campaign.tscn`, `scripts/campaign.gd` | Kampagne ab Kapitel 3 |
| `scripts/campaign_story.gd` | Kapiteltexte, Dialoge und Missionsziele |
| `scripts/campaign_drive.gd` | Motorrad-Verfolgung (Kapitel 3) |
| `scripts/aerodyne_flight.gd` | Aerodyne-Flug zum Tower mit Turmabwehr und Landung (Kapitel 6) |
| `scripts/sequence_calibration.gd` | Minispiel Sequenzkalibrierung am Tower-Scanner |
| `scripts/parked_aerodyne.gd` | gelandeter Aerodyne auf dem Tower-Landeplatz |
| `scenes/main.tscn`, `scripts/main.gd` | Separate Gameplay-Testszene |

## Kulissen und Requisiten

- `scripts/painted_world.gd` ordnet 16 PNG-Kulissen aus `assets/world/painted/` zu und definiert begehbare Bereiche, Hindernisse und Vordergrunddarstellung.
- `scripts/world_dressing.gd` enthält die Requisiten-Anordnungen je Umgebung.
- `scripts/world_prop.gd` implementiert das Verhalten der Weltobjekte.
- `assets/world/hq/props.png`, `assets/world/hq/vehicles.png` und `assets/audio/` enthalten die ergänzenden Requisiten und Geräusche. Die früheren prozeduralen Levelbilder werden nicht mehr benötigt.

## Figuren und Medien

- `scripts/pixel_actor.gd`: Blickrichtung, Animation, Schatten und Material.
- `scripts/sprite_assets.gd`: Validierung der Atlasraster und optionaler Custom-Sprite-Override; keine Pixel-Proxy-Umleitung mehr.
- `assets/sprites/heroes/`: direkt geladene HQ-Atlanten von Raven und Shadepi.
- `assets/sprites/npcs/`: direkt geladene HQ-Atlanten und digitale Gegner.
- `assets/custom/`: eigene Grafiken mit Vorrang vor Standardgrafiken; ältere selbst erstellte Pixelraster bleiben kompatibel.
- `tools/hero_sources/` und `tools/npc_sources/`: originale Schlüsselposen; `tools/compile_heroes.py` und `tools/compile_npcs.py` stellen die HQ-Atlanten zusammen.
- `tools/generate_assets.cjs`: Generator nur für Lichttextur und Basissounds.

Raster und Bearbeitungsregeln: [HQ-Sprites](helden-sprites.md) und [Figuren bearbeiten](figuren-bearbeiten.md).

## Entwickler-Testmenü

`scripts/admin_tools.gd` speichert die Testschalter, verwaltet die Kapitelzuordnung per Szenen-Metadaten und trennt die Kontrollpunktdateien vom normalen Profil. `scripts/hud.gd` enthält die versteckte Bedienoberfläche. Spieler, Gegner, Fahrzeugsequenzen und Flucht berücksichtigen die Testschalter, während Story-Sperren bei regulären Treffern bestehen bleiben. Weitere Hinweise: [Admin-Testmodus](admin-testmodus.md).

## Gameplay und Prüfung

`player.gd`, `enemy.gd` und `combat_rules.gd` steuern Bewegung und Kampf. HUD-Skripte verwalten Anzeigen, Menüs und Dialoge. `save_service.gd` enthält die Speichervalidierung; die Kapitel besitzen eigene Kontrollpunkte.

`tests/run.gd` prüft unter anderem Kapitelabläufe, Kampagne, Koop, Controller und Heldenanimationen. Der Workflow in `.github/workflows/build.yml` importiert das Projekt, führt die Tests aus und exportiert Windows und Linux. Bei einem Versions-Tag ist zusätzlich ein Release-Schritt vorgesehen.

`chapter_flow.gd` unterscheidet den einmaligen Einstieg nach einem Story-Abschluss von einem Menüaufruf mit vorhandenem Kontrollpunkt. Die numerischen Kapitel-/Abschnittswerte bleiben für bestehende Spielstände unverändert; ihre Reihenfolge im Enum ist keine chronologische Sortierung.

`tests/story_audit.gd` prüft echte Szenenwechsel mit alten Spielständen, die chronologische Kampagnenfolge, Wiederherstellung, Hackreichweite, Erinnerungspunkte und Textlayout. Ein Rasterlauf prüft Wege mit Godots Physikabfragen und dem tatsächlichen Spielerradius (7 Pixel), einschließlich intakter Requisiten. Kontrollabfragen stellen sicher, dass die Physikkörper aktiv sind. `tools/story_gallery.gd` erzeugt eine Renderübersicht und einzelne Szenenbilder im Godot-Benutzerverzeichnis.

Die Tests erzeugen Kontrollpunkte. Lokal dafür ein separates Godot-Benutzerverzeichnis verwenden; nicht mit persönlichen Spielständen ausführen. Der CI-Runner ist unabhängig von lokalen Spielständen.

## Herkunft

Dieser Quellstand wurde aus dem originalen Windows-Spiel wiederhergestellt und durch Dateien aus dem HQ-Archiv ergänzt. Die [Wiederherstellungsdokumentation](v0.12.0-wiederherstellung.md) nennt die Medienverluste und Prüfgrenzen. `.godot/` ist ein generierter Importcache und gehört nicht zu den versionierten Quellen.

- `scripts/prop_art.gd`: HQ-Atlasregionen, Darstellungsgrößen und Schadenszustände.
- `tests/drive_action.gd`: Flugnotfall und Verfolgungsphysik; `tools/generate_drive_audio.py`: reproduzierbare Fahrzeugsounds.
