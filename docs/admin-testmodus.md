# DEV // TESTLAB – verstecktes Admin-/Testmenü

Ab **ShadepiRPG v0.14.0** gibt es ein lokales Testmenü für Entwicklungs- und Leveltests. Es ist bewusst versteckt, aber **nicht passwortgeschützt**.

## Öffnen und bedienen

Öffne das Spielmenü (zu Spielbeginn oder mit `Esc` / Start-Taste im Spiel). Drücke dann **Strg + Umschalt + F10** oder **klicke fünfmal auf den Titel** im Hauptmenü. Das Fenster „DEV // TESTLAB“ erscheint. `Esc` oder das X schließt es; mit dem Mausrad kannst du durch die Optionen scrollen.

## Möglichkeiten

| Testwerkzeug | Wirkung |
| --- | --- |
| Alle Kapitel freischalten | Schaltet die Levelwahl 1–7 im Testmenü frei. |
| Test starten | Lädt den Anfang des ausgewählten Kapitels, auch wenn die Handlung diesen Punkt noch nicht erreicht hat. |
| Unendlich Leben | Schützt die Spielfiguren gegen normalen Schaden und verhindert Schaden in den Fahrzeugsequenzen. Skriptbedingte Storyereignisse bleiben erhalten. |
| Ein Treffer = K.O. | Reguläre Treffer besiegen ungeschützte Gegner sofort. Die Story-Panzerung und Mindestgesundheit in geskripteten Kämpfen bleiben wirksam. |
| Unendliche Energie | Füllt die Energieleiste fortlaufend auf. |
| Keine Wartezeiten | Setzt Abklingzeiten für Angriffe, Dash, Tarnung, Hacking und Fahrzeugangriffe zurück. |
| Fluchttimer anhalten | Friert nur den 60-Sekunden-Fluchttimer in Kapitel 6 ein. |
| Aktuelle Gegner besiegen | Besiegt die aktiven humanoiden Gegner bzw. entfernt aktuelle ICE-Gegner. Das geskriptete erste Jackal-Duell ist ausgenommen. |
| Leben / Energie auffüllen | Heilt lebende Charaktere und füllt Energie auf. |
| Alle Cheats AUS | Schaltet sämtliche Testhilfen ab. |

Die Kapitelnummern 3–7 werden auf ihre entsprechenden Startpunkte in der Kampagnenszene abgebildet: Pakt, Garage, Heiligtum, Anflug beziehungsweise See.

## Getrennte Spielstände

**Bereits beim Öffnen** des Testmenüs wird für den laufenden Programmstart die Testsitzung aktiviert. Test-Kontrollpunkte werden in separate Dateien `user://shadepi-admin-*.cfg` beziehungsweise eigene JSON-Testdateien geschrieben; normale `user://shadepi-*.cfg`-Spielstände bleiben erhalten. Das gilt auch bei Kapitelwechseln innerhalb derselben Testsitzung.

Die Cheat-Einstellungen selbst liegen in `user://shadepi-admin-settings.cfg`. Sie bleiben beim nächsten Start erhalten, die separate Testsitzung endet beim Schließen des Programms. Vor einem normalen Spieldurchlauf sollten die Cheats wieder abgeschaltet werden.

Das Testmenü ist ein Entwicklungswerkzeug. Es bietet keine Zugriffsverwaltung, keine Online-Freischaltung und keinen Schutz vor Manipulation lokaler Spielstände.
