# Shadepi · Echos in Neon

**2D-Action-RPG · v0.15.0 · Godot 4.7.2 · Windows / Linux · Einzelspieler und Lokal-Koop**

Ein spielbares Cyberpunk-Abenteuer nach **„Shadepi – Im Schatten des Raben“** mit sieben Kapiteln, gemalten Spielwelten, illustrierten Sprites für Raven, Shadepi und die Gegner sowie zerstörbarer Umgebung.

[**Spiel herunterladen (GitHub Actions)**](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) · [**Quellcode als ZIP**](https://github.com/Inrouder/ShadepiRPG/archive/refs/heads/main.zip) · [**Versionen**](CHANGELOG.md) · [**Spieleranleitung**](Spiel-README.md)

## Spielen

1. Den **neuesten erfolgreichen** Lauf unter [Actions → Test and build Shadepi](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) öffnen.
2. Das Artefakt **ShadepiRPG-Windows** oder **ShadepiRPG-Linux** herunterladen und vollständig entpacken (für Actions-Artefakte kann eine GitHub-Anmeldung nötig sein).
3. Unter Windows `Shadepi-Echos-in-Neon.exe` bzw. unter Linux `Shadepi-Echos-in-Neon.x86_64` starten. Eine Godot-Installation ist dafür nicht erforderlich.

Im Spiel gibt es ein Startmenü mit Einzelspieler und Lokal-Koop, eine gemeinsame Kamera und getrennte Kapitel-Kontrollpunkte. Details zu Tastatur, Controllern, Kampf, Speicherständen und Kapiteln stehen in der [Spieleranleitung](Spiel-README.md).

## Geschichte und Spielumfang

- **Kapitel 1:** Ravens Jagd auf Chrome Jackal, Shadepis Eingreifen und gemeinsamer Kampf.
- **Kapitel 2:** Industriegebiet, Ravens Versteck, Kühlsystem, Deep Dive und ICE-Abwehr.
- **Kapitel 3–5:** Pakt, Hinterhalt, Fahrzeugverfolgung, Hangar, Heiligtum und Erinnerungssequenzen.
- **Kapitel 6–7:** Anflug, Tower, Konfrontation mit Kenzō, Flucht und Abschluss am See.

Die Spielwelt nutzt **16 gemalte Kulissen** aus `assets/world/painted/`. Wände und verdeckende Bildteile sind in `scripts/painted_world.gd` abgestimmt. Zerstörbare Objekte, die sechs zugeordneten Musikstücke, HQ-Sprites und die Original-Keyframes sind im Repository enthalten.

Die Musik wechselt passend zwischen Hauptmenü, Erkundung, normalen Kämpfen und Bosskämpfen. Die vollständige Zuordnung und Hinweise zum Austauschen der MP3-Dateien stehen unter [Musik austauschen](assets/music/README.md).

## Neu in v0.15.0

- Alle neun zerstörbaren Requisitentypen in gemaltem HQ-Stil, jeweils intakt, beschädigt und zerstört; auch die festen Demo-Requisiten nutzen die neuen Grafiken.
- HQ-Aerodyne, Motorrad mit beiden Figuren, Verfolgerwagen und Drohnen.
- Tower-Anflug: rechtes Triebwerk fällt aus, Rauch und Schräglage; **J / X zwölfmal in acht Sekunden** drücken, um gegen das Cockpit zu klopfen und den Antrieb neu zu starten. Danach **Q / RB** für die Gleiterkennung.
- Verfolgungsjagd mit träger Lenkung, Einschlagfunken, Mündungsfeuer, Granatenexplosionen, fliegenden Trümmern, Rückstoß und Verfolgerrauch.

[Grafiken, Ablauf und Testhinweise](docs/hq-welt-und-fahrzeuge.md).

## Godot-Projekt entwickeln

`project.godot` mit **Godot 4.7.2 Standard** öffnen, Ressourcenimport abwarten und mit **F5** starten (Compatibility-Renderer; kein C#).

| Bereich | Verzeichnis / Datei |
| --- | --- |
| Einstieg und Kapitel | `scenes/`, `scripts/chapter_one.gd`, `scripts/chapter_two.gd`, `scripts/campaign.gd` |
| Gemalte Level | `assets/world/painted/`, `scripts/painted_world.gd` |
| Requisiten und Sound | `assets/world/`, `assets/audio/`, `assets/music/`, `scripts/world_dressing.gd` |
| Charaktere und Gegner | `assets/sprites/heroes/`, `assets/sprites/npcs/` |
| Editierbare Originalposen | `tools/hero_sources/`, `tools/npc_sources/` |
| Animationen zusammensetzen | `tools/compile_heroes.py`, `tools/compile_npcs.py` |
| Eigene Charaktergrafiken | `assets/custom/` |
| Tests und Export | `tests/`, `.github/workflows/build.yml`, `export_presets.cfg` |

**Verstecktes Testmenü:** Im Hauptmenü **Strg+Umschalt+F10** drücken oder fünfmal auf den Menütitel klicken. Dort können alle Kapitel freigeschaltet, Unsterblichkeit, One-Hit-K.O., unendliche Energie und weitere Testhilfen aktiviert werden. Eine Test-Sitzung speichert in separaten Kontrollpunktdateien. [Anleitung zum Testmenü](docs/admin-testmodus.md).

Zum Bearbeiten von Figuren siehe [Figuren bearbeiten](docs/figuren-bearbeiten.md), [Helden-Sprites](docs/helden-sprites.md) und [NPC-Sprites](docs/npc-sprites.md). Weitere technische Hinweise: [Architektur](docs/architecture.md).

**Bereinigte Sprite-Struktur (v0.13.2):** Alle Szenen laden die HQ-Atlanten direkt aus `assets/sprites/heroes/` und `assets/sprites/npcs/`. Die alten Pixel-Zwischendateien sind entfernt. `scripts/sprite_assets.gd` bietet weiterhin eigene Grafiken unter `assets/custom/` an und unterstützt dabei auch ältere selbst erstellte Pixelraster. `npm run assets` erzeugt nur noch Licht und Basissounds – keine Figuren, Hintergründe oder App-Symbole.

## Qualitätssicherung und Builds

Der Workflow importiert die Assets, führt Gameplay-, Story- und NPC-Tests durch und exportiert Windows und Linux. Bei einem **Versionstag** wird zusätzlich ein Release mit Windows- und Projekt-ZIP erzeugt.

Lokale Testbefehle (aus dem Projektordner):

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/npc_dive_visuals.gd
```

Für **v0.13.1** sind 501 automatisierte Prüfungen ohne Fehler dokumentiert. Für die direkte HQ-Einbindung von **v0.13.2** laufen dieselben Gameplay-, Story- und NPC-Tests im GitHub-Workflow; ein vollständiger manueller Spieldurchlauf wird dadurch nicht ersetzt. [Prüfbericht und Einschränkungen](docs/v0.13.1-fehlerpruefung.md). Der [GitHub-Build des Standes v0.13.1](https://github.com/Inrouder/ShadepiRPG/actions/runs/42095527700) wurde erfolgreich abgeschlossen.

## Hintergrund und Lizenzhinweise

Die Quellen wurden ursprünglich aus einer Windows-Fassung rekonstruiert und mit Original-Keyframes ergänzt. Die [Wiederherstellungsnotiz](docs/v0.12.0-wiederherstellung.md) erklärt Herkunft und Grenzen der Medien. Hinweise zu Godot-Lizenzen stehen in `docs/GODOT-LICENSE.txt` und `docs/GODOT-COPYRIGHT.txt`.
