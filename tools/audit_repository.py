#!/usr/bin/env python3
"""v0.46.2 · CodexAI: inspect real local links, runtime resources and export boundaries.

Read-only, standard library only. No generation, installation or gameplay saves.
"""
from pathlib import Path
import configparser
import fnmatch
import json
import re
import subprocess
import sys
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
errors = []
checks = 0


def check(ok, description):
    global checks
    checks += 1
    if not ok:
        errors.append(description)


def audit():
    manifest = json.loads((ROOT / "docs/repository-status.json").read_text())
    version = re.search(r'^config/version="([^"]+)"', (ROOT / "project.godot").read_text(), re.M).group(1)
    check(manifest["version"] == version, "Statusmanifest und Projektversion unterscheiden sich")
    for file in ["README.md", "Spiel-README.md", "CHANGELOG.md"]:
        check("v" + version in (ROOT / file).read_text()[:900], file + ": aktuelle Version fehlt am Einstieg")
    statuses = {"active", "backup", "reference", "rejected", "historical", "source", "authoritative-source", "record"}
    exports = configparser.ConfigParser(interpolation=None)
    exports.read(ROOT / "export_presets.cfg")
    export_filters = []
    for section in ["preset.0", "preset.1"]:
        export_filters.append(exports[section]["exclude_filter"].strip('"').split(','))
        for kind in (["file", "product"] if section == "preset.0" else []):
            check(exports[section + ".options"]["application/" + kind + "_version"].strip('"') == version + ".0", section + ": Windows-Versionsfeld inkonsistent")
    for entry in manifest["entries"]:
        check(entry["status"] in statuses and bool(entry["note"]), "Ungültiger/unbeschriebener Status")
        for name in entry["paths"]:
            check((ROOT / name).exists(), "Statuspfad fehlt: " + name)
            if entry["status"] in {"backup", "reference", "rejected", "historical"}:
                for filters in export_filters:
                    check(any(fnmatch.fnmatchcase(name, p) or fnmatch.fnmatchcase(name + "/probe.png", p) for p in filters), "Archiv/Backup nicht vom Export getrennt: " + name)
    # Git knows the repository boundary; include untracked task files while auditing before commit.
    tracked = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split('\0')
    names = set(subprocess.check_output(["git", "ls-files", "-co", "--exclude-standard", "-z"], cwd=ROOT).decode().split('\0'))
    for name in tracked:
        check(not name or not any(part in {".godot", "node_modules", "__pycache__", ".venv", "build"} for part in Path(name).parts), "Generierter Cache im Git: " + name)
    markdown = 0
    for name in sorted(names):
        p = ROOT / name
        if p.suffix != ".md" or not p.is_file():
            continue
        markdown += 1
        for target in re.findall(r'\]\(([^)]+)\)', p.read_text()):
            if "://" in target or target.startswith(("#", "mailto:")):
                continue
            local = unquote(target.split('#', 1)[0].strip('<>'))
            check((p.parent / local).exists(), name + ": fehlendes Linkziel " + target)
    runtime = [ROOT / "project.godot"]
    for directory in ["scripts", "scenes", "shaders"]:
        runtime.extend(p for p in (ROOT / directory).rglob('*') if p.suffix in {'.gd', '.tscn', '.tres', '.gdshader'})
    for p in runtime:
        text = p.read_text()
        for match in re.finditer(r'["\']res://([^"\'\n]+)["\']', text):
            name = match.group(1)
            line_prefix = text[text.rfind('\n', 0, match.start()) + 1:match.start()]
            if "_capture.call_deferred(" in line_prefix:
                continue  # Explicit screenshot write destinations, not runtime input assets.
            # Dynamic prefixes are not full paths; the ordinary Godot suites cover those.
            if text[match.end():].lstrip().startswith(('+', '%')) or any(c in name for c in ['%', '{', '*']):
                continue
            check((ROOT / name).exists(), str(p.relative_to(ROOT)) + ": fehlende Laufzeitressource " + name)
            for filters in export_filters:
                check(not any(fnmatch.fnmatchcase(name, f) for f in filters), str(p.relative_to(ROOT)) + ": aktive Referenz auf ausgeschlossene Ressource " + name)
    # v0.48.0 · ClaudeHelper: Größenbremse für Vorschaufilme. Bestehende große Filme bleiben
    # als Bestand erlaubt; neue Dateien über 5 MB sollen gekürzt oder als Release-Anhang
    # veröffentlicht werden, damit der Git-Verlauf nicht weiter anwächst.
    legacy_large = {
        "fehlerbericht-szenen-v045.webp", "menue-testpunkte-v044.webp", "verfolger-bewegung-v041.webp",
        "motorrad-bewegung-v040.webp", "tower-flucht-v033.webp",
    }
    for p in (ROOT / "docs/previews").glob("*"):
        if p.is_file() and p.name not in legacy_large:
            check(p.stat().st_size <= 5 * 1024 * 1024, "docs/previews/" + p.name + ": Vorschau über 5 MB – kürzen oder als Release-Anhang veröffentlichen")
    for file in ["README.md", "docs/README.md"]:
        check(bool(re.search(r'!\[[^]]*\]\([^)]*\.png\)', (ROOT / file).read_text())), file + ": eingebettete PNG-Vorschau fehlt")
    print(f"REPOSITORY AUDIT: {checks} checks, {len(errors)} failures; {markdown} Markdown files; {len(runtime)} runtime files")
    for error in errors:
        print("FAIL: " + error)
    return 1 if errors else 0


if __name__ == '__main__':
    sys.exit(audit())
