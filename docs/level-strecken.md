# Level strecken: Muster Hinterhalt und Verfolgung · v0.58.0 · ClaudeHelper

**11. November 2026.** [Bildgalerie](README.md) · [Spieleranleitung](../Spiel-README.md) · [Versionshinweise](../CHANGELOG.md).

![Etappe 2 im Tunnel, Etappe 3 auf der Hochstraße](previews/verfolgung-etappen-v058.webp)

Nutzerauftrag vom 11. November 2026: Das Spiel soll länger werden, die Story bleibt, die Level werden gestreckt. Dieses Muster zeigt den Weg an zwei Stellen; die übrigen Kapitel können genauso folgen.

## Verfolgung: drei Etappen

| Etappe | Kulisse | Verfolger | Besonderheit |
| --- | --- | --- | --- |
| 1 · Stadt | `highway.png` (unverändert) | 100 % | wie bisher |
| 2 · Tunnel | `tunnel.png` | 80 % | keine Drohnen, Hindernisse dichter |
| 3 · Hochstraße | `skyway.png` über `airspace.png` | 100 % | zwei Drohnen von Anfang an, Seitenwind |

- Ist ein Wagen der Etappen 1 und 2 besiegt, fällt er qualmend zurück; das Bild taucht kurz ins Dunkel einer Einfahrt, dann schließt der nächste von hinten auf.
- Beim Wechsel repariert sich das Motorrad um 25 %. Nach einem Sturz beginnt die Fahrt an der erreichten Etappe.
- Erst der dritte Wagen brennt, explodiert und bleibt als Wrack zurück ([Finale v0.56.0](verfolgung-finale-v056.md)).

## Hinterhalt: mehr Wellen, ein Truppführer

Beide Abschnitte haben eine vierte Welle. Die letzte bringt einen Truppführer: Schild nach vorn, 150 Leben, zwei Schützen als Deckung. Treffer von hinten oder Ravens Hack öffnen ihn.

## Kulissen

Die beiden neuen Kulissen sind aus den vorhandenen gemalten Bildern gebaut, nicht neu erzeugt: Fahrbahn und Gehwegplatten stammen aus `highway.png`, die Lüfter der Tunnelwand aus dessen Dachtechnik, die Stadt unter der Hochstraße ist `airspace.png` aus dem Flug. Dadurch stimmen Pinselstrich, Körnung und Farbwelt überein. Ein externer Bildgenerator war aus dieser Arbeitsumgebung nicht erreichbar.

`python3 tools/drive/build_chase_stages.py` erzeugt beide Dateien wiederholbar. Sie kacheln senkrecht ohne Naht.

## So lässt sich ein weiteres Level strecken

- Fahrszenen: `drive.stages` setzen, Kulisse je Etappe in `_draw_highway()` ergänzen, Regeln in `_spawn_road_object()` und den Etappenfunktionen von `scripts/campaign_drive.gd`.
- Kampfräume: Wellen in `scripts/arcade_waves.gd` ergänzen; Sondergegner als eigene Variante in `_spawn_arcade_foe()`.
- Prüfungen: `tests/drive_action.gd`, `tests/bug_report_v045.gd`, `tests/arcade_waves.gd`.
