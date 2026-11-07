# Zusammenarbeit an ShadepiRPG

Vom Nutzer festgelegte Arbeitsregeln:

- Vor Projektarbeiten immer **alle GitHub-Branches** abrufen (`git fetch origin '+refs/heads/*:refs/remotes/origin/*'`), ihre Versionen und Änderungen vergleichen und erst danach den passenden aktuellen Stand übernehmen. Ein aktueller `main` allein genügt nicht, wenn neuere Arbeit auf Entwicklungsbranches liegt. Änderungen anderer Bearbeiter und lokale Arbeit erhalten.
- Vor Projektarbeiten den lokalen Git-Stand und offene Änderungen prüfen, den aktuellen Stand von `Inrouder/ShadepiRPG` auf GitHub abrufen und nötige Aktualisierungen ohne Verlust lokaler Arbeit übernehmen.
- Nutzungslimit und Kosten berücksichtigen: gezielte Lektüre und Prüfungen, keine unnötigen Tool-Aufrufe, Wiederholungen oder Neugenerierungen vorhandener Assets.
- Regelmäßig Zwischenstände speichern und sinnvoll committen.
- Bei jeder abgeschlossenen Änderung die Spielversionsnummer passend erhöhen und die Änderungsinfos ergänzen. `project.godot`, die Windows-Versionsfelder in `export_presets.cfg`, die aktuelle Version in `README.md` und `Spiel-README.md` sowie den Eintrag in `CHANGELOG.md` konsistent halten. Das separate Asset-Werkzeugpaket hat eine eigene Versionsnummer.
- Eigene neue Versionshinweise, Änderungsinfos, Commit- und gegebenenfalls PR-Titel immer mit Versionsnummer und dem ausdrücklichen Vermerk **CodexAI** kennzeichnen. Diese Nutzervorgabe vom 7. November 2026 ersetzt für Codex-Änderungen den bisherigen Vermerk „ClaudeHelper“; historische Einträge anderer Bearbeiter unverändert lassen. Vor dem Push Version, Änderungsinfos und Kennzeichnung prüfen.
- Änderungen von Claude werden weiterhin mit Versionsnummer und **ClaudeHelper** gekennzeichnet (Nutzervorgabe vom 6. November 2026). Codex und Claude arbeiten am selben Repository: vor jeder Arbeit den neuesten Stand aller Branches übernehmen, fremde Änderungen erhalten und Versionsnummern fortlaufend weiterzählen.
- Fertige, geprüfte Änderungen auf GitHub sichern. Der Nutzer hat das Pushen ausdrücklich auch für künftige abgeschlossene Arbeiten erlaubt. Spätere konkrete Einschränkungen des Nutzers haben Vorrang.
- Falls ein Push scheitert, eine vollständige Projektkopie einschließlich Git-Verlauf und ungesicherter Änderungen außerhalb des Repository-Verzeichnisses sichern und den genauen Speicherort nennen. Kann auch die Sicherung nicht erfolgen, den tatsächlichen Stand und die Blockade offen benennen.
- Eine Veröffentlichung der Cloud-Umgebung ist eine eigene Aktion und gehört nicht automatisch zum Git-Push.

## Verbindlicher Grafikstil

Nutzervorgabe vom 7. November 2026: ShadepiRPG ist ein **Pixelart-Spiel**. Alle künftig erstellten Grafiken müssen **HQ-Pixelgrafiken** im passenden Cyberpunk-Stil sein. Hoher Detailgrad, erkennbare Materialtexturen, räumliche Tiefe, differenzierte Licht-/Schattenstufen und saubere Pixelcluster sind wesentlich. Keine einfachen Vektorgrafiken, flachen Ersatzformen oder glatten Illustrationen als Ersatz für Pixelart. Eine große PNG-Datei oder bloßes Hochskalieren/Verpixeln allein erfüllt HQ nicht.

Vor neuen Assets vorhandene HQ-Spielgrafiken und Figurenreferenzen vergleichen; Pixeldichte, Proportionen, Palette, Perspektive und Merkmalkonsistenz beachten. Pixelkanten bei Import und Skalierung gezielt erhalten; keine unkontrollierte Weichzeichnung. Die Regel gilt auch für neue Menübilder, Sprites, Umgebungsobjekte und grafische FX-Assets. Diese Stilfestlegung allein ist kein Auftrag, vorhandene Grafiken sofort auszutauschen.

## Quellen und Figuren

Das [Shadepi-Universum-Archiv](docs/universum/README.md) enthält die bereitgestellten Originalquellen, Textkopien und Hinweise zu Figurenreferenzen. Vor Arbeiten an Lore, Figuren oder ihrem Aussehen die passenden Quellen konsultieren. Vorhandene HQ-Assets und den aktuellen GitHub-Stand berücksichtigen.

Stand der Archivaufnahme: Teil 1 enthält die drei Original-PDFs und Notizen zu zwei Figurenreferenzen; Teil 2 und Teil 3 dokumentieren jeweils fünf weitere Bilder. Der Comic wurde wegen seiner Größe nicht hochgeladen. Der Nutzer hat am 6. November 2026 bestätigt, dass der vorhandene Storyverlauf und die Figurenreferenzen für weitere Arbeiten ausreichen; nicht auf den Comic warten. Die zwölf eingebetteten Bilder liegen bislang nur im Chat vor, nicht als lokal verfügbare Originaldateien; dieser Unterschied ist im Archiv dokumentiert. Raven ist verbindlich **160 cm** groß (Nutzerbestätigung vom 6. November 2026); die 168-cm-Angabe im älteren Referenzblatt ist überholt. Archivaufnahme allein ist kein Auftrag, die Spielwelt oder Figuren zu ändern.

Seit 6. November 2026 liegt in [Teil 4](docs/universum/teil-4/README.md) die Romanfassung „Shadepi im Schatten des Raben“; sie ist die Textgrundlage der Zwischensequenzen. Bestätigt: Kenzō Moriyama hat das Massaker am Orden mit Militechs Minotauren inszeniert; Shadepi erfährt das durch Raven. Kenzō ließ Ravens **Eltern** ermorden (bestätigt; die Raven-Akte nennt nur den Vater). Der Nutzer wünscht echte Zwischensequenzen im Spiel statt Comic-Einblendungen.

Seit 7. November 2026 liegt in [Teil 5](docs/universum/teil-5/README.md) das verbindliche Nutzerbriefing zu den drei Kloster-Erinnerungen; die [Roadmap](docs/erinnerungen-roadmap.md) beschreibt die Produktionsreihenfolge. Vor Arbeiten an diesen Erinnerungen beide lesen. Bestätigt: Oni- und schwerer MG-Krieger fallen in Erinnerung 1 zum Schutz Shadepis; Ly (weiße Gewandung) überlebt bis zu seinem Opfer gegen den Minotaurus in Erinnerung 2; der alte Meister überträgt in Erinnerung 3 das Heiligtum auf Shadepi, der nach dem Kampf gegen zwei Minotauren zusammenbricht. Das spätere Schicksal des Roboterkopf-Kriegers ist offen.

Umsetzungsstand v0.22.0 · CodexAI: [Erinnerung I](docs/kloster-angriff.md) umfasst jetzt Kulissen, Figuren, Map und den inszenierten Auftakt an Knoten 1. Vollständige Bot-Wellen, Oni-/MG-Schutzopfer und Erinnerungen 2/3 sind noch ausstehend. Oni trägt verbindlich Katana, der Roboterkopf-Krieger einen Stab.
