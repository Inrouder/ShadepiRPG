# Shadepi · Spieleranleitung

**Aktueller Stand v0.60.1 · ClaudeHelper.** [Neu: Gasse, Tower-Flur und Lobby, zwei Netz-Ebenen](docs/durchgangsraeume.md) · [Neu: Verfolgung in drei Etappen, längerer Hinterhalt](docs/level-strecken.md) · [Neu: Arcade-Automat NEON KOMBAT](docs/arcade.md) · [Neu: Verfolger explodiert, Baken zerbersten](docs/verfolgung-finale-v056.md) · [Neu: Hauptmenü aus jedem Kapitel, Koop in allen Abschnitten](docs/menue-kontrollpunkte.md) · [Neu: Koop mit Raven in Kapitel 3–7, neue Tonaufnahmen](docs/begleiter.md) · [Neu: Begleiter für Spieler 2](docs/begleiter.md) · [Neu: kalibrierte Sprites, Spiegelungen, Kinolicht](docs/szenenpolitur-v052.md) · [Neu: Towerplan, Pixelmarker, Alarmlicht, Umgebungsgeräusche](docs/verbesserungen-v048.md) · [Story-Durchsicht Kapitel 1–7](docs/story-durchsicht.md) · [Downloads](https://github.com/Inrouder/ShadepiRPG/releases/latest) · [Bilder und Filme](docs/README.md) · [Änderungen](CHANGELOG.md). [Ältere Anleitung mit damaligen Abläufen](docs/archiv/spielanleitung-bis-v0461.md).

**Kapitel 7 / Menü v0.49.0 · CodexAI:** Bewegte Mondspiegelung, sechs Drachenphasen und acht Kontaktbilder am See; kompakte Menüs mit innenliegender Hilfe und passenden Kapitelaktionen. [Bilder und Film](docs/mondsee-v049.md).

**Netzavatar v0.50.1 · CodexAI:** Raven erscheint im gesamten Deep Dive als cyanfarbene Gittersilhouette ihrer Originalfigur. Lauf-, Lade- und Handangriffsposen bleiben erhalten. [Bilder und Film](docs/netzavatar-v0501.md).

## ICE-Wächter in Kapitel 2 · v0.50.0 · CodexAI

Der dritte Deep-Dive-Knoten öffnet eine größere Bossarena. Warte die angekündigten Kugelsalven hinter den festen Datenwänden ab oder weiche seitlich aus. Bei **cyanfarbenem Kern** gehst du nah heran: **J / X** trifft mit Ravens Handimpuls. Pro Öffnung zählen zwei Treffer; danach zurück in Deckung! Vier erfolgreiche Runden besiegen den Wächter. Ein aufgeladener Impuls zählt aus kurzer Distanz doppelt.

**WASD / linker Stick** bewegen, **Leertaste / Umschalt / B** ausweichen, **K / RT halten und loslassen** aufladen. **Q / RB** verlängert eine offene Kühlphase einmal, wenn Raven nahe genug ist. Nach dem Sieg am markierten Relais **E / A** drücken und die Verbindung kurz halten. Im Test-Kontrollpunktmenü direkt **„Deep Dive · ICE-Bossarena“** wählen.

[Bilder, Kampffilm und Einzelheiten](docs/ice-kampf-v050.md).

**Anzeigeanalyse v0.50.2 · CodexAI:** Die vorhandenen Grafiken enthalten mehr Details als die aktuelle interne 640×360-Darstellung zeigt. [Echte Full-HD-Vergleiche und Empfehlung](docs/anzeigequalitaet-v0502.md). Dieser frühere Vergleich führte zum oben beschriebenen wählbaren HQ-Modus.

**Dropdown-Korrektur v0.51.1 · CodexAI:** Anzeige-, Kapitel-, Kontrollpunkt- und Hack-Auswahllisten sind im HQ-Modus wieder sichtbar. Im Hack öffnet **A / Enter** die Liste; Auswahl mit Oben/Unten, A / Enter bestätigt, B / Esc schließt nur die Liste. Links/Rechts bleibt als schnelle Wertwahl erhalten. [Bilder und Details](docs/dropdowns-v0511.md).

## HQ-Anzeige · v0.51.0 · CodexAI

**Haupt- oder Pausenmenü → Anzeige → Darstellung → „HQ · bis 1920 × 1080 nativ“.** HQ ist standardmäßig aktiv; „Klassisch · 640 × 360“ bleibt als sparsamere Alternative wählbar. Deine Wahl wird gespeichert.

Bei Full HD wird das Spielbild in 1920×1080 gezeichnet. 1440p und 4K vergrößern dieses Full-HD-Bild; die interne Spielauflösung steigt dabei nicht weiter. Kleinere Ausgaben erhalten ein passendes kleineres HQ-Bild. Die Anzeige nennt interne Auflösung und Ausgabe getrennt. Bildausschnitt, Figurenmaßstab und Bedienung bleiben gleich.

[Bilder, 4K-Nachweis und Bedienung](docs/hq-anzeige-v051.md).

## Starten und Speichern

Windows-/Linux-ZIP aus dem neuesten Release vollständig entpacken und das Spiel starten. Zwischenstände findest du unter [Actions](https://github.com/Inrouder/ShadepiRPG/actions/workflows/build.yml). Godot ist nur zum Entwickeln nötig. Im Hauptmenü Einzelspieler oder Lokal-Koop wählen. „Letzten Kontrollpunkt laden“ setzt den neuesten gültigen Stand des Modus fort. Solo und Koop sowie normale und Test-Spielstände sind getrennt. „Zurück zum Desktop“ beendet das Spiel.

Bildschirmmodus und Auflösung lassen sich einstellen: [Vollbild/Fenstervollbild und 16:9](docs/bildschirm.md). Die logische Spielbasis bleibt 640×360; der HQ-Modus nutzt beim Zeichnen mehr vorhandene Quellpixel, bis zur Full-HD-Grenze.

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
| Aufladbarer Angriff | RT halten, nach Bereitschaftsimpuls loslassen |
| Kick | LT |
| Speichern | LB |

## Steuerung im Einzelspieler

| Taste | Aktion |
| --- | --- |
| WASD / Pfeiltasten | Bewegen; Bewegungsrichtung bestimmt die Blickrichtung |
| J | Impulsschuss als Raven, Katana als Shadepi |
| Linke Maustaste | Angriff/Zielen passend zur aktiven Figur |
| K halten und loslassen | Aufgeladener Schlag oder Schuss |
| L | Kick |
| Leertaste / Umschalt | Ausweichen mit kurzem Schutzfenster |
| E / Enter | Sprechen, Terminal bedienen, Dialog weiterführen |
| C | Tarnfeld aktivieren oder beenden |
| Q | Raven stört Chrome Jackals Implantate |
| F5 / F9 | Speichern / Laden |
| Esc / H | Pause und Hilfe |
| M | Musik und Effekte umschalten |
| V | Bildstil wechseln: Atmosphärisch, Reduziert, Ausgewogen |

**Kampftipp:** Der rote Bogen kündigt Jackals Vorstoß an. Seitlich ausweichen, dann zuschlagen. Ravens Hack unterbricht den Angriff und schwächt die Panzerung für sechs Sekunden. Angreifen beendet die Tarnung. Energie regeneriert sich automatisch, während das Tarnfeld ausgeschaltet ist.

## Kapitel und besondere Mechaniken

| Abschnitt | Aktueller Ablauf und genaue Anleitung |
| --- | --- |
| Kapitel 1 | Ravens Auftrag, Jagdwellen, Shadepis Rettung und Jackal: [Auftakt](docs/kapitel1-auftakt.md), [Kampfwellen](docs/arcade-wellen.md). |
| Kapitel 2 | Industrie, eisgekühlter Deep Dive und Kryospray-Rettung. Raven verwendet im Datenraum Handblitze: [Eisbad](docs/eisbad.md), [Raven-Kampf](docs/raven-gegner-kampf.md). |
| Kapitel 3–4 | Hinterhalt, Motorrad-Verfolgung, ein Garagendecoder und gemeinsame Plattformfahrt in den Hangar. [Fahrzeugbewegung](docs/fahrzeugbewegung.md), [Hangar](docs/hangar-entdeckung.md). |
| Kapitel 5 | Shadepi geht zur Eindämmung voraus; Raven kommt nach der Reparatur, schläft zwei Stunden und sucht ihn. Der Maskenkontakt löst die Erinnerungen aus; kein vorgeschaltetes Pflicht-Timingduell. [Kompensator](docs/heiligtum-kompensator.md), [drei Erinnerungen](docs/erinnerungen-roadmap.md). |
| Kapitel 6 | Flug und Tower-Anflug; Raven wird von Kenzō gepackt, dann greift Shadepi ein. Kenzō lebt während der Datenextraktion. Raven schützen; drei Treffer starten diesen Abschnitt neu. Erst nach gesicherten Daten vernichtet sie ihn. Flucht über den Dach-Landeplatz. [Extraktion](docs/tower-extraktion.md), [Inszenierung](docs/tower-inszenierung.md). |
| Kapitel 7 | Landung, gemeinsamer See-Moment und Ordensaufnahme. Ravens rechte Hand hebt die Maske, ihre linke verdeckt Shadepis Gesicht. [See-Finale](docs/see-finale.md). |

Ravens Zugriffe verwenden fünf Rätselarten mit eigener Hilfe und Controller-Navigation: [Terminals](docs/ravens-terminals.md). Katanawelle, Kick und Ladung: [Kampfbewegungen](docs/kampfbewegungen.md). Körperliche Gegner erhalten [Bluteffekte](docs/bluteffekte.md); Datenwesen und Roboter behalten technische Treffer. Raven und Shadepi verwenden wieder die [Original-Sprites](docs/original-helden.md).

## Testen und Entwickeln

Im Hauptmenü Strg+Umschalt+F10 drücken oder fünfmal auf den Titel klicken. Nach der Kapitelwahl kannst du einen von 40 sicheren Test-Kontrollpunkten auswählen. Diese Test-Sitzung speichert getrennt vom normalen Spiel. [Bedienung und Kontrollpunkte](docs/menue-kontrollpunkte.md), [Admin-Testmodus](docs/admin-testmodus.md).

Projektimport, Architektur, Export und Quellbearbeitung stehen im [Mitarbeitseinstieg](CONTRIBUTING.md), [Werkzeugkatalog](tools/README.md) und [Repository-Status](docs/repository-status.md). Asset-Generatoren sind zum Spielen oder normalen Projektstart nicht erforderlich.
