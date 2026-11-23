#!/usr/bin/env python3
"""v0.69.2 · CodexAI: patch a Windows TEMPLATE, before Godot embeds its PCK.

Pinned dependency: lief==0.17.1. No Wine, no signing or gameplay modifications.
"""
import argparse, hashlib, json, pathlib, struct
import lief

def icon_blobs(path):
    data=pathlib.Path(path).read_bytes()
    reserved,kind,count=struct.unpack_from('<HHH',data)
    assert (reserved,kind)==(0,1) and count==6
    result=[]
    for i in range(count):
        entry=data[6+16*i:22+16*i]
        size,offset=struct.unpack_from('<II',entry,8)
        assert offset+size<=len(data)
        # LIEF deserializes one complete ICO image at a time.
        single=struct.pack('<HHH',0,1,1)+entry[:12]+struct.pack('<I',22)+data[offset:offset+size]
        result.append(lief.PE.ResourceIcon.from_serialization(single))
    return result

def node(key,value=b'',children=(),text=False):
    out=bytearray(b'\0'*6+key.encode('utf-16le')+b'\0\0')
    out.extend(b'\0'*((-len(out))%4));out.extend(value)
    for child in children:
        out.extend(b'\0'*((-len(out))%4));out.extend(child)
    struct.pack_into('<HHH',out,0,len(out),len(value)//2 if text else len(value),int(text))
    return bytes(out)

def version_info(version):
    a,b,c=map(int,version.split('.'));ms=(a<<16)|b;ls=c<<16
    fixed=struct.pack('<13I',0xfeef04bd,0x10000,ms,ls,ms,ls,0x3f,0,0x40004,1,0,0,0)
    strings={'CompanyName':'Shadepi Universum','FileDescription':'Shadepi - Echos in Neon',
             'FileVersion':version+'.0','ProductName':'Shadepi - Echos in Neon',
             'ProductVersion':version+'.0','InternalName':'ShadepiRPG',
             'OriginalFilename':'Shadepi-Echos-in-Neon.exe'}
    table=node('040904b0',children=[node(k,(v+'\0').encode('utf-16le'),text=True) for k,v in strings.items()],text=True)
    return node('VS_VERSION_INFO',fixed,[node('StringFileInfo',children=[table],text=True),node('VarFileInfo',children=[node('Translation',struct.pack('<HH',0x409,1200))],text=True)])

def prepare(template,icon,output,version):
    binary=lief.PE.parse(str(template));assert binary and binary.has_resources
    before={s.name:bytes(s.content) for s in binary.sections if s.name!='.rsrc'}
    assert 'pck' in before,'Missing Godot embedded-pack descriptor'
    originals=list(binary.resources_manager.icons);new=icon_blobs(icon)
    assert len(originals)==len(new)==6
    for old,fresh in zip(originals,new):
        fresh.id=old.id;fresh.lang=old.lang;fresh.sublang=old.sublang
        binary.resources_manager.change_icon(old,fresh)
    version_root=next(n for n in binary.resources.childs if n.id==16)
    for language in version_root.childs[0].childs:language.content=version_info(version)
    config=lief.PE.Builder.config_t()
    config.debug=False;config.load_configuration=False;config.relocations=False;config.tls=False
    builder=lief.PE.Builder(binary,config);builder.build();builder.write(str(output))
    result=lief.PE.parse(str(output));actual=list(result.resources_manager.icons)
    assert len(actual)==6
    for expected,got in zip(new,actual):
        assert bytes(expected.pixels)==bytes(got.pixels) and (expected.width,expected.height)==(got.width,got.height)
    for name,data in before.items():assert bytes(result.get_section(name).content)==data,'Changed executable section '+name
    info=result.resources_manager.version[0].file_info;a,b,c=map(int,version.split('.'))
    assert info.file_version_ms==(a<<16)|b and info.file_version_ls==c<<16
    return {'version':version,'author':'CodexAI','icon_sizes':sorted([i.width or 256 for i in actual]),
            'unchanged_code_and_pck_descriptor':True,'sha256':hashlib.sha256(pathlib.Path(output).read_bytes()).hexdigest()}

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('template');p.add_argument('icon');p.add_argument('output');p.add_argument('version');a=p.parse_args()
    print(json.dumps(prepare(a.template,a.icon,a.output,a.version),indent=2))
