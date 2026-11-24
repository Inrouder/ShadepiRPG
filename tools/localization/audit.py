#!/usr/bin/env python3
"""v0.70.0 · CodexAI. Catalog coverage and printf/puzzle-code invariants; stdlib only."""
import json,pathlib,re,sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
TOKEN=re.compile(r'#[^\n]*|"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'',re.S)
FORMAT=re.compile(r'%%|%[-+ 0#]*[0-9]*(?:\.[0-9]+)?[dsf]')

def catalog():
    entries={};key=None
    for line in (ROOT/'localization/game.en.po').read_text().splitlines():
        if line.startswith('msgid '):key=json.loads(line[6:])
        elif line.startswith('msgstr ') and key:
            assert key not in entries, 'Duplicate key: '+key
            entries[key]=json.loads(line[7:])
    return entries

def literals(path):
    for match in TOKEN.finditer(path.read_text()):
        raw=match[0]
        if raw.startswith('#'):continue
        try:value=json.loads(raw) if raw.startswith('"') else raw[1:-1]
        except json.JSONDecodeError:value=raw[1:-1]
        yield value

def main():
    entries=catalog();failures=[];checked=0
    for de,en in entries.items():
        checked+=1
        if not en.strip():failures.append('Empty English: '+repr(de))
        if FORMAT.findall(de)!=FORMAT.findall(en):failures.append('Changed placeholders: '+repr(de))
    for code in ['SIGNAL','SIEGEL','SICHER','SILBER','SENSOR','SENDET']:
        checked+=1
        if entries[code]!=code:failures.append('Decoder code renamed: '+code)
    for path in sorted((ROOT/'scripts').rglob('*.gd')):
        if path.name in ['game_translation.gd']:continue
        for text in literals(path):
            # Clear prose/UI literals; single German UI words are maintained in the catalog too.
            visible=bool(re.search(r'[äöüÄÖÜß]|[A-Za-z].* [A-Za-z]|[A-Za-z] · |[A-Za-z][.!?:]$',text) or text.isupper() and text.isalpha() and len(text)>3)
            if not visible or text.startswith(('res://','user://','http','SCRIPT ERROR','ERROR:')):continue
            checked+=1
            if text not in entries:failures.append(str(path.relative_to(ROOT))+': missing '+repr(text))
    for error in failures:print('FAIL:',error)
    print(f'Localization catalog: {len(entries)} messages; {checked} checks, {len(failures)} failures')
    return bool(failures)
if __name__=='__main__':sys.exit(main())
