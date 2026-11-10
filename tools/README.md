# Entwicklerwerkzeuge · v0.46.2 · CodexAI

[Repository-Status](../docs/repository-status.md) · [Aktive Assets](../assets/README.md) · [Mitwirken](../CONTRIBUTING.md).

**Zum normalen Spielen oder Projektimport keines dieser Herstellungswerkzeuge ausführen.** Die erzeugten Ressourcen sind bereits im Git enthalten. Schreibende Compiler/Generatoren können bestehende Originalgrafiken, Schriften oder Klänge überschreiben. Erst Quellen, Zielpfade, aktuelle Nutzerentscheidung und Arbeitskopie prüfen. Die historische Herkunft eines Compilers macht seine fertigen aktiven Assets nicht veraltet.

## Lesende Prüfung / Vermessung

| Werkzeug | Zweck |
| --- | --- |
| [audit_repository.py](audit_repository.py) | Liest Statusmanifest, Markdown-Links, feste Runtimepfade, Git-/Exportgrenzen und Versionen. Keine externen Pakete, keine Bild-/Spielstandänderung. |

## Metadatenwerkzeuge mit Schreibzugriff

Diese Vermessungen lesen PNG-Pixel, **überschreiben aber aktive JSON-Anker-/Akteurdateien**. Keine lesenden Auditbefehle und keine normalen Setup-Schritte. Bestehende Metadaten vor einer bewussten Neuberechnung sichern und anschließend Kontaktpunkte prüfen.

| Werkzeug | Ausgabe |
| --- | --- |
| [measure_combat_anchors.py](measure_combat_anchors.py) | `contact-poses.json` und `raven-hand-cast.json` |
| [measure_memory_art.py](measure_memory_art.py) | `assets/memories/attack/actors.json` |
| [measure_sacrifice_art.py](measure_sacrifice_art.py) | `assets/memories/sacrifice/actors.json` |
| [measure_legacy_art.py](measure_legacy_art.py) | `assets/memories/legacy/actors.json` für die aktive Erinnerung III |

## Herstellungsquellen mit Schreibzugriff

| Werkzeug | Status / Ziel |
| --- | --- |
| [compile_heroes.py](compile_heroes.py) | Herstellungsquelle; schreibt die aktiven Original-Heldenatlanten neu. Nicht für normalen Start oder unaufgeforderte Neugestaltung verwenden. |
| [compile_npcs.py](compile_npcs.py) | Herstellungsquelle; schreibt NPC-Atlanten und Herstellungsbericht. Vorhandene Kontakt-/Szenenquellen sind davon getrennt. |
| [generate_assets.cjs](generate_assets.cjs) | Optionaler Generator für Licht und Basissounds; `npm run assets` ist kein notwendiger Setup-Schritt. |
| [compose_parked_bike.py](compose_parked_bike.py) | Schreibendes Herstellungswerkzeug für das geparkte Motorrad. |
| [build_flight_props.py](flight/build_flight_props.py) | Schreibendes Herstellungswerkzeug für vorhandene Flugobjekte; kein neuer HQ-Stilstandard. |
| [generate_flight_audio.py](flight/generate_flight_audio.py) | Schreibendes Herstellungswerkzeug für Flugklänge. |
| [generate_combat_audio.py](generate_combat_audio.py) | Schreibendes Herstellungswerkzeug für Kampfklänge. |
| [generate_drive_audio.py](generate_drive_audio.py) | Schreibendes Herstellungswerkzeug für Fahrzeugklänge. |
| [generate_legacy_audio.py](generate_legacy_audio.py) | Schreibendes Herstellungswerkzeug für Erinnerung III; „legacy“ ist aktiv. |
| [build_pixel_font.py](ui_pixel/build_pixel_font.py) | Schreibendes Herstellungswerkzeug für bestehende Pixelschrift. |
| [build_ui_pixel.py](ui_pixel/build_ui_pixel.py) | Schreibendes Herstellungswerkzeug für bestehende Pixel-UI. |
| [audit_atlases.py](sprites/audit_atlases.py) | v0.52.0 · ClaudeHelper: **nur lesend.** Findet Posen, die ein Stück der Nachbarpose zeigen oder abgeschnitten sind. Braucht Pillow, numpy, scipy. |
| [calibrate_atlases.py](sprites/calibrate_atlases.py) | v0.52.0 · ClaudeHelper: schreibend. Gibt jeder Pose eine eigene Zelle mit Rand und passt die JSON-Kataloge an; zeichnet nichts neu. Ausschnitte stehen in [atlas_regions.py](sprites/atlas_regions.py). |
| [import_free_sfx.py](audio/import_free_sfx.py) | v0.54.0 · ClaudeHelper: wandelt die freien CC0-Aufnahmen in die Spieldateien um; Quellen in `assets/audio/CREDITS.md`. Braucht ffmpeg und die Quell-Klone. |
| [build_companions.py](companions/build_companions.py) | v0.53.0 · ClaudeHelper: schreibt Drohne und Naniten nach `assets/sprites/companions/`. |
| [build_marker.py](ui_pixel/build_marker.py) | v0.48.0 · ClaudeHelper: schreibt `assets/ui/marker.png` (Pixel-Bodenring und Pfeil). |
| [build_tower_plan.py](story/build_tower_plan.py) | v0.48.0 · ClaudeHelper: schreibt den Towerplan `assets/story/tower-plan.png`. |
| [build_alarm_props.py](story/build_alarm_props.py) | v0.48.0 · ClaudeHelper: schreibt Alarmbeacon und Boden-LED `assets/story/tower/alarm-lights.png`. |
| [generate_ambient.py](ambient/generate_ambient.py) | v0.48.0 · ClaudeHelper: synthetisiert die fünf Umgebungsloops `assets/audio/ambient_*.wav`. |

[hero_sources](hero_sources/README.md) und [npc_sources](npc_sources/README.md) sind ursprüngliche Rohposen samt Prompts. Aktuelle KONSISTENZ hat Vorrang vor historischen Prompt-Stilangaben. Zum Bearbeiten vorhandener Grafiken zuerst eine Custom-Kopie beziehungsweise isolierte Arbeitskopie verwenden.

## Godot-Aufnahme- und QA-Werkzeuge

Die Aufnahme-/QA-Skripte verwenden echte Spielressourcen und bereiten oft Kapitel, Gegner oder Kontrollpunkte automatisch vor. **Versionierte Bild-/Testwerkzeuge, keine normalen Setup-Schritte und keine vollständigen manuell erspielten Durchläufe.** Nach API-Änderungen anhand des zugehörigen Berichts prüfen. Mit isoliertem `XDG_DATA_HOME` und einem nativen Renderer ausführen; nicht mit persönlichen Spielständen. Ein aufgenommenes Bild ersetzt keine Prüfung des gesamten Abschnitts.

| Skript | Einordnung |
| --- | --- |
| [action_gallery.gd](action_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [aerodyne_art_gallery.gd](aerodyne_art_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [arcade_gallery.gd](arcade_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [atmosphere_film.gd](atmosphere_film.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [atmosphere_gallery.gd](atmosphere_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [blood_gallery.gd](blood_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [chapter_one_gallery.gd](chapter_one_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [chase_gallery.gd](chase_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [cinema_review.gd](cinema_review.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [cinematic_gallery.gd](cinematic_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [combat_gallery.gd](combat_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [cutscene_gallery.gd](cutscene_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [display_gallery.gd](display_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [feedback_gallery.gd](feedback_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [flight_gallery.gd](flight_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [story/scene_overview.gd](story/scene_overview.gd), [story/chapter_overview.gd](story/chapter_overview.gd), [story/light_gallery.gd](story/light_gallery.gd), [story/walk_audit.gd](story/walk_audit.gd) | v0.52.0 · ClaudeHelper: Gesamtansichten, Licht-/Spiegelungsaufnahmen und Laufweg-Prüfung für die [Szenenpolitur](../docs/szenenpolitur-v052.md); schreiben nur nach `/tmp`. |
| [story/companion_gallery.gd](story/companion_gallery.gd) | v0.53.0 · ClaudeHelper: Aufnahmen der [Begleiter](../docs/begleiter.md); schreibt nur nach `/tmp`. |
| [story/pact_plan_gallery.gd](story/pact_plan_gallery.gd), [story/marker_gallery.gd](story/marker_gallery.gd), [story/alarm_gallery.gd](story/alarm_gallery.gd), [story/aerodyne_views.gd](story/aerodyne_views.gd) | v0.48.0 · ClaudeHelper: Aufnahmen für [Verbesserungen v0.48.0](../docs/verbesserungen-v048.md); schreiben nur nach `/tmp`. |
| [generate_combat_fx.gd](generate_combat_fx.gd) | **Schreibender historischer FX-Generator:** überschreibt PNGs unter `assets/fx/`; kein Aufnahme-/Setup-Werkzeug und kein allgemeiner HQ-Grafikstandard. |
| [hangar_discovery_gallery.gd](hangar_discovery_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [ice_bath_gallery.gd](ice_bath_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [lake_gallery.gd](lake_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [legacy_gallery.gd](legacy_gallery.gd) | QA zur aktiven Erinnerung III „Das Vermächtnis“; nicht veraltet allein wegen des Namens. |
| [legacy_pilot.gd](legacy_pilot.gd) | QA zur aktiven Erinnerung III „Das Vermächtnis“; nicht veraltet allein wegen des Namens. |
| [map_gallery.gd](map_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [memory_gallery.gd](memory_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [menu_checkpoint_gallery.gd](menu_checkpoint_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [menu_gallery.gd](menu_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [menu_reflection_gallery.gd](menu_reflection_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [npc_gallery.gd](npc_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [pursuit_gallery.gd](pursuit_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [pursuit_pose_gallery.gd](pursuit_pose_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [raven_enemy_gallery.gd](raven_enemy_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [report8_gallery.gd](report8_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [report_gameplay_gallery.gd](report_gameplay_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [report_scenes_film.gd](report_scenes_film.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [sacrifice_gallery.gd](sacrifice_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [sanctuary_gallery.gd](sanctuary_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [sanctuary_pose_gallery.gd](sanctuary_pose_gallery.gd) | Aktuelle Kontaktposen; `--before` lädt ausdrücklich das historische Vergleichsblatt, keine aktive Grafikumschaltung. |
| [sanctuary_reference.gd](sanctuary_reference.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [story_gallery.gd](story_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [style_bible_gallery.gd](style_bible_gallery.gd) | Aktive Quellen als Dokumentation rendern; `-- --part=heroes` erneuert nur Heldenkarten und komplette Figurenübersicht. |
| [technology_gallery.gd](technology_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [technology_pose_gallery.gd](technology_pose_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [terminal_gallery.gd](terminal_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [tower_departure_film.gd](tower_departure_film.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [tower_gallery.gd](tower_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [vehicle_motion_gallery.gd](vehicle_motion_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |
| [vehicle_pose_gallery.gd](vehicle_pose_gallery.gd) | Versionsbezogener Aufnahme-/QA-Aufbau; aktuellen Aufruf im Skript/zugehörigen Bericht prüfen. |

Der entfernte v0.45.0-Heldenrenderer liegt als [historische Quelle](../docs/archiv/code-v045/README.md) im ignorierten Archiv. Keine aktive Laufzeit lädt ihn.

**v0.49.0 · CodexAI:** [moon_lake_gallery.gd](moon_lake_gallery.gd) nimmt native Menügrößen, alle acht Kontaktbilder und das tatsächlich laufende Finale auf. Isoliertes XDG_DATA_HOME und nativer Renderer; kein Grafikgenerator. Neue Vorschaufilme unter 5 MB halten.

**v0.50.0 · CodexAI:** `ice_boss_gallery.gd` nimmt den echten Bosskampf mit gesteuerten Bewegungs-/Angriffsaktionen in Godot auf. Schreibt ausschließlich Aufnahmen nach `/tmp/shadepi-v050-gallery`; keine Quellgrafik wird bearbeitet. Aufruf mit isoliertem `XDG_DATA_HOME=/tmp/shadepi-v050-gallery` und nativem Display; Film aus diesen Frames bleibt unter 5 MB.

**v0.50.1 · CodexAI:** `net_avatar_gallery.gd` nimmt Netz-/Körperdarstellung und 64 Animationsphasen nach `/tmp/shadepi-v0501-gallery` auf. Native Godot-Aufnahmen mit isoliertem Benutzerdatenordner; keine Bearbeitung der Quellgrafiken.

**v0.50.2 · CodexAI:** `display_quality_probe.gd` analysiert reale Renderziele und erfasst physische 720p-/1080p-Fenster mit ImageMagick `import` als X11-Fallback. Nur isoliert mit `XDG_DATA_HOME=/tmp/shadepi-display-quality` und eigenem nativem Display starten. Schreibt nach `/tmp/shadepi-display-quality`, keine Anzeigepräferenzen oder Quellgrafiken; die Spieloptionen werden dadurch nicht verändert. [Befund](../docs/anzeigequalitaet-v0502.md).

**v0.51.0 · CodexAI:** `hq_display_gallery.gd` erfasst echte 1080p-/4K-Fenster, das dazugehörige auf 1080p begrenzte Spielbild und 48 HQ-Animationsframes nach `/tmp/shadepi-hq-gallery`. Isolierter Benutzerdatenordner, eigener 4K-Desktop, physische Aufnahmemaße werden geprüft. `-- --stills-only` nimmt nur die Standvergleiche/Optionen auf. [Nachweis](../docs/hq-anzeige-v051.md).

**v0.51.1 · CodexAI:** `tests/hq_popups.gd -- --gallery` zeichnet geöffnete Anzeige-/Kapitel-/Kontrollpunkt- und sämtliche Hack-Auswahllisten im nativen Fenster auf. Pixelvergleiche prüfen die tatsächlich sichtbare Liste; `--4k` prüft 4K, `--small --gallery` erzeugt separate 640×360-Filmframes. Nur isoliert mit `XDG_DATA_HOME=/tmp/shadepi-popup-…` ausführen; Ausgaben unter `/tmp/shadepi-popup-gallery`.
