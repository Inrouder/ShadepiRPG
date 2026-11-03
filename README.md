# Shadepi · Echos in Neon

**Spielbare Pixel-Testszene zu „Shadepi – Im Schatten des Raben“.**

![Echtes Spielbild aus Godot](docs/screenshot.png)

[Dieselbe Szene mit reduziertem Bildstil](docs/screenshot-reduced.png)

Shadepi und Raven treffen in einer regennassen Gasse auf Chrome Jackal. Sprich mit Raven, öffne die Sicherheitssperre, kombiniere Katana und Netrunning und sichere die Daten am Ausgang.

Diese Version **0.3.2** ist eine frei arrangierte Gameplayprobe aus einem **späteren Abschnitt**. Shadepi und Raven kennen sich hier bereits. Die eigentliche Geschichte beginnt mit Shadepi allein; Raven begegnet er erst später. Die Dialoge dieser Szene sind eigens für den Test geschrieben.

## Spielen

1. Unter [Actions](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) den letzten erfolgreichen Lauf öffnen.
2. **ShadepiRPG-Windows** herunterladen, ZIP vollständig entpacken und `Shadepi-Echos-in-Neon.exe` starten. Eine Godot-Installation wird zum Spielen nicht benötigt.
3. Im Startmenü **Einzelspieler** oder **Lokal-Koop** wählen und starten. Das Missionsziel steht oben rechts.

Ein Linux-Build und das vollständige Godot-Projekt werden ebenfalls als Artefakte erzeugt. Bei späteren Versions-Tags veröffentlicht der Workflow zusätzlich Windows-ZIP und Projekt-ZIP im Bereich [Releases](https://github.com/Inrouder/ShadepiRPG/releases).

## Lokal-Koop

Im Start- oder Pausenmenü über **Modus** den **Lokal-Koop** auswählen. Danach könnt ihr ein neues Spiel starten oder euren Koop-Spielstand laden. Ihr könnt eine Tastatur, zwei Controller oder eine Tastatur zusammen mit einem Controller nutzen. Beide Figuren sind auf einem Bildschirm zu sehen. Die Kamera folgt eurem Mittelpunkt. Wenn ihr euch zu weit voneinander entfernt, geht ihr wieder aufeinander zu.

| Aktion | Shadepi | Raven |
| --- | --- | --- |
| Bewegen | WASD | Pfeiltasten |
| Angriff | J oder linke Maustaste für das Katana | U für einen Impulsschuss in Blickrichtung |
| Ausweichen | Leertaste oder Umschalt | P |
| Spezialfähigkeit | C für Tarnung | O für einen Hack aus Ravens Reichweite |
| Interagieren | E | Enter |

Beide können das Terminal bedienen und die Daten sichern. Jede Figur hat eigene Lebenspunkte und Energie. Wenn eine Figur besiegt wird, setzt ihr den Kampf gemeinsam am Kontrollpunkt fort. **F5** und **F9** speichern und laden den aktiven Modus. Solo und Koop haben getrennte Spielstände.

## Controller

Im Einzelspieler steuert der erste Controller Shadepi. Im Koop steuern zwei verbundene Controller Shadepi und Raven in der Reihenfolge ihrer Gerätezuordnung. Bei einem Controller übernimmt er Raven und Shadepi wird mit WASD gespielt.

| Aktion | Controller (Xbox-Tasten) |
| --- | --- |
| Bewegen / Menüauswahl | Linker Stick oder Steuerkreuz |
| Angriff | X für Katana oder Impulsschuss |
| Ausweichen | B |
| Spezialfähigkeit | Y für Shadepis Tarnung oder Ravens Hack |
| Ravens Hilfe im Einzelspieler | RB für Hack |
| Interagieren / Dialog weiter / Menü bestätigen | A |
| Pause / Fortsetzen | Start |
| Speichern | LB |

## Steuerung im Einzelspieler

| Taste | Aktion |
| --- | --- |
| WASD / Pfeiltasten | Bewegen; Bewegungsrichtung bestimmt die Blickrichtung |
| J | Katana in Blickrichtung |
| Linke Maustaste | Katana in Richtung des Mauszeigers |
| Leertaste / Umschalt | Ausweichen mit kurzem Schutzfenster |
| E / Enter | Sprechen, Terminal bedienen, Dialog weiterführen |
| C | Tarnfeld aktivieren oder beenden |
| Q | Raven stört Chrome Jackals Implantate |
| F5 / F9 | Speichern / Laden |
| Esc / H | Pause und Hilfe |
| M | Musik und Effekte umschalten |
| V | Bildstil wechseln: Atmosphärisch, Reduziert, Ausgewogen |

**Kampftipp:** Der rote Bogen kündigt Jackals Vorstoß an. Seitlich ausweichen, dann zuschlagen. Ravens Hack unterbricht den Angriff und schwächt die Panzerung für sechs Sekunden. Angreifen beendet die Tarnung. Energie regeneriert sich automatisch, während das Tarnfeld ausgeschaltet ist.

## Was enthalten ist

- Eigene PNG-Spritesheets mit acht Bildern je Zyklus: Stand, Laufbewegung, Katanahieb und Trefferpose; acht Blickrichtungen für Shadepi und Raven, vier für Jackal. Beim Laufen wechseln Shadepi und Raven über diagonale Zwischenposen zur neuen Richtung.
- Begehbare Gasse mit Gebäudekollisionen, Hindernissen, Sicherheitssperre und einer überprüften Route zum Ausgang.
- Gegner mit angekündigtem Angriff, Vorstoß, Erholungsphase und hackbarer Panzerung.
- Katana-Kombination, Energie, Ausweichen, zehn Sekunden maximales Tarnfenster und Fähigkeitencooldowns.
- Dialoge, fünf Missionszustände, Kontrollpunkte und manuelles Speichern/Laden.
- Geworfene Schatten, Neonhalos, nasse Spiegelungen, Schritte im Regen, Dampf, Hackentladungen und ein dezenter Farb- und Lichtfilter. Die drei Bildstile sind im Menü und mit **V** umschaltbar; die Einstellung bleibt beim Neustart erhalten.
- Eigens synthetisierte elektronische Hintergrundmusik und Kampf-/Hackeffekte.

## Godot-Projekt öffnen

Verwendete und geprüfte Version: **Godot 4.7.2 Standard**, Renderer **Compatibility**, kein C# erforderlich.

Repository herunterladen oder klonen, `project.godot` importieren, Ressourcenimport abwarten und **F5** drücken. Die Darstellung rechnet mit 640 × 360 Pixeln und ganzzahliger Skalierung; das Fenster startet mit 1280 × 720 Pixeln.

## Tests und eigene Builds

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
mkdir -p build/windows build/linux
godot --headless --export-release "Windows Desktop" build/windows/Shadepi-Echos-in-Neon.exe
godot --headless --export-release Linux build/linux/Shadepi-Echos-in-Neon.x86_64
```

Zum Export müssen die offiziellen Exportvorlagen derselben Godot-Version installiert sein. Die GitHub Action richtet dies automatisch ein. Die Windows-EXE wird unter Linux exportiert; ihre Ausführung auf einem tatsächlichen Windows-PC ist ein gesonderter manueller Prüfschritt.

Die **89 automatisierten Prüfungen** behandeln unter anderem Bewegung und Gebäudekollision, Missionsfortschritt, Kampf, Tarnung, Spriteformate, Grafikprofile, gleichzeitige Eingaben für beide Figuren, Koop-Kampf, simulierte Controller-Eingaben, Laden beider Figuren sowie ungültige und beschädigte Spielstände einschließlich Backup-Wiederherstellung.

Speicherort: Godots `user://shadepi-test-save.json` für Solo und `user://shadepi-coop-save.json` für Koop (unter Windows normalerweise `%APPDATA%/Godot/app_userdata/Shadepi - Echos in Neon/`). Bei beschädigter Hauptdatei wird ein validiertes Backup versucht. Beim Laden werden laufende Fähigkeiten zurückgesetzt und Jackal an seine Startposition gesetzt; sein gespeicherter Lebensstand bleibt erhalten.

## Grafiken und Audio weiterbearbeiten

Die Figuren sind als transparente PNGs enthalten. Kopiere die gewünschte Figur aus `assets/sprites/` nach `assets/custom/` und bearbeite die Kopie. Das Spiel lädt deine Variante automatisch. In der [Bearbeitungsanleitung](docs/figuren-bearbeiten.md) stehen Raster, Zeilenreihenfolge und Exportvorgaben.

Node.js wird nur für eine erneute Asset-Erzeugung benötigt:

```bash
npm ci
npm run assets
```

`tools/generate_assets.cjs` enthält die Rasterzeichner und den Synthesizer. Es werden keine SVG-Figuren und keine extern geladenen Bilder verwendet. Die Szene läuft vollständig lokal, ohne Konten, KI-Dienste oder Onlinepflicht.

## Nächster Ausbau

Der eigentliche Einstieg zeigt Shadepi zunächst allein, etwa bei der Erkundung der Dächer und Gassen. Ravens erste Begegnung erhält ihren eigenen späteren Storymoment. Die aktuelle Gassenszene bleibt eine separat gekennzeichnete Gameplayprobe mit bereits vertrauten Figuren.
