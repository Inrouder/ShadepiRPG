# Erinnerung III: Das Vermächtnis · v0.26.0 · CodexAI

**Alle drei Erinnerungen sind jetzt eingebunden.** Am dritten Knoten erlebt Raven Shadepis Schutzversprechen an seinen Meister, die Übertragung des Heiligtums und den letzten Kampf gegen zwei Minotauren. Danach bricht Shadepi reglos zusammen. Der Abschluss erklärt ihn nicht für tot.

![Aufgezeichnete Spielszenen aus der dritten Erinnerung](previews/vermaechtnis.webp)

Die Vorschau zeigt Ausschnitte des tatsächlichen Godot-Spielablaufs. Ein Testpilot bedient den Kampf durch Bewegung, Angriff und Ausweichen; er verändert weder Bossleben noch Schadenswerte. Dialoge werden für die Aufzeichnung automatisch weitergeschaltet.

## Die Übergabe

Das Kloster ist fast vollständig zerstört. Drachenreliefs, Treppe, Seitengang und Tor bleiben als dieselbe Architektur erkennbar. In einem ruhigen Seitenbereich hält Shadepi seinen Meister: einen alten Mann mit weißem Bart, gebundenem Haar und traditioneller bronze-/brauner Kampfausrüstung. Der Meister erhält keinen erfundenen Eigennamen.

> **Meister:** „Shadepi, du musst das Heiligtum beschützen. Das hat oberste Priorität.“
>
> **Shadepi:** „Ich werde es mit meinem Leben beschützen. Der Orden muss leben. Danke für alles, Meister.“

![Shadepi hält den Meister](vermaechtnis-meister.png)

Licht entsteht in der Brust des Meisters und geht als weißer Nanitenstrom auf Shadepi über. Acht Bildphasen, weiße Partikel und eigenes Knistern begleiten die Übertragung. Danach richtet sich Shadepi auf; der Meister bleibt im Seitenbereich. Der Roboterkopf-Krieger wird in dieser Erinnerung nicht gezeigt und erhält keinen zusätzlichen Tod.

![Der weiße Strom zwischen Meister und Shadepi](vermaechtnis-uebergabe.png)

## Spielbarer Kampf gegen zwei Minotauren

Shadepi tritt allein gegen beide Gegner an. Jeder Minotaurus besitzt **168 eigene Lebenspunkte**, eigene Taumelwerte und seinen eigenen Wrackzustand. Katana-Treffer in Reichweite und Blickrichtung beschädigen die Servogelenke; vier Treffer bringen den jeweiligen Gegner kurz ins Taumeln. Beide müssen zerstört werden. Ein Zeitablauf beendet den Kampf nicht automatisch.

![Beide Gegner im tatsächlichen Kampf](vermaechtnis-kampf.png)

Die Mechs wechseln sich mit angekündigtem Sperrfeuer ab. Die Einschlagsflächen werden vor dem Schuss festgelegt und verfolgen Shadepi nicht. Mit sinkenden Boss-Lebenswerten steigen Zahl und Tempo der Einschläge. Ausweichen schützt kurz vor Treffern. Ein besiegter Gegner durchläuft den Zusammenbruch und bleibt als Wrack liegen; sein Feuer setzt aus.

| Eingabe | Im Kampf |
| --- | --- |
| WASD / Pfeile / linker Stick / Steuerkreuz | Bewegen. |
| J / X / linke Maustaste | Katana-Schlag. Nah herangehen und zum Gegner schauen. |
| Leertaste / B | Ausweichen; kurzer Schutz, danach Abklingzeit. |
| Esc / Start | Pause öffnen. |
| E / Enter / A nach Niederlage | Nur den Kampf wiederholen. Beide Gegner und lokale Lebenswerte werden zurückgesetzt. |

Im Pausenmenü wählen Pfeiltasten, Steuerkreuz, Stick oder Tab den Knopf; Enter / E / A bestätigt. **Erinnerung überspringen** löst den vollständigen Abschluss aus, **Erinnerung verlassen** kehrt ohne Abschluss zum dritten Knoten zurück. Während des Kampfs ist B Ausweichen; bewusstes Überspringen erfolgt über das Pausenmenü. Außerhalb des Kampfs gelten E / Enter / A für Weiter und Leertaste / B für Überspringen. Fokusverlust pausiert den Kampf ebenfalls.

## Der Zusammenbruch und die Rückkehr

Nach dem Sieg setzt die Inszenierung ein: Shadepi sinkt auf ein Knie und fällt reglos auf den Boden. Beide Minotaurus-Wracks bleiben im Bild. Es gibt keinen Todesmarker für Shadepi. Die Erinnerung endet, Raven kehrt zurück und spricht über sein Versprechen. Danach geht der bestehende Ablauf in den Aerodyne-Flug über.

![Shadepi zwischen den zerstörten Minotauren](vermaechtnis-zusammenbruch.png)

Die historische Gesundheit bleibt von Raven und Shadepis Gegenwartswerten getrennt. Der dritte Knoten hat ein eigenes typgeprüftes Speicherfeld `memory_legacy_complete`. Ältere ECHO-Spielstände behalten die Abschlüsse der ersten beiden Erinnerungen und bieten die dritte Szene am letzten Knoten an. Bereits abgeschlossene neue Speicherstände wiederholen den Kampf nicht; sie setzen am Rückkehrdialog fort, wenn der letzte Knoten erneut bestätigt wird. Kapitel außerhalb der Erinnerungskammer werden nicht zurückgesetzt.

## Grafiken, Ton und Umsetzung

| Neue Quelle unter `assets/memories/legacy/` | Inhalt |
| --- | --- |
| `courtyard.png` · 1585×992 | Letzte Ruinenstufe mit gleicher Raumaufteilung. |
| `characters.png` · 1536×1024 | Acht Meister-, Halte-, Empfangs-, Erschöpfungs- und Liegeposen. |
| `transfer.png` · 1536×1024 | Acht weiße Transferphasen als freigestellter Pixel-FX-Atlas. |
| `actors.json` | Gemessene Quellregionen und Bodenkontakte mit gemeinsamer Körpergröße. |
| `manifest.json` | Figuren, Umfang und ausdrücklich nicht als Tod festgelegter Schlusszustand. |

Die drei PNG-Quellen wurden mit dem Bildwerkzeug auf Grundlage der vorhandenen Grafiken erstellt. `tools/measure_legacy_art.py` liest die Transparenz, ohne Bildpixel umzuschreiben. Minotauren, Shadepis Kampf-Sprites, Einschläge und die Bedienung aus Erinnerung II werden wiederverwendet. Die Halte- und Schlussposen ergänzen die Originalfigur nur für diese Inszenierung. Alle Sprite-Atlanten werden mit Nearest-Filter dargestellt.

`tools/generate_legacy_audio.py` erzeugt das eigene kurze Knistern `assets/audio/legacy_transfer.wav` aus deterministisch synthetisierten Impulsen; es enthält keine fremden Aufnahmen. Vor der Schlacht läuft die Musik des Heiligtums, im Bosskampf **Boss.mp3**, danach wieder die Musik der Erinnerungskammer. Die Tonoption gilt auch für die neuen Geräusche.

Laufzeitdateien: `legacy_memory.gd`, `legacy_figure.gd` und `legacy_battle.gd` unter `scripts/memories/`. Die Szene nutzt den vorhandenen Direktor, eine eigene historische Physikwelt und die sichere Rückkehr mit Serien-/Knotenprüfung. `tools/legacy_gallery.gd` zeichnet den Kampagneneinstieg auf; `tools/legacy_pilot.gd` enthält nur die Eingabeautomation für Tests und Vorschauen.

## Geprüfter Stand

**Sechs Prüfreihen mit insgesamt 1.068 Prüfungen ohne Fehler:** Erinnerung III 42, Erinnerung II 69, Erinnerung I/Einbindung 143, erster Klosterkampf 226, Kampagne/Speichern 382 und Story-Audit 206.

Die gezielten Prüfungen spielen die komplette Szene einschließlich beider Siege durch tatsächliche Angriffs- und Ausweicheingaben. Sie prüfen getrennten Schaden, Taumeln, Warnziele, Wiederholung, Pause einschließlich des ersten Transferbilds, Controller-Abbruch/-Überspringen im Kampf, gespeicherte Abschlüsse und veraltete Rückmeldungen nach Kapitelwechsel. Shadepis Schlusszustand wird ohne Todesflag geprüft. Bestehende Erinnerungen und der Kampagnenablauf bis zum Flug werden zusätzlich kontrolliert.

Ein Linux-PCK wurde erzeugt und die neuen Figuren, Transfergrafik, Ankerdaten, Knistern, beide Mechs und der vollständige Zusammenbruchzustand direkt daraus geladen und geprüft.

Die Szene wurde im OpenGL-Renderer vom Meistergespräch bis zu Ravens Rückkehr angesehen. Alle drei Erinnerungen bleiben nach der [Roadmap](erinnerungen-roadmap.md) und dem [verbindlichen Briefing](universum/teil-5/README.md) nachvollziehbar. Der weitere Verbleib des Roboterkopf-Kriegers und das spätere Verschwinden des Klosters werden durch diese Szene nicht ergänzt.
