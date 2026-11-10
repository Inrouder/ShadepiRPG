# See-Ankunft, Mondlicht und Kontaktposen · v0.49.0 · CodexAI

## Aktive Quellen v0.49.0 · CodexAI

- `poses-moon.png`: unveränderte Bildwerkzeugquelle, tatsächlich 1774×887, vier Spalten / zwei Reihen. Acht echte Schritte: Hände, Griff, Maske heben, Annäherung, Kuss, gehaltener Kuss, Maske wieder aufsetzen, Umarmung. `lake_tableau.gd` registriert gerundete Einzelregionen, Fußanker lokal `(200,423)` und Maßstab `58/408`. Quellenkörper bleiben auf dem Boden; keine durchsichtigen Silhouetten-Überblendungen. Bestehende logische Posen 0–3 bleiben kompatibel und wählen die passenden Bildfolgen.
- `dragon-flight.png`: unveränderte Bildwerkzeugquelle, 2172×724, sechs 724×362-Zellen. Eigenständige Körper-/Schweif-/Mähnenphasen. `lake_mystic.gdshader` liest nur die belastbare Alpha-Silhouette; schwache Generierungsränder und blaue Außenfransen werden bei der Schattenabtastung verworfen. Ausgabe bleibt auf Wasser beschnitten.
- `lake_contact.gdshader`: Farbtemperatur der echten Atlasbilder. Keine zusätzliche Texturverdoppelung oder Gesichtstextur. Der ursprüngliche normale Heldenbestand bleibt unverändert.

Herkunft außerhalb des Repos: `/workspace/generated_images/exec-111e3487-a426-4f26-8833-11789da7ba3a.png` (Kontaktbilder, nach Hand-/Maskenkorrektur), `exec-2940582a-3496-4f76-bd30-c81cb7efac67.png` (Drachenphasen mit Zellabständen). Referenzen tatsächlich gesichtet: aktive Original-Figurenkarten und vorherige See-/Drachenquelle. Keine Python-Bemalung oder Vektor-Ersatzgrafik. [Aktuelle Aufnahme und Film](../../../docs/mondsee-v049.md).

Raven bleibt 160 cm, Shadepis Körpergröße nicht neu festgelegt. Ravens eigene rechte Hand hebt/hält die Maske; ihre linke berührt und verdeckt sein Gesicht. Kein lesbares unmaskiertes Gesicht. In der Umarmung ist die Maske wieder aufgesetzt. Körper-, Schatten- und Lichtverdeckungen der normalen Figuren während Ersatzposen unterdrücken und bei Szenenwechsel wiederherstellen.

## Historische Quellen v0.36.0 / v0.36.1

`poses.png`, `dragon.png` und `lake_pose_blend.gdshader` bleiben als Vergleichsquellen erhalten, sind nicht mehr aktive Laufzeit und werden nicht exportiert. Die folgenden ursprünglichen Angaben dokumentieren ihre damalige Verwendung.

**Handkorrektur v0.36.1 · CodexAI:** Die aktive Quelle wurde gezielt nachbearbeitet: Raven hebt die Maske mit ihrer eigenen **rechten** Hand; ihre **linke** berührt und verdeckt Shadepis Gesicht. Diese anatomische Zuordnung gilt in Zelle 1 (Maskenabnahme) und Zelle 2 (Kuss). Die rechte Hand hält die Maske angehoben statt an Ravens linker Außenseite am Bein.

`poses.png` ist ein unverändert generierter transparenter 1536×1024-Atlas mit vier 768×512-Zellen: Händehalten mit Maske, Ravens Maskenabnahme mit verdeckender Hand, Kuss mit weiterhin verdecktem Gesicht und Umarmung mit wieder aufgesetzter Maske. Referenzen waren die tatsächlichen Raven-/Shadepi-Bildkarten aus den normalen Gameplay-Atlanten. Eine erste Studie wurde vor der Verwendung anhand der sichtbaren Spritebreite korrigiert: breiter Kasa und passende Raven-Größe. Die aktive Datei ist die überarbeitete Quelle, keine programmatisch bemalte Montage.

Raven bleibt 160 cm; Shadepis Zentimetergröße wird nicht neu festgelegt. Kasa, segmentierte Maske, rotes Linsenlicht, Weste, Schal und Stoffbahnen sowie Ravens schwarze/blaue Haare, Cyan-Linien, rote Schulterzeichen, Handschuhe und Gürtel bleiben erhalten. In den maskenlosen Zellen verdecken Ravens Hand, der Kasa und der abgewandte Kopf Shadepis Gesicht; es gibt kein vollständig lesbares Porträt. Die Gesichtsgestaltung unter der Hand ist kein neuer bestätigter Kanon.

Der Comic ist nicht lokal vorhanden und wurde nicht als gesichtete Quelle ausgegeben. Die konkrete Nutzerbeschreibung der Handverdeckung hat Vorrang vor der früheren Roman-/Spieltextfassung, in der Shadepi die Maske selbst abnahm und sein Gesicht ausdrücklich beschrieben wurde. Die Ordensaufnahme bleibt vor diesem Moment erhalten.

`lake_tableau.gd` nutzt Fußanker `(300,488)` und Maßstab 0,125; die beiden Figuren werden gemeinsam auf den Uferboden gesetzt. Der Shader überblendet ausschließlich die vier gesichteten Zellen in vormultiplizierter Farbe. Keine zusätzliche unmaskierte Kopftextur, kein Freistell-Ersatz durch harte Alphakanten. Normale Sprites und Schatten werden während der Kontaktpose ausgeblendet und beim Szenenwechsel zurückgesetzt.

`dragon.png` ist eine eigene unverändert generierte transparente HQ-Pixelquelle, ausgehend vom weißen östlichen Drachen im vorhandenen Menübild. Sie ist erforderlich, weil dort kein separat freigestellter Drache vorhanden war. Der flüchtige Drachenschatten wird aus ihrer Silhouette erzeugt und über die echte Wasserfläche beschnitten; kein neues Wesen mit Namen oder zusätzlicher Hintergrundgeschichte wird behauptet.

Kulisse und Fahrzeug sind vorhandene Spielquellen: `lakeside.png` und `cinematic_aerodyne.gd`. Landepunkt `(225,430)` auf trockenem Gras, Schatten-/Kontaktbereich und Weg zum Ufer werden im Renderer und gegen die Wasserkollision geprüft. [Arbeitsnachweis](../../../docs/arbeiten/see-finale-v036.md).
