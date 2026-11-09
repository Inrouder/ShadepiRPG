# Projektaufbau · v0.46.2 · CodexAI

[Aktuelle Spielanleitung](../Spiel-README.md) · [Repository-Status](repository-status.md) · [Asset-Katalog](../assets/README.md) · [Werkzeuge](../tools/README.md).

## Laufzeit

`project.godot` startet `scenes/chapter_one.tscn`. Godot 4.7.2 Standard, Compatibility-Renderer. `scripts/main.gd` ist die gemeinsame Laufzeitbasis; `scenes/main.tscn` ist zusätzlich eine separate Test-/Demo-Szene und darf nicht als ungenutzter Altcode entfernt werden.

| Bereich | Zuständigkeit |
| --- | --- |
| Kapitel 1 | `chapter_one.gd`, Auftakt, Jagd-/Rettungswellen und Jackal. |
| Kapitel 2 | `chapter_two.gd`, Industrie, Eisbad und Deep Dive. |
| Kapitel 3–7 | `campaign.gd` / `campaign_story.gd`, weitere Kampagne und kontrollpunktkompatible Zustände. |
| Dialoge und Inszenierung | `cutscene.gd`, kapitelspezifische Szenenfunktionen und eigene Kontakt-/Sequenzmodule. Keine Laufzeit-Comictafeln mehr. |
| Bewegung / Figuren / Kampf | `pixel_actor.gd`, `player.gd`, `enemy.gd`, `combat_rules.gd`, `sprite_assets.gd`. Originalhelden plus Custom-Priorität. |
| Treffer und Atmosphäre | `effects.gd`, `blood_fx.gd`, `scene_atmosphere.gd` und Ortsprofile. |
| Räume / Objekte | `painted_world.gd`, `world_dressing.gd`, `world_prop.gd` und jeweilige Art-/Ankerdateien. |
| Fahrzeuge | `campaign_drive.gd`, `aerodyne_flight.gd`, `aerodyne_art.gd`, `motorcycle_art.gd`, Verfolger-/Drohnenrenderer. |
| Erinnerungen | `scripts/memories/`; `legacy_*` ist die aktive dritte Erinnerung „Das Vermächtnis“. |
| Tower | `tower_story.gd`, `tower_extraction.gd`, Kenzō-/Fluchtmodule; Extraktion vor endgültiger Vernichtung, Abflug vom Dach-Landeplatz. |
| Speicherung / Testeinstiege | `save_service.gd`, Kapiteldateien, `checkpoint_resume.gd`, `test_checkpoints.gd`, `admin_tools.gd`. Normale-/Test- sowie Solo-/Koop-Dateien getrennt. |
| Menü / HUD / Controller | `hud.gd`, Kapitel-HUDs, `start_menu_backdrop.gd`, `gamepad_bindings.gd` und Eingabeprofile. |

Numerische Kapitel-/Abschnittswerte sind Teil bestehender Spielstände; Enum-Reihenfolge nicht als chronologische Sortierung behandeln. `chapter_flow.gd` unterscheidet Story-Ausgang und Menü-Fortsetzen. Aktuelle Szenen- und Kontinuitätsregeln stehen in [KONSISTENZ](../KONSISTENZ.md).

## Quellen, Import und Export

Die aktiven PNGs, MP3s, Schriften und Effekte liegen unter `assets/`; Rohposen und Quellwerkzeuge unter `tools/`. Grafiken sind bereits enthalten, Compiler/Generatoren werden beim normalen Projektimport nicht ausgeführt. Das Godot-Importcache-Verzeichnis `.godot/` ist generiert und nicht versioniert; `*.import`-Konfigurationen aktiver Assets werden dagegen bewusst erhalten.

Das [Entwicklungsarchiv](archiv/README.md) enthält verworfene Quellen, alte Comictafeln und frühere Anleitungen. `.gdignore` und Exportfilter trennen es von der Laufzeit. Einige historische Vergleichsbilder bleiben für Vorher-Galerien an stabilen Assetpfaden, sind aber ebenfalls vom Export ausgeschlossen. [Statuskatalog](repository-status.json) und [Audit](../tools/audit_repository.py) prüfen die Grenze. Das Universumsarchiv bleibt eine inhaltlich verbindliche Quelle, kein Altcode.

## Prüfung

[CI-Workflow](../.github/workflows/build.yml): Repository-Audit, Godot-Import, gezielte Spiel-/Darstellungsprüfungen und Windows-/Linux-Export. Neue Testeinstiege und lokale Tests brauchen ein isoliertes `XDG_DATA_HOME`, damit persönliche Spielstände erhalten bleiben. Skripte in `tools/` sind Entwicklungs-/QA-Werkzeuge; nach API-Änderungen vor Benutzung prüfen. Native Renderaufnahmen sind keine manuelle Abnahme jedes Spielabschnitts und ein Linux-Windows-Export keine tatsächliche Windows-Ausführung.
