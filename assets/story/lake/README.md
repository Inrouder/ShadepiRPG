# See-Ankunft und Kontaktposen · v0.36.0 · CodexAI

`poses.png` ist ein unverändert generierter transparenter 1536×1024-Atlas mit vier 768×512-Zellen: Händehalten mit Maske, Ravens Maskenabnahme mit verdeckender Hand, Kuss mit weiterhin verdecktem Gesicht und Umarmung mit wieder aufgesetzter Maske. Referenzen waren die tatsächlichen Raven-/Shadepi-Bildkarten aus den normalen Gameplay-Atlanten. Eine erste Studie wurde vor der Verwendung anhand der sichtbaren Spritebreite korrigiert: breiter Kasa und passende Raven-Größe. Die aktive Datei ist die überarbeitete Quelle, keine programmatisch bemalte Montage.

Raven bleibt 160 cm; Shadepis Zentimetergröße wird nicht neu festgelegt. Kasa, segmentierte Maske, rotes Linsenlicht, Weste, Schal und Stoffbahnen sowie Ravens schwarze/blaue Haare, Cyan-Linien, rote Schulterzeichen, Handschuhe und Gürtel bleiben erhalten. In den maskenlosen Zellen verdecken Ravens Hand, der Kasa und der abgewandte Kopf Shadepis Gesicht; es gibt kein vollständig lesbares Porträt. Die Gesichtsgestaltung unter der Hand ist kein neuer bestätigter Kanon.

Der Comic ist nicht lokal vorhanden und wurde nicht als gesichtete Quelle ausgegeben. Die konkrete Nutzerbeschreibung der Handverdeckung hat Vorrang vor der früheren Roman-/Spieltextfassung, in der Shadepi die Maske selbst abnahm und sein Gesicht ausdrücklich beschrieben wurde. Die Ordensaufnahme bleibt vor diesem Moment erhalten.

`lake_tableau.gd` nutzt Fußanker `(300,488)` und Maßstab 0,125; die beiden Figuren werden gemeinsam auf den Uferboden gesetzt. Der Shader überblendet ausschließlich die vier gesichteten Zellen in vormultiplizierter Farbe. Keine zusätzliche unmaskierte Kopftextur, kein Freistell-Ersatz durch harte Alphakanten. Normale Sprites und Schatten werden während der Kontaktpose ausgeblendet und beim Szenenwechsel zurückgesetzt.

`dragon.png` ist eine eigene unverändert generierte transparente HQ-Pixelquelle, ausgehend vom weißen östlichen Drachen im vorhandenen Menübild. Sie ist erforderlich, weil dort kein separat freigestellter Drache vorhanden war. Der flüchtige Drachenschatten wird aus ihrer Silhouette erzeugt und über die echte Wasserfläche beschnitten; kein neues Wesen mit Namen oder zusätzlicher Hintergrundgeschichte wird behauptet.

Kulisse und Fahrzeug sind vorhandene Spielquellen: `lakeside.png` und `cinematic_aerodyne.gd`. Landepunkt `(225,430)` auf trockenem Gras, Schatten-/Kontaktbereich und Weg zum Ufer werden im Renderer und gegen die Wasserkollision geprüft. [Arbeitsnachweis](../../../docs/arbeiten/see-finale-v036.md).
