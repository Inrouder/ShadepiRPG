# Story-Durchsicht Kapitel 1–7 · v0.47.0–v0.47.1 · ClaudeHelper

**Stand 9. November 2026.** Der gesamte spielbare Storyverlauf von Ravens Apartment bis zum See wurde gegen die Romanfassung ([Teil 4](universum/teil-4/README.md)), die Erinnerungsbriefings ([Teil 5](universum/teil-5/README.md)), die Tower-Vorgaben ([Teil 6](universum/teil-6/README.md)) und das See-Finale ([Teil 7](universum/teil-7/README.md)) gelesen. Bestätigte Nutzerzeilen und -abläufe blieben unverändert, darunter der Maskengriff mit allen fünf Zeilen, Lys Ruf, die Meisterübergabe, „Dreckmühle“, Kenzōs Griff vor Shadepis Eingreifen, die Extraktion vor Kenzōs Tod und Ravens Handverdeckung am See.

Es wurden keine neuen Grafiken erzeugt und keine Spielmechaniken geändert. Geändert wurden Dialoge, Ziele, Hinweise und ein Terminaltitel.

## Behobene Logikfehler

| Stelle | Problem | Korrektur |
| --- | --- | --- |
| Kapitel 3 → 6, Zeitlinie | Raven plant „morgen Abend“. Der Abflug folgte aber direkt auf ihren zweistündigen Schlaf in derselben Nacht. | Shadepi schließt Kapitel 5 mit „Morgen Abend ist Kenzō allein“. Kapitel 6 beginnt mit „Am nächsten Abend · Zurück im Hangar“, und Raven meldet die abgezogenen Angestellten. Der Plan nennt den Dienstag wie im Roman. |
| Kapitel 6, Dach | „Kennung am Dachterminal prüfen“, obwohl der Tower die kopierte Kennung im Anflug schon akzeptiert hatte. | Der Romansensor liest auch Biometrie. Raven fälscht jetzt das Biometrie-Log der Landung, bevor es die Wache eine Etage tiefer erreicht. Ziel, Hinweis und Terminaltitel `DACHTERMINAL / BIOMETRIE-LOG` passen dazu. |
| Kapitel 6, Tarnung | „Zwanzig Sekunden Tarnung“ wurden auf dem Dach genannt, aber es folgten zwei Hacks. | Das Tarnfeld hält drinnen zwanzig Sekunden; Shadepi wartet im Schatten der Luke, bis die Tür offen ist. Beim Eingreifen zeigt der Sprecher `SHADEPI / TARNUNG · 0`. |
| Kapitel 6, Kenzō | „Du bist tatsächlich gekommen“ setzte voraus, dass Kenzō Raven erwartet. Im Roman erschrickt er. | Kenzō bemerkt die nicht befohlene Landung, erkennt Raven überrascht. Er ahnte nur, dass jemand in seinen Projektdaten war, und ließ mögliche Verstecke stürmen. Ravens Frage nennt jetzt ausdrücklich ihre Eltern. |
| Kapitel 6, Explosion | Ein allgemeines „Evakuierungsprotokoll“ erklärte weder die Penthouse-Explosion noch die Sperrladung am Aufzug. | Shadepis in Kapitel 3 angekündigter **Plan C**: Ladungen am Tragwerk, T-60 wie im Roman. Das System meldet Wachen im Aufzug, deshalb muss Raven den Aufzug sperren. Der Countdown in der Fluchtszene zeigt den tatsächlichen Restwert. |
| Kapitel 6, Ravens Satz | „Wenigstens kann er ihnen niemanden mehr nachschicken“ ergab bei ermordeten Eltern keinen Sinn. | „Mama. Papa. … Es ist vorbei. Er jagt niemanden mehr.“ |
| Kapitel 7, Maske | „Und jetzt … darf ich?“ setzte eine Regel voraus, die vorher nie genannt wurde. | In Kapitel 5 nennt Shadepi den Kodex des Romans: Niemand außerhalb des Ordens sieht sein Gesicht. Am See macht die Aufnahme die Maskenabnahme erst möglich. Die Handverdeckung bleibt unverändert. |
| Kapitel 3, Hinterhalt | Der Hinterhalt fand Ravens Versteck, ohne dass erklärt wurde, wie. | **Nutzervorgabe v0.47.1:** Raven ist beim Deep Dive in Kenzōs ICE auf seine Daten gestoßen. Trotz verwischter Spuren hat sie offenbar nicht alles verschleiert. Kenzō ahnt einen Zugriff und schickt auf bloßen Verdacht Schläger und Soldaten an mehrere mögliche Orte. Raven will nicht zugeben, dass sie nicht gut genug war („Er rät nur“), und Shadepi antwortet: „Dann hat er diesmal richtig geraten.“ Raven würde nie ein fremdes Telefon mitnehmen; die Peilsender-Idee aus v0.47.0 ist verworfen. Im Tower erklärt Kenzō, warum er Raven nicht erwartet hat. |

## Intensivere Kontexte

- **Kapitel 1:** Shadepi beobachtet vom Dach mit dem Romanmotiv der fünf Jahre seit dem Feuer und mit der Wärmesicht auf die beiden Signaturen. Er greift mit „Das reicht. Tarnung“ ein.
- **Kapitel 2:** Während Ravens Deep Dive meldet Shadepis HUD die Unruhe des Heiligtums (85 %) wie im Roman. Das bereitet Kapitel 5 vor, ohne Ordensgeheimnisse zu verraten. Ravens Kollaps klingt nach Synapsenüberhitzung.
- **Kapitel 3:** Der Tower-Plan nennt Kenzōs Dienstagsritual, Shadepis Misstrauen („fast zu einfach“) und Ravens Ziel, Kenzō am Ende ins Gesicht zu sehen.
- **Kapitel 4:** Ravens Romanfrage „Mensch oder nur Metall?“ fällt vor Shadepis Gang zum Kompensator und führt zum späteren Maskengriff.
- **Kapitel 5:** Ravens Eintritt in die Rückblende beginnt mit Rauch, Explosionen und Schreien. Nach jeder Erinnerung reagiert sie in einem eigenen Satz auf die Gefallenen und auf Ly.
- **Kapitel 6:** Shadepi sagt im Hangar „Du wurdest mir prophezeit“, und Raven verschiebt die Erklärung auf „wenn wir lebend zurück sind“. Shadepi ruft „Nicht ich töte dich – das ist ihr Vergnügen“, die Flucht endet mit „Halt dich gut fest – jetzt wird's holprig!“.
- **Kapitel 7:** Die Aufnahme folgt dem Romanwortlaut: Shadepi stünde auch ohne Prophezeiung an Ravens Seite und ist mit ihr „nicht nur ein Schatten“. Er spricht als einst erster Krieger des Ordens, und Ravens „Ich habe nichts mehr zu verlieren“ löst die Prophezeiung aus dem Hangar auf.

## Unverändert offen

Warum Kenzō den Angriff inszeniert hat und wer sein Auftraggeber ist, bleibt laut Teil 6 unbekannt. Ebenso offen sind das spätere Schicksal des Roboterkopf-Kriegers, der Name des Meisters und die Identität des Drachen am See.

## Prüfung

Alle 33 CI-Testsuiten liefen lokal ohne Fehler. Dazu gehören Story-Audit (Dialog- und Zielgrößen), Heiligtum-Ablauf mit den fünf Pflichtzeilen, Hangar-Abflug mit „Dreckmühle“, Tower-Ablauf, See und alle drei Erinnerungen. Das Repository-Audit lief ebenfalls ohne Fehler.
