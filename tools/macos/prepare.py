#!/usr/bin/env python3
"""v0.67.1 · CodexAI: append a Mac preset without changing the game's other presets."""
import argparse,configparser,json,pathlib,platform,re

def prepare(root, tag):
    root=pathlib.Path(root)
    if not re.fullmatch(r'v\d+\.\d+\.\d+',tag):raise ValueError('Expected a version tag such as v0.67.1')
    version=re.search(r'^config/version="([^"]+)"', (root/'project.godot').read_text(),re.M).group(1)
    if tag!='v'+version:raise ValueError('Release tag and game version differ')
    path=root/'export_presets.cfg';text=path.read_text();cfg=configparser.ConfigParser(interpolation=None);cfg.read_string(text)
    sections=[s for s in cfg.sections() if re.fullmatch(r'preset\.\d+',s)]
    for s in sections:
        if cfg[s].get('platform')=='"macOS"':
            # Only replace the Mac block. Windows/Linux/Android text stays byte-identical.
            text=re.sub(r'\n?\['+re.escape(s)+r'\][\s\S]*?(?=\n\[preset\.\d+\]|\Z)','',text)
            index=int(s.split('.')[1]);break
    else:index=max(int(s.split('.')[1]) for s in sections)+1
    quote=lambda value:json.dumps(value,ensure_ascii=False)
    shared=cfg[sections[0]]
    entries={'name':'"macOS"','platform':'"macOS"','runnable':'true','dedicated_server':'false','custom_features':'""','export_filter':'"all_resources"','include_filter':shared['include_filter'],'exclude_filter':shared['exclude_filter'],'export_path':'"build/macos/ShadepiRPG-macOS.zip"','encryption_include_filters':'""','encryption_exclude_filters':'""','encrypt_pck':'false','encrypt_directory':'false','script_export_mode':'2'}
    options={'custom_template/debug':'""','custom_template/release':'""','export/distribution_type':'0','binary_format/architecture':'"universal"','debug/export_console_wrapper':'0','application/icon':'"res://assets/icon.png"','application/bundle_identifier':'"de.shadepi.rpg"','application/app_category':'"Games"','application/short_version':'""','application/version':'""','application/min_macos_version_x86_64':'"10.13"','application/min_macos_version_arm64':'"11.00"','display/high_res':'true','codesign/codesign':'3' if platform.system()=='Darwin' else '1','codesign/identity':'"-"','notarization/notarization':'0'}
    block='\n\n[preset.%d]\n'%index+'\n'.join(k+'='+v for k,v in entries.items())+'\n\n[preset.%d.options]\n'%index+'\n'.join(k+'='+v for k,v in options.items())+'\n'
    path.write_text(text.rstrip()+block)
    return {'version':version,'preset':index,'architectures':['x86_64','arm64'],'signing':'ad-hoc','notarized':False}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('game');p.add_argument('tag');a=p.parse_args();print(json.dumps(prepare(a.game,a.tag)))
