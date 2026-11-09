# An ShadepiRPG mitarbeiten

**v0.46.2 · CodexAI.** Diese Einstiegspunkte gelten für menschliche Mitwirkende und KI-Werkzeuge gleichermaßen:

1. [AGENTS.md](AGENTS.md): aktuellen Repository-Stand übernehmen, Arbeit erhalten, Versions- und Sicherungsregeln beachten.
2. [KONSISTENZ.md](KONSISTENZ.md) und die [bebilderte Stilbibel des gesamten Spiels](docs/stilbibel/README.md): Art Direction, alle 23 Figuren mit Bildkarten, Welten, Fahrzeuge, Objekte, UI und FX sowie Fertigprüfung.
3. [Konsistenzauftrag und Arbeitsnachweis](docs/vorlagen/konsistenz-auftrag.md): für die konkrete Aufgabe kopieren oder im Pull Request ausfüllen.

Vor neuen Grafiken die tatsächlich geladenen Assets und normale Gameplay-Figuren ansehen. Grafikänderungen mit vergleichbaren Godot-Ansichten und den relevanten Prüfungen belegen. Für reine Dokumentationsänderungen sind Inhalts-, Link- und Versionsprüfung ausreichend.

Die [Pull-Request-Vorlage](.github/pull_request_template.md) erinnert an die Prüfung. Auch bei direktem Push gelten dieselben Anforderungen. Vorhandene Nutzerautorisierung gilt weiter; diese Dokumente führen keine zusätzliche Freigaberunde ein.

## Schnell klonen · v0.48.0 · ClaudeHelper

Der Git-Verlauf ist durch frühere Vorschaufilme groß (rund 400 MB). Für die Arbeit genügt meist ein Teil davon:

```sh
# Aktueller Stand, Verlauf wird bei Bedarf nachgeladen (empfohlen):
git clone --filter=blob:none https://github.com/Inrouder/ShadepiRPG.git
# Nur der neueste Stand ohne Verlauf:
git clone --depth 1 https://github.com/Inrouder/ShadepiRPG.git
```

Der Verlauf wird nicht umgeschrieben, damit bestehende Klone und Zweige gültig bleiben. Neue Vorschaufilme bleiben unter 5 MB (kürzer, kleinere Auflösung) oder werden als Release-Anhang veröffentlicht; `tools/audit_repository.py` prüft das.

## Repository-Ordnung

Vor Änderungen [Statuskatalog](docs/repository-status.md), [aktive Assetquellen](assets/README.md) und [Werkzeugkatalog](tools/README.md) ansehen. Entwicklungsarchiv und Sicherungen nicht als aktive Quellen verwenden; das Universumsarchiv bleibt verbindlich. Die alte README-Chronik und überholte Spieleranleitung stehen im [Archiv](docs/archiv/README.md).

`python3 tools/audit_repository.py` vor dem Commit ausführen: lokale Markdown-Links, feste Laufzeitressourcen, Statuspfade und Exportgrenzen. Bei Gameplay-Änderungen anschließend die gezielten Godot-Prüfungen mit isolierten Spielständen. Asset-Compiler/Generatoren sind keine normalen Setup-Schritte.
