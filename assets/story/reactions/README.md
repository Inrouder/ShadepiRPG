# Fall-, Boden- und Erholungsbilder · v0.45.0 · CodexAI

`poses.png`: unveränderte transparente Bildwerkzeugquelle, **1774×887**. Original `/workspace/generated_images/exec-087d89b8-9a9e-440b-9807-ddd5b9dd42c1.png`. Raven-Referenz aus Kapitel 1, Jackals aktive Figurenkarte; beide tatsächlich gesichtet.

| Pose | Verwendung |
| --- | --- |
| 0–2 | Raven: Knie einknicken → seitlicher Fall → bewusstlos seitlich auf dem Boden; kein Tod. |
| 3 | Raven hält sich benommen den Kopf, bevor sie aus der Erinnerung zurücktritt. |
| 4–7 | Jackal taumelt → kniet → fällt zur Seite → bleibt tot liegen. |

Ausschnitte und Kontaktanker sind in `scripts/actor_reaction.gd` registriert. Paar-/Liegebilder überschreiten teilweise das nominelle Spaltenraster; deshalb tatsächliche Regionen verwenden. Raven Maßstab 0,149, Jackal 0,16, gegen normale Weltgröße geprüft. Liegelänge statt geringer Körperhöhe vergleichen; keine stehende Figur drehen.

Während der Ersatzpose normale Figur, beide Schatten und Lichtblocker ausblenden; Kontaktzeichnung unterdrücken. Sichtbarkeit beim Freigeben exakt zurücksetzen, auch bei Abbruch. Freigabe ist idempotent: ein verzögertes Entfernen der alten Pose darf eine neue Pose nicht überschreiben. Erholung endet bei Szenenabbruch; Boden-/Todesposen bleiben bis zum entsprechenden Storyübergang bestehen. Menü und Terminal halten die Animationszeit an.

[Spielbilder und Bericht](../../../docs/fehlerbericht-v045.md).
