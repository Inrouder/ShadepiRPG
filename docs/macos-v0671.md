# macOS-Nachtrag · v0.67.1 · CodexAI

**20. November 2026.** [Release v0.67.1](https://github.com/Inrouder/ShadepiRPG/releases/tag/v0.67.1) · [Mac-ZIP](https://github.com/Inrouder/ShadepiRPG/releases/download/v0.67.1/ShadepiRPG-macOS.zip) · [Prüfsummen](https://github.com/Inrouder/ShadepiRPG/releases/download/v0.67.1/SHA256SUMS.txt).

Zusätzlicher macOS-Download zu demselben veröffentlichten Spielstand v0.67.1, ohne neue Gameplay-Version oder Verschieben des vorhandenen Release-Tags. Ein Universal-Paket enthält Intel x86_64 und Apple Silicon arm64. Spielcode, Grafiken und bisherige Windows-/Linux-/Android-Pakete bleiben erhalten.

## Starten

`ShadepiRPG-macOS.zip` vollständig entpacken und **Shadepi - Echos in Neon.app** nach Programme kopieren. Das ZIP enthält eine Mac-Startanleitung sowie Godot-Lizenz-/Copyrighttexte.

Die App ist ad-hoc signiert, **nicht von Apple notarisiert**. Falls macOS den ersten Start blockiert, nach einem Startversuch unter **Systemeinstellungen → Datenschutz & Sicherheit** gezielt für diese App **„Dennoch öffnen“** wählen. Gatekeeper nicht global deaktivieren. Ein manueller Grafik-/Controller-Spieltest auf einem Mac steht noch aus.

## Erstellung und Prüfung

- Godot 4.7.2 und offizielle Mac-Exportvorlage; Paket enthält echte Universal-Mach-O-Datei, `Info.plist`, PCK und Ad-hoc-Signatur. Der lokale Linux-Export wurde strukturell geprüft.
- Der zusätzliche GitHub-Workflow verwendet den unveränderten Spiel-Tag v0.67.1, ergänzt allein das Mac-Exportpreset und baut auf einem macOS-Runner. Dort werden Apples `codesign --verify --deep --strict` und ein nativer Headless-Start des entpackten Pakets außerhalb des Projektordners geprüft.
- Erst nach erfolgreichem Start werden Mac-ZIP, erweiterte gemeinsame Prüfsummen und ein ausdrücklich mit CodexAI gekennzeichneter Hinweis im vorhandenen Release veröffentlicht. Vorhandene Notizen und vier bisherige Download-Prüfsummen bleiben erhalten.
- Ein Headless-Start auf einer Runner-Architektur ist kein manueller Grafiktest auf beiden Mac-Familien. Die strukturelle Prüfung kontrolliert beide Architekturen.

**Veröffentlicht und geprüft:** [macOS-Lauf erfolgreich](https://github.com/Inrouder/ShadepiRPG/actions/runs/44810408050), native Start-/Signaturprüfung auf Apple Silicon (arm64). Das veröffentlichte ZIP wurde anschließend vollständig heruntergeladen, gegen die veröffentlichte SHA-256-Prüfsumme geprüft und nochmals strukturell untersucht. Alle vier bisherigen Download-Prüfsummen sind unverändert. [Veröffentlichungs-/Paketnachweis](pruefungen/v0671/macos.json).

[Lokaler Paketnachweis](pruefungen/v0671/macos-local.json) · [Werkzeuge und Ablauf](../tools/macos/README.md). Die bisherige [55-Suiten-Abnahme](pruefungen/v0671/ergebnisse.json) gilt weiter für denselben Spielcode; für diesen Paketnachtrag werden gezielt Export, Bundle, Signatur, Start und Erhalt bestehender Release-Inhalte geprüft.
