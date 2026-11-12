# Versionshinweise

## v0.60.2 – ClaudeHelper: Netz-Ebenen spielbar · 12. November 2026

Nutzerbericht: In Netz-Ebene 2 kein Durchgang an der Kristallsäule; Netz-Ebene 3 nicht abschließbar, Gegner fehlten.

- **Fehlende Gegner:** Die ICE-Programme waren auf den Bewegungsraum der Hauptebene begrenzt und sprangen beim ersten Schritt dorthin zurück – in beiden neuen Ebenen. Sie bleiben jetzt in der Ebene, in der sie erscheinen, und weichen deren Hindernissen aus.
- **Durchgang:** An Kristallspeichern und Datenwänden ist nur noch der Sockel gesperrt. Man läuft dahinter durch und wird vom Bildteil verdeckt.
- Einstieg in den roten Kern liegt jetzt rechts neben der ersten Datenwand.
- `passages` prüft beides mit echter Bewegung (69 Prüfungen).

## v0.60.1 – ClaudeHelper: Hintertür der Gasse auf Figurenmaß · 12. November 2026

Nutzerbericht: Die Tür in der Gasse war viel größer als Raven.

- Die Türeinheit (Rahmen, Lampe, Schloss) ist auf etwa 1,3 Figurenhöhen verkleinert und steht weiter auf dem Gehweg; vorher war sie rund 2,4 Figuren hoch. Die frei gewordene Wand ist mit dem Blech der Nachbarwand gefüllt.
- Werkzeug `tools/passages/fit_backalley_door.py` wiederholt den Schritt aus dem gelieferten Bild.

## v0.60.0 – ClaudeHelper: Gasse, Tower-Flur und Lobby, zwei Netz-Ebenen · 12. November 2026

Der Nutzer hat fünf Level-Bilder geliefert und beschrieben, wo sie hingehören.

- **Kapitel 1 · Gasse:** Raven tritt aus der Hintertür ihrer Wohnung in eine Gasse, kommentiert das Drachen-Graffiti und kann frei laufen. Ein Punk quatscht sie an („Na, Püppchen. Wie wär's mit uns beiden?“), sie hackt seinen Neuralport, er fällt um. Danach geht es wie bisher auf die Bingo Street.
- **Kapitel 6 · Tower:** Zwischen Landeplatz und Kenzōs Suite liegen jetzt ein Flur und die Lobby. Auf dem Hinweg sind sie leer; auf dem Rückweg stehen in beiden je drei Wachen, eine davon mit Schild. Der Flucht-Countdown ruht in dieser Zeit.
- **Kapitel 2 · Deep Dive:** Nach dem ersten Relais führt die Spur ins violette Datenarchiv, nach dem zweiten in den roten Kern, je mit zwei Wellen ICE; danach folgt der Wächter wie bisher.
- Gemeinsame Technik: `scripts/passage_room.gd`. Story, Dialoge der bestehenden Szenen und Spielstände bleiben unverändert. [Übersicht](docs/durchgangsraeume.md).
- Neuer Test `passages` (61 Prüfungen), 47 Suiten.

## v0.59.0 – ClaudeHelper: Jagd, Rettung, Flug und Aufzugkampf gestreckt · 12. November 2026

Fortsetzung des Auftrags „Level strecken“; Story und Dialoge unverändert, keine neuen Kulissen nötig.

- **Kapitel 1 · Jagd:** jeder der drei Abschnitte hat eine dritte Welle zu dritt (21 statt 12 Gegner).
- **Kapitel 1 · Rettung:** vierte Welle vor Jackal (11 statt 8 Gegner).
- **Kapitel 6 · Flug:** die Häuserschlucht dauert 34 statt 23 Sekunden, die Turmabwehr 20 statt 7; nach der Hälfte kommt eine dritte Laser-Drohne als Verstärkung.
- **Kapitel 7 · Aufzugwachen:** vierte Welle mit zwei Schildträgern (11 statt 8 Gegner).
- Eine wackelige Prüfung der Bodenspiegelung (`scene_polish`) verglich Bildnummern auf den Frame genau; sie lässt jetzt ein Bild Versatz zu.

## v0.58.1 – ClaudeHelper: gelieferte Kulissen für die Verfolgung · 11. November 2026

Der Nutzer hat fünf Kulissenbilder für die Fahrt geliefert.

- **Tunnel und Hochstraße** nutzen jetzt die gelieferten Bilder statt der Behelfskulissen aus v0.58.0; deren Werkzeug `tools/drive/build_chase_stages.py` ist entfernt.
- **Stadt:** zwei weitere Straßenzüge wechseln sich mit dem bisherigen ab.
- **Fußgängerbrücke:** aus dem fünften Bild freigestellt; sie zieht in der Stadt-Etappe gelegentlich über die Fahrbahn, Motorrad und Wagen fahren darunter hindurch.
- Regeln und Länge der Etappen sind unverändert. [Übersicht](docs/level-strecken.md).

## v0.58.0 – ClaudeHelper: Verfolgung in drei Etappen, längerer Hinterhalt · 11. November 2026

Nutzerauftrag: Level strecken, Story unverändert; als Muster Hinterhalt und Verfolgung. Neue Kulissen im Stil der vorhandenen.

- **Verfolgung in drei Etappen:** Stadt → Tunnel → Hochstraße, je ein eigener Verfolgerwagen (100 / 80 / 100 % Panzerung). Die ersten beiden fallen qualmend zurück, erst der dritte explodiert wie bisher. Beim Etappenwechsel repariert sich das Motorrad um 25 %; nach einem Sturz geht es an der erreichten Etappe weiter.
- **Tunnel:** keine Drohnen, Hindernisse stehen dichter. **Hochstraße:** Drohnen von Anfang an zu zweit, Seitenwind drückt das Motorrad zur Seite.
- **Zwei neue Kulissen** (`tunnel.png`, `skyway.png`), gebaut aus den vorhandenen gemalten Kulissen (`tools/drive/build_chase_stages.py`). Unter der Hochstraße zieht die Stadt aus dem Flug langsamer vorbei.
- **Hinterhalt:** je Abschnitt eine vierte Welle; am Ende ein Truppführer mit Schild nach vorn und 150 Leben. 19 statt 13 Gegner.
- Story, Dialoge und Kapitelfolge sind unverändert. [Übersicht](docs/level-strecken.md).

## v0.57.1 – ClaudeHelper: Ravens Schüsse, unsichtbare Wand, Motorrad · 11. November 2026

Nutzerbericht mit Bild aus der Halle (Kapitel 4, Koop).

- **Ravens Schüsse treffen wieder:** In Kapitel 3–7 kannte die Schussprüfung nur den Gegner der Testszene; Ravens normale Schüsse gingen deshalb durch alle Kampagnengegner hindurch. Jetzt trifft sie den nächsten Gegner im Schusskegel.
- **Unsichtbare Wand im Koop:** Die Koop-Leine hielt eine allein geführte Figur am unsichtbar wartenden Partner fest (in der Halle: Raven kam nicht weiter nach rechts). Die Leine gilt nur noch zwischen zwei gespielten, sichtbaren Helden.
- **Geparktes Motorrad:** Der Mittelteil bestand aus einer flachen Ersatzfläche mit zwei durchsichtigen Streifen. Er ist durch Rahmen, Lenker, Tank und Sitzbank ersetzt (`tools/vehicles/repair_parked_bike.py`); Verkleidung, Motor und Heck sind unverändert.
- **Anzeige:** Führt Raven allein, erscheint keine doppelte Raven-Zeile mehr; die Balken zeigen ihre Werte.

## v0.57.0 – ClaudeHelper: Arcade-Automat „NEON KOMBAT“ · 11. November 2026

Nutzerauftrag: ein Automat in Shadepis Versteck mit einem Kampfspiel für alle Figuren, auch zu zweit.

- **Automat in der Halle des Ordens (Kapitel 4):** an der Rückwand rechts neben dem grünen Tank. Mit E / A öffnet Raven das Spiel; die Mission bleibt unberührt.
- **NEON KOMBAT:** seitliches Kampfspiel mit zehn Figuren (Shadepi, Raven, Jackal, Kenzō, vier Straßenkämpfer, zwei Schützen). Leichter Schlag, schwerer Hieb, Sprung, Block, Spezialleiste mit vier Spezialarten, Trefferzähler, 60 Sekunden je Runde, zwei Gewinnrunden.
- **1 Spieler gegen CPU oder 2 Spieler im Duell** an einer Tastatur oder mit Gamepads.
- **Hauptmenü:** Nach dem ersten Fund steht „Arcade · NEON KOMBAT“ auch im Hauptmenü.
- Figuren nutzen unverändert ihre vorhandenen Seitenansichten; neu sind Bühne, Automat und Trefferfunken (`tools/arcade/build_arcade.py`). [Anleitung](docs/arcade.md).
- Neuer Test `arcade` (56 Prüfungen), 46 Suiten.

## v0.56.0 – ClaudeHelper: Verfolger explodiert, Hindernisse zerbersten · 11. November 2026

Nutzerbericht: Nach dem Sieg fuhr der Verfolgerwagen unversehrt weiter, dann stand man plötzlich in der Garage.

- **Ende der Verfolgung:** Der besiegte Wagen fängt Feuer, schlingert führerlos, geht nach knapp einer Sekunde in einer großen Explosion hoch und bleibt als brennendes, sich drehendes Wrack hinter dem Motorrad zurück. Erst danach geht es zur Garage. Drohnen und Minen, die noch im Bild sind, explodieren mit.
- **Der Wagen zerlegt Hindernisse:** Baken zerbersten an seinem Bug in Betonbrocken und Lampensplitter; rammt er ein Wrack, explodiert es und kostet ihn 6 % Panzerung.
- **Neue Pixel-FX:** Explosion, Rauch, Flammen und Bruchstücke sind jetzt gezeichnete Pixelblätter statt Kreisflächen ([Übersicht](docs/verfolgung-finale-v056.md)); erzeugt mit `tools/fx/build_drive_fx.py`.

## v0.55.0 – ClaudeHelper: Koop in jedem Kapitel geprüft, Menü mit „Zurück ins Hauptmenü“ · 11. November 2026

- **Menü umgebaut:** Die Pause in allen Kapiteln zeigt Fortsetzen, Kontrollpunkt laden, Kapitel neu starten, Ton/Bild und **Zurück ins Hauptmenü**. Die fehlerhafte Schaltfläche „Zurück zu Kapitel 1“ entfällt. Moduswechsel und Kapitelwahl (Kapitel 2, Kapitel 3–7) liegen nur noch im Hauptmenü; ein dort geöffnetes Kapitel startet direkt und im gewählten Modus. Das Hauptmenü merkt sich den Modus der laufenden Sitzung.
- **Koop in jedem Abschnitt:** Neuer Test `coop_chapters` startet alle 21 Abschnitte der sieben Kapitel in einer Koop-Sitzung und drückt echte Tasten für beide Spieler. Spieler 2 steuert überall Raven, die Drohne oder die Naniten.
- **Verfolgung und Flug:** Dort hatte Spieler 2 bisher nichts zu tun. Jetzt schießt, hackt und wirft Raven vom Sozius (U / O / P bzw. zweites Pad), im Flug gibt sie den Kalibriercode ein (Pfeile) und öffnet das Wartungsdeck (U).
- **Kontrollpunkt laden im Koop:** berücksichtigt jetzt auch Kapitel 2–7 (bisher nur Kapitel 1).
- 45 Suiten ohne Fehler; `coop_chapters` mit 68 Prüfungen.

## v0.54.2 – ClaudeHelper: Koop bleibt ab Kapitel 2 erhalten · 11. November 2026

- Nutzerbericht: Ab Kapitel 2 konnte Spieler 2 nicht mehr steuern. Ursache: Kapitel 1 hat ein eigenes Startmenü, das den gewählten Modus nicht für die Sitzung vermerkte; v0.54.1 hatte das nur für die Menüs der späteren Kapitel getan. Kapitel 1 vermerkt den Modus jetzt bei jedem Start und Laden, ebenso „Letzten Kontrollpunkt laden“.
- Der Test `companion_input` spielt jetzt den echten Weg nach: Koop-Start im Menü von Kapitel 1, Übergang in Kapitel 2, Begleiter mit echten Tasten steuern (41 Prüfungen). Alle 44 Suiten ohne Fehler.

## v0.54.1 – ClaudeHelper: Begleiter im Koop wirklich steuerbar · 11. November 2026

Nutzerbericht: Im Koop ließ sich die Drohne in Kapitel 1 nicht steuern, nach einem Kapitelwechsel auch Drohne und Naniten nicht. Drei Ursachen behoben:

- **Kapitel 1:** Das Kapitel schaltet den Koop-Modus in Ravens Solo-Abschnitten intern ab. Der Begleiter hielt das für ein Solospiel und wartete auf eine Übernahmetaste. Jetzt zählt die Koop-Sitzung; Spieler 2 hat die Drohne sofort und dauerhaft.
- **Kapitelwechsel:** Jedes neue Kapitel startete still im Einzelspieler. Der im Menü gewählte Modus gilt jetzt für die ganze Sitzung, auch in Kapitel 2 und 3–7.
- **Gamepad:** Die Bindung wurde nur einmal beim Start gesetzt, bevor der Modus feststand; mit nur einem Gamepad blieb der Begleiter ohne Pad. Sie folgt jetzt laufend dem Pad von Spieler 2. Zusätzlich: **A** greift an, **LB** löst die Spezialfähigkeit aus.
- Pfeiltasten gehören Spieler 2, solange er den Begleiter fliegt, auch wenn ein Kapitel den Modus zwischendurch umschaltet. Im Solospiel zeigt ein einmaliger Hinweis, wie ein zweiter Spieler einsteigt.
- Neue CI-Suite `companion_input` (33 Prüfungen) bedient den Begleiter über echte Tastenereignisse und den Menüstart; alle 44 Suiten ohne Fehler.

## v0.54.0 – ClaudeHelper: Koop mit Raven in Kapitel 3–7, freie Tonaufnahmen · 11. November 2026

- **Koop:** In Kapitel 3 bis 7 steuert Spieler 2 Raven jetzt selbst, wo sie frei in der Szene steht: im Versteck, im Hinterhalt, bei der Symbolsuche in der Garage und im Kampf gegen die Aufzugwachen. Wo die Geschichte Raven festlegt oder nur ein Held da ist, spielt Spieler 2 weiter den Begleiter. Behoben: Im Koop blieb Raven in diesen Kapiteln bisher einfach stehen.
- **Ton:** Schüsse, Explosionen, Schwerthiebe, Treffer, Requisiten und alle Gegnerstimmen sind jetzt freie CC0-Aufnahmen (Superpowers Asset Packs, Kenney, qubodup) statt synthetischer Rauschstöße. Dateinamen unverändert; Quellen und Lizenz in `assets/audio/CREDITS.md`.
- Neue CI-Suite `coop_campaign` (23 Prüfungen); alle 43 Suiten und das Repository-Audit ohne Fehler.

## v0.53.0 – ClaudeHelper: Begleiter für Spieler 2 – Ravens Drohne und Shadepis Nanitenschwarm · 10. November 2026

- Nutzeridee: Ist ein Held allein spielbar, steuert Spieler 2 dessen Begleiter. **Raven → Aufklärungsdrohne** (Schuss, Störimpuls), **Shadepi → Nanitenschwarm** des Heiligtums, weiß leuchtend und rot beim Angriff (Biss, Schutzschwarm).
- Im Koop erscheint der Begleiter immer, wenn nur ein Held spielbar ist, also in fast allen Szenen von Kapitel 3 bis 7. Im Solospiel begleitet er einen Helden, der wirklich allein in der Szene ist, und folgt nur; ein zweiter Spieler kann jederzeit mit Angriffs- oder Spezialtaste einsteigen.
- Steuerung Spieler 2: Pfeiltasten oder zweites Gamepad bewegen, **U / X** Angriff, **O / Y** Spezialfähigkeit. Der Begleiter fliegt, bleibt an einer Leine beim Helden und kann nicht sterben. Kein Begleiter bei Motorradfahrt, Flug, Erinnerungen und Abspann.
- Neue Pixelgrafiken aus einzeln gesetzten Pixeln; neue CI-Suite `companion` (22 Prüfungen). [Steuerung und Regeln](docs/begleiter.md).

## v0.52.0 – ClaudeHelper: Sprites kalibriert, Ringe unter den Figuren, freie Türen, Spiegelungen und Kinolicht · 10. November 2026

- **Sprites:** Neues Prüfwerkzeug fand 214 sichtbare Fehler in zehn Posenblättern (Nachbarpose im Bild, abgeschnittene Glieder und Waffen), darunter Shadepis Tritt, Ravens Ladepose und alle Gegner-Angriffsposen. Jede Pose hat jetzt eine eigene Zelle mit leerem Rand; Bildschirmposition unverändert, keine Figur neu gezeichnet. Prüfung danach: 0 Fehler.
- **Aktionsringe** liegen als Bodenmarkierung unter den Figuren; nur der Pfeil schwebt darüber.
- **Türen frei:** Laterne neben statt vor der Verstecktür (Kapitel 3), Werkzeugkasten und Container neben den Garagen-Rolltoren. Laufweg-Prüfwerkzeug für die Kinoszenen der Kampagne.
- **Licht:** Bodenspiegelung aller Figuren auf nassem Asphalt, Dach, Marmor und Hallenboden; Kino-Vignette in Filmszenen; Lichtkegel und Bodenschein an Straßenlaternen.
- Neue CI-Suite `scene_polish` (54 Prüfungen); alle 41 Suiten und das Repository-Audit ohne Fehler. [Bilder und Details](docs/szenenpolitur-v052.md).

## v0.51.1 – CodexAI: sichtbare HQ-Dropdowns in Menüs, Kontrollpunkten und Hacks · 10. November 2026

- Zentraler Renderfehler behoben: eingebettete Godot-Listen verwenden die reservierte Canvas-Ebene 1024. Der HQ-Präsentationspass lag auf derselben Ebene und verdeckte sie trotz intern geöffnetem Zustand.
- Präsentation liegt jetzt auf Ebene 512 unter den eingebetteten Fenstern. Sichtbarkeitsmasken und bestehende HQ-Isolation bleiben erhalten. Keine doppelte native Rasterung der Spielszene; Full-HD-Grenze bleibt erhalten.
- Anzeige-, Kapitel-, Kontrollpunkt- sowie sämtliche Energie-/Reparatur-Auswahlen sichtbar und bedienbar. Im Hack öffnet A / Enter eine echte Liste; B / Esc schließt diese zuerst. Bestehende Links-/Rechts-Schnellwahl bleibt erhalten; Popup-Stil folgt dem Hack-Deck.
- Neue native Pixelbildprüfung statt alleiniger Prüfung von `PopupMenu.visible`, zusätzlich Headless-/4K-/Eingabe-Regressionen. [Bilder und Details](docs/dropdowns-v0511.md).

## v0.51.0 – CodexAI: wählbare native HQ-Anzeige bis 1920×1080, Full-HD-Bild für größere Ausgaben · 10. November 2026

- HQ-Modus im Anzeige-Menü, standardmäßig aktiv und getrennt von Spielständen gespeichert; klassischer 640×360-Modus bleibt wählbar. Anzeige zeigt interne und physische Ausgabeauflösung.
- Vorhandene Welt-/UI-Canvases werden einmal in ein auf 1920×1080 begrenztes Spielbild gezeichnet. Größere Ausgaben skalieren dieses fertige Bild; 4K-Pixelvergleich bestätigt die zweifache Vergrößerung. Unterhalb Full HD passt sich das HQ-Spielbild an die Ausgabe an.
- Logische 640×360-Komposition, Szenen, Kameras, GUI-Fokus, Maus-/Controller-Eingabe und Originalhelden bleiben erhalten. Kein zweiter Spiellauf, kein neuer Heldenatlas und keine künstlich vergrößerten Quelldateien.
- Bloom behält über Auflösungsskalierung seinen Radius in der Welt. Weicher texturbasierter Fußkontakt ersetzt harte rechteckige Schattenanteile. Menü, Terminals, Kino und Kapitelwechsel behalten ihre Ebenen und Modalität.
- 2.255 Headless-Checks, 73 native Anzeige-/Maus-/4K-Prüfungen und 23 zusätzliche Paketprüfungen ohne Fehler; Bildbelege und HQ-Film unter 5 MB.
- [Bilder, Steuerung und Messungen](docs/hq-anzeige-v051.md) · [Arbeits-/Exportnachweis](docs/arbeiten/hq-anzeige-v051.md).

## v0.50.2 – CodexAI: Anzeigequalität analysiert und native Full-HD-Vergleiche dokumentiert · 10. November 2026

- Nutzerauftrag zur Anzeigeanalyse: Grafikpfad, Quellmaße, Importparameter, Abtastung und tatsächliche Renderziele untersucht. Gameplay rendert intern 640×360; das Menü nutzt bereits Canvas-Rendering in Ausgabeauflösung.
- Physische Fensteraufnahmen bei 720p und 1080p, Versteck mit Originalhelden, ICE und See. Gleiche Kamera, Figurenpositionen und logische Komposition; direkter nativer Vergleich erhält sichtbar mehr Quelldetails. Keine neuen Texturen und kein hochgerechneter 640er-Screenshot als HQ-Nachweis.
- Empfehlung: zusätzlicher wählbarer HQ-Modus mit Prüfung von Bloom, Schatten, Bewegung und Leistungsbedarf. Keine Produktions-Renderoption geändert; Versionssprung dokumentiert Analyse und reproduzierbares Vergleichswerkzeug.
- 40 native Vergleichspunkte, 73 Anzeigeprüfungen und Startprüfung ohne Fehler.
- [Bilder, Messungen und Empfehlung](docs/anzeigequalitaet-v0502.md) · [Arbeitsnachweis](docs/arbeiten/anzeigeanalyse-v0502.md).

## v0.50.1 – CodexAI: Raven als animierte Gittersilhouette im Netz · 10. November 2026

- Cyanfarbenes Pixelgitter und Körperkontur aus der tatsächlichen Transparenz der unveränderten Raven-Sprites. Haare, Körperbau und Handposen bleiben die Vorlage; keine neue Ersatzfigur.
- Effekt begleitet alle Deep-Dive-Relais, Gehen, Aufladen und Handangriffe. Gitter am Fußanker, Datenimpuls pausiert im Menü. Bisherige frei über dem Avatar liegende Querstreifen entfernt.
- Netzavatar ohne körperlichen Schatten; bei Rückkehr normaler Shader und normale Licht-/Schattenzustände. Bossmechanik, Quellen, Anker und Spielstandformat erhalten.
- 905 Headless-Checks, 56 native Checks einschließlich Pixelkonturprüfung und 18 Paketprüfungen ohne Fehler.
- [Bilder und Animationsfilm](docs/netzavatar-v0501.md) · [Arbeitsnachweis](docs/arbeiten/netzavatar-v0501.md).

## v0.50.0 – CodexAI: ICE-Bosskampf mit Kugelsalven, Deckung und Kernfenstern · 10. November 2026

- Kapitel 2, dritter Deep-Dive-Knoten: eigene Wächterarena mit 2,25-facher Bodenfläche. Hintergrund, feste Wände, Verdeckung, Requisiten, Relais und Kamera zusammen angepasst.
- Acht neue HQ-Pixelart-Bossphasen: Aufladen, Schuss, Rückstoß, offener Kühlkern, Treffer und Zerstörung. Fünf ausweichbare Dreier-Kugelsalven je Angriff, feste Deckung stoppt die Geschosse. Kein sofortiger Querstrahl mehr.
- Nah heran während des cyanfarbenen Kernfensters, höchstens zwei Integritätspunkte je Runde, dann Rückzug. Vier erfolgreiche Öffnungen gewinnen den Kampf; optionaler Hack verlängert eine offene Phase. Raven ist im Netz besser lesbar, Originalhelden und bestehende Handanker bleiben erhalten.
- Boss.mp3 am Wächter, klare Tastatur-/Controllerhinweise, benannter Test-Kontrollpunkt. Pause, Laden, Wiederholung und Raumwechsel räumen Geschosse und Raumzustände auf.
- 1.725 gezielte Checks und 16 zusätzliche Paketprüfungen ohne Fehler; nativer vollständiger Boss-Sieg aufgenommen, Film unter 5 MB.
- [Bilder, Kampffilm und Steuerung](docs/ice-kampf-v050.md) · [Prüf- und Quellnachweis](docs/arbeiten/ice-v050.md).

## v0.49.0 – CodexAI: Mondsee, bewegter Drachenschatten, Kontaktanimation und Menügrößen · 9. November 2026

- Aktuellen v0.48.0-GitHub-Stand übernommen; Storykorrekturen, Towerplan, Marker, Alarmlicht, Umgebungston und einheitliche Aerodyne-Düsen erhalten.
- Kapitel 7 mit kühlem Mondlicht und bewegtem silberblauem Reflexpfad unter dem vorhandenen Mond. Wasserbewegung und mystischer Glanz bleiben auf der Seegeometrie. Sechs echte Körper-/Schweifphasen statt einzeln verschobener Drachenquelle; weiterer Kamerablick hält den Mond im Kinoausschnitt sichtbar.
- Acht registrierte Kontaktbilder ohne transparente Doppelkonturen: Griff, rechte Maskenhand/linke Gesichtsverdeckung, Annäherung, Kuss, Rücksetzen und Umarmung. Normale Originalhelden unverändert. Körper-/Schattenersatz, Pause, Kino-HUD und Wiederherstellung bei Ende/Abbruch berücksichtigt.
- Menübreite 260 logische Pixel, Höhe nach sichtbaren Kapitelaktionen. Hilfe und Beschreibung bleiben im Rahmen, Anzeige erhält ihre Mindestbreite. Haupt-/Pausenmenü aller drei Oberflächen bei 640×360, 1280×720 und 1920×1080 geprüft; Controller, Test-Kontrollpunkte und Desktop-Ausgang erhalten.
- 1.428 gezielte Prüfungen ohne Fehler, 32 zusätzliche Exportprüfungen, native Vergleichs-/Szenenaufnahmen und Film unter 5 MB. Neue Moon-/Menü-Regression in CI. [Bilder, Film und Details](docs/mondsee-v049.md), [Arbeits-/Exportnachweis](docs/arbeiten/mondsee-v049.md).

## v0.48.0 – ClaudeHelper: Towerplan, Pixelmarker, Alarmlicht, Umgebungsgeräusche · 9. November 2026

- **Kapitel 3:** Der Pakt läuft in drei Gesprächsschritten mit Reaktionen ab, nach dem Roman. Raven projiziert einen HQ-Pixel-Towerplan über ihre Konsole. Jeder Prüfschritt und die Planbesprechung heben farbtreu Aufzug und Wachetage, Landeplatz und Scanner hervor.
- **Interaktion:** Pixel-Bodenring und Pixelpfeil ersetzen die Vektorkreise und -pfeile in allen Kapiteln; der Pfeil erscheint nur außerhalb der Reichweite. Die Aktionszeile ist ein kompakter Pixel-Chip mit der reinen Handlung.
- **Tower-Flucht:** Die rote Vollfläche ist ersetzt durch Wandbeacons mit rotierendem Reflektor, wanderndem Lichtreflex auf dem Boden und Lauflicht-LEDs zum Ausgang. Der Aufzug wirft beim Öffnen echtes Licht.
- **Ton:** Leise synthetisierte Umgebungsgeräusche pro Ort (Regen, Stadt, Lüftung, See, Netz) mit eigener Stufe „Umgebung: Aus / Leise / Normal“ im Menü.
- **Aerodyne:** Alle Ansichten nutzen denselben Rumpf. Die Düsen in Flug und Landung sind Pixelflammen statt Vektorkreisen.
- **Technik:** Actions laufen auf Node 24. Schnell-Klonanleitung und 5-MB-Bremse für neue Vorschaufilme; der Verlauf wird nicht umgeschrieben.
- Zwei neue CI-Suiten (`story_plan`, `ambient_audio`); alle 35 Suiten und das Repository-Audit ohne Fehler. [Bilder und Details](docs/verbesserungen-v048.md).

## v0.47.1 – ClaudeHelper: Hinterhalt durch Kenzōs Verdacht statt Jackals Telefon · 9. November 2026

- Nutzerkorrektur: Raven würde als guter Hackerin nie ein fremdes Telefon mitnehmen. Die Peilsender-Erklärung aus v0.47.0 ist entfernt.
- Neu vor der Motorradflucht: Ravens Deep Dive in Kenzōs ICE blieb nicht ganz unbemerkt. Kenzō schickt auf bloßen Verdacht Schläger und Soldaten an mehrere mögliche Verstecke. Raven will nicht zugeben, dass ihre Spuren nicht perfekt waren („Er rät nur“); Shadepi: „Dann hat er diesmal richtig geraten.“
- Kenzōs überraschte Begrüßung im Tower passt dazu: Er ließ mögliche Verstecke stürmen und rechnete nicht damit, dass Raven selbst kommt. Story-Durchsicht und AGENTS.md nachgeführt.

## v0.47.0 – ClaudeHelper: Story-Durchsicht Kapitel 1–7, Logikfehler behoben und Szenen verdichtet · 9. November 2026

- Gesamten Storyverlauf gegen Roman und Briefings Teil 4–7 geprüft. Bestätigte Nutzerzeilen und Abläufe unverändert; keine neuen Grafiken, keine geänderte Spielmechanik.
- Logik: Zeitsprung „Am nächsten Abend“ zwischen Kapitel 5 und 6 passend zum geplanten Dienstagabend. Auf dem Dach wird das Biometrie-Log gefälscht statt einer bereits akzeptierten Kennung, und Shadepis zwanzig Sekunden Tarnung beginnen erst an der Tür. Kenzō reagiert überrascht wie im Roman. Die Penthouse-Explosion ist Shadepis angekündigter Plan C, Wachen im Aufzug begründen die Sperrladung, und der Flucht-Countdown zeigt den echten Restwert. Ravens Satz zu ihren Eltern korrigiert; der Maskenkodex wird in Kapitel 5 eingeführt und am See aufgelöst.
- Umsetzungsentscheidung: Jackals Telefon mit Peilsender erklärt den Hinterhalt vor Ravens Versteck. Kenzōs Motiv und sein Auftraggeber bleiben unbekannt.
- Spannender: Shadepis Dachbeobachtung mit fünf Jahren Suche und Wärmesicht, Heiligtum-Unruhe (85 %) während Ravens Deep Dive, Dienstagsplan, „Mensch oder Metall?“ im Hangar, Ravens Reaktionen auf die Erinnerungen, „Du wurdest mir prophezeit“, „Nicht ich töte dich“ und Aufnahmeworte am See nach dem Romanwortlaut.
- Alle 33 CI-Testsuiten und das Repository-Audit ohne Fehler. [Story-Durchsicht mit allen Änderungen](docs/story-durchsicht.md).

## v0.46.2 – CodexAI: Repository ordnen und historischen Bestand eindeutig kennzeichnen · 9. November 2026

- Startseite und Spieleranleitung von Versionschroniken getrennt. Überholte Timing-, Tower- und Comic-Anweisungen durch den aktuellen Ablauf ersetzt; alte Texte vollständig im Entwicklungsarchiv mit Herkunft und Nachfolgern erhalten.
- Verworfene v0.45.0-Helden samt ungenutztem Renderer, frühere Comictafeln und erste GIF-Vorschauen archiviert. Tote Renderer-Verzweigungen entfernt; aktive Originalhelden, Sonderangriffe und Blut-FX erhalten. Keine neue Grafikgenerierung oder Änderung von Original-PNGs.
- Statuskatalog für aktive Quellen, Vergleichsbilder, Backups, Herstellungsquellen und Versionsbelege. Aktive Erinnerung III heißt „legacy/Vermächtnis“ und bleibt erhalten; das Universumsarchiv bleibt verbindlich. Ordner-READMEs und Werkzeug-/Arbeitskatalog ergänzt.
- Archiv vom Godot-Import getrennt; historische Vergleichsbilder und Sicherungen ausdrücklich aus Desktop-Exporten ausgeschlossen. Read-only Repository-Audit für Links, feste Laufzeitressourcen, Versionsfelder und Exportgrenzen in CI ergänzt.
- 1.210 gezielte Regressionen und 31 zusätzliche Exportprüfungen ohne Fehler. Verschobene Quellen und aktive Originalgrafiken bytegleich geprüft; Archiv-/Backup-Ausschluss im tatsächlichen PCK bestätigt.
- [Repository-Status](docs/repository-status.md), [Archiv](docs/archiv/README.md), [Arbeits-/Prüfnachweis](docs/arbeiten/repository-v0462.md). Vorhandene PNG-Vorschauen mit ihrem tatsächlichen Aufnahmestand erhalten.

## v0.46.1 – CodexAI: Original-Sprites für Raven und Shadepi wiederhergestellt · 9. November 2026

- Auf ausdrücklichen Nutzerwunsch automatische Ersetzung der beiden unveränderten Original-Heldenblätter durch `heroes/gameplay` entfernt. Wieder acht Richtungen und acht Phasen je Reihe, Maßstab 0,5 und ursprüngliche lineare Verkleinerung. Nach Sonderposen auch die normale Abtastung zurücksetzen; Heiligtum-Kontaktposen wieder daran angleichen.
- Übrige Fehlerkorrekturen, neue Szenenreaktionen, Sonderangriffe und Bluteffekte erhalten. Keine Änderung der Spielstände oder Custom-Priorität. Verworfene Variante als historische Quelle gekennzeichnet.
- Beide Figurenkarten und vollständige Übersicht mit 23 Figuren erneuert, aktive Konsistenzregeln und PNG-Vorschauen korrigiert. Keine neue Grafikgenerierung. 1.210 gezielte Prüfungen ohne Fehler; Originale und Export zusätzlich nativ geprüft.
- [Aktuelle Originalhelden und Gehfilm](docs/original-helden.md), [Arbeits-/Exportnachweis](docs/arbeiten/original-helden-v0461.md).

## v0.46.0 – CodexAI: Pixel-Blutspritzer und Bodenlachen bei Gegnertreffern · 9. November 2026

- Neue transparente HQ-Pixelquelle mit vier gerichteten Spritzphasen und vier Bodenformen. Blut beginnt am getroffenen Körper; Tropfen fallen auf den Boden, bei Tod wächst eine größere Lache mit dunkler gesetzter Darstellung. Kurz dem tatsächlichen Leichenrutschen folgen, danach ortsfest unter den Figuren bleiben.
- Nur echter positiver Schaden an menschlichen Gegnern einschließlich Cyberware-Trägern. Kein Blut bei Block, Nullschaden oder erneutem Treffen eines Toten; Datenwesen, Erinnerungsbots und Mechs behalten ihre technische Effektfamilie. Vorhandene Trefferwerte, Klänge, Eingaben und Storyfolgen erhalten.
- Eigene Boden-/Luftlagen, begrenzte Mengen und Zusammenführen naher Flecken. 90 Sekunden Lebenszeit mit Ausblenden; Reduziert verringert die Menge. Pause/Terminal frieren die Uhren ein; Laden, Neustart und Abschnittswechsel leeren die Effekte ohne neue Spielstandfelder.
- 992 gezielte Prüfungen und zwölf zusätzliche Prüfungen des exportierten Pakets ohne Fehler. Native Treffer-/Bodenaufnahmen und Film; neue Blut-Regression in GitHub-CI. Versionsfelder und PNG-Vorschauen aktualisiert.
- [Bilder, Regeln und Film](docs/bluteffekte.md), [Quelle/Anker](assets/fx/blood/README.md), [Arbeits-/Exportnachweis](docs/arbeiten/blut-v046.md).

## v0.45.0 – CodexAI: Heldenqualität und zwölf Fehlerpunkte aus dem Spielbericht · 9. November 2026

- Zwei neue Gameplay-Heldenbanken mit je 64 detaillierten Pixelposen, acht Richtungen und vier echten Gehphasen. Tatsächliche Regionen, Sohlen- und Pistolenkontakte pro Pose registriert; stabile Körperhöhe und Abtastung. Originale bytegleich erhalten und zusätzlich gesichert; bestehende Sonderangriffe und Custom-Ersetzungen weiter nutzbar.
- Raven erhält Fall-/Bodenbilder und eine benommene Rückkehr aus den Erinnerungen; Jackal eine eigene Todesfolge. Ersatzposen pausieren und werden bei Rückkehr/Abbruch bereinigt.
- Elektroverteiler/Server behalten ihre sichtbare Gehäusehöhe beim Schadenswechsel; blaue/violette Schützen setzen Raster und Maßstab bei jedem Zustandswechsel zurück. Ravens Weg im Versteck umgeht Wagen und Verteiler.
- Verfolgung endet nur bei gültigem Ausgang der aktuellen Fahrzeuginstanz, mit längerem Siegauslauf oder sichtbarem Ausfall. Garageneinfahrt zeigt Straße; ein Decoder ersetzt die unlogische Hin-/Rücklauf-Aufgabe. See-Gespräch richtet Raven auf Shadepi aus.
- 1.897 gezielte Prüfungen und 20 Prüfungen des exportierten Pakets ohne Fehler. Native Spielansichten und Szenenfilm, neue Regression in GitHub-CI. Keine vollständige manuelle Kampagnen-/Audioabnahme.
- [Bilder, Originalvergleich und Film](docs/fehlerbericht-v045.md), [Arbeits-/Exportnachweis](docs/arbeiten/fehlerbericht-v045.md). Figurenkarten, Konsistenzregeln, PNG-Vorschauen und Versionsfelder fortgeschrieben.

## v0.44.1 – CodexAI: Bodenreflexion im Standbereich der Menüfiguren korrigiert · 9. November 2026

- Helle eingemalte Nässe-Lichtspur und zusätzliche Glanzverstärkung im unmittelbaren Standbereich der vier Stiefel gezielt dämpfen. Gleiche Sohlenanker wie die Kontaktschatten; Transformation der vergrößerten Stadttextur berücksichtigen.
- Quellfarben und dunkle Bodentextur bleiben erhalten, Dachkante begrenzt die Korrektur. Reduzierter Bildstil behält denselben Bodenkontakt. Keine neuen Figurenbilder oder Änderungen der Menüfunktionen.
- 86 bestehende Menü-/Anzeigeprüfungen ohne Fehler. Nativer Vorher/Nachher-Vergleich und direkt aus dem Exportpaket aufgenommene Bilder; Änderungen auf den Boden begrenzt.
- [Aktueller Bildvergleich](docs/menue-kontrollpunkte.md), [Arbeitsnachweis](docs/arbeiten/menue-reflexion-v0441.md). PNG-Vorschauen und Versionsfelder konsistent fortgeschrieben.

## v0.44.0 – CodexAI: Menü-Bodenkontakt, Desktop und gezielte Kontrollpunktauswahl · 9. November 2026

- Vier kräftige Sohlen-Kontaktschatten mit weichem Auslauf und Dachkantenbegrenzung ersetzen die zu schwache Menüebene. Ravens separaten Maßstab berücksichtigen; Figuren und Architektur bleiben fest, Schatten auch bei reduziertem Bildstil sichtbar.
- Haupt- und Pausenmenüs erhalten „Zurück zum Desktop“. „Letzten Kontrollpunkt laden“ findet den neuesten gültigen Stand über Kapitelgrenzen anhand präziser optionaler Speicherzeiten; ältere Dateien über Änderungszeit weiter nutzbar. Einzelspieler-/Koop- und normale/Test-Dateiräume erhalten.
- 40 vorgegebene Test-Kontrollpunkte nach Kapitelwahl: einzelne Jagd-/Hinterhaltabschnitte, Relais, Hangaraufgaben, Erinnerungsknoten, Tower-Kampf/Extraktion/Flucht und See. Vorbedingungen korrekt setzen; kein Überschreiben normaler Spielstände.
- Controller öffnet, wählt und startet Kontrollpunkte; B schließt zuerst die Liste, dann das Testmenü. Start kehrt aus dem Testfenster zum pausierten Menü zurück. Neuer isolierter Save-/Navigationstest in GitHub-CI.
- 1.001 gezielte Prüfungen plus zehn Prüfungen des exportierten Pakets ohne Fehler; Controller-Navigation zusätzlich im nativen Renderer geprüft. Tatsächlicher Desktop-Exit getestet. Native Menü-/Testansichten samt Schattenvergleich und Film in der Doku verlinkt.
- [Bilder, Film und Bedienung](docs/menue-kontrollpunkte.md), [Arbeits-/Exportnachweis](docs/arbeiten/menue-v044.md). PNG-Vorschauen auf Startseite und Doku-Galerie aktualisiert, Versionsnummer und CodexAI-Vermerk fortgeschrieben.

## v0.43.0 – CodexAI: Sichtbarer Kapitel-1-Auftakt und Shadepis Dachauftritt · 9. November 2026

- Acht neue transparente HQ-Pixelposen: Raven erreicht und bedient den Monitor, übernimmt Jackals Auftrag, kontrolliert die Pistole und verstaut sie. Anschließend geht sie tatsächlich zur Tür.
- Shadepi wird in zwei Kauer-/Beobachtungsbildern auf einem regennassen Sims gezeigt; später erkennt er Ravens Notlage. Eigene Kniebeuge- und Aufrichtbilder mit Wasserspritzern ersetzen die bisherige Landung als reine Standpose.
- Tatsächliche Atlasgröße 1774×887, registrierte Boden-/Handkontakte und vergleichbare Heldenhöhe. Vorhandene Kulissen wiederverwendet, normaler Körper samt Schatten bei Kontaktposen versteckt. Lesbare Monitorbestätigung im vorhandenen Pixel-UI.
- Jede neue Szene prüft ihr Generationsticket nach Warteoperationen. Der Filmregisseur weckt bei Abbruch wartende Schritte; Laden und Überspringen hinterlassen keine Figur-/Monitor-/Dachreste. Jagd-/Rettungswellen und Speicherformat bleiben erhalten.
- 1.125 gezielte Prüfungen plus zehn Prüfungen des exportierten Pakets ohne Fehler. Auftakt und Bedrohung/Landung im nativen Spielrenderer aufgenommen; neue Szenen auch direkt aus dem Exportpaket geprüft. Neue Kapitel-1-Regression in GitHub-CI.
- [Spielbilder und zwei Filme](docs/kapitel1-auftakt.md), [Quellen/Anker](assets/story/chapter-one/README.md), [Arbeits- und Exportnachweis](docs/arbeiten/kapitel1-v043.md). PNG-Vorschauen in Startseite und Doku-Galerie ergänzt, Versionen und Stilregeln fortgeschrieben.

## v0.42.0 – CodexAI: Betriebsanimationen und Rückmeldung an technischer Umgebung · 9. November 2026

- Je acht HQ-Pixelphasen für die vorhandenen Schaltkästen und Serverschränke: Lüfter/Messwerk, mechanischer Zugriff, Übertragung, grüne Bestätigung und Störung. Gehäuse, Bodenanker und bestehende Kollisionsflächen bleiben fest.
- Explizit verbundene Statusgeräte reagieren auf bestehende Garage-/Hangar-/Tower-Terminals; keine zufällige Auswahl des nächstgelegenen Dekors. Rätsel und unmittelbare Erfolgs-Callbacks bleiben erhalten. Intakte Geräte animieren im Raum, während Menü und Terminal ihre Uhren anhalten.
- Beschädigte und zerstörte Gegenstände verwenden weiter den passenden vorhandenen Atlas und verlieren ihre Betriebsanimation. Sprite-Raster/Basisposition korrekt zurücksetzen; wiederholte Treffer verursachen keinen Gehäusedrift. Gesundheitszustände bleiben kompatibel gespeichert.
- Abbrechen, Fehler, Laden, Kapitelwechsel und späte Panel-Signale setzen vorübergehende Verbindungen sicher zurück. Zerstörtes optionales Statusgerät blockiert kein Storyrätsel. Neue Prüfung in GitHub-CI.
- 1.069 gezielte Prüfungen und zehn zusätzliche Exportprüfungen ohne Fehler. Tatsächlicher Energiebus-Zugriff und Decoderfehler im Renderer aufgenommen; neue Ressourcen direkt im Exportpaket gesichtet.
- [Aktuelle Spielbilder und Film](docs/technik-gegenstaende.md), [Arbeits-/Exportnachweis](docs/arbeiten/technik-v042.md). PNG-Vorschauen in Startseite und Doku-Galerie aktualisiert, Quellen/Referenzregeln und Versionsfelder fortgeschrieben.


## v0.41.1 – CodexAI: Bildvorschauen und zentraler Doku-Einstieg auf GitHub · 9. November 2026

- Repository-Startseite zeigt aktuelle Fahrzeug-, Verfolgungs-, Hangar- und See-Aufnahmen wieder direkt als anklickbare PNG-Vorschauen.
- Neue [Doku-Galerie](docs/README.md) bündelt bebilderte Berichte, Szenenfilme, Spielanleitung und Stilbibel. Vorhandene Renderer-Aufnahmen mit ihrem Aufnahmestand wiederverwendet; keine neuen Assets oder Gameplay-Änderungen.
- Projektregeln ergänzen die dauerhafte Pflege dieser Vorschauen. Version, Windows-Felder und aktuelle READMEs konsistent fortgeschrieben. Inhalts-/Link-/Versionsprüfung; kein unnötiger neuer Gameplay-Testlauf für diese Dokumentationsänderung.


## v0.41.0 – CodexAI: Verfolgerwagen mit Rückstoß und Frachtdrohnen mit Rotorphasen · 9. November 2026

- Neun neue HQ-Pixelphasen für den dunklen gepanzerten Verfolgerwagen: Geradeausfahrt, zwei Lenkbilder, Federung, Lastverlagerung vor Rammstoß, Geschützrückstoß/-rücklauf und Rammstoß-Erholung. Vier Rotorphasen für die bestehende Frachtdrohne mit festen Ringen und Frachtkörper.
- Rumpf- und Mündungspunkte pro Wagenpose registriert. Das vorhandene Pixel-Mündungsfeuer folgt dem Dachgeschütz. Beide Geschosse des beschädigten Wagens beginnen dort, der zweite fächert danach zum bisherigen Zielabstand auf. Trefferwerte, Intervalle und Angriffsmuster erhalten.
- Minenabwurf samt Impuls folgt dem tatsächlichen Frachtkontakt. Verfolgungsdrohnen und Frachthindernisse im Aerodyne-Flug verwenden dieselbe animierte Quelle; gewolltes Trudeln der gehackten Drohne bleibt unabhängig vom Rotorlauf.
- Controller-RB, Pause, saubere Zustände nach Laden und Kapitelwechsel geprüft. Neue Quellen unverändert kopiert, tatsächliche 418er-/627er-Raster dokumentiert; keine Hochskalierung oder programmgesteuerte Bemalung. Neue Quellen-/Ablaufprüfung in GitHub-CI.
- 799 gezielte Prüfungen und neun zusätzliche Exportprüfungen ohne Fehler. Alle neun Wagen-/vier Rotorbilder im tatsächlichen Renderer erreicht; Schuss und Luftfrachtquelle direkt aus dem Exportpaket gesichtet.
- [Spielbilder und Film](docs/verfolger-animationen.md), [Arbeits- und Exportnachweis](docs/arbeiten/verfolger-v041.md). Stilbibel und Cinema-Roadmap aktualisiert; Version und Windows-Felder fortgeschrieben.


## v0.40.0 – CodexAI: Eigene Fahrzeug-Kurvenlagen und Motorrad-Fahrposen · 9. November 2026

- Vier eigene Aerodyne-Bankansichten und Luftbremsbild ergänzen die bestehende mechanische Kabinen-/Triebwerksquelle. Material, Cockpit und Triebwerksidentität erhalten. Bildlagen folgen tatsächlicher Lenkung, Ausweichphase und Bremsen; eigene Cockpit-/Düsenanker pro Ansicht.
- Acht aktive Motorradposen für Geradeausfahrt, leichte/starke Links-/Rechtslage, Bremsen und Federungsbewegung. Shadepi vorne und Raven hinten bleiben konsistent. Hinterer Reifenkontakt bleibt fest auf dem Asphalt; Turbo-FX folgen den jeweiligen Auspuffpunkten.
- Kurvenlage ist von Heading getrennt und in Flug, Landung, See-Anflug und Tower-Abfangen eingebunden. Kabinenöffnung setzt Rumpf und Düsen sofort zum geraden mechanischen Satz zurück. Pause, Controller und Laden geprüft; keine Umbelegung oder Änderung der Kampf-/Kollisionsregeln.
- Erste matte Aerodyne-Quelle gezielt freigestellt; die aktive korrigierte PNG unverändert übernommen. Tatsächliche Motorrad-Zellgröße dokumentiert, zusätzlicher Schussentwurf ausdrücklich nicht aktiv. Klare Pixelphasen ersetzen durchsichtige Silhouettenüberblendungen.
- 856 gezielte Prüfungen und zehn zusätzliche Exportprüfungen ohne Fehler. Motorrad-/Flugbewegung im Renderer aufgenommen, tatsächliche See-Ankunft und Tower-Flucht durchlaufen.
- [Spielbilder und Filme](docs/fahrzeugbewegung.md), [Prüf- und Exportnachweis](docs/arbeiten/fahrzeugbewegung-v040.md). Neue Prüfung in GitHub-CI; Version, Exportfelder, Stilbibel und Roadmap aktualisiert. Weitere Verfolger-/Drohnen-/Fahrwerkssätze bleiben Folgeblöcke.


## v0.39.0 – CodexAI: Sichtbare Plattformfahrt und Hangar-Enthüllung · 9. November 2026

- Zweiter Cinema-Block: vier HQ-Pixelposen für Shadepis Werkbankschalter, sechs tatsächliche Entriegelungsbilder und eine texturierte Schachtkulisse. Figuren und Motorrad fahren gemeinsam sichtbar nach unten; Andocken und Hallenöffnung ersetzen die beschriebene Schwarzblende.
- Die Kameraprojektion bleibt beim Andocken erhalten. Erst Halle und Aerodyne zeigen, danach Ravens Reaktion; gemeinsame freie Laufwege und Shadepis Abgang zum Kompensator. Reparatur- und Kennungsrätsel bleiben spielbar.
- Normaler Erkundungs-Hangar und Enthüllung verwenden nun denselben Aerodyne wie Flug/Flucht/See. Geschlossener unterirdischer Dachbereich, KOBAN-TEC-Marke, dauerhafte Plattform und geparktes Motorrad; Kisten/Fässer außerhalb der Ankunftsfläche, vorhandene Speicher-IDs bleiben gültig.
- Unterbrochene Entdeckung kompatibel speichern und wiederholen, abgeschlossene oder ältere Hangarstände ohne Wiederholung laden. Tatsächliche Figuren vor Abbruch/Kapitelwechsel aus der Filmansicht lösen; Pause und Controller-Skip geprüft. Neue Ablaufprüfung in GitHub-CI.
- 841 gezielte Prüfungen und zehn zusätzliche Exportprüfungen ohne Fehler. Schalterkontakt, Fahrt, tatsächliches Andocken und vollständige Übergabe im Renderer aufgenommen; geschlossener Hangar und Reparaturzugang auch aus dem exportierten Paket gesichtet.
- [Spielbilder und zusammenhängender Film](docs/hangar-entdeckung.md), [Arbeitsnachweis und Exportprüfung](docs/arbeiten/hangar-v039.md). Version und Windows-Datei-/Produktfelder fortgeschrieben; Stilbibel, Konsistenzvorlage und Cinema-Roadmap aktualisiert.

## v0.38.0 – CodexAI: Ravens Eisbad, sichtbare Rückkehr und Kryospray-Rettung · 9. November 2026

- Erster nächster Cinema-Block in Kapitel 2: acht neue HQ-Pixelposen für Anschluss, Absenken, Ruhe im Wasser, Rückkehr, Erschöpfung und gestützte Kryospray-Behandlung. Vorhandene Wanne und vordere Wasser-/Randfläche verdecken eingetauchte Körperteile; texturiertes Kabel an Pumpen- und Kragenkontakt. Shadepi wartet auf freiem Boden neben dem Becken.
- Sprayholen bleibt ein Spielerabschnitt. Raven sitzt sichtbar erschöpft am Rand; Behandlung beginnt nach dem Zurückbringen. Stützen und tatsächlicher Sprühkontakt ersetzen eine allgemeine Angriffsgeste. Normale Körper und Kontaktschatten während Ersatzposen vollständig ausgeblendet; nach Aufstehen oder Abbruch wiederhergestellt.
- Aufgenommenes Spray und unterbrochene Anschluss-/Rückkehr-/Behandlungsszenen werden kompatibel gespeichert. Alte/ungültige Felder sicher behandelt. Bestehende Kenzō-/Minotaurus-Informationen und der anschließende Pakt bleiben erhalten.
- Nachträgliche Aktionen alter Kapitel-2-Szenen nach Laden/Wechsel durch Generationstickets unterbunden. Neue Sicht-/Ablaufprüfung deckt auch den vollständigen Zeichenrahmen für zurückgelehnte Köpfe/Haare und saubere Atlaszuschnitte ab.
- 792 gezielte Prüfungen und neun zusätzliche Exportprüfungen ohne Fehler. Einstieg und vollständige Rückkehr-/Spray-Rettungsfolge im tatsächlichen Renderer aufgenommen; Wasser-/Behandlungsdarstellung auch aus dem exportierten Spielpaket gesichtet.
- [Spielbilder, Filme und Bedienung](docs/eisbad.md), [Arbeitsnachweis](docs/arbeiten/eisbad-v038.md). Roadmap um erledigten Kapitel-2-Block ergänzt; Kapitel 4 bleibt der nächste Block.

## v0.37.0 – CodexAI: Kapitel-7-Musik, Aerodyne-Sprites und Cinema-Roadmap · 9. November 2026

- Beide Kapitel-7-Musikslots verwenden jetzt `assets/music/menu.mp3`. Das Hauptmenü behält `Level.mp3`; Kampf- und Bosszuordnung bleiben erhalten. Aktuelle Musikdokumentation und Regressionserwartung angepasst.
- Neuer transparenter HQ-Aerodyne-Atlas mit sechs mechanischen Bildern: Kabine geschlossen/öffnend/halb offen/offen und zwei Triebwerksphasen. Gemessene Rumpfanker gleichen unterschiedliche Zellränder aus; gemeinsame tatsächliche Düsenzentren für Rumpf und Abgasprojektion.
- Gemeinsame Quelle für bewegten und geparkten Aerodyne, spielbaren Flug und filmische Start-/Landeszenen. Kabine öffnet vor dem Ein-/Aussteigen und schließt danach in Hangar, Tower-Flucht und am See; Pause, Skip und Kapitelwechsel erhalten. Echte neue Flugwinkel und das eingemalte Erkundungs-Hangarschiff bleiben weiterer Bedarf.
- Abläufe und Ressourcen aller sieben Kapitel inklusive Erinnerungen geprüft; zusätzliche Renderer-Stichproben aller Kapitel sowie vollständige Tower-/Hangar-Szenen. [Priorisierte Cinema-/Sprite-Roadmap](docs/cinema-roadmap.md) benennt konkrete Szenen, Bildbedarfe und Abnahme. Große vorgeschlagene Szenenumbauten sind noch nicht umgesetzt.
- 811 gezielte Prüfungen und elf zusätzliche Exportprüfungen ohne Fehler. Neue Rumpfquelle, spielbare Flugansicht und tatsächliche Kapitel-7-Musikstreams auch aus dem exportierten Spielpaket geprüft.
- [Aktueller Arbeitsnachweis](docs/arbeiten/cinema-v037.md), [Fahrzeugquelle](assets/vehicles/aerodyne/README.md) und tatsächliche Spielbilder/Technikfilm in der Roadmap. Neue 30-Fälle-Fahrzeugprüfung im GitHub-Build.

## v0.36.1 – CodexAI: Ravens rechte Hand an der Maske, linke am Gesicht · 9. November 2026

- Handführung der beiden See-Kontaktposen korrigiert: Raven hebt die abgenommene Maske mit ihrer eigenen rechten Hand; ihre eigene linke Hand berührt und verdeckt Shadepis Gesicht. Dieselbe anatomische Zuordnung gilt im Kuss. Gesicht, Kasa und Kostüme bleiben konsistent.
- Bestehenden HQ-Atlas gezielt nachbearbeitet; Zellformat, Fußanker und Szenenablauf bleiben erhalten. Figurenvertrag und Archivpräzisierung dokumentiert. Galerie kann das Finale für gezielte Sichtprüfungen separat durchlaufen.
- 32 gezielte Seeprüfungen und acht zusätzliche Exportprüfungen ohne Fehler. Gesamtes Finale mit korrigierter Handführung im tatsächlichen Renderer durchlaufen und gefilmt; Kontaktpose auch aus dem exportierten Paket gesichtet.
- [Aktuelle Bilder und Film](docs/see-finale.md), [Arbeitsnachweis](docs/arbeiten/see-haende-v0361.md).

## v0.36.0 – CodexAI: See-Anflug, Aussteigen und romantisches Finale · 9. November 2026

- Neuer tatsächlicher Aerodyne-Anflug über den Mondscheinsee: weite Ansicht, stetige Annäherung, Kamerafahrt zur freien Uferfläche und weiches Aufsetzen auf trockenem Gras. Derselbe HQ-Fahrzeug-/Düsenrenderer bleibt erhalten. Raven und Shadepi steigen nacheinander aus dem seitlichen Kabinenbereich und gehen sichtbar zum Wasser; das geparkte Schiff bleibt dort mit Bodenkollision stehen.
- Neues kontaktgebundenes HQ-Pixelblatt mit Händehalten, Ravens Maskenabnahme, Kuss und anschließender maskierter Umarmung. Kasa-Breite und Ravens Proportionen gegen normale Spielfiguren geprüft. Ravens Hand, der Kasa und der abgewandte Kopf verdecken Shadepis Gesicht in allen maskenlosen Posen; kein vollständig sichtbares Porträt. Die konkrete Nutzerbeschreibung ersetzt die frühere erzählte Gesichtsenthüllung.
- Kurzer texturierter Drachenschatten auf dem See und bewegtes mystisches Leuchten. Beide bleiben auf die tatsächliche Wasserfläche beschnitten und verwenden eine anhaltbare Szenenuhr. Keine Comic-Einblendung oder neue Behauptung über die Identität des Drachen.
- Natürlichere Dialoge mit freiwilliger Ordensaufnahme vor dem Maskenmoment; die offene Suche nach Kenzōs Auftraggeber bleibt erhalten. Die Musikzuordnung bleibt unverändert.
- Ein kompatibles Speicherfeld unterscheidet laufende und abgeschlossene Seeszenen. Laden einer unterbrochenen Szene beginnt diese erneut; ältere Anfangs-/Endspielstände erhalten die neue Szene einmal. Pause, Controller-B, Abbruch und Wiederherstellung von Sichtbarkeit/Deckkraft/Tiefenreihenfolge geprüft.
- 920 gezielte Prüfungen und acht zusätzliche Exportprüfungen ohne Fehler. Ankunft und Finale im tatsächlichen Godot-Renderer durchlaufen und gefilmt; Kontaktgrafik auch aus dem exportierten Spielpaket gesichtet.
- [Spielaufnahmen](docs/see-finale.md), [Assetquellen](assets/story/lake/README.md) und [Konsistenznachweis](docs/arbeiten/see-finale-v036.md).

## v0.35.1 – CodexAI: Tower-Abflug vom Landeplatz, Fall am Balkon vorbei · 9. November 2026

- Räumlichen Fehler der v0.35.0-Flucht ersetzt: Rennen, Einsteigen und Abheben finden auf dem tatsächlichen Dach-Landeplatz statt. Der Aerodyne steht an seinem Aufsetzpunkt aus dem spielbaren Anflug.
- Erst nach dem Abheben fällt der Antrieb aus. Das Schiff verlässt die Dachkante; danach folgt der Blick auf die Fassade darunter. Es kommt von oberhalb des Bildes, rauscht am Balkon vorbei und fängt sich unterhalb der Balkonebene ab. Erst beim Wegflug explodiert das Penthouse.
- Derselbe Fahrzeugknoten und Düsenrenderer bleiben erhalten. Der Blickwechsel übernimmt Bildgröße, Orientierung und projizierte Fallgeschwindigkeit. Die anschließenden Kurven bleiben stetig; während des Falls wartet kein Dialog auf Eingabe.
- Neues optionales Speicherfeld für den tatsächlichen Abstellpunkt; ältere oder ungültige Einträge verwenden sicher den ursprünglichen Landeplatz. Die Penthouse- und Hangarverbesserungen bleiben erhalten.
- 731 gezielte Prüfungen und sieben zusätzliche Exportprüfungen ohne Fehler; die vollständige Flucht im Renderer gesichtet und als Film aufgenommen.
- [Aktuelle Spielbilder, Film und gezielte Abnahme](docs/tower-inszenierung.md), [Arbeitsnachweis](docs/arbeiten/tower-landeplatz-v0351.md).

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
