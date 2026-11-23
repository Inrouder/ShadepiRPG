#!/usr/bin/env python3
"""v0.69.2 · CodexAI: icon/version template preparation and normal Godot export."""
import argparse, configparser, hashlib, json, os, pathlib, re, struct, subprocess, tempfile
import lief
from prepare import prepare, icon_blobs

def verify(path,icon,version):
    path=pathlib.Path(path);binary=lief.PE.parse(str(path))
    got=list(binary.resources_manager.icons);expected=icon_blobs(icon)
    assert len(got)==len(expected)==6
    for a,b in zip(got,expected):assert bytes(a.pixels)==bytes(b.pixels) and (a.width,a.height)==(b.width,b.height)
    file_info=binary.resources_manager.version[0].file_info
    a,b,c=map(int,version.split('.'))
    assert file_info.file_version_ms==(a<<16)|b and file_info.file_version_ls==c<<16
    section=binary.get_section('pck');offset=section.pointerto_raw_data
    assert 1_000_000<offset<path.stat().st_size
    assert offset+section.sizeof_raw_data==path.stat().st_size
    with path.open('rb') as stream:
        stream.seek(offset);assert stream.read(4)==b'GDPC','Embedded Godot pack is not reachable'
        stream.seek(-4,2);assert stream.read(4)==b'GDPC','Embedded pack footer missing'
    digest=hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(1024*1024),b''):digest.update(block)
    return {'version':version,'author':'CodexAI','icon_sizes':[i.width or 256 for i in got],
            'embedded_pack_offset':offset,'embedded_pack_reachable':True,'sha256':digest.hexdigest(),
            'native_windows_start_tested':False,'signed':False}

def export(template,output,godot):
    root=pathlib.Path(__file__).resolve().parents[2];path=root/'export_presets.cfg';original=path.read_text()
    version=re.search(r'^config/version="([^"]+)"',(root/'project.godot').read_text(),re.M).group(1)
    cfg=configparser.ConfigParser(interpolation=None);cfg.read_string(original)
    section=next(s for s in cfg.sections() if cfg[s].get('platform')=='"Windows Desktop"')
    preset=cfg[section]['name'].strip('"');icon=root/cfg[section+'.options']['application/icon'].strip('"').removeprefix('res://')
    output=pathlib.Path(output).resolve();output.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='shadepi-windows-template-') as folder:
        custom=pathlib.Path(folder)/'shadepi.exe';report=prepare(template,icon,custom,version)
        pattern=r'(\['+re.escape(section+'.options')+r'\]\n)([\s\S]*?)(?=\n\[|\Z)'
        def block(match):
            options=re.sub(r'^custom_template/release=.*$',lambda _: 'custom_template/release='+json.dumps(str(custom)),match[2],flags=re.M)
            return match[1]+options
        changed,count=re.subn(pattern,block,original);assert count==1
        try:
            path.write_text(changed)
            subprocess.run([godot,'--headless','--path',str(root),'--export-release',preset,str(output)],check=True)
        finally:path.write_text(original)
    report.update(verify(output,icon,version))
    proof=output.with_suffix('.verification.json');proof.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2));return report

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--template',required=True);p.add_argument('--output',required=True);p.add_argument('--godot',default=os.environ.get('GODOT_BIN','godot'));a=p.parse_args()
    export(a.template,a.output,a.godot)
