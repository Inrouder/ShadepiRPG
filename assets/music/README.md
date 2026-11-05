# Austauschbare Musik

Jeder Spielabschnitt lädt seine Musik aus diesem Ordner. Lege eine Datei mit dem unten genannten Namen hier ab und öffne das Projekt einmal in Godot, damit sie importiert wird. Unterstützt werden **MP3**, **OGG** und **WAV**; gesucht wird in dieser Reihenfolge. Fehlt eine Datei, läuft automatisch `assets/audio/neon-loop.wav`.

Die Dateien werden beim Abspielen automatisch wiederholt. Für einen Export müssen die Musikdateien vor dem Export im Projekt liegen.

| Abschnitt | Dateiname ohne Endung |
| --- | --- |
| Startmenü | `menu` |
| Testszene | `demo` |
| Kapitel 1: Apartment | `chapter-1-apartment` |
| Kapitel 1: Jagd | `chapter-1-hunt` |
| Kapitel 1: Duell | `chapter-1-duel` |
| Kapitel 1: Dach | `chapter-1-rooftop` |
| Kapitel 1: Rettung | `chapter-1-rescue` |
| Kapitel 1: Finale | `chapter-1-finale` |
| Kapitel 2: Industriehof | `chapter-2-industry` |
| Kapitel 2: Versteck | `chapter-2-hideout` |
| Kapitel 2: Deep Dive | `chapter-2-dive` |
| Kapitel 2: Rettung / Kühlung | `chapter-2-recovery` |
| Kapitel 3: Pakt | `chapter-3-pact` |
| Kapitel 3: Hinterhalt | `chapter-3-ambush` |
| Kapitel 3: Verfolgung | `chapter-3-chase` |
| Kapitel 4: Garage | `chapter-4-garage` |
| Kapitel 4: Hangar | `chapter-4-hangar` |
| Kapitel 5: Heiligtum | `chapter-5-sanctuary` |
| Kapitel 5: Echo | `chapter-5-echo` |
| Kapitel 6: Flug | `chapter-6-flight` |
| Kapitel 6: Tower | `chapter-6-tower` |
| Kapitel 6: Boss | `chapter-6-boss` |
| Kapitel 6: Flucht | `chapter-6-escape` |
| Kapitel 7: See | `chapter-7-lake` |
| Kapitel 7: Finale | `chapter-7-finale` |

Beispiel: `chapter-2-dive.mp3` ersetzt ausschließlich die Musik im Deep Dive. Bereits exportierte Builds enthalten weiterhin die Musik, die zum Zeitpunkt des Exports im Projekt lag.
