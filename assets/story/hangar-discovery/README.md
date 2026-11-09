# Plattformfahrt und Hangar · v0.39.0 · CodexAI

Drei unverändert übernommene PNG-Quellen aus direkter HQ-Pixelgenerierung mit den aktiven Garagen-, Hangar- und Figurenreferenzen. Keine programmgesteuerte Bemalung, keine neu erfundene Fahrzeug- oder Figurenidentität. Metall, Beton, Abnutzung und lokale Cyan-/Amberleuchten passen zur bestehenden Werkstattfamilie. Raven bleibt 160 cm groß; während der Fahrt werden die tatsächlichen normalen Figuren und das vorhandene geparkte Motorrad verwendet.

| Quelle | Inhalt / tatsächliche Registrierung |
| --- | --- |
| `platform.png`, 1536×1024 RGBA | Sechs 512×512-Zellen in drei Spalten, zwei Reihen. 0 verriegelt bis 5 vollständig entriegelt; Bolzen bewegen sich tatsächlich. Gemeinsamer Ausschnitt `(16,80,480,350)` je Zelle. Weltrechteck Garage `(740,320,270,185)`, Hangar um `(-578,+24)` versetzt. Alpha außerhalb der Konstruktion; komplette Latch-Kanten erhalten. |
| `shaft.png`, 1024×1536 | Durchgehende texturierte Schachtkulisse, feste Schienen und Seitenwände. Während der Abfahrt fährt die Wand relativ zur Plattform nach oben; beim Andocken öffnet sich der Blick in die Halle. Keine eingemalten Figuren oder zweite Plattform. |
| `switch.png`, 1536×1024 RGBA | Vier 768×512-Zellen, zwei Spalten/Reihen: Ruhe, Hinlangen, Drücken, Zurücknehmen. Shadepis Maske/Kasa/Weste/Schal und Stoffbahnen erhalten. Gemeinsamer Fußanker `(380,488)`, Maßstab 0,125; tatsächlicher Druckfinger in Zelle 2 bei `(531,88)`. Weltfuß `(720,296)`, Kontakt `(738.875,246)` am verdeckten Werkbanksymbol. |

`hangar_art.gd` ist die gemeinsame Geometriequelle. Beim Wechsel der Szenenkoordinaten wird die tatsächliche Garagenprojektion übernommen, einschließlich ihrer Kamerabegrenzung. Erst beim Öffnen der Halle fährt die Kamera weich auf die Hangarprojektion. Beide Figuren bleiben dieselben Nodes und werden vor dem Entfernen der Filmansicht wieder in die Spielwelt umgehängt; Laden, Abbruch und Skip berücksichtigen das.

Die Halle verwendet die vorhandene `departure/hangar-empty.png` mit dem **geschlossenen Dachbereich** aus der ursprünglichen `painted/hangar.png`. Das offene Dach gehört erst zum späteren Abflug. Der KOBAN-TEC-Aufnäher wird zuletzt gezeichnet. Das historische eingemalte Fluggerät ist im aktuellen Hangar nicht aktiv: Erkundung und Filmansicht verwenden denselben sechsphasigen Aerodyne aus `vehicles/aerodyne/airframe.png` wie Flug/Flucht/See. Vor der Reparatur ruht er abgeschaltet. Kisten und Fässer stehen außerhalb der Plattform und der gemeinsamen Ausstiegsroute; ihre Speicher-IDs bleiben erhalten.

[Szenenbilder und Film](../../../docs/hangar-entdeckung.md) · [Arbeitsnachweis](../../../docs/arbeiten/hangar-v039.md).
