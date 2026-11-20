#!/usr/bin/env python3
"""v0.67.1 · CodexAI: preserve existing release notes/checksums and add the Mac package."""
import argparse,hashlib,json,pathlib,re

def prepare(folder,tag,repo):
    folder=pathlib.Path(folder);report=json.loads((folder/'macos-verification.json').read_text())
    assert tag=='v'+report['version'] and report.get('native_start_tested') is True
    assert report.get('native_signature_verified') is True
    archive=folder/'ShadepiRPG-macOS.zip';digest=hashlib.sha256(archive.read_bytes()).hexdigest();assert report['sha256']==digest
    hashes={}
    for line in (folder/'previous-SHA256SUMS.txt').read_text().splitlines():
        h,name=line.split(maxsplit=1);assert re.fullmatch(r'[0-9a-f]{64}',h);name=name.strip();assert name not in hashes;hashes[name]=h
    existing={'ShadepiRPG-Windows.zip','ShadepiRPG-Linux.zip','ShadepiRPG-Android-Test.apk','ShadepiRPG-Godot-Projekt.zip'}
    assert set(hashes) in [existing,existing|{archive.name}],'Unexpected existing checksum list'
    hashes[archive.name]=digest;(folder/'SHA256SUMS.txt').write_text(''.join(h+'  '+n+'\n' for n,h in hashes.items()))
    start='<!-- codexai-macos-'+tag+':start -->';end='<!-- codexai-macos-'+tag+':end -->'
    body=(folder/'previous-notes.md').read_text();assert body.count(start)<=1 and body.count(end)==body.count(start)
    note=f'''{start}
### macOS-Nachtrag · {tag} · CodexAI

[macOS Universal ZIP herunterladen](https://github.com/{repo}/releases/download/{tag}/ShadepiRPG-macOS.zip) · Intel x86_64 und Apple Silicon arm64.

Das ZIP enthaelt die .app, eine Mac-Startanleitung und Godot-Lizenzen. Es verwendet denselben Spielstand/Quellcode des Release-Tags. Universal-Binaerdatei, Ressourcenpaket und ad-hoc-Signatur wurden geprueft; der native Headless-Start auf einem macOS-Runner ({report['native_architecture']}) war erfolgreich. Ein manueller Grafik-/Controller-Spieltest auf einem Mac steht noch aus.

Ad-hoc signiert, **nicht von Apple notarisiert**. Falls macOS den ersten Start blockiert, nach einem Startversuch unter Systemeinstellungen → Datenschutz & Sicherheit gezielt fuer diese App „Dennoch oeffnen“ verwenden. Gatekeeper nicht global deaktivieren. Die erweiterte SHA256SUMS.txt umfasst alle fuenf Plattform-/Projektpakete.
{end}'''
    if start in body:body=re.sub(re.escape(start)+r'[\s\S]*?'+re.escape(end),lambda _:note,body)
    else:body=body.rstrip()+'\n\n'+note+'\n'
    (folder/'release-notes.md').write_text(body)
    return {'tag':tag,'checksum_entries':len(hashes),'original_downloads_preserved':True}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('folder');p.add_argument('tag');p.add_argument('repo');a=p.parse_args();print(json.dumps(prepare(a.folder,a.tag,a.repo)))
