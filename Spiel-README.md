# Shadepi · Echos in Neon

**Spieleranleitung für v0.14.0.** Aktuelle Downloads und Prüfstatus: [Repository-Startseite](README.md). Änderungen: [Versionshinweise](CHANGELOG.md).

**Kapitel und Kontrollpunkte:** Mit „Weiter zu Kapitel …“ beginnt das folgende Kapitel am Anfang. Die Menüoption „Fortsetzen“ lädt dessen vorhandenen Kontrollpunkt. Kapitel 2 verläuft über Industriegebiet → Versteck → Kühlsystem → Deep Dive → Kryospray → Abschluss. Danach folgen Pakt, Hinterhalt und Verfolgung (3), Garage und Hangar (4), Heiligtum und Erinnerungen (5), Anflug, Dach, Kenzō und Flucht (6), See und Aufnahme in den Orden (7).

**Flucht:** Nach Kenzōs Fall und den Aufzugwachen: Daten sichern, Aufzug blockieren, Treibstoffpumpe fernstarten, Dachausgang erreichen. Die sechzig Sekunden laufen während des Spielens; Dialoge und Pause halten den Timer an. Lange Dialoge besitzen mehrere Seiten, die vollständig mit E / Enter / A weitergeschaltet werden.

**Kapitel 1 · Echos in Neon und Schatten** ist der spielbare Auftakt zu „Shadepi – Im Schatten des Raben“.

Raven bekommt in ihrem Apartment einen Hinweis auf Chrome Jackal, räumt die Punks in Bingo Street aus dem Weg und verfolgt ihn bis zum Wartungshof. Dort hält seine Panzerung jedem Treffer stand. Nach 30 Kampfsekunden dreht er Ravens Hack gegen sie. Shadepi kämpft sich durch die Wartungsgasse und stellt Jackal mit 360 HP. Sobald die Hälfte seiner Lebenspunkte weg ist, steht Raven auf und steigt in den Kampf ein.

**Gegnerwellen:** Die Jagd, der Rettungsweg, der Hinterhalt und der Towerkampf sind in gesperrte Kampfabschnitte aufgeteilt. Besiege alle Wellen, bis „WEITER →“ erscheint. Zwischen Wellen hast du zwei Sekunden Pause. Ein geschaffter Abschnitt gibt bis zu 15 Lebenspunkte und 20 Energie zurück. Am nächsten Abschnitt wird automatisch gespeichert; nach einer Niederlage beginnt dessen erste Welle erneut. [Alle Abschnitte und Gegnerzahlen](docs/arcade-wellen.md).

**Neue Kampfbewegungen:** Halte **K / RT**, bis nach 1,1 Sekunden der kurze Wellenring „bereit“ signalisiert. Loslassen sendet Shadepis Katana-Welle oder Ravens Kraftschuss aus. Im Koop lädt Raven mit **I / RT** an ihrem Controller. **L / LT** führt Shadepis Kick aus. Frühes Loslassen ergibt einen normalen Angriff; Treffer, Ausweichen und Pausen brechen das Laden ab. [Details und animierte Vorschau](docs/kampfbewegungen.md).

Die Zwischenszenen nutzen Ausschnitte aus dem Comic „Shadepi – Im Schatten des Raben“ (deutsche Fassung, PDF-Seiten 2, 4, 5, 6 und 9) mit eigens für das Spiel geschriebenen Dialogen.

## Verstecktes Test-/Admin-Menü

Im Haupt- oder Pausenmenü **Strg + Umschalt + F10** drücken oder fünfmal auf die Überschrift klicken. Alle Kapitel freischalten und Kapitel 1–7 direkt starten; zusätzlich unendlich Leben/Energie, One-Hit-K.O., keine Abklingzeiten und ein Fluchttimer-Stopp. Im Testmenü können aktuelle Gegner besiegt oder Figuren geheilt werden. Das erste Jackal-Duell ist weiterhin ein geskriptetes Storyereignis. Test-Kontrollpunkte bleiben von normalen Spielständen getrennt. [Weitere Details](docs/admin-testmodus.md).

## Illustrierte Helden in v0.12.0

Raven und Shadepi verwenden neue, transparent freigestellte Figurenbilder im Stil der gemalten Kulissen. Raven trägt detaillierte schwarze Rüstung mit cyanfarbenen Leuchtlinien und blauen Haarakzenten. Shadepi hat einen breiten Kasa-Hut, rote Augen hinter der Maske, einen Mantel mit Drachenemblem und ein rotes Katana.

Beide Figuren behalten acht Blickrichtungen. Die Lauf- und Angriffsanimationen sind aus jeweils 32 generierten Schlüsselposen zusammengestellt; Stand und Treffer nutzen die Ruhepose. Die Spielatlanten in `assets/sprites/heroes/` sind 1024 × 5120 Pixel groß, mit 128 × 160 Pixeln pro Einzelbild. Ihre Darstellung wird auf die bisherige Figurengröße abgestimmt. Fußpunkte, Drehungen, Schatten und Tarnung berücksichtigen das neue Format.

Die Originalposen liegen in `tools/hero_sources/`. Mit Pillow und `python tools/compile_heroes.py` werden sie ohne erneute Bildgenerierung in die Spielatlanten gepackt. Eigene Figuren unter `assets/custom/` haben weiterhin Vorrang; auch die bisherigen Formate bleiben unterstützt.

## Bildkulissen in v0.11.0

Alle Schauplätze verwenden ausgearbeitete, eigens generierte Hintergrundbilder. Die 16 Bilddateien umfassen Apartment, Bingo Street, Wartungshof, Industriegebiet, Ravens Versteck, Deep Dive, Hinterhalt, Garage, Sanktuarium, Wohnraum, Erinnerungsraum, Landedach, Penthouse, See sowie die Straße und die Häuserschlucht der Fahrzeugsequenzen.

Die Hintergrundbilder stehen in `assets/world/painted/`. Die Wandkollisionen, festen Einbauten und Vordergrundausschnitte sind in `scripts/painted_world.gd` auf diese Bilder abgestimmt. Die Ausschnitte verwenden dieselben Bildpixel und lassen Figuren hinter Mauern verschwinden. Zerstörbare Gegenstände werden als eigene Objekte darüber dargestellt.

Die 16 gemalten Kulissen liegen direkt in `assets/world/painted/`; ihre Zuordnung und die darauf abgestimmten Hindernisse stehen in `scripts/painted_world.gd`. Ein Generator für diese gemalten Bilder liegt nicht im Repository.

## Zerstörbare Gegenstände in v0.10.0

Die Gassen, das Industriegebiet, das Versteck, die Garage, der Hangar und der Tower sind mit zusätzlichen Gegenständen ausgestattet. Dazu gehören Frachtkisten, Straßenlaternen, geparkte Wagen, Müllcontainer, Brennstofffässer, Schaltkästen, Getränkeautomaten und Serverschränke. Im Deep Dive gibt es zerstörbare Datenkristalle.

**J / X** greift mit der aktiven Figur an. Shadepis Katana trifft auch die Kante großer Gegenstände. Ravens Schüsse treffen zuerst die Deckung vor einem Gegner. Beschädigte Gegenstände erhalten sichtbare Risse und Dellen. Zerstörte Objekte hinterlassen begehbare Trümmer oder Wracks. Lampen gehen aus, Metallteile sprühen Funken und Fässer explodieren und können benachbarte Gegenstände zerstören. Auch gegnerische Angriffe beschädigen die Deckung.

**F5 / LB** speichert die Schäden zusammen mit dem Kapitelkontrollpunkt. Solo und Koop behalten ihre getrennten Zustände. Im Penthouse bleiben die Schäden während der anschließenden Flucht sichtbar.

Lichttextur und Basissounds lassen sich mit `npm ci` und `npm run assets` neu erzeugen. Der Generator verändert **keine** Charakter-Sprites, gemalten Level oder das App-Symbol. Vor Änderungen an Requisiten/Geräuschen die vorhandenen Dateien sichern. Die Platzierungen stehen in `scripts/world_dressing.gd`.

## Comicgestaltung in v0.9.0

Die Bildregie orientiert sich an der deutschen Comicfassung. Zwischenszenen nutzen einen gemeinsamen Panelrahmen mit Kapitelkennung und getrenntem Dialogfeld.

| Kapitel | PDF-Seiten | Motive im Spiel |
| --- | --- | --- |
| 1 | 2–9 | Kaltes Monitorlicht im Apartment, Neonreklame und Reflexe in den Gassen |
| 2 | 10–16 | Totenkopf am Versteck, Kühlbad, magentafarbene Netzflächen und rote ICE-Scanlinie |
| 3 | 17–28 | Blaue Hinterhaltgasse mit Einschlägen und kupferrotes Motorrad vor dem dunklen Verfolgerwagen |
| 4 | 29–34 | Verdeckte Absenkplattform und grüner Zylinder im Sanktuarium |
| 5 | 35–42 | Blaues Licht am Bett und unterscheidbare Echos von Kloster, Trägern und Angriff |
| 6 | 43–53 | Aerodyne mit orangefarbenen Triebwerken, grünes Zeichen am Dach und Kenzōs cyanfarbene Implantate |
| 7 | 54–55 | Waldlichter am See und rote sowie cyanfarbene Lichtspuren beim Abschluss |

Die tatsächlich verwendeten Levelbilder liegen in `assets/world/painted/`. Nicht mehr benutzte prozedurale Vorlagen aus `assets/world/levels/` gehören nicht länger zum Quellstand. Zum Anpassen der Spielwelt die jeweilige gemalte Kulisse und ihre Kollisionen in `scripts/painted_world.gd` gemeinsam bearbeiten.

## Spielen

1. Unter [Actions](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml) den letzten erfolgreichen Lauf öffnen.
2. **ShadepiRPG-Windows** herunterladen, ZIP vollständig entpacken und `Shadepi-Echos-in-Neon.exe` starten. Eine Godot-Installation wird zum Spielen nicht benötigt.
3. Im Startmenü **Einzelspieler** oder **Lokal-Koop** wählen und starten. Das Missionsziel steht oben rechts. Mit **E**, **Enter** oder **A** geht es in den Zwischenszenen weiter.

Ein Linux-Build und das vollständige Godot-Projekt werden ebenfalls als Artefakte erzeugt. Bei späteren Versions-Tags veröffentlicht der Workflow zusätzlich Windows-ZIP und Projekt-ZIP im Bereich [Releases](https://github.com/Inrouder/ShadepiRPG/releases).

## Lokal-Koop

Im Start- oder Pausenmenü über **Modus** den **Lokal-Koop** auswählen. Ravens Jagd und Shadepis Rettung spielt ihr nacheinander mit der Hauptsteuerung. Sobald Shadepi Jackal auf 180 HP gebracht hat, übernimmt im Lokal-Koop die zweite Person Raven. Im Einzelspieler folgt Raven und feuert auf Jackal, sobald sie freie Sicht hat. Ihr könnt eine Tastatur, zwei Controller oder eine Tastatur zusammen mit einem Controller nutzen. Beide Figuren sind auf einem Bildschirm zu sehen. Die Kamera folgt eurem Mittelpunkt. Wenn ihr euch zu weit voneinander entfernt, geht ihr wieder aufeinander zu.

| Aktion | Shadepi | Raven |
| --- | --- | --- |
| Bewegen | WASD | Pfeiltasten |
| Angriff | J oder linke Maustaste für das Katana | U für einen Impulsschuss in Blickrichtung |
| Aufgeladener Angriff | K halten und nach dem Bereitschaftsimpuls loslassen | I halten und nach dem Bereitschaftsimpuls loslassen |
| Kick | L | – |
| Ausweichen | Leertaste oder Umschalt | P |
| Spezialfähigkeit | C für Tarnung | O für einen Hack aus Ravens Reichweite |
| Interagieren | E | Enter |

Jede Figur hat eigene Lebenspunkte und Energie. Wenn eine Figur besiegt wird, setzt ihr den Kampf gemeinsam am Kontrollpunkt fort. **F5** und **F9** speichern und laden den aktiven Modus. Solo und Koop haben getrennte Spielstände.

Raven zielt mit der Maus und schießt im Solo mit Linksklick, im lokalen Koop mit Rechtsklick. Auf dem Controller zielt sie mit dem rechten Stick und feuert mit X. J beziehungsweise U feuert in Blickrichtung.

[Kapitelbilder, Level und Figuren bearbeiten](docs/figuren-bearbeiten.md)

## Kapitel 2 · Offenbarungen im Verborgenen

Nach Kapitel 1 führt **E / A** direkt ins Industriegebiet. Nach dem ersten Abschluss ist Kapitel 2 auch aus dem Menü erreichbar. Scanne das Gelände, zeige Raven das Fragment und schließe das Kühlsystem an. Im Deep Dive bestätigt Raven die Seriennummer per Timing-Hack, bekämpft zwei Viruswellen und hält die Verbindung beim letzten Knoten. J / X feuert Impulse, Q / RB stört die Pfosten am ICE-Wächter. Nach dem Abbruch holt Shadepi das Kryospray. Kapitel 2 wechselt erzählerisch zwischen Shadepi und Raven und hat einen eigenen Kontrollpunkt.

## Kapitel 3–7 · Der Pakt bis Der neue Orden

Mit **E / A** nach Kapitel 2 startet die restliche Kampagne. Der Kontrollpunkt liegt in einem eigenen Spielstand. Die Geschichte führt vom Hinterhalt über Shadepis Sanktuarium bis zum Penthouse im Arasaka-Tower und zum Ordensritual am See.

- **Motorrad:** A/D, Pfeiltasten oder Stick wechseln die Spur. J/X feuert, Q/RB hackt den Wagen, Leertaste/B wirft eine Granate. Der Wagen bleibt hinter dem Motorrad. Feuer und Granaten gehen nach hinten. Weiche dem Verkehr vor dir und den Schüssen sowie Rammversuchen des Wagens aus. Für den Hack musst du auf seiner Spur sein.
- **Sanktuarium:** Fahre gemeinsam mit Raven auf der Plattform hinab. Schalte Strom, Gleiterkennung und Transponder frei und prüfe die Ports 2, 1 und 3 bei Cyan.
- **Heiligtum:** Starte die Timing-Runde mit J/X im Solo oder Leertaste/B zu zweit. Shadepi tippt mit J, Raven mit U. Mit zwei Controllern nutzen beide X. Anschließend ordnet Raven die drei Erinnerungsanker.
- **Aerodyne:** Wechsle beim Tower-Anflug die Flugspur und sende die Kennung mit Q/RB, sobald der Scanner in Reichweite ist.
- **Kampf und Flucht:** Q/RB stört gegnerische Implantate. Kenzō kämpft im Penthouse allein. Erst nach seinem Tod ruft sein Totmannschalter die Aufzugwachen (drei Wellen); danach startet der Fluchttimer. Sichere anschließend die Daten, blockiere den Aufzug, starte die Pumpe neu und erreiche den Aerodyne vor Ablauf von 60 Sekunden.

Die Geschichte bleibt im Spiel vollständig bis zum Ende am See. Die Geschichte wechselt zwischen den Figuren an der Hauptsteuerung. Kapitel 5 bietet zusätzlich ein lokales Timing-Duell. Der Kapiteltext, die Comiczuordnungen und die Missionsziele stehen in `scripts/campaign_story.gd`.

## Controller

Vor dem gemeinsamen Kampf steuert der erste Controller die jeweils aktive Figur. Im Einzelspieler bleibt diese Zuordnung auch im Finale erhalten. Im Koop steuern zwei verbundene Controller Shadepi und Raven in der Reihenfolge ihrer Gerätezuordnung. Bei einem Controller übernimmt er Raven und Shadepi wird mit WASD gespielt.

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
| J | Impulsschuss als Raven, Katana als Shadepi |
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
- Begehbare Gasse mit Gebäudekollisionen, Hindernissen, Sicherheitsschleuse und markierter Jagdroute.
- Gegner mit angekündigtem Angriff, Vorstoß, Erholungsphase und hackbarer Panzerung.
- Katana-Kombination, Energie, Ausweichen, zehn Sekunden maximales Tarnfenster und Fähigkeitencooldowns.
- Comic-Zwischenszenen, zwei Kämpfe gegen Jackal, vier animierte Punk-Varianten, eine Rettung mit drei Gegnerwellen und separate Kapitel-Kontrollpunkte für Solo und Koop.
- Geworfene Schatten, Neonhalos, nasse Spiegelungen, Schritte im Regen, Dampf, Hackentladungen und ein dezenter Farb- und Lichtfilter. Die drei Bildstile sind im Menü und mit **V** umschaltbar; die Einstellung bleibt beim Neustart erhalten.
- Eigens synthetisierte elektronische Hintergrundmusik und Kampf-/Hackeffekte.

## Godot-Projekt öffnen

Verwendete und geprüfte Version: **Godot 4.7.2 Standard**, Renderer **Compatibility**, kein C# erforderlich.

Repository herunterladen oder klonen, `project.godot` importieren, Ressourcenimport abwarten und **F5** drücken. Die Darstellung rechnet mit 640 × 360 Pixeln und ganzzahliger Skalierung; das Fenster startet mit 1280 × 720 Pixeln.

## Tests und eigene Builds

```bash
godot --headless --editor --import --quit
godot --headless --script res://tests/run.gd
godot --headless --script res://tests/drive_action.gd
godot --headless --script res://tests/painted_world.gd
mkdir -p build/windows build/linux
godot --headless --export-release "Windows Desktop" build/windows/Shadepi-Echos-in-Neon.exe
godot --headless --export-release Linux build/linux/Shadepi-Echos-in-Neon.x86_64
```

Zum Export müssen die offiziellen Exportvorlagen derselben Godot-Version installiert sein. Die GitHub Action richtet dies automatisch ein. Die Windows-EXE wird unter Linux exportiert; ihre Ausführung auf einem tatsächlichen Windows-PC ist ein gesonderter manueller Prüfschritt.

Die automatisierten Prüfungen behandeln den Kapitelfortschritt vom Apartment bis zum Finale sowie Bewegung und Gebäudekollision, Missionsfortschritt, Kampf, Tarnung, Spriteformate, Grafikprofile, gleichzeitige Eingaben für beide Figuren, Koop-Kampf, simulierte Controller-Eingaben, Laden beider Figuren sowie ungültige und beschädigte Spielstände einschließlich Backup-Wiederherstellung.

Kapitel-Kontrollpunkte liegen in `user://shadepi-chapter-one.cfg`. Beim Laden beginnt der gespeicherte Abschnitt von vorn. Die spätere Testszene nutzt Godots `user://shadepi-test-save.json` für Solo und `user://shadepi-coop-save.json` für Koop (unter Windows normalerweise `%APPDATA%/Godot/app_userdata/Shadepi - Echos in Neon/`). Bei beschädigter Hauptdatei wird ein validiertes Backup versucht. Beim Laden werden laufende Fähigkeiten zurückgesetzt und Jackal an seine Startposition gesetzt; sein gespeicherter Lebensstand bleibt erhalten.

## Grafiken und Audio weiterbearbeiten

Die Figuren sind als transparente PNGs enthalten. Kopiere die gewünschte Figur aus `assets/sprites/` nach `assets/custom/` und bearbeite die Kopie. Das Spiel lädt deine Variante automatisch. In der [Bearbeitungsanleitung](docs/figuren-bearbeiten.md) stehen Raster, Zeilenreihenfolge und Exportvorgaben.

Node.js wird nur für eine erneute Asset-Erzeugung benötigt:

```bash
npm ci
npm run assets
```

`tools/generate_assets.cjs` erzeugt nur noch kleine Hilfsgrafiken und Basissounds. Die Figuren nutzen die fertigen HQ-Atlanten unter `assets/sprites/heroes/` und `assets/sprites/npcs/`. Das Spiel läuft lokal, ohne Konten, KI-Dienste oder Onlinepflicht.

## Weiterentwicklung

Neue Änderungen auf dem vollständigen v0.12-Projekt aufbauen. Vor größeren Eingriffen einen Projektstand sichern und anschließend Import, Tests sowie einen Starttest durchführen. Aktuelle Hinweise stehen in der [README](README.md).


### Tower-Anflug und Fahrzeug-Action (v0.15.0)

Beim Anflug fällt nach etwa drei Sekunden das rechte Triebwerk aus. Ravens **Jumper-Wartungsdeck** öffnet sich: Pins nach Wartungslog verbinden, TX/RX kreuzen, Kette Alpha auf insgesamt 120 Ω bringen und die Verbindungen prüfen. Erst **Übernehmen** startet das Triebwerk. Nach Abbruch öffnet **J / X** die Konsole erneut; dafür bleiben 45 Sekunden außerhalb des Decks. **A/D bzw. linker Stick** gleichen währenddessen den seitlichen Drift aus. Konsole und Pause halten die Reparaturfrist an. Nach erfolgreichem Neustart im Scannerfenster **Q / RB** für die kopierte Kennung drücken.

Raven nutzt außerdem Matrix-Hacks, Passwort-Decoder, Schaltungsnetze und Signalabgleich für Türen, Jackals Tor, Hangar und die Sperrladung am Aufzug. **E / A** öffnet das Terminal; **Tab / Pfeile / Steuerkreuz** wählt, **Enter / A** bestätigt, **Esc / B** bricht ab. **P / Start** pausiert. Fehlversuche lassen sich direkt wiederholen. [Alle Rätsel mit Bildern und Regeln](docs/ravens-terminals.md).

In der Motorradverfolgung schießt Raven nach hinten: **J / X** halten, **Q / RB** hackt auf der Spur des Verfolgers, **Leertaste / B** wirft eine Granate. Der Wagen wechselt seine Spur jetzt weich. Warnlinien kündigen Rammangriffe an. Treffer und Hindernisse versetzen das Motorrad seitlich; Rauch zeigt den beschädigten Verfolger. Seine letzte Explosion bleibt kurz sichtbar, bevor es in der Garage weitergeht.
