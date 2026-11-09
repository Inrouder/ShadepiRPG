# Assets: aktive Quellen, Vergleich und Sicherungen

**v0.46.2 · CodexAI.** [Repository-Status](../docs/repository-status.md) · [Verbindliche Stilbibel](../docs/stilbibel/README.md).

| Gruppe | Status / heutige Verwendung |
| --- | --- |
| `sprites/heroes/raven.png`, `shadepi.png` | **Aktiv:** unveränderte Originalhelden; keine automatische Ersatzvariante. |
| `sprites/heroes/combat-poses.png`, `raven-hand-cast.png` / `.json` | **Aktiv:** Ladung, Kick, Ravens Handblitze und Anker. |
| `sprites/npcs/` | **Aktiv:** Gegner, Kontaktposen und Datenwesen; individuell registrierte Raster/Größen beachten. |
| `sprites/heroes/backup-v0441/` | **Backup:** bytegleiche gewünschte Helden-Sicherungen; im Git, nicht im Spieleexport. |
| `custom/` | **Eigene aktive Ersetzungen:** haben bei gültigem Raster Vorrang. [Regeln](custom/README.md). |
| `menu/` | Aktive Stadt und HQ-Figuren; ältere Illustration nur Referenz. [Dateistatus](menu/README.md). |
| `story/` | **Aktiv:** Kontakt-, Fahr- und Szenenquellen. Ausnahme: zwei historische Heiligtumblätter; [Status](story/sanctuary/README.md). |
| `memories/attack/`, `sacrifice/`, `legacy/` | **Aktiv:** alle drei Kloster-Erinnerungen. `legacy` bedeutet „Vermächtnis“, nicht veralteter Code. |
| `world/`, `vehicles/`, `fx/` | Aktive Orts-/Fahrzeug-/Effektquellen; Vorlagen einzelner überarbeiteter Räume können als Herstellungsreferenz erhalten sein. Konkrete Ladepfade im jeweiligen Renderer prüfen. |
| `audio/`, `music/` | **Aktiv:** vorhandene Klänge und zugeordnete MP3s. [Musikzuordnung](music/README.md). |
| `ui/`, `fonts/` | Spieloberflächen und Schriften des aktiven UI. |

Die **verworfenen** v0.45.0-Helden liegen jetzt [im Entwicklungsarchiv](../docs/archiv/assets/helden-v045/README.md). Die alten bildschirmfüllenden Comictafeln sind [historisch archiviert](../docs/archiv/assets/comic-bis-v017/README.md), seit v0.18.0 keine Spiel-Zwischenszenen mehr. Beide Gruppen werden nicht importiert oder exportiert.

`*.import` neben aktiven PNG/MP3-Dateien sind Godot-Importkonfigurationen mit Ressourcenkennungen. Sie nicht mit dem generierten Cache `.godot/` verwechseln. Quell-Compiler unter `tools/` sind optionale Herstellungswerkzeuge und werden beim normalen Setup nicht ausgeführt.
