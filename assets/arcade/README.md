# Arcade- und Materialgrafiken · v0.61.0 · CodexAI

**15. November 2026.** Neue Grafiken wurden mit dem Bildgenerator anhand aktiver Spielreferenzen erstellt und anschließend registriert. [Herstellungsquellen](../../tools/art-v061/README.md) · [Arbeitsnachweis](../../docs/arbeiten/arcade-begleiter-v061.md).

| Quelle | Aktiver Vertrag |
| --- | --- |
| `fighters/<id>.png` | Zehn eigene Arcade-Blätter, jeweils 2048×1280, 4×4 Zellen à 512×320. Anker (224,288), Maßstab 0,5; alle Körper vollständig mit transparentem Rand. Originale in `sprites/heroes/` und `sprites/npcs/` bleiben unabhängig. |
| `fighters/atlas.json` | Posenreihenfolge, tatsächliche Quellausschnitte, Registrierung, Figurenmaßstab und eigene Hand-/Mündungsanker. Im Export enthalten. |
| `cabinet-hq.png` | Aktiver materialreicher Automat in der Halle; unveränderte Kollision und Benutzungsposition. |
| `props-fx-hq.png` | 1024×1024, 4×4 Zellen à 256×256: Zeile 0 Bake/Mine/Öl/Boost; Zeile 1 Cyanblitz/Patronenspur/Violettplasma/Kontaktschatten; Zeile 2 vier Trefferphasen; Zeile 3 vier EMP-Phasen. Verwendet von Arcade, Begleitern und Fahrabschnitt. |
| `stage-rooftop.webp` | Vorhandene Dachbühne bleibt aktiv. |
| `cabinet.png`, `sparks.png` | Frühere kleine Quellen aus v0.57.0 · ClaudeHelper; nur Referenz, nicht mehr geladen und vom Export ausgeschlossen. Der alte Generator ist kein Wiederherstellungswerkzeug für die neue Grafik. |

Liegende Posen sind gezeichnete Körperzustände. Kein Drehen eines Standbilds, kein Einfärben als Ersatz für Block. In `_frame()` passen Ausholen, Kontakt und Rücknahme zu denselben Zeiten wie die Trefferlogik. Die Figurenwahl nutzt Ausschnitte aus dem neuen Bereitschaftsbild.
