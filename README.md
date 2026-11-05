# Shadepi · Echos in Neon

**2D-Action-RPG · v0.13.1 · Godot 4.7.2 · Windows / Linux · Einzelspieler und Lokal-Koop**

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

Die Spielwelt nutzt **16 gemalte Kulissen** aus `assets/world/painted/`. Wände und verdeckende Bildteile sind in `scripts/painted_world.gd` abgestimmt. Zerstörbare Objekte, Audio, HQ-Sprites und die Original-Keyframes sind im Repository enthalten.

## Godot-Projekt entwickeln

`project.godot` mit **Godot 4.7.2 Standard** öffnen, Ressourcenimport abwarten und mit **F5** starten (Compatibility-Renderer; kein C#).

| Bereich | Verzeichnis / Datei |
| --- | --- |
| Einstieg und Kapitel | `scenes/`, `scripts/chapter_one.gd`, `scripts/chapter_two.gd`, `scripts/campaign.gd` |
| Gemalte Level | `assets/world/painted/`, `scripts/painted_world.gd` |
| Requisiten und Sound | `assets/world/`, `assets/audio/`, `scripts/world_dressing.gd` |
| Charaktere und Gegner | `assets/sprites/heroes/`, `assets/sprites/npcs/` |
| Editierbare Originalposen | `tools/hero_sources/`, `tools/npc_sources/` |
| Animationen zusammensetzen | `tools/compile_heroes.py`, `tools/compile_npcs.py` |
| Eigene Charaktergrafiken | `assets/custom/` |
| Tests und Export | `tests/`, `.github/workflows/build.yml`, `export_presets.cfg` |

Zum Bearbeiten von Figuren siehe [Figuren bearbeiten](docs/figuren-bearbeiten.md), [Helden-Sprites](docs/helden-sprites.md) und [NPC-Sprites](docs/npc-sprites.md). Weitere technische Hinweise: [Architektur](docs/architecture.md).

**Hinweis zur Medienstruktur:** Die kleinen Pixel-Sprites unter `assets/sprites/` bleiben vorerst erhalten: Spielskripte laden sie noch als Ausgangsressourcen, bevor `scripts/sprite_assets.gd` sie gegen die HQ-Atlanten austauscht. Sie dürfen nicht ohne Code- und Testanpassung gelöscht werden. Gleiches gilt für die `.import`-/`.uid`-Dateien genutzter Godot-Ressourcen.

## Qualitätssicherung und Builds

Der Workflow importiert die Assets, führt Gameplay-, Story- und NPC-Tests durch und exportiert Windows und Linux. Bei einem **Versionstag** wird zusätzlich ein Release mit Windows- und Projekt-ZIP erzeugt.

Lokale Testbefehle (aus dem Projektordner):

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/story_audit.gd
godot --headless --script res://tests/npc_dive_visuals.gd
```

Für **v0.13.1** sind 501 automatisierte Prüfungen ohne Fehler dokumentiert; ein vollständiger manueller Spieldurchlauf ist damit nicht ersetzt. [Prüfbericht und Einschränkungen](docs/v0.13.1-fehlerpruefung.md). Der [GitHub-Build des Standes v0.13.1](https://github.com/Inrouder/ShadepiRPG/actions/runs/42095527700) wurde erfolgreich abgeschlossen.

## Hintergrund und Lizenzhinweise

Die Quellen wurden ursprünglich aus einer Windows-Fassung rekonstruiert und mit Original-Keyframes ergänzt. Die [Wiederherstellungsnotiz](docs/v0.12.0-wiederherstellung.md) erklärt Herkunft und Grenzen der Medien. Hinweise zu Godot-Lizenzen stehen in `docs/GODOT-LICENSE.txt` und `docs/GODOT-COPYRIGHT.txt`.
