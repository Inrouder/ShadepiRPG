# Projektaufbau · v0.12.0

## Einstieg und Kapitel

`project.godot` startet `scenes/chapter_one.tscn`. Das Projekt verwendet Godot 4.7.2 Standard mit dem Compatibility-Renderer.

| Szene / Skript | Aufgabe |
| --- | --- |
| `scenes/chapter_one.tscn`, `scripts/chapter_one.gd` | Einstieg, Raven/Jackal, Shadepis Rettung und Kapitelabschluss |
| `scenes/chapter_two.tscn`, `scripts/chapter_two.gd` | Industriegebiet und Deep Dive |
| `scenes/campaign.tscn`, `scripts/campaign.gd` | Kampagne ab Kapitel 3 |
| `scripts/campaign_story.gd` | Kapiteltexte, Dialoge und Missionsziele |
| `scripts/campaign_drive.gd` | Fahrzeugsequenzen |
| `scenes/main.tscn`, `scripts/main.gd` | Separate Gameplay-Testszene |

## Kulissen und Requisiten

- `scripts/painted_world.gd` ordnet 16 PNG-Kulissen aus `assets/world/painted/` zu und definiert begehbare Bereiche, Hindernisse und Vordergrunddarstellung.
- `scripts/world_dressing.gd` enthält die Requisiten-Anordnungen je Umgebung.
- `scripts/world_prop.gd` implementiert das Verhalten der Weltobjekte.
- `assets/world/levels/` und `assets/world/destructibles.png` ergänzen die Weltressourcen.

## Figuren und Medien

- `scripts/pixel_actor.gd`: Blickrichtung, Animation, Schatten und Material.
- `scripts/sprite_assets.gd`: Auswahl und Prüfung der Spritesheets, einschließlich eigener Figuren.
- `assets/sprites/heroes/`: HQ-Atlanten von Raven und Shadepi.
- `assets/custom/`: optionale eigene Figuren mit Vorrang vor den Standardgrafiken.
- `tools/hero_sources/` und `tools/compile_heroes.py`: originale Schlüsselposen und Zusammenstellung der Heldenatlanten.

Raster und Bearbeitungsregeln: [HQ-Sprites](helden-sprites.md) und [Figuren bearbeiten](figuren-bearbeiten.md).

## Gameplay und Prüfung

`player.gd`, `enemy.gd` und `combat_rules.gd` steuern Bewegung und Kampf. HUD-Skripte verwalten Anzeigen, Menüs und Dialoge. `save_service.gd` enthält die Speichervalidierung; die Kapitel besitzen eigene Kontrollpunkte.

`tests/run.gd` prüft unter anderem Kapitelabläufe, Kampagne, Koop, Controller und Heldenanimationen. Der Workflow in `.github/workflows/build.yml` importiert das Projekt, führt die Tests aus und exportiert Windows und Linux. Bei einem Versions-Tag ist zusätzlich ein Release-Schritt vorgesehen.

## Herkunft

Dieser Quellstand wurde aus dem originalen Windows-Spiel wiederhergestellt und durch Dateien aus dem HQ-Archiv ergänzt. Die [Wiederherstellungsdokumentation](v0.12.0-wiederherstellung.md) nennt die Medienverluste und Prüfgrenzen. `.godot/` ist ein generierter Importcache und gehört nicht zu den versionierten Quellen.
