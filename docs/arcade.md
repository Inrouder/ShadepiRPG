# Arcade-Automat „NEON KOMBAT“ · v0.67.0 · CodexAI

**17. November 2026.** [Bildgalerie](README.md) · [Spieleranleitung](../Spiel-README.md) · [Versionshinweise](../CHANGELOG.md).

![Automat in der Halle, Kämpferwahl und Kampf](previews/arcade-v057.webp)

Nutzerauftrag vom 11. November 2026: In Shadepis Versteck steht ein Automat mit einem Kampfspiel im Stil klassischer Prügelspiele, mit den Figuren des Spiels und einem Zweispieler-Duell.

## Wo

- **Kapitel 4, Halle des Ordens:** an der Rückwand rechts neben dem grünen Tank. Raven tritt davor, **E / A** startet.
- **Hauptmenü:** Nach dem ersten Fund erscheint „Arcade · NEON KOMBAT“.
- **Esc / Start** öffnet das eigene Pausenmenü. Fortsetzen erhält den Kampf; „Zur Titelauswahl“ oder „Automat verlassen“ sind bewusste Menüaktionen (v0.64.0 · CodexAI).

## Steuerung · v0.67.0 · CodexAI

| Aktion | Spieler 1 | Spieler 2 | Gamepad / Touch |
| --- | --- | --- | --- |
| Laufen | A / D | Pfeil links / rechts | Steuerkreuz / Stick |
| Fester Sprungbogen | W, auch mit A/D | hoch, auch diagonal | hoch / diagonal-hoch |
| Ducken | S | runter | runter |
| Hoch-/Mittelblock | Zurück halten | Zurück halten | vom Gegner weg |
| Tief-/Mittelblock | Unten-Zurück | Unten-Zurück | diagonal unten weg |
| Light | J | U | X |
| Medium | K | I | Y |
| Heavy | L | O | B |
| Special EX · 50 Energie | H | P | A |
| Wählen | E / Leertaste | Enter | A |

Allein am Automaten gelten für Spieler 1 auch Pfeiltasten und Enter. Erstes Gamepad: Spieler 1, zweites: Spieler 2. Im Duell mit nur einem Gamepad gehört es Spieler 2. Touch und WLAN senden dieselben Gamepad-Tasten.

**Richtungstechniken:** `236 + L/M/H` startet die persönliche Technik ohne Energieverbrauch, `623 + L/M/H` einen Aufstieg. **Zurück 0,75 s halten, dann Vorwärts + L/M/H** startet Ansturm; Unten halten → Oben + L/M/H einen Aufstieg. Vorwärts/Zurück spiegeln sich sofort bei einem Seitenwechsel. Die Special-Taste ist die stärkere EX-Abkürzung. [Schrittfolge, Toleranz, Hoch-/Tiefblock und native Bilder](arcade-inputs-v067.md).

## Regeln

- 60 Sekunden je Runde, wer zwei Runden gewinnt, gewinnt das Duell. Bei Zeitablauf zählt der höhere Lebensanteil.
- Treffer füllen die Spezialleiste. Nur Special EX kostet die Hälfte; Richtungsbefehle sind energiefrei.
- Passender Hoch-/Tiefblock fängt vier Fünftel des Schadens ab, nur am Boden und von vorn. Heavy/Luftangriffe schlagen über Tiefblock, geduckte Light/Medium unter Hochblock durch.

| Kämpfer | Leben | Spezial |
| --- | --- | --- |
| Shadepi | 100 | Schattenschnitt: Sturm durch den Gegner |
| Raven | 90 | Hack-Impuls: Geschoss |
| Jackal | 120 | Chromfaust: Bodenschlag im Umkreis |
| Kenzō | 105 | Drachenhagel: drei Treffer im Vorstoß |
| Punk Rot | 95 | Schlagserie |
| Punk Grün / Punk Violett | 95 | Geschoss |
| Punk Ocker | 110 | Keulenhieb: Bodenschlag |
| Wache Violett / Wache Cyan | 85 | Salve: Geschoss |

## Eigene Arcade-Animationen · v0.61.0 · CodexAI

Jeder der zehn Kämpfer besitzt jetzt ein separat generiertes 16-Posen-Blatt: Bereitschaft/Atmen, Gehen, Sprung, Block, Treffer, liegender K.O., Faust ausholen/treffen, Kick anziehen/ausstrecken, Spezial ausholen/auslösen, Sieg und Landung. Körpermaß und Fußkontakt werden registriert; die normalen Kampagnenhelden bleiben unverändert.

**Kombo:** Nach bestätigtem Light-Treffer während der Kontakt-/Erholungsphase Medium, Heavy oder eine Technik eingeben; Medium kann zu Heavy/Technik übergehen. Der Eingabepuffer hält 180 ms vor, auch während Hitstop. Bei Fehlschlägen und Blocks bleibt die Erholung. Normale Luftangriffe, Block, Rückstoß und Hitstop bleiben im Automaten; die globale Kampagnenbelegung ändert sich nicht.

Ravens Hack-Impuls kommt sichtbar aus ihrer offenen Hand, Schützen feuern aus der Gewehrmündung. [Neue Bilder, Film und Quellen](arcade-begleiter-v061.md).

## Technik

- `scripts/arcade/neon_kombat.gd` (Spiel, eigenes Bild über der Welt), `scripts/arcade/arcade_cabinet.gd` (Automat in der Halle), `open_arcade()` in `scripts/main.gd`.
- Aktive [Arcade-Quellen](../assets/arcade/README.md); Bühne bleibt erhalten. `tools/art-v061/pack.py` registriert die neuen generierten Posen und Materialien. Der frühere `build_arcade.py` ist nur Hersteller des historischen kleinen Automaten/Funkenblatts und der vorhandenen Bühne; nicht zum Überschreiben aktueller Grafiken ausführen.
- Spielstand `user://shadepi-arcade.cfg`: Fund und Siege gegen die CPU.
- Prüfungen: `tests/arcade.gd`, `tests/arcade_art.gd`, `tests/arcade_inputs.gd`, `tests/integration_v064.gd`. Der reine Richtungsring steht in `scripts/arcade/fighter_input.gd`.
