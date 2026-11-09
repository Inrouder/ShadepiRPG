# Schaltkasten und Serverschrank · v0.42.0 · CodexAI

`electrical.png` und `server.png` sind direkt generierte HQ-Pixelatlanten anhand der entsprechenden tatsächlich aktiven Gegenstände aus `assets/world/hq/props.png`. Beide PNGs wurden unverändert kopiert. Keine programmgesteuerte Bemalung, Freistellung oder Hochskalierung. Dunkles gebrauchtes Metall, Kabelführung, gelbes Warnschild beziehungsweise Rackfront und Cyan-Technik gehören weiterhin zur vorhandenen Gerätefamilie.

Je Quelle 1536×1024, vier Spalten und zwei Reihen, tatsächliche Zelle 384×512. Das Gehäuse bleibt in allen acht Bildern an derselben Stelle; Lüfterblätter, Messwerk und Relais-/Schubladenmechanik bewegen sich. Echter transparenter Außenraum; keine neu gemalten Bodenflächen oder zweiten Möbel.

| Bild | Inhalt |
| --- | --- |
| 0–3 | Betrieb: verschiedene Lüfterwinkel, kleine Mess-/Laufwerksbewegung |
| 4 | Zugriff beginnt, Verriegelung/Relais angesprochen |
| 5 | Übertragung bzw. mechanisches Einrasten |
| 6 | Kleine grüne Bestätigung am Gerät |
| 7 | Rote/amberfarbene Störanzeige, Auslöse-/Rücksetzstellung |

`technology_art.gd` enthält die gemessenen vorderen Bodenanker `(195,444)` für den Kasten und `(210,477)` für das Rack. Die rechte perspektivische Ecke reicht in der Quelle tiefer als die vordere Bodenmitte; daher nicht pauschal die gesamte Alpha-Boundingbox als Fußpunkt verwenden. Zielrahmen inklusive transparentem Rand: 52×74 beziehungsweise 64×78. Die tatsächliche sichtbare Silhouette wurde neben normalen Figuren und dem bisherigen Objektbild im Renderer verglichen. Collider und gespeicherte Objekt-IDs bleiben unverändert.

Neue Betriebsphasen gelten nur oberhalb halber Lebenspunkte. Beschädigte und zerstörte Geräte verwenden weiterhin ihre passenden Bilder aus dem bestehenden Prop-Atlas. Dabei Sprite-Raster, Maßstab und Basisposition vollständig zurücksetzen; keine intakte Statusgrafik über ein zerstörtes Gerät legen. Trefferwackeln darf sich nicht in den Bodenanker einschreiben.

Explizite optionale Statusverbindungen (`LINKS`), keine Suche nach zufälligem nächstem Dekor:

| Layout / Zugriff | Verbundene Anzeige |
| --- | --- |
| Garage / Garagencode | `tool_case` |
| Hangar / Energiebus | `spare_server` |
| Hangar / Transponder | `diagnostics` |
| Dach / Funkkennung oder Penthouse-Zugang | `backup_generator` |
| Suite / Aufzugssperrladung | `lift_server`, `power_box` |

Das sind verbundene Statusgeräte, keine neu eingeführten Pflichtterminals. Ihr Defekt blockiert kein bestehendes Storyrätsel. Das offene Terminal hält Betriebs-/Statusuhren an; der angesprochene Zustand bleibt sichtbar stehen. Übernehmen startet 4→5→6 und kehrt zum Betrieb zurück, Alarm setzt 7. Normales Abbrechen trennt ohne Erfolgsanzeige. Nach Laden/Wechsel keine alten Zugriffsreferenzen oder wiederbelebten Trümmer; Generation und Objektgültigkeit vor Rückmeldungen prüfen. Keine neuen dauerhaften Speicherfelder.

[Spielbilder und Film](../../../docs/technik-gegenstaende.md) · [Arbeitsnachweis](../../../docs/arbeiten/technik-v042.md).
