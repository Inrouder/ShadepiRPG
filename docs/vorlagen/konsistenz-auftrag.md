# Kopiervorlage: Konsistenzauftrag und Arbeitsnachweis

**v0.32.1 · CodexAI.** Vor Verwendung [KONSISTENZ.md](../../KONSISTENZ.md) und [AGENTS.md](../../AGENTS.md) lesen. Für eine konkrete Aufgabe die Vorlage in einen eigenen Arbeitsnachweis kopieren, etwa `docs/arbeiten/<aufgabe>.md`, oder dieselben Felder im PR verwenden. Diese leere Vorlage erhalten. Kurze, nachvollziehbare Antworten genügen; „nicht betroffen“ jeweils begründen.

## Auftrag und Ausgangslage

- **Aufgabe / Nutzerziel:** …
- **Ausgangscommit und Spielversion:** …
- **Alle Remote-Branches abgerufen und relevante Änderungen verglichen:** …
- **Übernommener Stand / erhaltene lokale oder fremde Änderungen:** …
- **Betroffene Szene, Figuren, Ressourcen und Aufrufe im Code:** …
- **Geplanter Umfang / weitere nicht beauftragte Änderungen:** …
- **Neue Version und Bearbeitervermerk:** …

## Referenzen und unveränderte Merkmale

| Zweck | Tatsächlich gesichteter Pfad / Version | Was daraus übernommen wird |
| --- | --- | --- |
| Aktiver Gameplay-Sprite und Nachbarfigur | … | Körperbau, Material, Pixeldichte … |
| Bestätigte Figuren-/Storyquelle | … | Feste Merkmale und Szenenreihenfolge … |
| Aktive Kulisse und Kameradarstellung | … | Perspektive, Licht, Bodenebene … |
| Bestehende Animation und Metadaten | … | Fuß-, Sitz-, Hand- oder Mündungsanker … |

- **Historische oder verworfene Quellen, die nicht als aktuelle Stilreferenz gelten:** …
- **Fehlende/unbestätigte Angaben und gewählte dokumentierte Annahmen:** …
- **Wiederverwendete Assets / begründeter Bedarf für neue Quellen:** …

## Grafik- und Animationsbriefing

- **Pose/Aktion und Phasen:** Ausgang → Übergang → Kontakt/Auslösen → Rückkehr: …
- **Figurenmerkmale:** … (Raven: 160 cm; Shadepis Größe nicht frei erfinden.)
- **Material und Licht anhand der konkreten Referenz:** …
- **Zell-/Blattformat, getrennte Ausschnitte und Transparenz:** …
- **Weltgröße im Vergleich zum normalen Sprite:** …
- **Fuß-/Sitz-/Liegeanker und Maßstab pro Pose:** …
- **Hand-/Mündungs-/Kontaktpunkte sowie Schatten und Verdeckung:** …
- **Abtastung passend zum aktiven Renderer:** …
- **Erlaubte Bewegung von Haar/Stoff / feste Körper- und Möbelpunkte:** …
- **Rücksetzung bei Unterbrechung, Laden oder Szenenwechsel:** …
- **Herkunft neuer Quellen und gegebenenfalls Bearbeitungsschritte:** …

### Kurzer Auftragstext für Grafikwerkzeug oder KI

Die Platzhalter vor Weitergabe mit Pfaden und konkreten Angaben füllen; benötigte Bildreferenzen tatsächlich bereitstellen. Ein Textpfad allein übermittelt einem Bildwerkzeug keine Referenz.

```text
Projekt: ShadepiRPG, HQ-Pixelart im Cyberpunk-Stil.
Aufgabe: [konkrete Szene/Pose/Animation].
Verbindliche Stilreferenz: [gesichtete aktive Gameplay-Grafik + Spielansicht].
Identitätsreferenz: [bestätigte Figurenmerkmale und Quellen].
Kulisse/Kamera: [Perspektive, Licht, tatsächliche Größe].
Erhalten: [Kostüm, Körperbau, Farben, Maske, Haare, Ausrüstung].
Pose und Kontakt: [Bewegungsphasen, feste Anker, greifende Hand/Ziel].
Ausgabe: [PNG/Atlas, Layout, Freiräume, vollständige Silhouetten,
echte Transparenz, gewünschte Pixelcluster und Materialschattierung].
Historische Vorlage nur für: [z. B. Pose/Layout, ausdrücklich nicht Stil].
Unpassend: glatte Vektor-/Anime-Ersatzfiguren, körniger Materialwechsel,
weiße/graue Matte, abgeschnittene Haare/Waffen, driftende Körpergröße.
Nach Erstellung: im tatsächlichen Spiel neben der normalen Figur prüfen;
das generierte Quellblatt allein ist kein Nachweis der Konsistenz.
```

## Umsetzung und Nachweis

| Prüffeld | Ergebnis / Messung / begründet nicht betroffen | Beleg |
| --- | --- | --- |
| Aktive Quellen und feste Merkmale | … | Pfade / Archivstelle |
| Spielgröße, Material und Abtastung | … | Vergleich bei gleicher Kamera |
| Vollständige Silhouette / Alpha-Kanten | … | Nahansicht / Bildanalyse |
| Fuß-/Möbelanker und Kontaktpunkte | … | Weltkoordinaten / Kontaktframe |
| Vollständiger Animationsablauf | … | Godot-Bilder oder Film |
| Controller und Tastatur | … | Durchgeführte Eingabefolge |
| Pause, Bildstil und Ton-Aus | … | Beobachtetes Verhalten |
| Überspringen, Abbruch und Laden | … | Kontrollpunkte / Rücksetzprüfung |
| Relevante automatisierte Prüfungen | … | Befehl, Ergebnis, aktuelle Anzahl |
| Exportierte Ressourcen | … | Geprüftes Paket / Start |
| Version, Änderungsinfo und Sicherung | … | Commit / GitHub-Stand |

**Sichtprüfung durch / Datum:** …

**Verbleibende Abweichungen, Einschränkungen oder offene Punkte:** …

**Ergebnis:** … (fertig / konkreter Korrekturbedarf; nicht allein aus einem grünen Build ableiten).
