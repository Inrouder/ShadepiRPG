# Verfolgerwagen · v0.65.0 · CodexAI

`car.png` bleibt die unveränderte aktive Quelle der normalen Fahrt (neun 418×418-Phasen). `drone.png` bleibt die bestehende Drohnenquelle.

**Neu: `rollover.png`**, unveränderte transparente Bildgenerator-Ausgabe vom 16. November 2026, mit `car.png` als tatsächlich gesichteter Identitäts-/Materialreferenz. 1536×1024, Raster 3×2, sechs 512×512-Zellen: Ankippen, angehobene Seite/Räder, Seitenlage, weiterer Überschlag, Unterboden, zerstörte Dachlage. Dunkle Panzerung, cyanfarbene Scheibe, rote Rückleuchten und Dachwaffe gehören weiterhin zu demselben Wagen. Keine Flammen oder Schatten als Ersatz für Körperphasen; diese kommen separat aus bestehenden Spiel-FX.

Ausschnitte, individuelle Kontaktanker und unveränderte Welt-Zeichenfläche 112×96 stehen in `scripts/pursuit_car_art.gd`. Alle Zellen besitzen transparenten Freiraum; tatsächliche Alpha-/Schnittprüfung über `tools/sprites/audit_atlases.py`, Registrierung in `atlas_regions.py`. Kein starres Drehen einer einzelnen Draufsicht als Überschlagsersatz. [Arbeitsnachweis](../../../docs/arbeiten/cinema-v065.md).

`wreck.png` ist die frühere einzelne Wrackansicht aus v0.56.0: **Referenz/Sicherung, nicht mehr aktiv und vom Spieleexport ausgeschlossen.** Der historische `tools/fx/build_drive_fx.py` kann sie erzeugen; er erzeugt oder ersetzt den neuen Überschlagsatlas nicht. Alte Herstellungswerkzeuge nicht beim Setup ausführen.

## Bestehende Normalphasen und Drohne · v0.41.0 · CodexAI

Beide Quellen sind direkte HQ-Pixelgenerierungen mit den tatsächlich aktiven Einzelbildern aus `assets/world/hq/vehicles.png` als Bildreferenz. Unverändert kopierte PNGs, keine programmgesteuerte Bemalung/Freistellung, keine neue Fahrzeugidentität. Dunkle Panzerung, verschlissene Metallkanten, Cyan-Scheibe, Dachgeschütz und rote Rücklichter des Wagens bleiben erhalten; die Frachtdrohne behält orange Last, vier Rotor-Ringe und Cyan-Akzente. Die separate bewaffnete Tower-Sentry bleibt ein anderes vorhandenes Objekt.

**Tatsächliche Quellgrößen:** Beide PNGs sind 1254×1254. Der Wagen hat neun Zellen à 418×418; die Drohne vier à 627×627. Das angeforderte Raster wurde vom Generator anders ausgegeben; nicht blind nominelle 512er-Zellen schneiden oder durch Hochskalieren angeblichen Detailgewinn erzeugen. Beide Quellen haben echten transparenten Außenraum, die Drohne auch zwischen den Rotorblättern.

| Wagenzelle | Sichtbare Phase |
| --- | --- |
| 0 | Gerade, ruhende Aufhängung |
| 1 / 2 | Links-/Rechtslenkung mit sichtbaren Vorderrädern und Gewichtsverlagerung |
| 3 / 4 | Einfedern / Rückfedern |
| 5 | Vorderachslast vor dem Rammstoß |
| 6 / 7 | Eingezogener Geschützlauf / Rücklauf |
| 8 | Rammstoß-Rückfederung |

`pursuit_car_art.gd` enthält die Rumpfanker im Hinterachsenbereich, Mündungspunkte und den gemeinsamen Bezug der Hinterachsen. Zielrahmen 112×96 Weltpixel inklusive transparentem Rand; sichtbare Karosserie ungefähr 47×82 gegenüber zuvor etwa 44×64. Der Wagen wirkt dadurch länger als das Motorrad und behält einen glaubhaften Abstand beim normalen Folgen. Die Lenk-/Ramm-/Trefferregeln wurden nicht auf neue Quellpixel umgerechnet. Bei Schüssen zuerst den Rückstoßzustand setzen, dann Mündung aus demselben Bild bestimmen. Feuerblitz verwendet den bereits vorhandenen Pixelatlas `assets/fx/muzzle.png` und bleibt bei Fahrzeugbewegung an der Mündung. Zwei Geschosse des beschädigten Wagens starten dort gemeinsam und fächern danach zum bisherigen 16-Pixel-Zielabstand auf; kein seitlich teleportierter zweiter Schuss.

Die Drohne verwendet vier Rotorbilder bei 18 Bildphasen pro Sekunde. Frachtkörper, Ringe, Arme und Rotorzentren bleiben fest; Blätter wechseln ihre Winkel. `cargo_drone_art.gd`: Mitte `(316,304)`, Rotorzentren `(134,134)`, `(500,134)`, `(134,464)`, `(500,464)`, Abwurfkontakt `(316,473)`. Der vorhandene Minenabwurf folgt diesem Kontakt. Derselbe Atlas wird für Verfolgungsdrohnen und fliegende Frachthindernisse genutzt. Ein gehacktes Fluggerät behält sein gewolltes Trudeln; dieses ist unabhängig vom weiterlaufenden Rotorbild. Uhr pausiert mit Menü oder Terminal.

[Spielbilder und Film](../../../docs/verfolger-animationen.md) · [Arbeitsnachweis](../../../docs/arbeiten/verfolger-v041.md).
