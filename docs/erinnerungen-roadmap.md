# Roadmap: Shadepis drei Erinnerungen · v0.21.2 · CodexAI

**Stand: Planung, keine neuen Grafiken oder Spielszenen umgesetzt.** Grundlage sind das [Nutzerbriefing mit bestätigten Schutzopfern](universum/teil-5/README.md), die vorhandenen Figurenreferenzen und das [Heiligtum-/Romanarchiv](universum/teil-4/README.md). Diese Roadmap legt die Produktionspakete und die erzählerische Kontinuität vor dem ersten Asset fest.

## Ziel und vorhandener Spieleinstieg

Raven erlebt an jedem der drei Erinnerungsknoten eine eigenständige Rückblende aus Shadepis Vergangenheit. Der Spieler sieht das historische Geschehen mit Shadepi und dem Orden. Raven bleibt die Empfängerin der Erinnerung; sie läuft nicht als zusätzliche Kämpferin durch das damalige Kloster.

Im aktuellen Spiel existieren die drei Anker bereits: `Painted.ECHO_POINTS` in `scripts/painted_world.gd` und der Ablauf `Beat.ECHO` in `scripts/campaign.gd`. Aktuell erscheinen dort nur die Hinweise „Das Kloster“, „Die früheren Träger“ und „Die Nacht des Angriffs“; am letzten Punkt folgt die Rückkehr zu Raven. Diese Anker sollen später gezielt durch **Der Angriff → Lys Opfer → Das Vermächtnis** erweitert werden. Die bestehenden übrigen Kapitel, Menüs und Kontrollpunkte bleiben Ausgangsbasis.

Die Rückblenden nutzen später das vorhandene System für laufende Figuren, Kamerafahrten, Dialoge und Überspringen. Zunächst entstehen inszenierte Szenen; vollständige spielbare Kämpfe sind getrennte Ausbaupakete. Es werden keine Comicseiten als Ersatz für die Szene eingeplant.

## Die drei Erinnerungen

### 1. Der Angriff

**Bildidee:** Ein abgeschiedenes Ordenskloster aus Stein, Holz und traditionellen Dächern, mit zurückhaltend integrierter Cybertechnik. Zunächst sind Tor, Hof, Arkaden und ein Teil des Hauptgebäudes erkennbar. Bombeneinschläge verändern genau diese Umgebung: gebrochene Ziegel, brennende Balken, Rauch und Schutt. Flüchtende Menschen machen Richtung und Gefahr lesbar.

| Moment | Sichtbares Geschehen | Dramatische Aufgabe |
| --- | --- | --- |
| Ankunft der Erinnerung | Kamera fährt vom beschädigten Dach in den Hof; Glocke, Einschläge und Feuer etablieren die Lage. | Ort und Angriff begreifbar machen. |
| Flucht | Mönche und gewöhnliche Bewohner laufen durch einen geschützten Seitenweg aus dem Hof. | Zeigen, wen der Orden verteidigt. |
| Gegenstoß | Shadepi tritt vorne an, die vier Krieger folgen in erkennbarer Formation. | Alle fünf Figuren eindeutig vorstellen. |
| Shadepis Ruf | „Bringt euch in Sicherheit! Wir werden sie abwehren!“ | Schutzauftrag statt namenloser Kampf. |
| Erste Feindberührung | Bots dringen durch den äußeren Zugang ein; die Verteidiger fangen sie ab. | Übergang zum späteren Kampf. |
| Späteres Kampf-Ausbaupaket | Bot-Wellen durchbrechen Teile der Verteidigung. Oni- und MG-Krieger schützen Shadepi und fallen dabei. | Den Verlust der beiden verbindlich ausgewählten Kameraden erzählen. |

Für den ersten sichtbaren Bot-Auftritt gehört eine passende HQ-Botansicht zusätzlich zum Szenenpaket; sie entsteht nach der Map und nur bei verbleibendem Kontingent. Eine echte neue Angreiferfigur wird dabei nicht durch einen beliebigen menschlichen NPC oder eine einfache Form ersetzt.

Der erste Szenenstand darf beim Beginn der Auseinandersetzung enden. Die vollständigen Bot-Wellen und Schutzopfer folgen erst im ausdrücklich getrennten Kampf-Ausbau. Ly und der Roboterkopf-Krieger überleben diese Erinnerung. Die beiden Opfer werden später als feste Storymomente inszeniert; sie sollen nicht zufällig durch die erste beliebige KI-Attacke sterben.

**Vorschlag für die beiden Schutzmomente, noch kein zusätzlicher Kanon:** Der Oni-Krieger fängt einen Nahkampfangriff ab, der Shadepi treffen würde. Der MG-Krieger hält anschließend die Bresche gegen mehrere Bots offen und ermöglicht Shadepis Rückzug zu den Überlebenden. Die konkrete Choreografie wird bei der Kampfproduktion abgestimmt.

### 2. Lys Opfer

Der Hof geht in einen schwer beschädigten Verteidigungsbereich über. Ein deutlich größerer **Minotaurus-Panzer** dominiert den Kampf. Ly bleibt durch seine weiße Gewandung sofort erkennbar. Shadepi versucht, ihn aufzuhalten; Ly entscheidet sich bewusst für sein Opfer.

> **Shadepi:** „Nein! Ly, nicht!“
>
> **Ly:** „Verzeih mir, Bruder. FÜR DEN ORDEN!“

Die Dialogfassung ist sprachlich geglättet, die Aussage des Nutzerbriefings bleibt erhalten. Ly rennt auf den Minotaurus zu; sein Angriff zerstört den Panzer und kostet ihn das Leben. Die technische Ursache der Zerstörung – etwa Überladung oder Sprengladung – ist noch nicht bestimmt und wird nicht als bestätigte Fähigkeit erfunden.

**Spätere Assets:** beschädigte Variante des vorhandenen Hofs, Minotaurus-Panzer mit klar erkennbaren Schwachstellen, Lys Lauf-/Opferbewegung, passende Licht-, Rauch- und Trümmerphasen. Vor der Tankgrafik ist die Bauform festzulegen: Laufbeine oder Ketten sind im Briefing noch nicht entschieden.

Der Roboterkopf-Krieger ist nach Erinnerung 1 noch am Leben. Sein weiterer Einsatz oder Verbleib wird nicht ohne zusätzliche Vorgabe als Tod erzählt. Diese Erinnerung wird erst nach Abschluss des ersten Erinnerungspakets produziert.

### 3. Das Vermächtnis

Das gleiche Kloster ist nun fast vollständig zerstört. Wiedererkennbare Säulen, Stufen und Dachreste verbinden die Bilder mit den ersten beiden Erinnerungen. In einer kurzen Ruhezone hält Shadepi den alten Meister, den bisherigen Träger des Heiligtums.

> **Meister:** „Shadepi, du musst das Heiligtum beschützen. Das hat oberste Priorität.“
>
> **Shadepi:** „Ich werde es mit meinem Leben beschützen. Der Orden muss leben. Danke für alles, Meister.“

Das Licht beginnt im Inneren des Meisters und geht als weißer Energiestrom auf Shadepi über. Pixelpartikel, Kleidung und Rüstung reagieren auf das Licht; Knistern und Knacken steigern sich. Die Darstellung bleibt mit dem Archiv vereinbar: Das Heiligtum ist der empfindungsfähige Nanitenschwarm, keine neu eingeführte Gottheit.

Nach einem Moment der Stille richtet sich Shadepi auf. Zwischen Feuer und Trümmern stellen sich ihm **zwei Minotauren** entgegen. Nach dem Kampf bricht er reglos zusammen; die Erinnerung endet und Raven kehrt in die Gegenwart zurück. Der Zusammenbruch ist keine Todesfestlegung für Shadepi. Das spätere Verschwinden des Klosters liegt außerhalb dieser drei gezeigten Augenblicke.

**Spätere Assets:** alte Meisterfigur in traditioneller Kampfausrüstung, Halte-/Übergabeposen, Ruinenvariante derselben Architektur, weißer Nanitenstrom und beide Panzer. Panzer und Zerstörungsteile aus Erinnerung 2 werden weiterverwendet.

## Figuren und visuelle Kontinuität

| Figur | Verbindliche Merkmale | Rolle und Kontinuität |
| --- | --- | --- |
| Shadepi | Bestehende Originalmerkmale: schwarzer Kasa, segmentierte Maske, rote Augenlinsen, taktische Ausrüstung, Schal, Umhang und Laser-Katana. | Führt den Gegenstoß; überlebt die drei Erinnerungen, bricht zuletzt zusammen. |
| Oni-Krieger | Deutlich erkennbare Oni-Maske; eigene Silhouette und passende Ordensrüstung. | Stirbt in Erinnerung 1 beim Schutz Shadepis. Name und Waffe offen. |
| Roboterkopf-Krieger | Erkennbarer Roboterkopf, Dreadlocks aus Kabelsträngen; gemeinsame Ordensgestaltung. | Überlebt Erinnerung 1; weiteres Schicksal offen. Name und Waffe offen. |
| Ly | Shadepi-ähnliche Maske und weiße Gewandung, als eigene Person erkennbar. | Überlebt Erinnerung 1 und opfert sich in Erinnerung 2. „Bruder“ wird nicht ungefragt zu einer bestätigten biologischen Verwandtschaft ausgebaut. |
| Schwerer MG-Krieger | Samurai-Maske, volle schwere Panzerung, sehr großes MG; breite und gewichtige Silhouette. | Stirbt in Erinnerung 1 beim Schutz Shadepis. Name offen. |
| Mönche und Bewohner | Unbewaffnete Klosterbevölkerung in passenden Gewändern bzw. einfacher Alltagskleidung. | Fliehen auf nachvollziehbaren Wegen; keine bloß im Hintergrund eingebrannten Personen. |
| Meister / alter Träger | Alter Mann in traditioneller Kampfausrüstung. | Übergibt in Erinnerung 3 das Heiligtum. Eigenname und endgültiges Design offen. |

Neue Grafiken sind **detailreiche HQ-Pixelart**: sichtbare Pixelcluster, strukturierte Stoffe, Metall, Stein und Holz, abgestimmte Lichtstufen und echte Materialtiefe. Große Dateimaße allein reichen nicht. Perspektive, Figurengröße, Fußpunkte und Pixeldichte richten sich nach dem aktuellen Spiel. Ly darf nicht mit Shadepi oder dem Meister verwechselt werden. Keine einfachen Vektorfiguren oder glatten Ersatzillustrationen.

## Produktionsreihenfolge für Erinnerung 1

„Kulissen“ bezeichnet zunächst den visuellen Master und die benötigten Bildebenen. „Map-Kulisse“ bezeichnet anschließend die daraus aufgebaute, begehbare Spielumgebung mit Tiefe, Laufwegen, Verdeckungen und Kollisionen. So entsteht keine doppelte, voneinander abweichende Architektur.

| Paket | Arbeit | Konkretes Ergebnis | Abschlusskriterium |
| --- | --- | --- | --- |
| 0 · Roadmap | Quellen, Handlung und Prioritäten sichern. | Dieses Dokument und Archiv Teil 5. | Reihenfolge, Opfer und offene Fragen sind benannt. **Aktueller Stand.** |
| 1 · Kulissen zuerst | Ein Kloster-Master mit Tor/Hof/Hauptgebäude; beschädigte und brennende Ebenen daraus ableiten. | HQ-Pixel-PNGs, getrennte Vorder-/Mittel-/Hintergrundteile sowie erste modulare Trümmer- und Feuerbereiche. | Ort, Maßstab und Stimmung funktionieren ohne Figuren; keine Bewohner oder Krieger ins Bild einbrennen. |
| 2 · Vier Krieger | Zuerst die vier Identitäten sauber festlegen, danach die für den Ansturm nötigen Richtungen und Bewegungen. Shadepi wiederverwenden. | Oni-, Roboterkopf-, Ly- und MG-Referenzen; nutzbare Spritebilder mit konsistenten Fußankern. | Alle vier sind im Spielmaßstab unterscheidbar und behalten Ausrüstung und Proportionen beim Blickwechsel. |
| 3 · Mönche und Bewohner | Kleine Gruppe unterschiedlicher unbewaffneter Figuren mit Stehen, Rennen und erschrockenem Reagieren. | Wiederverwendbare Bewohner-/Mönch-Sprites statt vieler unnötiger Einzelporträts. | Ein kurzer Fluchtlauf wirkt lebendig und führt ohne Stau aus der Gefahrenzone. |
| 4 · Map-Kulisse | Kulissenebenen, Figurenmaßstab und Laufwege zusammenführen. | Spielmap mit Torbresche, Verteidigungslinie, Fluchtweg, Kollisionskörpern und Vordergrundverdeckungen. | Niemand läuft durch Mauern; Füße stehen auf dem Boden; Figuren werden hinter Säulen/Dächern korrekt verdeckt. |
| 5 · Szene, nur bei verbleibendem Kontingent | Kamerafahrt, Flucht, Ansturm, Shadepis Ruf, Einschläge und beginnender Bot-Angriff verbinden. | Erste inszenierte Rückblende am ersten Erinnerungsknoten. | Szene startet und endet sauber, lässt sich bedienen/überspringen und kehrt korrekt zu Raven zurück. |
| 6 · Kampf-Ausbau später | Erst jetzt vollständige Bots, Wellen, Kampfposen und die Schutzopfer von Oni und MG-Krieger ergänzen. | Spielbarer oder vollständig inszenierter Angriff mit verbindlichen Storyereignissen. | Ly und Roboterkopf überleben, die beiden Schutzopfer sind klar verständlich, Fortschritt ist zuverlässig gespeichert. |

Die Identitätsreferenzen kommen vor den Bewegungsatlanten. Neue Angriffssätze entstehen jeweils dann, wenn sie für den nächsten Kampfabschnitt gebraucht werden.

Nach Abschluss von Paket 6 folgt **Erinnerung 2**, danach **Erinnerung 3**. Erst die Roadmap umfasst alle drei; die erste Produktion konzentriert sich auf Erinnerung 1.

## Aufbau der ersten Map

| Bereich | Funktion |
| --- | --- |
| Klosterfassade und Dächer | Ort etablieren; unbeschädigte Referenzteile machen den späteren Verlust sichtbar. |
| Innerer Hof | Bewohner fliehen, Shadepi und vier Krieger sammeln sich. |
| Geschützter Seitenweg | Klarer Fluchtkorridor, der nicht durch den Bot-Zugang führt. |
| Tor und Bresche | Eindeutiger Eintritt der Angreifer und spätere Wellenbegrenzung. |
| Verteidigungslinie | Platz für fünf verschieden breite Figuren und spätere Kämpfe, besonders den MG-Krieger. |
| Arkaden, Säulen, Trümmer | Tiefe und Deckung mit getrennten Vordergrundebenen statt flachem Tapetenbild. |

Feuer, Rauch, Bombeneinschläge und herumfliegende Teile werden als begrenzte, wiederverwendbare FX-Gruppen angelegt. Reale Fluchtfiguren und bewegte Verteidiger erzeugen die Handlung; Kamera und Hintergrund werden nicht nur zur Simulation von Bewegung hin- und hergeschoben.

## Spätere Einbindung an den Erinnerungsknoten

Geplante Zuordnung: **Knoten 1 → Der Angriff; Knoten 2 → Lys Opfer; Knoten 3 → Das Vermächtnis**. Jede Rückblende erhält einen eigenen stabilen Bezeichner, getrennt vom sichtbaren Titel.

Beim Start werden Ravens aktuelle Position und der Erinnerungsknoten gehalten. Die historische Szene erhält eigene Figuren und lokalen Szenenzustand; Shadepi ist darin sichtbar und wird bei einem später spielbaren Ausbau gesteuert. Historische Figuren ersetzen keine Gegenwarts-NPCs und überschreiben keine aktuellen Lebens-/Energiewerte.

Ein Anker wird erst nach dem regulären Ende oder bewusstem Überspringen als abgeschlossen gespeichert. Abbruch, Neustart und Laden dürfen nicht doppelt weiterzählen oder die Szene an jedem Frame neu starten. Ein Rücksprung landet an Raven und dem passenden Anker. Ältere Spielstände ohne neue Rückblendenfelder müssen weiter laden können. Bestehende Bedienung und Controller-Unterstützung der Zwischensequenzen werden übernommen.

Die zwei ersten Erinnerungen sollen nicht schon offenlegen, dass Kenzō den Angriff beauftragt hat. Diese Enthüllung gehört weiterhin zum späteren Deckfund durch Raven. Die im Archiv zusätzlich erwähnten Erinnerungen früherer Träger bleiben Teil der Lore, sind aber nicht automatisch weitere Aufgaben in dieser dreiteiligen Rückblende.

## Kontingent, Sicherung und Prüfung

Es wird keine feste Rest-Credit-Zahl oder garantierte Zahl weiterer Bildgenerierungen behauptet. Vor jeder Assetgruppe werden vorhandene Quellen und bereits fertige Teile geprüft. Zuerst entsteht der kleinste zusammenhängende Satz, der das nächste Paket nutzbar macht; anschließend wird gespeichert und der Stand beschrieben. Varianten von Ruinen, Feuer und späteren Schauplätzen werden aus derselben Architektur entwickelt.

Wenn das Kontingent nach der Map ausgeschöpft ist, endet der Durchlauf mit gesicherten Kulissen, Kriegern, Bewohnern und Map. Die Szene bleibt dann ausdrücklich offen. Jeder Abschluss enthält Versionsnummer, CodexAI-Vermerk, Assetübersicht und tatsächlichen Prüfstatus; fertige Arbeit wird auf GitHub gesichert. Bei fehlgeschlagenem Push gilt die vollständige lokale Sicherung laut Projektregeln.

Spätere Prüfungen umfassen Grafik- und Fußanker, Laufwege, Sichtbarkeit der vier Krieger, korrekte Sterbereihenfolge, Lys Überleben bis Erinnerung 2, unveränderte Gegenwartsfiguren, Controllerbedienung, Pause/Überspringen, Speichern/Laden und Export aller benötigten Assets. Kulissen und Bewegungen werden zusätzlich im tatsächlichen Godot-Renderer angesehen.

## Noch offene Festlegungen

Die Auswahl der beiden ersten Gefallenen ist **geklärt: Oni und MG-Krieger**. Offen bleiben Eigennamen der übrigen neuen Figuren, Waffen von Oni-/Roboterkopf-Krieger, die genaue Minotaurus-Bauform, die technische Ausführung von Lys Opfer und das spätere Schicksal des Roboterkopf-Kriegers. Diese Punkte blockieren die Roadmap nicht; sie werden vor dem jeweiligen betroffenen Asset bzw. Storymoment festgelegt. Weitere Tote oder zusätzliche Fähigkeiten werden nicht ungefragt als Kanon eingetragen.
