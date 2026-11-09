# Fahrzeuge und Requisiten · v0.32.2 · CodexAI

**Technische Umgebung v0.42.0 · CodexAI:** [Bewegte Schaltkästen und Serverschränke](../technik-gegenstaende.md) mit festen Bodenankern aus `technology_art.gd`. Nur oberhalb halber Lebenspunkte neue Betriebsphasen; darunter die passenden alten Schadensbilder mit vollständig zurückgesetztem Sprite-Raster verwenden. Zugriff nur an explizit verbundenen Statusgeräten, keine neue Storysperre. Menü/Terminal frieren die Uhren ein; Abbruch/Laden/Wechsel lösen Referenzen und Generationstickets verhindern späte Rückmeldungen. Neue PNG-Vorschauen in Root-README und Doku-Galerie erhalten.

**Verfolgung v0.41.0 · CodexAI:** [Neun Wagenbilder und vier Frachtdrohnen-Rotorphasen](../verfolger-animationen.md). Tatsächliche Zellgrößen 418 beziehungsweise 627; gemeinsame Rumpf-/Mündungs-/Abwurfkontakte in `pursuit_car_art.gd` und `cargo_drone_art.gd`. Schusszustand vor Bestimmen der Mündung setzen; Pixel-Feuer bleibt an der bewegten Mündung. Beschädigter Wagen fächert den zweiten Schuss erst nach Austritt auf. Rotorlauf unabhängig vom Trudeln einer gehackten Drohne; Pause und Kapitelbereinigung erhalten.

**Fahrzeugbewegung v0.40.0 · CodexAI:** [Aerodyne-Kurvenlagen und Motorrad-Fahrposen](../fahrzeugbewegung.md). Separate Banklage von bisherigem Heading unterscheiden. Hinterer Reifenkontakt und Düsenpunkte je Quellbild sind fest registriert; keine transparenten Überblendungen verschiedener Silhouetten. Offene Kabine verwendet sofort wieder mechanischen Rumpf und passende gerade Düsenanker. Motorradquelle besitzt tatsächlich 418×418-Zellen; nur acht der neun Entwurfszellen sind aktiv.

**Aktualisierung v0.39.0 · CodexAI:** [Plattformfahrt und Hangarentdeckung](../hangar-entdeckung.md), vier eigene Shadepi-Schalterposen, sechs Entriegelungsbilder und texturierter Schacht. Fahrt mit den tatsächlichen Figuren; danach identischer Aerodyne in normaler Erkundung und Film. [Aktive Quellen und Kontaktanker](../../assets/story/hangar-discovery/README.md).

[Stilbibel](README.md) · [Art Direction](artdirection.md) · [Welten](welten.md)

## Fahrzeuge

**Ausbau v0.37.0 · CodexAI:** Der aktive bewegte Aerodyne verwendet jetzt einen [gemeinsamen Atlas mit sechs Rumpfbildern](../../assets/vehicles/aerodyne/README.md): Kabine geschlossen/öffnend/offen und Triebwerksphasen. [Aktuelle Sichtprüfung und weiterer Spritebedarf](../cinema-roadmap.md). Die folgende alte Fahrzeugtafel bleibt als Herkunftsreferenz für das ursprüngliche Einzelbild erhalten.

![Vorhandene Fahrzeugansichten](bilder/fahrzeuge.png)

Die Tafel zeigt vorhandene Quellbilder zur Form-/Materialerkennung, **keinen gemeinsamen Weltmaßstab**. Im Spiel werden Top-down-Verfolgung, Flug, Landung und Garagenobjekte unterschiedlich groß und mit unterschiedlichen Kameras gezeichnet.

| Objekt | Identität / Bildmerkmale | Aktive Quelle und Darstellung |
| --- | --- | --- |
| **Aerodyne** | Gepanzertes dunkles Fluggerät, sichtbares Cockpit, technische Fugen und Düsen; Lichtakzente passend zum Systemzustand. | [airframe.png](../../assets/vehicles/aerodyne/airframe.png), sechs mechanische Zustände plus [banks.png](../../assets/vehicles/aerodyne/banks.png) für Kurven/Luftbremse über [aerodyne_art.gd](../../scripts/aerodyne_art.gd); ursprüngliche Identität aus Zelle 0 von `vehicles.png`. |
| **Verfolgerauto** | Dunkler gepanzerter Wagen, klare Dach-/Motorflächen und Rücklichter; eigene breite Silhouette. | [car.png](../../assets/vehicles/pursuit/car.png), neun registrierte Phasen über [pursuit_car_art.gd](../../scripts/pursuit_car_art.gd); ursprüngliche Identität aus Zelle 1 des alten Atlas. |
| **Motorrad mit Shadepi und Raven** | Rotes/dunkles Motorrad; Fahrer mit Kasa und maskiertem Kopf, Raven mit schwarz-blauem Haar und Cyan-Ausrüstung. Beide gehören sichtbar zum Motorrad, keine beliebigen generischen Fahrer. | [riding.png](../../assets/vehicles/motorcycle/riding.png), acht aktive Fahrposen über [motorcycle_art.gd](../../scripts/motorcycle_art.gd); ursprüngliche Identität aus Zelle 2 des alten Atlas. |
| **Drohne** | Kompakter technischer Körper mit vier deutlich erkennbaren Rotoren. | [drone.png](../../assets/vehicles/pursuit/drone.png), vier Rotorphasen über [cargo_drone_art.gd](../../scripts/cargo_drone_art.gd); gleiche Quelle in Verfolgung und Frachthindernissen. Größe und Warn-/Angriffsflächen nach Flug-/Fahrmodus. |
| **Geparktes Motorrad** | Eigenständige Variante ohne Fahrer; dieselbe rote/dunkle Materialfamilie. | [bike-parked.png](../../assets/world/hq/bike-parked.png), Garage und Weltobjektdarstellung. |

### Historischer Aerodyne-Unterschied

| Hangar-/Abflugdarstellung | Flug-/Dachdarstellung |
| --- | --- |
| ![Aerodyne beim Abflug](../previews/bericht8-abflug.png) | ![Aerodyne nach der Landung](../flug-dach.png) |

Die Bilder in dieser historischen Vergleichstabelle zeigen den früheren Unterschied. Seit v0.35.0 nutzt der filmische Hangar-Abflug denselben Fahrzeugrenderer wie die Tower-Flucht; ab v0.37.0 verwenden diese, Flug, Landung und See den gemeinsamen animierten Atlas. **Seit v0.39.0 ist auch das eingemalte Schiff im Erkundungs-Hangar ersetzt.** Der identische animierte Rumpf steht separat auf dem freien Hallenboden. v0.40.0 ergänzt vier Kurvenlagen und eine Luftbremsansicht. Vollständige Seiten-/Unterseiten-/Fahrwerksansichten stehen weiterhin in der [Roadmap](../cinema-roadmap.md).

## Neun Weltobjekte in allen drei Zuständen

Alle folgenden Tafeln benutzen denselben **Weltmaßstab ×1,5**, einschließlich Raven als Vergleich. Sie verwenden die tatsächliche `PropArt.apply()`-Darstellung und deren Zustandsskalierung; die Zellaußenmaße allein sind keine Objektgröße. Die normale Standfigur darf neben einem Container nicht plötzlich wie eine Miniatur wirken.

![Kisten, Fässer und Laternen](bilder/requisiten-1.png)

![Autos, Container und Elektrokästen](bilder/requisiten-2.png)

![Automaten, Serverschränke und Datenspeicher](bilder/requisiten-3.png)

| Typ / Atlas-Spalte | Soll-Silhouette und Material | Angezeigter intakter Zielrahmen in Weltpixeln |
| --- | --- | --- |
| Kiste / 0 | Glaubhaftes Frachtobjekt mit Materialkanten, räumlicher Oberseite und passender Bodenfläche. | 54 × 58 |
| Fass / 1 | Zylindrischer Behälter mit Ringen und erkennbarem Volumen. | 44 × 58 |
| Laterne / 2 | Hohe schlanke Lichtquelle; Licht gehört an den Leuchtenkopf. | 74 × 111 |
| Geparktes Auto / 3 | Langer niedriger Wagen mit Rädern und lesbarer Karosserie. | 160 × 74 |
| Müllcontainer / 4 | Breiter niedriger Metallbehälter mit Deckel, Kanten und klarer Bodenauflage. | 104 × 70 |
| Elektrokasten / 5 | Technisches Gehäuse mit Scharnier, Warn-/Bedienelementen und Metalloberfläche. | 52 × 74 |
| Getränkeautomat / 6 | Aufrechter Automat mit Frontfeldern; nicht dieselbe Silhouette wie ein Müllcontainer. | 59 × 79 |
| Serverschrank / 7 | Hohes technisches Gehäuse mit Geräte-/Lüftungsfront. | 56 × 78 |
| Datenkristall / 8 | Virtuelles Speicher-/Kristallobjekt mit eigener leuchtender Formensprache. | 67 × 69 |

Diese Werte beschreiben den aktuellen Zeichenrahmen aus [PropArt](../../scripts/prop_art.gd), keine Lore-Maße. Kollisionsflächen stehen getrennt in [WorldProp.TYPES](../../scripts/world_prop.gd). Transparente Ränder und Perspektive beeinflussen den sichtbaren Umriss.

## Zustand und Kontakt erhalten

- Intakt, beschädigt und zerstört gehören zu demselben Objekt. Rost/Farbe, Hauptsilhouette und Standpunkt beim Übergang wiedererkennbar halten.
- Trümmer liegen auf der bisherigen Bodenfläche, nicht in ursprünglicher Schrankhöhe. Der bestehende Renderer flacht Zeile 2 bereits ab.
- Kollisionszustand, Lampenlicht und Trefferfeedback müssen zum sichtbaren Zustand passen. Ein kaputter Kasten darf nicht unverändert beleuchtet oder unsichtbar kollidierend bleiben.
- Verdeckungen und Weltpositionen nach [world_dressing.gd](../../scripts/world_dressing.gd) und der tatsächlichen Szene prüfen. Ein vorhandener Layoutname wird nicht automatisch in jeder Szene verwendet.
- Quelle ist [assets/world/hq/props.png](../../assets/world/hq/props.png) mit den Ausschnitten aus `PropArt`. Ältere `assets/world/props.png`-/`destructibles.png`-Bestände nicht allein anhand des Dateinamens als aktive HQ-Vorlage wählen.
