# Musikzuordnung

Das Spiel lädt die zugeordneten MP3-Dateien in diesem Ordner direkt. Eine Datei wird für mehrere passende Abschnitte wiederverwendet; Kopien sind nicht nötig. **Zuordnung v0.37.0 · CodexAI:** Kapitel 7 nutzt ausdrücklich `menu.mp3`; das Hauptmenü behält `Level.mp3`.

| Datei | Verwendung |
| --- | --- |
| `menu.mp3` | ganz Kapitel 7: See-Anflug, Ordensaufnahme und romantisches Finale |
| `Boss.mp3` | alle Bosskämpfe: Chrome Jackal und Kenzō |
| `Fight.mp3` | normale Kämpfe, Deep Dive, Hinterhalt und Fahrzeugverfolgung |
| `Level.mp3` | Hauptmenü, Kapitel 1 und Garage |
| `Level2.mp3` | Industriegebiet, Ravens Versteck, Hangar und Tower-Erkundung |
| `Level3.mp3` | Pakt, Heiligtum, Echo, Flug und Flucht |

## Ablauf im Spiel

- Beim Öffnen des Hauptmenüs läuft weiterhin `Level.mp3`.
- In Kapitel 7 läuft `menu.mp3`, sowohl bei der See-Ankunft als auch beim Finale. Beide Abschnitte verwenden dieselbe Datei ohne Kopie.
- Sobald ein normaler Kampf beginnt, wechselt die Musik zu `Fight.mp3`.
- Bei jedem Bosskampf läuft `Boss.mp3`.
- In gemischten Abschnitten wechselt die Musik erst beim tatsächlichen Kampfbeginn. Die Tower-Erkundung nutzt beispielsweise `Level2.mp3`; bei den Aufzugwachen beginnt `Fight.mp3`.
- Nach dem Ende eines Kampfes oder beim Betreten des nächsten Abschnitts wird wieder die dort zugeordnete Levelmusik geladen.

## Dateien austauschen

Die Namen einschließlich Groß- und Kleinschreibung beibehalten und die jeweilige MP3 ersetzen. Danach das Projekt einmal in Godot öffnen, damit die Datei neu importiert wird. Beim Export wird die zu diesem Zeitpunkt vorhandene Musik eingebettet.

Falls eine Datei fehlt, verwendet das Spiel automatisch `assets/audio/neon-loop.wav`. Alternativ unterstützt der Loader weiterhin OGG und WAV mit demselben Basisnamen, wobei MP3 zuerst gewählt wird.
