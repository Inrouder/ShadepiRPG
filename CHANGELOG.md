# Versionshinweise

## v0.35.0 – CodexAI: Glaubhafte Tower-Ankunft, durchgehende Flucht und Hangar-Laufwege · 9. November 2026

- Kenzō wartet sichtbar neben dem Sessel statt in dessen Sitz-/Standfläche. Raven kommt vom Eingang und nähert sich über freie Laufpunkte. Erst nach Griff und Bedrohung wird Shadepi sichtbar und läuft vom Eingang zu ihnen; keine unmittelbare Erscheinung am Gegner.
- Tower-Abflug in einer einzigen Außenansicht vom Rennen bis zum Wegflug. Derselbe Schiffsknoten bleibt bestehen. Flugkurven teilen sich Position und Geschwindigkeit an den Übergängen: Kippen, beschleunigter Fall, langsamer Schubaufbau und Abfangen gehen ineinander über. Die Nase richtet sich zur Flugbahn aus. Der Kontaktschatten folgt bis zum Verlust der Bodenauflage.
- Gemeinsamer filmischer Aerodyne-Renderer verwendet die vorhandene HQ-Fahrzeuggrafik. Tatsächliche Düsenanker aus dem Quellbild und dieselbe Perspektiv-/Rolltransformation für Körper und Abgasstrahlen. Isolierte vorhandene Flammenpixel mit Cyan-Farbe und sanft überblendeten Bildern ersetzen Fackel-/Holzfragmente und schwebende Glühkreise. Explosionsbilder laufen einmal am Penthouse ab.
- Hangar-Start auf freiem Gang vor der Vorderwand; beide laufen unterhalb des großen Kastens und seitlich um die Konsolen zum Schiff. Kameraausschnitt hält den Gang sichtbar. Raven und Shadepi steigen nacheinander ein. Cockpit, ARTOS-Ausfall, Armatur-Schlag und anschließender Flug bleiben erhalten.
- **1.132 Prüfungen ohne Fehler** in neun gezielten Prüfreihen, zusätzlich tatsächliche Godot-Aufnahmen aller drei Abläufe. Neue Bewegungs-/Routenprüfung im GitHub-Build. [Spielbilder und Film](docs/tower-inszenierung.md), [Konsistenznachweis](docs/arbeiten/tower-inszenierung-v035.md).

## v0.34.0 – CodexAI: Bildschirmfüllendes 16:9, Vollbild und Anzeigeoptionen · 9. November 2026

- Zentrale Anzeigeverwaltung für alle Kapitel: Standard Fenstervollbild, zusätzlich Fenster und exklusives Vollbild. F11 und Alt+Enter wechseln zum Fenster und zurück zum zuletzt gewählten Vollbildmodus; Tastaturwiederholung löst keinen mehrfachen Wechsel aus.
- Standardmäßig passende Skalierung statt erzwungener ganzer Pixelstufen: Auch ein maximiertes beziehungsweise ungerades Fenster nutzt die verfügbare Bildfläche mit korrektem 16:9. Ausgabe in Full HD, 1440p und 4K. Die Spielbasis bleibt 640×360; das HQ-Menü behält seinen Renderer in Fensterauflösung.
- Gemeinsames Anzeige-Menü mit persistenter Modus-/Fenstergrößen-/Skalierungsauswahl, tatsächlicher Ausgabegröße und vollständiger Controller-/Tastaturbedienung. Ganze Pixelstufen bleiben optional. Größen werden mit Platz für Fensterrahmen an den aktuellen Monitor angepasst; Vollbild nutzt die native Desktopauflösung.
- Anzeige-Knopf neben Ton ohne Überschneidung mit Kapitelknöpfen. Controller-B schließt auch native Auswahllisten, danach den Dialog; Fokus bleibt im Dialog und kehrt zum Menü zurück. Getrennte Einstellungsdatei, keine Änderung an Spielständen.
- [Bedienung, Bildnachweise und Prüfungen](docs/bildschirm.md); [Arbeitsnachweis](docs/arbeiten/bildschirm-v034.md).

## v0.33.0 – CodexAI: Kenzō, Raven schützen und knappe Tower-Flucht · 8. November 2026

- Physischer Griff nach Raven vor Shadepis Eingreifen. Kenzō wird im Bosskampf kampfunfähig statt vorzeitig getötet; eine eigene schwer verletzte Kniepose zeigt den gelähmten Gefangenen.
- Raven extrahiert bei festem Standort Daten. Drei Treffer führen zum Neustart dieses Abschnitts; die drei Wachenwellen und der Transfer müssen beendet sein. Erst dann folgt Ravens endgültige Vernichtung von Kenzōs Implantaten und der 60-Sekunden-Fluchtabschnitt.
- Kenzōs Inszenierung ist belegt, Motiv und Auftraggeber bleiben offen. Raven schließt sich der weiteren Suche an; der Abschluss am See erhält einen entsprechenden Ausblick.
- Eigene sichtbare Flucht mit Rennen, Einsteigen, Kippen über die Kante, Zünden im Fallen und Explosion des Penthouses. Neues KOBAN-TEC-Banner als lokale Grafikschicht in beiden Hangaransichten; bestehende Raumgeometrie bleibt erhalten.
- Kompatible Kontrollpunkte für Schutzphase, gesicherte Daten, Flucht und Abflug; neue Ablauf-/Schadensprüfungen und aktualisierte Regressionserwartungen für die neue Reihenfolge.
- **1.628 Prüfungen ohne Fehler** in zehn relevanten Prüfreihen; neue Tower-Prüfung mit 42 Fällen im GitHub-Workflow. Tatsächliche Galerie, kurzer Fluchtfilm und Exportpaket kontrolliert. [Bilder, Film und Bedienung](docs/tower-extraktion.md).

## v0.32.2 – CodexAI: Bebilderte Stilbibel für das gesamte Spiel · 8. November 2026

- Konsistenzvorlage vom Heiligtum-Schwerpunkt zu einer [vollständigen visuellen Spielreferenz](docs/stilbibel/README.md) erweitert. Fünf Teile: Art Direction, Figuren, Welten, Fahrzeuge/Requisiten und Oberflächen/FX/Ton.
- 23 einzelne Figurenkarten aus den aktiven Spielpixeln: Hauptfiguren, Bosse, vier Punktypen, zwei Schützen, vier Krieger, vier Ziviltypen, Meister, Bot, Minotaurus, Virus und ICE-Wächter. Vorhandene Ansichten/Aktionsposen, unveränderte Merkmale, Weltmaßstab und Quellen pro Karte; fehlende Ansichten werden nicht neu erfunden.
- Insgesamt 31 in Godot gerenderte Tafeln mit zusätzlicher Figurenübersicht, 20 Hintergrundquellen, Fahrzeugen, drei Zuständen aller neun Requisitentypen neben Raven, sechs UI-Themen und Effektframes. Wiederholbarer Renderer und maschinenlesbarer Figurenindex; keine generierten Ersatzgrafiken und keine Änderung der Gameplay-Assets.
- UI-/Hackbeispiele, Musikzuordnung, Material-/Lichtfamilien und Animationsregeln für alle Kapitel dokumentiert. Bekannte Abweichungen im Altbestand, insbesondere Aerodyne und Figurenschärfe, ausdrücklich vom Soll-Standard getrennt.
- Gemeinsame Einstiegspunkte und Prüfvorlage aktualisiert; Referenzrendering, PNG-Ausgaben, Quellverweise, lokale Dokumentationslinks und Versionsfelder geprüft. Keine pauschale Gameplay-Neuprüfung für diese Dokumentationsänderung behauptet.

## v0.32.1 – CodexAI: Verbindliche Konsistenzvorlage für Menschen und KI · 8. November 2026

- Zentrale [KONSISTENZ.md](KONSISTENZ.md) mit aktiven Referenzen, Quellenpriorität, festen Figurenmerkmalen, HQ-Pixelstil, tatsächlichen Heldenmaßen im Renderer, Alpha-/Abtastungsregeln sowie Animations- und Möbelkontakten.
- Szenenlogik, Controller, Effekte und Ton in die Fertigprüfung aufgenommen. Historische Posen eindeutig von aktiven Quellen getrennt; echte Godot-Vergleiche bleiben zusätzlich zu automatisierten Prüfungen erforderlich.
- Kopierbare [Arbeitsvorlage](docs/vorlagen/konsistenz-auftrag.md) mit Grafik-/KI-Briefing, Referenznachweis und Prüfergebnissen. Einstieg in CONTRIBUTING, AGENTS, CLAUDE, README und GitHub-PR-Vorlage verankert.
- Reine Dokumentationsänderung; lokale Links, aktuelle Versionsfelder und Inhalte gegen aktive Quellen geprüft. Keine neuen Grafiken und keine Änderung des Spielablaufs.

## v0.32.0 – CodexAI: Heiligtum-Posen an die Spielfiguren angeglichen · 8. November 2026

- Alle sechs Posen des Gegenwartsrahmens überarbeitet: Shadepi allein im Sessel, Ravens Griff nach der Maske, abgefangenes Handgelenk, Raven am Bettrand, schlafend und aufwachend. Tatsächliche Helden-Sprites dienen als Stilreferenz; dunkle matte Rüstung statt körniger Bronze-/Weißtexturen.
- Neues transparentes Quellblatt `poses-game.png`; harte Alpha-Erzwingung entfällt. Figuren werden bei der Verkleinerung genauso abgetastet wie die normalen Helden. Sitz-/Liegegröße und Quellanker gezielt kalibriert; getrennte Ausschnitte erhalten die vollständigen Haare.
- Ravens Annäherungspunkt auf die tatsächliche Fußposition der Kontaktposen gesetzt. Pose zurücksetzen löscht auch die weiße Aufhellung der Übertragung, zusätzlich zu Lichtstrom und Leistungswert.
- 18 neue Grafik-/Verankerungsprüfungen im GitHub-Build; zusammen mit Ablauf, Fehlerbericht 8, Atmosphäre, Story und Gameplay **789 Prüfungen ohne Fehler**. Alle sechs Posen sowie die ungekürzten Schlaf-/Kontaktabschnitte in Godot gesichtet.
- [Vorher/Nachher und technische Hinweise](docs/heiligtum-figuren-v032.md).

## v0.31.0 – CodexAI: Ortsbezogene Atmosphäre und projektweiter Designcheck · 8. November 2026

- 18 deterministische Ortsprofile für Straßen, Wohnung, Industrie, Versteck, Garage, Hangar, Wohn-/Kompensatorraum, virtuelle Räume, Tower, See und drei Erinnerungen. Vorhandene Pixel-Rauch-/Lichtquellen wiederverwendet; keine neuen Ersatzgrafiken für Figuren oder Gebäude.
- Fensterregen nur auf Glas, Staub in Lichtbereichen, texturierter Dampf an Anlagen, kleine Diagnoseläufe, Datenpakete und bewegte Neonreflexe. Glut und Asche kommen von den tatsächlichen Brandstellen; dünner Nebel und Glühwürmchen beleben das Seeufer.
- Animierter See-Zusatzpass aus den Originalpixeln, gegen die Uferkontur und Baumlinie beschnitten und hinter den Figuren gezeichnet. Keine Verformung von Ufer, Figuren oder Spielfeldgeometrie.
- Raumabhängige Farbkorrektur und geringeres Bloom bewahren warme Innenräume und Texturdetails. Bildstil reduziert beziehungsweise deaktiviert die zusätzlichen Effekte. Pause und Terminals frieren auch die bisherigen Regen-/Dampfuhren ein.
- Ausgeblendete alte Bodenatmosphäre verarbeitet keine Frames mehr; Zusatz-FX arbeiten mit festen Zeichenbudgets und ohne Einfluss auf Gameplay-Zufall oder Speicherstände. Fahr- und Menüsequenzen behalten ihre bestehenden eigenen Wetterdarstellungen; beim Hangar-Abflug läuft das neue Raumprofil nur draußen, nicht über den Cockpitbildern.
- 27 tatsächliche Godot-Ansichten geprüft. Stilvorschläge getrennt dokumentiert: einheitlicher Aerodyne-Atlas, vergleichbare Figurenschärfe und kompaktere Interaktionsanzeigen; weitere Vorschläge zu Alarmlicht und Umgebungsgeräuschen.
- **2.277 Prüfungen ohne Fehler** in 17 Prüfreihen; alle sieben Kapitel, Menü, Hack-Oberfläche und Erinnerungen im Renderer gesichtet. Exportpaket mit Profilen, Shadern, Qualitätsstufen und Abflug erfolgreich gestartet.
- [Animierte Vorschau und Designbericht](docs/design-atmosphaere.md).

## v0.30.0 – CodexAI: Fehlerbericht 8, Szenenpassung und Hangar-Abflug · 8. November 2026

- Drei Hangarkonsolen mit eigenen festen Standflächen und Textur-Verdeckungen versehen; alle zugehörigen Interaktionspunkte erreichbar vor die Geräte gesetzt.
- Wohnraumtür direkt in die Wandgrafik integriert; schwebendes Türfragment und davor stehenden Elektrokasten entfernt. Verankerte Sprechblase zeigt Shadepis Ruf hinter dieser Tür.
- Ankunft führt automatisch in eine ausführliche Schlafszene mit Aufsteigen, Sitz-, Liege- und Aufwachpose sowie Nahaufnahme. Zwei-Stunden-Sprung und kompatibler Suchkontrollpunkt bleiben erhalten.
- Kompensatorraum ohne doppelte Hintergrundstuhl-Grafik; drei neue gemeinsam gezeichnete Stuhl-/Figurenposen passen Sitzfläche, Lehne, Armlehnen, Stiefel und Handkontakt zueinander.
- Tempeltür aus dem passenden geschlossenen Raumzustand in die schräge Portalöffnung eingesetzt; vorhandene Schwellenkollision, Bruchphasen und Mech-Eintritt bleiben erhalten. Keine frontale freistehende Tür mehr vor der Wand.
- Shadepis Zusammenbruch nach Erinnerung III: Erschöpfung, langsame letzte Schritte auf freier Bodenfläche, aufrechter Halt, Einknicken, schrittweise erlöschende Aura, vier Sekunden regloses Liegen und langsame Abblende. Kein Todesflag für Shadepi.
- Neue Hangar-Abflugsequenz: sichtbares Einsteigen, vier Cockpitbilder, fehlgeschlagener ARTOS-Start, Schlag auf die Armatur, wieder aktive Anzeigen, Abheben durch die Dachschleuse und Übergabe an den bisherigen Flug. Spätere Jumper-Reparatur nicht übersprungen.
- Optionales kompatibles Speicherfeld für einen noch laufenden Abflug; Controller-Pause, Weiterblättern, Überspringen und Kapitelabbruch berücksichtigt. Kampagnenszenen prüfen nach wartenden Schritten ihre Generation, damit abgebrochene ältere Szenen keine neue Szene beenden.
- **2.143 Prüfungen ohne Fehler** in 16 Prüfreihen; reale Godot-Szenenbilder und vollständigen Exportinhalt kontrolliert.
- [Punktweise Abnahme, Original-PDF und tatsächliche Godot-Bilder](docs/fehlerbericht-8.md).

## v0.29.0 – CodexAI: Heiligtum-Chronologie und separater Kompensatorraum · 8. November 2026

- Shadepi geht im Hangar voraus zur regelmäßigen Eindämmung; Raven macht den Aerodyne gangbar und folgt erst danach. Wohnraum, zwei Stunden Schlaf und Suche durch die geschlossene Tür ersetzen das verfrühte gemeinsame Erklärungsgespräch.
- Neuer separater HQ-Pixel-Kompensatorraum; neue Quellposen für sitzenden Shadepi, Ravens Schlafen, Maskengriff und festgehaltenes Handgelenk. Weißer Lichtstrom und schimmernde Augen führen in die bestehenden drei Erinnerungen; das frühere Timing-Minispiel entfällt an dieser Stelle.
- Rückkehr in denselben Raum: Raven torkelt zurück und fragt nach den Erinnerungen. Shadepi entschuldigt sich, erklärt den Sechs-Tage-Rhythmus und beschränkt Ordensinformationen auf das Nötige.
- Kompatibles zusätzliches Speicherfeld für Schlaf-/Tür-/Raumfortschritt. Alte Erinnerungsabschlüsse bleiben erhalten; Speichern während des Rückkehrdialogs wiederholt nur diesen Dialog. Abgebrochene Szenenschritte können keine spätere Szene verändern.
- Neues Raumdesign aus vorhandenen Spielgrafiken abgeleitet: Das im Nutzertext erwähnte neue Referenzbild wurde nicht mitgeliefert; ein exakter Abgleich damit ist weiterhin offen.
- **1.133 Prüfungen ohne Fehler** in sieben Prüfreihen; tatsächliche Godot-Szenenbilder und Exportpaket geprüft.
- [Bilder, Steuerung und Ablauf](docs/heiligtum-kompensator.md).

## v0.28.0 – CodexAI: Meistertod, Energieaura und Erinnerungseffekte · 7. November 2026

- Vor Beginn alle GitHub-Branches geprüft und auf v0.27.0 aufgebaut. Nutzerpräzisierung gesichert: Der Meister ist nach der Übertragung definitiv tot; Shadepi soll eine kräftige, aufsteigende Aura wie bei einem Anime-Power-up erhalten.
- Neuer vierteiliger HQ-Pixel-Atlas: erschlaffender Meister in Shadepis Armen, behutsames Ablegen und zwei flache Leichenposen mit geschlossenen Augen. Expliziter Szenenzustand und Ereignis für den Tod nach der vollständigen Übertragung. Die abgelegte Leiche bleibt gesperrt und kann nicht in die frühere Ellenbogenpose zurückfallen. Shadepis Schlusszustand bleibt Erschöpfung ohne Todesflag.
- Neuer 16-teiliger HQ-Pixel-Aura-Atlas mit getrennten Flammen-/Blitzebenen. Weißgoldener Aufbau während der Übertragung, an die Originalfigur gebundene Aura im Kampf und Ausklingen beim Zusammenbruch. Sprites werden um den Körper sortiert; keine Verformung, Skalierung oder Verschiebung der Figur. Bildstil „Reduziert“ schaltet Vordergrundblitze ab und reduziert die Frequenz.
- Eigener deterministisch synthetisierter, leiser Aura-Loop; Pause, Niederlage, Tonoption, Abbruch und Abschluss werden berücksichtigt. Meister- und Aura-PNGs unverändert übernommen; Kontakte und gemeinsame Körpergröße aus den Quellen vermessen.
- Effektprüfung: optionale Weiteranimation für die isolierten Erinnerungswelten, damit Trümmer, Rauch, Schockeffekte und Ladungsringe nicht während einer laufenden Zwischensequenz stehenbleiben. Zeitbezogene Partikeldämpfung in diesem Modus. Die drei Erinnerungen übernehmen die gewählte Bildqualität; Einschläge blenden vor ihrem Ablauf sauber auf null aus.
- Erweiterte gezielte Prüfungen für Meistertod, gesperrte Leichenpose, Aura-Anker und Ebenen, unveränderte Figurenproportionen, reduzierte Darstellung, Pause und Ende sowie Effektlaufzeiten. Tatsächlicher Szenenlauf und Vorschauen aktualisiert.

- Validierung: sechs Prüfreihen mit **1.104 Prüfungen, 0 Fehlern** (Erinnerung III 78, Erinnerung I 143, Klosterkampf 226, Erinnerung II 69, Kampagne/Speichern 382, Story-Audit 206). Tatsächlichen Szenenlauf mit Meistertod und Aura bis zur Rückkehr im Renderer angesehen. Linux-PCK erstellt und neue Grafiken, Metadaten, Loop-Klang sowie den bestätigten Tod und die abschließende Effektbereinigung direkt daraus geprüft.

## v0.27.0 – CodexAI: Tempelinneres und Einbruch in Erinnerung III · 7. November 2026

- Vor Beginn alle GitHub-Branches geprüft und auf dem aktuellen v0.26.0-Hauptstand aufgebaut.
- Nutzervorgabe zur Schauplatzlogik gesichert: Der Tempel tarnt eine riesige unterirdische Hightech-Basis. Die bevorzugte Tempelvariante umgesetzt: Meistergespräch, Heiligtumsübergabe, letzter Kampf und Zusammenbruch bleiben im Tempelinneren; der frühere Außenhof wird in Erinnerung III nicht mehr benutzt.
- Zwei neue HQ-Pixel-PNGs: Tempelhalle mit freigelegter Technik, großem Schacht und sichtbaren unteren Ebenen sowie vierteiliger freigestellter Tor-Atlas. Vorhandene Figuren, Nanitenstrom, Minotaurus- und FX-Grafiken wiederverwendet.
- Neues Innenraum-Mapskript mit eigener Kollision, Rückwand vor dem Basisschacht, Wand-/Säulenverdeckung und Türsperre. Keine weiterwirkende Hofsäule oder Außenhof-Feuerposition im Tempel. Beim vollständigen Durchbruch wird die Türsperre entfernt; gebrochene Paneele weichen auseinander, damit die Mechs hindurchpassen.
- Ablauf konkretisiert: geschlossener Zugang während der Übergabe, kamerageführter Durchbruch mit Einschlägen, erster Mech durch die Öffnung, zweiter folgt und nimmt die andere Kampfposition ein. Pause friert auch den Durchbruch ein. Dialog zur gesicherten Basisschleuse und Kontextzeile zum Tarn-Tempel ergänzt; bestätigte Schutzversprechen bleiben erhalten.
- Gezielte Prüfungen um Innenraum-Geometrie, echte Türsperre, Transparenz der Öffnung, Pause beim Bruch sowie Reihenfolge Übergabe → Durchbruch → beide Eintritte → Kampf erweitert. Bereits gespeicherte Abschlüsse und die beiden früheren Erinnerungen werden beibehalten.

- Validierung: sechs Prüfreihen mit **1.078 Prüfungen, 0 Fehlern** (Erinnerung III 52, Erinnerung I 143, Klosterkampf 226, Erinnerung II 69, Kampagne/Speichern 382, Story-Audit 206). Tempelüberblick, Übergabe, Torbruch, Zweibosskampf und Zusammenbruch im Godot-Renderer kontrolliert. Linux-PCK erstellt und neue Texturen, Tür-Kollision, Einbruchsreihenfolge und vollständigen Abschluss direkt daraus geprüft.

## v0.26.0 – CodexAI: Erinnerung III „Das Vermächtnis“ · 7. November 2026

- Alle GitHub-Branches vor Beginn verglichen; auf dem aktuellen v0.25.0-Stand aufgebaut und bestehende Arbeit erhalten.
- Dritte Erinnerung am dritten ECHO-Knoten: Shadepi stützt den alten Meister, beide sprechen die bestätigten Schutzversprechen, das Heiligtum geht als weißer Nanitenstrom auf Shadepi über. Danach stellt er sich allein zwei Minotauren. Nach deren Zerstörung bricht er reglos zusammen; dies wird nicht als sein Tod festgelegt. Keine Rückkehr der Gefallenen und keine neue Festlegung zum späteren Schicksal des Roboterkopf-Kriegers.
- Neue HQ-Pixel-Ruinenvariante derselben Architektur, Meister-/Halte-/Empfangs-/Zusammenbruchposen und achtteiliger weißer Transfer-Atlas. Gemessene Bildkontakte mit konstanter Körpergröße; Originalbilder werden nicht nachbearbeitet. Vorhandene Minotaurus- und Kampfeffekte wiederverwendet. Transfer einschließlich erstem Bild korrekt pausierbar.
- Spielbarer Zweibosskampf auf Grundlage der vorhandenen Steuerung: eigene Lebens-, Taumel- und Zerstörungswerte für beide Mechs; wechselndes, vorab markiertes Sperrfeuer, Katana-Schaden an den Servogelenken, Ausweichen und lokaler Wiederholungsversuch. Sieg erst nach Zerstörung beider Gegner, nicht durch Countdown. Wiederholung entfernt Ereignisse eines gescheiterten Versuchs und stellt beide Gegner wieder her.
- Abbruch und Controller-Überspringen auch während des echten Kampfes geprüft. Gegenwartswerte bleiben getrennt. Eigenes typgeprüftes Speicherfeld für Knoten 3, ältere Spielstände behalten die beiden früheren Abschlüsse. Nach Abschluss folgt Ravens Rückkehrdialog und anschließend unverändert der Aerodyne-Flug.
- Beide Exportprofile enthalten die neuen Ankerdaten. Eigenständiger CI-Test, inputgesteuerter Testpilot und Renderer-Galerie ergänzt. Roadmap und Spielerhinweise auf den abgeschlossenen Dreiteiler aktualisiert.

- Validierung: sechs Prüfreihen mit **1.068 Prüfungen, 0 Fehlern** (Erinnerung III 42, Erinnerung II 69, Erinnerung I 143, Klosterkampf 226, Kampagne/Speichern 382, Story-Audit 206). Vollständige Szene mit Eingabe-Testpilot im OpenGL-Renderer bis zu Ravens Rückkehr kontrolliert; Linux-PCK erzeugt und neue Grafiken, Ankerdaten, Knistern sowie beide Mechs und Schlusszustand direkt aus dem Paket geprüft. Vorschau und Bedienung unter docs/das-vermaechtnis.md.

## v0.25.0 – CodexAI: Spielbarer Überlebenskampf gegen den Minotaurus · 7. November 2026

- Erinnerung II enthält vor Lys Opfer einen echten 45-Sekunden-Kampf mit steuerbarem Shadepi, lokalen Lebenswerten, Katana-Treffern, Taumeln und Ausweichen. Die Panzerung bleibt intakt; der Spieler kann den festen Opfermoment nicht durch einen vorzeitigen Bosskill umgehen.
- Drei Eskalationsstufen: ein, drei und fünf vorab fixierte Einschlagziele, kürzere Warnungen und höherer Schaden. Vorhandene HQ-Pixelgrafiken, Kampfposen, Einschläge und Sounds wiederverwendet.
- Timerende führt in die vorhandene Opferszene. Niederlage hält den Timer an und erlaubt einen direkten Wiederholungsversuch; sie schließt keinen Knoten ab. Leertaste / B weicht im Kampf aus; Überspringen bleibt über das Pausenmenü verfügbar. Pause und Fokusverlust halten den Kampf an, Eingaben werden beim Pausieren gelöscht.
- Historische Lebenswerte bleiben von Raven getrennt. Abbruch, Überspringen, Wiederholung, Controller und vollständiger Übergang einschließlich Lys Tod, Mech-Wrack und Rückkehr zur Kampagne gezielt geprüft. Alle Branches vor Beginn verglichen; ältere abweichende Entwicklungsbranches und fremde Änderungen erhalten.
- Validierung: **1.024 Prüfungen, 0 Fehler** in fünf Prüfreihen (Erinnerung II 69, Erinnerung I 143, Klosterkampf 226, Kampagne/Speichern 380, Story-Audit 206).

## v0.24.0 – CodexAI: Erinnerung II „Lys Opfer“ · 7. November 2026

- Vor Beginn alle GitHub-Branches abgerufen und mit v0.23.0 verglichen; bestehende Arbeit erhalten.
- Zweite inszenierte Erinnerung am zweiten ECHO-Knoten: gemeinsamer Abwehrkampf der drei Überlebenden gegen den Minotaurus, freigelegter Servoschacht, Shadepis „Nein! Ly, nicht!“, Lys „Verzeih mir, Bruder. FÜR DEN ORDEN!“, Anlauf, Sprung, Anbringen der Ladung, Detonation und dauerhaft zerstörter Panzer. Nur Ly fällt; Shadepi und der Roboterkopf-Krieger überleben. Keine Vorwegnahme der späteren Kenzō-Enthüllung oder der Heiligtumsübergabe.
- Neue HQ-Pixel-Kulissenvariante derselben Architektur, freigestellter Minotaurus-Atlas und weiße Ly-/Ladungsposen. 16 neue Quellregionen mit gemessenen Kontakten und konstanter Skalierung; alte Figuren-, Feuer- und Einschlaggrafiken wiederverwendet. Minotaurus als zweibeiniger Mech-Hybrid nach Dossier, Sprengladung als konkrete Umsetzungsentscheidung dokumentiert, nicht als zusätzliche Nutzerbestätigung.
- Gemeinsamer Erinnerungsaufbau für Kulisse/Figuren erweitert; bestehender Angriff bleibt erhalten. Zweiter Knoten benutzt denselben Szenendirektor, Pausen- und Controllerweg, isolierte Physikwelt, Serien-/Knotenprüfung und sichere Rückkehr. Boss.mp3 während des Minotaurus-Kampfs, danach Musik der Erinnerungskammer.
- Eigenes kompatibles Speicherfeld für Erinnerung 2. Alte ECHO-Stände am bisherigen Textknoten werden bei fehlendem Abschluss an Knoten 2 fortgesetzt. Abschluss und Überspringen zählen genau einmal; Abbruch zählt nicht. Beide Exportprofile nehmen die zusätzlichen Ankerdaten mit.
- Gezielte Prüfungen für tatsächlichen Szenenlauf, Sprung/Ladung/Detonation, Zerstörung und Überlebende, Bildanker, Laufwege, Pause, Controller-Überspringen und Abbruch mitten im Sprung, Speicherkompatibilität und veraltete Signale. Kampagnen-Gesamttest berücksichtigt beide neuen Rückblenden. Erinnerung III bleibt ausstehend.

- Validierung: fünf Prüfreihen mit **1.003 Prüfungen, 0 Fehlern** (Erinnerung II 48, Erinnerung I/Einbindung 143, Klosterkampf 226, Kampagnen-/Speicherablauf 380, Story-Audit 206). Tatsächliche Szene bis zur Rückkehr zu Raven im OpenGL-Renderer kontrolliert; Linux-PCK erstellt und neue Atlanten, Metadaten, Figuren und Opfer-/Wrackzustand direkt daraus geprüft. Animierte Vorschau und Bedienhinweise unter docs/lys-opfer.md.

## v0.23.0 – CodexAI: Klosterkampf und Gehbewegungen der Mönche · 7. November 2026

- Vor Beginn alle GitHub-Branches abgerufen und mit dem aktuellen v0.22.0-Hauptstand verglichen; vorhandene Aerodyne-/Tower-Arbeit erhalten.
- Neue HQ-Pixel-PNG-Atlanten für vierteilige Gehzyklen aller vier Bewohneridentitäten in vier Richtungen und für Kampf-/Fallposen der vier Krieger sowie Bots. 104 zusätzliche Quellbilder, insgesamt 264 vermessene Frames. Bildpixel bleiben unverändert; gemeinsame Skalierung pro Figur verhindert Größenwechsel beim Gehen und Fallen.
- Drei endliche, inszenierte Bot-Wellen mit neun getrennten Angreifern. Sichtbare Aushol-/Kontakt-/Rücknahme-, Treffer-, Knie-/Fall-/Liegeposen, Katana- und Stabangriffe, kurze MG-/Bot-Schussfolgen und vorhandene Kampf-Sounds. Mündungsfeuer endet nach dem Schuss; deaktivierte Bots bleiben gedämpft sichtbar.
- Bestätigte Schutzopfer als feste Szenenfolge: Oni wirft sich in Shadepis Angriffslinie; der schwere MG-Krieger hält die Stellung, während Shadepi, Ly und Roboterkopf zurückweichen. Gefallene bleiben liegen. Keine Zufallstode und kein vorzeitiger Tod Lys; Erinnerungen 2/3 bleiben ausstehend.
- Sämtliche neuen Schritte verwenden den vorhandenen Szenendirektor: Pause hält Bewegung und Wellenfortschritt an; Abbruch beendet ohne Knotenfortschritt; bewusstes Überspringen löst auch mitten im Kampf den eindeutigen Endzustand aus. Bestehende Speicherfelder und Ravens Gegenwartszustand bleiben kompatibel.
- Neuer gezielter Test und CI-Prüfschritt für Gehzyklen, konstante Körpergröße, Kollisionen aller Kampfwege, drei Wellen, richtige Opfer-/Überlebendenfolge, Pause, Abbruch und Controller-Überspringen. Galerie mit Geh-Nahaufnahme und längerer tatsächlicher Szenenaufzeichnung erweitert.

- Validierung: vier Prüfreihen mit **953 Prüfungen, 0 Fehlern** (Klosterkampf 226, Erinnerungseinbindung 143, Kampagnen-/Speicherablauf 378, Story-Audit 206). Vollständige Szene bis zu Ravens Rückkehr und Geh-Nahaufnahme im OpenGL-Renderer kontrolliert. Linux-PCK erstellt; neue Texturen, Ankerdaten, neun Bots und korrekter Abschluss direkt aus dem Paket geprüft.

## v0.22.0 – CodexAI: Erste Klosterrückblende „Der Angriff“ · 7. November 2026

- Alle Remote-Branches geprüft; Produktion auf v0.21.2 begonnen und währenddessen hinzugekommene Aerodyne-Änderungen v0.21.3 verlustfrei integriert. Versionsfelder und Dokumentation auf v0.22.0 abgestimmt.
- In vorgegebener Reihenfolge HQ-Pixel-Kulisse des angegriffenen Klosters, 4×4-Requisiten-/FX-Atlas, vier Ordenskrieger mit Richtungs-/Laufbildern, vier unbewaffnete Bewohneridentitäten und eine begehbare 1024×640-Map erstellt. Eigene Bot-Grafik für den zusätzlichen Szeneneinstieg. Transparente PNG-Quellen und 160 vermessene Actor-Frames; lesendes Ankerwerkzeug enthalten.
- Oni mit bestätigtem Katana, Roboterkopf-Krieger mit bestätigtem Stab und Kabel-Dreadlocks, Ly in Weiß, schwerer Samurai-MG-Krieger. Shadepis bestehende Original-Sprites weiterverwendet. Fußanker, getrennte Schatten, y-Sortierung, Vordergrundverdeckungen und Kollisionen für Wände/Requisiten abgestimmt.
- Erste Rückblende an Knoten 1: Kamerafahrten, acht fliehende Bewohner, Formation der fünf Verteidiger, Shadepis Schutzruf, Bombeneinschläge und erster Schusswechsel mit drei Bots. Eigene historische Physikwelt; Gegenwart bleibt eingefroren. Noch kein vollständiger Kampf, keine Tode: Oni-/MG-Schutzopfer und die weiteren Erinnerungen bleiben spätere Pakete.
- E / Enter / A für Dialog, Leertaste / B zum Überspringen, Esc / Start für Pause; Pausenknöpfe mit Maus, Tastatur, Steuerkreuz und linkem Stick. Abbruch schließt die Szene ohne Fortschritt; Abschluss/Überspringen speichert Knoten 1 genau einmal. Speicherstände erhalten kompatible Erinnerungsfelder; Laden, Kapitelwechsel und veraltete Rückmeldungen sind abgesichert.
- Beide Exportprofile nehmen Actor-Anker-JSON mit. Neue Prüfungen im CI; Gesamt-Ablauftest berücksichtigt die neue Szene vor dem Aerodyne-Flug. Roadmap, Assetmanifest und Spielerhinweise aktualisiert; echte Renderer-Bilder und animierte Vorschau unter docs/kloster-angriff.md.
- Geprüft: elf Prüfreihen mit **1.716 Prüfungen, 0 Fehlern** (davon 143 gezielte Erinnerungsprüfungen); tatsächlichen Szenenlauf bis zur Rückkehr zu Raven gerendert. Linux-PCK erzeugt und neue Szene, Anker-JSON, 16 Figuren sowie importierte Texturen direkt daraus geladen.

## v0.21.3 – ClaudeHelper: Aerodyne-Flug mit Sequenzkalibrierung und Landung auf dem Tower · 7. November 2026

- Alle Branches geprüft; auf CodexAI v0.21.2 (Erinnerungs-Roadmap) aufgebaut, ohne Überschneidung.
- Kapitel-6-Flug neu als eigenes Level (`scripts/aerodyne_flight.gd`) nach der Romanfassung: Häuserschluchten mit Frachtdrohnen, Stahlbrücken mit Lücke und engen Lücken, Fassadenkontakt; freies Steuern mit Trägheit, Schub/Bremse, Ausweichrolle mit schmalem Profil und kurzer Unverwundbarkeit; Beinahe-Treffer als Stunts mit kleiner Integritätsrückgabe.
- Triebwerksausfall mit Ravens Jumper-Reparatur bleibt; nach einem Absturz fällt das reparierte Triebwerk nicht erneut aus.
- Turmabwehr: Abwehrdrohnen mit angekündigten Laserlinien (Warnton, blinkende Linie, dann Strahl).
- Neues Minispiel **Sequenzkalibrierung** (`scripts/sequence_calibration.gd`): sichtbarer Scannerstrahl, Fenster = Strahl auf dem Rumpf, Richtungscode, Metronom, Fehler-LEDs, Zeitbalken. Fehlschlag löst Alarm und einen neuen Scan aus statt eines Absturzes. Das frühere unsichtbare Zeitfenster für die Kennung entfällt.
- Driftkurve (Rolle im Signalfenster) und interaktive Landung über dem Tower-Dach im Bildausschnitt der folgenden Szene: Schatten in den Landering, Bremsdüsen halten, Höhen- und Sinkratenanzeige; präzise, harte und sehr harte Landung, Durchstarten neben der Plattform.
- Der Aerodyne bleibt an der Aufsetzstelle auf Kenzōs Landeplatz stehen (y-sortiert, Kollision, Nachdampfen); Shadepi und Raven steigen daneben aus.
- Pixelart: Abwehrdrohne (2 Rotorbilder), Brückensegment, Warnpylon, Scannerkopf (`assets/world/hq/flight-props.png`, `tools/flight/build_flight_props.py`). Elf selbst synthetisierte Sounds (`tools/flight/generate_flight_audio.py`).
- Behoben: Pixel-UI-Styleboxen, die direkt gezeichnet werden, verloren ihre Textur (Texturcache in `ui_skin.gd`).
- Geprüft: neuer Test `tests/aerodyne_flight.gd` (50 Prüfungen, im CI), Kampagnenablauf bis aufs Dach erweitert; alle zehn Prüfreihen fehlerfrei. Flugphasen und Dachszene im OpenGL-Renderer gerendert; ein automatischer Testpilot schafft den Flug in rund 43 s.

## v0.21.2 – CodexAI: Roadmap und Quellen der Kloster-Erinnerungen · 7. November 2026

- Vor Beginn alle GitHub-Branches geprüft und den aktuellen Hauptstand v0.21.1 übernommen.
- Nutzerbriefing zu drei Erinnerungsknoten als neue Textquelle in Archiv Teil 5 gesichert. Bestätigte Schutzopfer: Oni-Krieger und schwer gepanzerter MG-Krieger in Erinnerung 1; Ly überlebt bis zu seinem Opfer in Erinnerung 2. Weitere offene Rollen ausdrücklich gekennzeichnet.
- Detaillierte Roadmap für Kulissen, vier neue Krieger, Mönche/Bewohner, begehbare Map, optionale erste Szene und späteren Bot-Kampf erstellt. Zweite und dritte Erinnerung einschließlich Dialogen, Heiligtumsübergabe und Minotauren-Kämpfen vorgeplant.
- Vorhandene drei Erinnerungsanker und Zwischensequenz-Anbindung geprüft. Nur Planung, Archiv, Arbeitsregeln und Versionsinfos geändert; noch keine Assetgenerierung oder neue Spielszenen. Relative Dokumentlinks und Versionsangaben geprüft.

## v0.21.1 – ClaudeHelper: Downloads über Releases und Anleitung geordnet · 7. November 2026

- Stand v0.21.0 von CodexAI geprüft: neun Prüfreihen mit 1.517 Prüfungen ohne Fehler; Menü-, Terminal- und Kampfgalerien gerendert. Releases v0.20.6 und v0.21.0 mit Windows-, Linux- und Projektpaket veröffentlicht.
- README: Download-Link und Spielanleitung verweisen auf das neueste Release statt auf Actions-Artefakte (keine Anmeldung nötig).
- Spiel-README: Kopfzeile mit Version wieder ganz oben, Kampfupdate-Hinweis darunter.
- Alte Branches v0.13.1, v0.13.2 und v0.14.0 nochmals verglichen: nur bewusst entfernte Low-Res-Sprites fehlen in `main`; Löschung steht noch aus.

## v0.21.0 – CodexAI: Ravens Handblitze, Pistolenschüsse und Gegnerkampf · 7. November 2026

- Alle GitHub-Branches vor Beginn geprüft; die während der Arbeit erschienenen Stände v0.20.5 und v0.20.6 sicher übernommen und lokale Kampfänderungen erhalten.
- Eigene HQ-Pixel-Handzauberposen für Raven mit Ausholen, offener Hand, Freigabe und Nachbewegung in acht Richtungen. Handflächenanker aus den Bilddaten vermessen; Mündungsanker separat je Richtung. Skalierung und Sprite-Transformation werden beim Austritt berücksichtigt.
- Deep-Dive-Impulse und aufgeladene Geschosse als animierte verzweigte Pixelblitze; normale Pistolenschüsse als kurze warme Geschosse mit Mündungsfeuer. Eigene elektrische und Pistolen-Sounds. Kollisionspfade, Wände, Schaden und ICE-Regeln bleiben maßgeblich.
- Neue Kontaktposen für alle acht menschlichen NPC-Typen in acht Richtungen, ergänzt um vorhandene Aushol- und Rücknahmebilder. Trefferphase, Erholung, Blickrichtung, Trefferunterbrechung und Kontrollpunkt-Reset synchronisiert. Benutzerdefinierte NPC-Grafiken werden nicht ersetzt.
- Eigene prozedural synthetisierte Anstrengungs-, Schmerz- und Sterbelaute mit Varianten, kurzem Wiederholungsschutz und separatem Stimmenpool. Ton-Aus stoppt die Stimmen; besiegte Gegner wiederholen den Sterbelaut nicht.
- PNG-Quellen, Pixel-FX-Generator, Audiogenerator und lesendes Werkzeug zur Ankervermessung enthalten. Beide Exportprofile nehmen die erforderlichen Anker-JSON-Dateien mit. Neue gezielte Prüfungen im CI und Kampfgalerie ergänzt.
- Validierung: neun Prüfreihen mit insgesamt 1.517 Prüfungen ohne Fehler (davon 292 neue Kampfprüfungen). Pistole, Handblitze und drei Gegnerphasen im Godot-Renderer kontrolliert. Exportpaket erzeugt und Anker-JSONs, importierte Grafiken, Audio sowie Gegneraufbau direkt aus dem Paket geprüft.

## v0.20.6 – ClaudeHelper: Release per Knopfdruck · 7. November 2026

- GitHub-Workflow „Test and build Shadepi“: Unter *Actions → Run workflow* kann jetzt ein Release-Tag (z. B. `v0.20.6`) eingetragen werden. Nach erfolgreichen Tests und Exporten legt GitHub Tag und Release auf genau diesem Stand an; Tag-Pushes funktionieren weiterhin.
- Das Release enthält Windows- und jetzt auch das Linux-Paket sowie das Godot-Projekt. Ein Tag, der nicht zur Version in `project.godot` passt, wird abgelehnt.
- Erstes veröffentlichtes Release mit den Pixelart-Menüs und Hack-Oberflächen aus v0.20.5.

## v0.20.5 – ClaudeHelper: Pixelart-Menüs und szenenbezogene Hack-Oberflächen · 7. November 2026

- Alle GitHub-Branches geprüft; auf CodexAI v0.20.4 (verbindlicher HQ-Pixelart-Stil) aufgebaut.
- Neue UI-Pixelart im Pixelwright-Studio (Projekt „Shadepi UI“) gezeichnet: 64×64-Stahlrahmen als Nine-Slice mit gebürsteten Flecken, Plattennähten, Nieten, Fase, Neonklammern und Status-LEDs; Button-Zustände normal/Fokus/gedrückt/gesperrt; Codezellen frei/erlaubt/Cursor/verbraucht; Titelleiste mit Warnstreifen; Regler und Griffe; Embleme für Rabe, Chrome Jackals, Weißen Drachen, ARToS-7, Moriyama-Tower und See. Quellraster und Themenfarben in `tools/ui_pixel/build_ui_pixel.py`, Ausgabe unter `assets/ui/`.
- Sechs Farbthemen: Terminals nach Zielsystem (`jackal`, `order`, `artos`, `tower`), Pausenmenü nach Kapitel bzw. Ort der Kampagne. Rahmenkanten kacheln im 20-px-Raster statt zu verschmieren; Buttons und Fokus bleiben pixelgenau, Menü-Hover verschiebt um ganze Pixel statt zu skalieren.
- Hack-Decks bleiben im 640×360-Spielraster. Hintergrund als verpixeltes, gedithertes Szenenbild mit Scanlines; Oszilloskop, Leitungen und Funken als Pixelgrafik.
- Pixelschriften: „Shadepi Pixel“ (Jersey 10, OFL, Em auf 1 px = 1 Bildpunkt bei Größe 20 skaliert, Pfeile/Haken/Kreise/Ω ergänzt; `tools/ui_pixel/build_pixel_font.py`) und Silkscreen (OFL). Lizenztexte unter `assets/fonts/`.
- Behoben: überlappende Terminal-Fußleiste; Garagen-Terminal hieß noch „Versteck“. Signatur im Hauptscreen nennt nur noch die Version.
- Geprüft: run 372, drive_action 60, terminal_puzzles 67, terminal_controller 186 (neu: Fußleiste, Thema, Filterung, Spielraster), arcade_waves 246, combat_moves 68, npc_dive_visuals 20, story_audit 206 – ohne Fehler. Terminal- und Menügalerien im OpenGL-Renderer kontrolliert.

## v0.20.4 – CodexAI: HQ-Pixelart als verbindlichen Grafikstil festhalten · 7. November 2026

- Nutzervorgabe in `AGENTS.md` dauerhaft gesichert: alle neuen Grafiken als detailreiche HQ-Pixelart, mit Materialtextur, Tiefenwirkung, abgestimmter Pixeldichte, Licht-/Schattenstufen und sauberen Pixelclustern. Keine einfachen Vektorgrafiken oder glatten Illustrationen als Pixelart-Ersatz.
- HQ wird über tatsächliche Detailqualität definiert; große PNG-Abmessungen oder bloßes Hochskalieren/Verpixeln genügen nicht. Figurenmerkmale und vorhandene Referenzen bleiben verbindlich.
- Alle GitHub-Branches vor Beginn geprüft. Nur Projektregeln, Versionsangaben und Änderungsinfos gepflegt; keine Grafik- oder Gameplay-Änderung. Versionsfelder auf Konsistenz geprüft.

## v0.20.3 – CodexAI: HQ-Hauptscreen und animiertes Cyberpunk-Menü · 7. November 2026

- Vor Beginn alle Remote-Branches geprüft und `main` auf v0.20.2 aktualisiert.
- Neue transparente HQ-Figurenebene `start-heroes-hq.png` aus der vorhandenen Referenzillustration im Material-/Lichtstil der gemalten Spielkulisse erstellt. Shadepis Kasa, segmentierte Maske, rote Linsen, taktische Weste und Katana sowie Ravens schwarz-blaue Haare, rote Augen, Septum, Cyan-Kragen und rote Rabenembleme erhalten. Bisherige Illustration bleibt als Quelle im Repo.
- PNGs und Text des Hauptscreens werden in Fensterauflösung gerendert statt im 640×360-Spielraster; Wechsel zurück auf das Spielraster bei Start und Pause. HUD und Gameplay-Grafiken werden nicht ersetzt.
- Separater Stadteffekt für leichte Wasserreflex-Bewegung und sanftes Drachenlicht. Mehr Regenlagen mit Lichtstreuung, Sprühnebel, Wasserringen, wanderndem Nebel, Neonlichtstrahlen und sparsamen Glaströpfchen. Kein Maus-Parallax und kein Bewegen der Fußanker.
- Menükonturen und ruhige laufende Lichtakzente an Nightwing-Farbpalette angepasst. Reduzierter Bildstil stoppt die neuen Stadt-/Atmosphäre-FX, den Wind und die Menülichtanimation.
- Vorschauen und Galerie um Full-HD-Rendering, skalierte Mausbedienung, UI-Fokus und optionalen Animationsmitschnitt erweitert. Version, Spielerinfos und technische Menüdokumentation aktualisiert.
- Geprüft: 372 Gameplay-, 67 Terminal-/Integrations- und 154 Controller-Prüfungen ohne Fehler. Full-HD-Rendering, skalierter Mausklick, UI-Fokus sowie Haupt-/Pausenmenü im OpenGL-Renderer kontrolliert.

## v0.20.2 – ClaudeHelper: Gemeinsamer Stand geprüft · 7. November 2026

- Zusammengeführten Stand von CodexAI (v0.18.1–v0.20.1) und ClaudeHelper (v0.17.0–v0.20.0) erneut vollständig geprüft: run 367, drive_action 60, terminal_puzzles 67, terminal_controller 154, arcade_waves 246, combat_moves 68, npc_dive_visuals 20, story_audit 206 – 1.188 Prüfungen ohne Fehler. Menü-, Terminal-, Zwischensequenz-, Kampf- und Verfolgungsgalerien gerendert und kontrolliert.
- Alle Remote-Branches verglichen: die alten Entwicklungsbranches v0.13.1, v0.13.2 und v0.14.0 sind inhaltlich in `main` enthalten, die ClaudeHelper-Branches vollständig gemergt.
- `AGENTS.md`: Kennzeichnung „ClaudeHelper“ für Claude-Änderungen neben „CodexAI“ festgehalten; fortlaufende Versionsnummern für beide Bearbeiter.


## v0.20.1 – CodexAI: Aktuelle Entwicklungsbranches integrieren · 7. November 2026

- Die bisherige lokale Abrufkonfiguration berücksichtigte nur `main`. Alle GitHub-Branches abgerufen und den neueren Entwicklungsstand `claudehelper/v0.20.0` einschließlich v0.19.0 übernommen.
- Neuere Spieländerungen mit den bestehenden Menü- und Hack-Verbesserungen zusammengeführt; beide Entwicklungsverläufe bleiben im Git-Verlauf erhalten.
- Abrufkonfiguration lokal auf alle Branches erweitert und die Arbeitsregel in `AGENTS.md` präzisiert. Versionsangaben einschließlich Windows-Export und Spieleranleitung vereinheitlicht.
- Zusammengeführten Stand mit allen acht automatisierten Prüfreihen kontrolliert: 1.188 Prüfungen, keine Fehler.

## v0.20.0 – ClaudeHelper: Verfolgungsjagd und Garageneinfahrt · 7. November 2026

- Motorrad-Verfolgung: freies Lenken, Gas/Bremse mit Tempo- und Abstandstaktik, Bordsteinfunken, Tempolinien, Turbo.
- Neue Straßenobjekte: Betonbarrieren, brennende Wracks, Ölspuren, Turbostreifen, Drohnenminen; Kampfdrohnen, die sich per Hack in den Verfolger lenken lassen; zweite Phase ab 50 % Panzerung.
- Kapitel 4 beginnt mit der Einfahrt: Rolltor öffnet sich, Motorrad parkt auf der Hebeplattform (fester Körper), Tor schließt; Zugangsterminal und Ersatzteilkiste verschoben.
- Neues Asset `bike-parked.png` aus dem HQ-Atlas (`tools/compose_parked_bike.py`), Cutscene-Schritt `animate`, `tools/chase_gallery.gd`, 13 neue Prüfungen.


## v0.19.0 – ClaudeHelper: Kampfgefühl, Deep Dive, Apartment · 7. November 2026

- Trefferrückmeldung: Trefferstopp, Rückstoß/Zucken (Bosse nur bei schweren Treffern), Kamerastoß, Funken, neue Schadenszahlen, Kombozähler, K.O.-Fallanimation, roter Treffer-Blitz, Tonhöhenvariation.
- Shadepi: Ausfallschritt pro Hieb und Nahkampf-Zielhilfe. Raven: Zielkegel statt 8-Pixel-Linie.
- Deep Dive: ICE kollidiert mit Datenwänden, Schuss-Zielhilfe, „Schale knacken“ macht ICE sofort verwundbar.
- Ravens Apartment im Figurenmaßstab (16:10, Skalierung 0,46) mit eigener Kamera; Szene und Lichter angepasst.
- Kapitel 2: Storyschritte im Versteck behalten die Positionen (kein Zurückspringen zum Eingang).
- Unsicherer Cloak-Test stabilisiert; 13 neue Prüfungen; `tools/feedback_gallery.gd`.

## v0.18.3 – CodexAI: Nightwing-Hacks, Controller und verständliche Hilfe · 7. November 2026

- Alle fünf Terminaltypen in einheitliche dunkle Nightwing-Flächen vor der Neonstadt eingebettet: Cyan-Beschriftung, goldener Fokus, getrennte Aufgaben-/Statusbereiche und sichtbare Reglerwerte.
- Controller-Eingaben direkt im modalen Terminal verarbeitet: räumliche Navigation über Steuerkreuz/Stick, Wiederholung beim Halten, Totzone, A für Aktionen, Links/Rechts für Regler und Steckplätze sowie LB/RB als vollständiger Fokusumlauf einschließlich Abbruch, Neustart, Pause, Hilfe und Übernehmen. Gameplay erhält diese Ereignisse nicht weiter.
- Decoder beginnt auf dem Rauschfilter. Signalqualität hilft beim Abstimmen; nach Fehlschlag liegt der Fokus auf Neu versuchen, nach Erfolg auf Übernehmen.
- Ziele und nächste Schritte in jeder Ansicht erklärt. Pausierendes Handbuch mit Y/F1, Rückkehr mit A/B/Y/F1 und Erhalt des vorherigen Fokus. Start/P pausiert weiterhin separat.
- Prüfung: 154 Controller-, 67 Terminal-/Integrations- und 351 Gameplay-Prüfungen bestanden; alle fünf Ansichten und das Handbuch im Godot-Renderer kontrolliert. Controller-Ereignisse wurden simuliert, kein physisches Gerät angeschlossen.
- Automatisierte Controller-Tests lösen alle acht Einsätze mit eingespeisten Joypad-Ereignissen; zusätzlicher CI-Prüfschritt. Terminal-Vorschaubilder erneuert, Spieleranleitung und Repository-Infos ergänzt.

## v0.18.2 – CodexAI: Plattformproportionen und gezielter Figurenwind · 7. November 2026

- Beide Menüfiguren kleiner und passend auf der vorderen Plattform positioniert. Raven separat proportional skaliert und leicht zurückversetzt; weiche Kontaktschatten unter allen Stiefeln.
- Bestehende Referenzillustration ohne neue Bildgenerierung verwendet, entlang des transparenten Zwischenraums in zwei Figuren aufgeteilt und farblich dezent an das Nachtlicht angepasst.
- Ravens freie Haarspitzen und Shadepis äußere Umhangenden bewegen sich sanft im Wind. Geschützte Körperbereiche, Hände, Waffen und Füße bleiben fest. Keine Maus-Parallax.
- Windstärke folgt dem Bildstil; „Reduziert“ deaktiviert die Figurenanimation. Verdeckte Menüs stoppen weiterhin ihre Verarbeitung.
- Version in Godot, Windows-Export, Repository- und Spielerinfos auf v0.18.2 angehoben. Nur Menü und zugehörige Prüfung/Dokumentation geändert.
- Prüfung: 351 Gameplay-/Menüprüfungen bestanden. Zwei isolierte Windphasen im Godot-Renderer verglichen: Haar- und Stoffenden bewegen sich, Gesichter und Füße bleiben pixelgleich.

## v0.18.1 – CodexAI: Hauptmenü, Figurenreferenzen und ruhiger Bildaufbau · 7. November 2026

- Neue Menüillustration nach den aktuellen Nutzerbildern: Shadepi in Bereitschaftshaltung mit passender segmentierter Maske; Raven mit Tablet, Referenzgesicht, schwarz-blauen Haaren und taktischem Anzug im gezeichneten Stil.
- Maus-Parallax und Figurenverformung entfernt. Figuren und Dach bleiben fest, während Regen, Flugverkehr und Licht weiter animiert werden.
- Hauptmenü verwendet die Musik des See-Finales (`Level.mp3`); bisherige Musikdatei bleibt erhalten.
- Vor Umsetzung mit GitHub auf v0.18.0 synchronisiert. Tower, Kampagne und Zwischensequenzen werden durch diese Änderung nicht bearbeitet.
- Versionsnummer in Godot, Windows-Export, README und Spieleranleitung nachgetragen; Kennzeichnung **CodexAI** und die Pflicht zu Version und Änderungsinfos in `AGENTS.md` festgehalten.
- Prüfung der Menüänderung: 329 Gameplay-/Menüprüfungen bestanden, Menü im Godot-Renderer visuell kontrolliert.

## v0.18.0 – ClaudeHelper: Zwischensequenzen statt Comicseiten · 6. November 2026

- Alle Story-Dialoge in Kapitel 1, 2 und der Kampagne (3–7) sind jetzt inszenierte Szenen im Spiel; die Comic-Einblendungen der Dialoge entfallen (`comic_texture` liefert keine Bilder mehr, `Story.DIALOGUE`/`PANELS` entfernt).
- Texte folgen der Romanfassung „Shadepi im Schatten des Raben“ (Archiv Teil 4). Kenzōs Deck enthüllt nach seinem Tod, dass er das Massaker mit Militech-Minotauren inszeniert hat.
- Penthouse nach dem Roman: Kenzō im Sessel, „Lange nicht gesehen“, Raven wird quer durch den Raum geschleudert, das Tarnfeld fällt, erster Schlag in die Schulterservos.
- Kapitel-Titelkarten, Rückblende Shadepi über den Dächern, Explosion beim Abflug, Ritual und Maskenkodex mit Romantexten.
- Fehlerkorrekturen: Kampfhinweise (`combat_ready`) nur in Kampfphasen; Hinweistexte werden beim Szenen-/Kontrollpunktwechsel gelöscht; Zielmarker und Lebensbalken während Szenen ausgeblendet; Kapitel-1-Titel ergänzt.
- Cutscene-Werkzeuge: `lines`, `leap`, `play_lines`; `tools/cutscene_gallery.gd` rendert alle Szenen (Filter per Argument).
- Archiv Teil 4 mit sechs PDFs, Textkopien und bestätigten Storyfakten; AGENTS.md ergänzt.


## v0.17.0 – ClaudeHelper: Szenen und Kapitel-6-Fix · 6. November 2026

- **Fehlerkorrektur:** Die Aufzugwachen griffen bisher auf dem Dach *vor* Kenzōs Kampf an. Sie folgen jetzt seinem Tod (Totmannschalter) mit drei Wellen im Penthouse; der 60-Sekunden-Timer läuft erst danach. Speicherstand merkt sich den Zwischenstand, alte Stände am Dachkampf springen direkt zu Kenzō.
- **Zwischensequenz-System** (`scripts/cutscene.gd`): Kinobalken, Kamerafahrten mit Zoom, Laufwege, Untertitel mit Sprecherfarben, Blitz/Überblendung, Titelkarten, Dachsprung. E/A blättert weiter, Leertaste/B überspringt. Pause, Kontrollpunkt und Neustart brechen Szenen sauber ab.
- **Neue Szenen:** Jackals Auftritt, Shadepis Landung in der Wartungsgasse, Penthouse-Konfrontation mit Enttarnung, Kenzōs Ende durch Raven, Alarm und Aufzug, Ritual am See ohne Teleport, Finale mit Maskenkodex und Titelkarte.
- Kenzō erhält eine Boss-Anzeige; Lebensbalken werden in Zwischensequenzen ausgeblendet.
- „Orden des Weißen Drachen“ in Kapitel 2 korrigiert.
- Tests angepasst und erweitert (Reihenfolge Kenzō → Wachen, Timer, Laden während der Wachen); `tools/cutscene_gallery.gd` rendert alle Szenen.


## v0.16.0 – Ravens Terminals, Arcade-Kämpfe und Live-Menü · 6. November 2026

- Fünf interaktive Terminal-Rätseltypen an acht Storypunkten mit Eingaben per Maus, Tastatur und Controller, Pause, Wiederholung und gespeichertem Fortschritt. Aerodyne-Notfall nun per Jumper-Wartungsdeck statt Klopf-Sequenz.
- Zusätzliche Gegnerwellen mit Abschnittssperren und Kontrollpunkten; aufladbarer Katana-Schlag mit Energiewelle, Kick und Ravens aufgeladener Pistolenschuss samt HQ-Kampfposen.
- Bewegtes Hauptmenü mit Neonstadt, Parallax-Effekt, Regen, Reflexionen und Windanimationen; Steuerung über Maus und Controller.
- Korrekturen an der Dachkante für Raven, Größenverhältnissen im Versteck sowie dem Boden-/Straßenübergang von Bingo Street zur Gasse.
- Automatisierte Tests für Terminal-Mechanik, Arcade-Wellen und neue Kampfbewegungen in den Build-Workflow eingebunden. **Build-/Release-Erfolg für v0.16.0 noch nicht bestätigt.**
- Versionsnummer in `project.godot` und auf der Projektstartseite vereinheitlicht.

**Hinweis:** v0.16.0 bezeichnet zunächst den dokumentierten Quellstand auf `main`. Ein GitHub Release wird nicht allein durch die Änderung der Versionsnummer angelegt.


## Weiterentwicklung – Ravens Terminals · 6. November 2026

- Acht Story-Einsätze mit fünf Rätseltypen: Hex-Matrix samt überlappenden Daemons, Glitch-/Passwort-Decoder, Leitungsnetz mit Active ICE und Überlast, Oszilloskop-Abgleich und Jumper-Platine.
- Jackals Schleuse verlangt nach den Wellen einen Raven-Hack. Garagenzugang, Hangar, Dach und Penthouse erhalten interaktive Terminals; der Aufzug wird per synchronisierter Sperrladung blockiert.
- Aerodyne-Reparatur ersetzt die Klopf-Eingaben durch Pins und Widerstände. Scannerfenster bleibt erhalten; Abbruch, Wiederholung und 45-Sekunden-Wiederzugriff sind möglich.
- Maus-, Tastatur- und Controller-Bedienung, Terminal-Pause, Erfolgsbestätigung und gespeicherter Kampagnenfortschritt. Laufende Rätsel frieren die Welt ein.
- Regel-, Fehlerpfad- und Integrationstests sowie eine Godot-Bildergalerie und aktualisierte Spieleranleitung.

## v0.15.0 – HQ-Weltobjekte und Fahrzeug-Action · 5. November 2026

- Neun HQ-Objekttypen mit drei Schadenszuständen; feste Requisiten verwenden dieselbe Grafikbasis. Alte Pixel-Atlanten entfernt.
- Gemalte Fahrzeuge ersetzen die geometrischen Platzhalter in Anflug und Verfolgungsjagd.
- Einmaliger Triebwerksausfall mit acht Sekunden Reparaturzeit, zwölf einzelnen Klopf-Eingaben, Rauch, Schräglage und Wiederzündung. Anflugzeit und Scannerfenster bleiben während der Reparatur erhalten.
- Träge, bildratenstabile Lenkung, Rückstoß, Trefferfunken, Mündungsfeuer, Explosionen und begrenzte Trümmer-/Rauchsysteme.
- Fünf eigenständig synthetisierte Sounds respektieren den vorhandenen Ton-Schalter.
- Neue automatisierte Tests für Reparatur, Pause, Fehlversuch, Scanner, Physik, Treffer und Effektgrenzen.


## v0.14.0 – Verstecktes Testmenü · 5. November 2026

- Das Testmenü öffnet sich im Haupt- oder Pausenmenü mit **Strg+Umschalt+F10** oder fünf Klicks auf den Menütitel.
- Kapitelwahl für alle sieben Kapitel; Kapitel 3–7 starten am passenden Beginn innerhalb der gemeinsamen Kampagne.
- Testschalter: Unsterblichkeit, One-Hit-K.O., unendliche Energie, keine Abklingzeiten, Fluchttimer-Stopp und Alle-Kapitel-Freischaltung.
- Testaktionen: Gegner im aktuellen Kampf ausschalten, Leben/Energie auffüllen und alle Testschalter zurücksetzen.
- Normale Spielstände bleiben getrennt: Ab Öffnen des Testmenüs werden Kontrollpunkte mit Admin-Dateinamen gespeichert.
- Testoptionen werden lokal gespeichert, es gibt keinen Passwortschutz. Storybedingte Schutzmechaniken bleiben bei regulären Treffern erhalten.
- Neue Prüfungen für Kapitelzuordnung, getrennte Speicherpfade, UI, Unsterblichkeit und One-Hit-Modus.


## v0.13.2 – Direkte HQ-Sprites und weniger Altlasten · 5. November 2026

- Alle Szenen laden Raven, Shadepi und die humanoiden Gegner unmittelbar aus den fertigen HQ-Atlanten.
- Zehn alte Pixel-Sprites samt Godot-Importdateien entfernt; die HQ-Atlanten, Original-Keyframes und digitalen Gegner bleiben bestehen.
- `SpriteAssets` auf die Custom-Sprite-Auswahl und Atlasgrößenprüfung vereinfacht. Benutzereigene ältere 4-/8-Richtungs-Pixelraster bleiben kompatibel.
- Gameplay- und Animationstests prüfen den direkten HQ-Ladevorgang und das Fehlen der Pixel-Zwischendateien.
- Node-Generator auf die weiterhin genutzten Pixel-Requisiten, Lichttextur und Basissounds reduziert; keine Figuren/Level/Icons werden mehr überschrieben.
- Aktualisierte Dokumentation, identische Kapitel- und Spielstandformate.


## v0.13.1 – Story, Kapitel und Szenen · 5. November 2026

- Story-Ausgänge starten das folgende Kapitel am Anfang, auch bei älteren abgeschlossenen Spielständen. Menü-Fortsetzen lädt weiterhin den gespeicherten Kontrollpunkt; ungültige Dateien schalten keine Kapitel frei.
- Startposition in Kapitel 2 aus der Autokollision verschoben; Gesundheit, Energie und Hackbereitschaft werden bei der Wiederherstellung zurückgesetzt. Niederlagen außerhalb des Deep Dive führen ebenfalls zum Kontrollpunkt.
- Erinnerungsraum erhält einen definierten Einstieg; falsche Echos führen zum echten Erinnerungsanker zurück.
- Ravens Hackreichweite wird von Raven aus gemessen. Der bewaffnete Ganggegner in Kapitel 1 benutzt Fernangriffe. Der Dachsprung stellt den Fußpunkt der HQ-Grafik korrekt wieder her.
- Überarbeitete Hinterhalt-, Tower-, Rückkehr- und Fluchtdialoge; erklärter Zeitsprung zum nächsten Abend. Das Notfallprotokoll erklärt die Überlastung anstelle nie gelegter Sprengsätze. Fernzugriff und Dachausgang entsprechen den Fluchtaktionen im Penthouse.
- Towerplan wird am Arbeitsterminal geprüft; kontextbezogene Steuerungshinweise. Lange Dialoge werden ohne Textverlust aufgeteilt; HUD-Breiten und mehrzeilige Hinweise angepasst.
- Wassergrenze folgt dem gemalten Ufer. Ritual und Schlusspositionen liegen auf begehbarem Land. Keine Frachtkisten am See, kein Getränkeautomat im Heiligtum oder Penthouse.
- 501 Prüfungen erfolgreich (241 Gameplay, 240 Story/Geometrie/HUD, 20 digitale NPCs). Story-Prüfung in den GitHub-Workflow aufgenommen; Renderübersicht visuell kontrolliert.

[Detaillierter Prüfbericht und Grenzen](docs/v0.13.1-fehlerpruefung.md)

## v0.13.0 – HQ-NPCs · 5. November 2026

- Acht illustrierte humanoide NPC-Atlanten mit acht Blickrichtungen; zwei neue digitale Gegnergrafiken.
- Neue Schuss-/Rundumschlag-Animationen bei unverändertem Kampftiming.
- Originalposen, reproduzierbares Packwerkzeug und NPC-Anleitung enthalten.
- 239 Spieltests und 20 digitale Gegnerprüfungen unter Windows erfolgreich; Godot-Galerie visuell geprüft.
- 32 Ausgangsposen je humanoider Figur werden für die Animationsfelder wiederholt; keine 256 unabhängig gezeichneten Frames.


## v0.12.0 – wiederhergestellter Quellstand auf GitHub

**4. November 2026** · [Upload 3d4b2c4](https://github.com/Inrouder/ShadepiRPG/commit/3d4b2c492ded8a656a2311997781de6d027e1e34)

### Spiel und Medien

- Illustrierte HQ-Sprites für Raven und Shadepi mit acht Blickrichtungen sowie Lauf- und Angriffsanimationen.
- Originale Schlüsselposen und `tools/compile_heroes.py` zur Bearbeitung der Heldenatlanten.
- Die vorherigen Ausbaustufen mit 16 gemalten Kulissen, abgestimmter Kollisions-/Vordergrunddarstellung und zerstörbaren Requisiten sind enthalten.
- Kapitel 1–7, Solo-/Koop-Steuerung, Controller-Unterstützung und Spielstände bleiben Teil des Projekts.

### Wiederherstellung und Sicherung

- Alle 25 Spielskripte dekompiliert und alle 105 importierten Ressourcen konvertiert.
- Originaldateien aus dem separaten HQ-Archiv ergänzt.
- Alle 243 Dateien des bereitgestellten Projekts auf GitHub nachgewiesen; 242 stimmen mit dem lokal geprüften Stand überein. Die neu serialisierte Projektkonfiguration nennt 0.12.0.
- README, Projektaufbau, Bearbeitungshinweise und Wiederherstellungsbericht aktualisiert.

### Prüfung und Grenzen

- Lokale Rekonstruktion unter Windows mit Godot 4.7.2: **177 Prüfungen, 0 Fehler**, erfolgreicher Starttest.
- [GitHub-Test- und Buildlauf des Uploads](https://github.com/Inrouder/ShadepiRPG/actions/runs/41922510900): **erfolgreich**, einschließlich Windows-/Linux-Export und Linux-Starttest.
- 30 Ressourcen von GDRE als verlustbehaftet konvertiert eingestuft. Ursprüngliche Medienquellen und nicht exportierte Entwicklungsdateien sind nicht vollständig rekonstruierbar.
- Kein vollständiger manueller Spieldurchlauf. Die früher genannten 301 Tests gelten nicht als Testzahl dieser Rekonstruktion.
- Der Quellstand auf `main` und die Actions-Artefakte sind vorhanden. Ein eigenständiger GitHub Release ist ein zusätzlicher Veröffentlichungsschritt.

[Ausführlicher Wiederherstellungsbericht](docs/v0.12.0-wiederherstellung.md)

## Entwicklungsschritte vor der Wiederherstellung

Diese Zuordnung stammt aus den bisherigen Entwicklungsberichten; sie bezeichnet keine nachträglich angelegten Git-Tags oder separat geprüften Releases.

| Version | Schwerpunkt |
| --- | --- |
| v0.11.0 | 16 gemalte Levelkulissen, abgestimmte Kollisionen und Vordergrundwände |
| v0.10.0 | Zerstörbare Kisten, Straßenlaternen, Autos, Fässer und weitere Requisiten |
| v0.9.0 | Comicgerechte Kapitelinszenierung |
| v0.7.0 | Vorheriger GitHub-Quellstand vor der Rückführung des v0.12-Projekts |
