#!/usr/bin/env python3
"""v0.67.1 · CodexAI: inspect the actual Universal Mach-O, plist and resource pack."""
import argparse,hashlib,json,pathlib,plistlib,struct,zipfile

def verify(path,version):
    path=pathlib.Path(path)
    with zipfile.ZipFile(path) as z:
        assert z.testzip() is None,'Corrupt ZIP'
        names=z.namelist();plists=[n for n in names if n.endswith('.app/Contents/Info.plist')]
        assert len(plists)==1,'Expected one .app bundle'
        plist=plistlib.loads(z.read(plists[0]));app=plists[0].split('/Contents/')[0]
        assert plist['CFBundleIdentifier']=='de.shadepi.rpg'
        assert plist['CFBundleShortVersionString']==version and plist['CFBundleVersion']==version
        executable=app+'/Contents/MacOS/'+plist['CFBundleExecutable'];binary=z.read(executable)
        assert z.getinfo(executable).external_attr>>16&0o111,'Executable bit missing'
        magic,count=struct.unpack_from('>II',binary);assert magic==0xcafebabe and count==2,'Expected Universal Mach-O'
        cpus=[]
        for i in range(count):
            cpu,_,offset,size,_=struct.unpack_from('>IIIII',binary,8+20*i)
            assert offset+size<=len(binary);assert struct.unpack_from('<I',binary,offset)[0]==0xfeedfacf
            ncmds=struct.unpack_from('<I',binary,offset+16)[0];pos=offset+32;signed=False
            for _ in range(ncmds):
                cmd,length=struct.unpack_from('<II',binary,pos);assert length>=8
                if cmd==0x1d:
                    sigoffset,sigsize=struct.unpack_from('<II',binary,pos+8);signed=sigsize>0 and sigoffset+sigsize<=size
                pos+=length
            assert signed,'Code signature missing in Mach-O slice';cpus.append(cpu)
        assert set(cpus)=={0x01000007,0x0100000c},'Missing Intel/Apple Silicon'
        packs=[n for n in names if n.startswith(app+'/Contents/Resources/') and n.endswith('.pck')]
        assert len(packs)==1 and z.getinfo(packs[0]).file_size>1_000_000,'Game resource pack missing'
        with z.open(packs[0]) as p:assert p.read(4)==b'GDPC','Wrong pack header'
        assert any(n.endswith('/_CodeSignature/CodeResources') for n in names),'Bundle signature missing'
        resources=z.getinfo(packs[0]).file_size
    digest=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):digest.update(chunk)
    return {'version':version,'author':'CodexAI','file':path.name,'bytes':path.stat().st_size,'sha256':digest.hexdigest(),'app':app,'executable':plist['CFBundleExecutable'],'architectures':['x86_64','arm64'],'resource_pack_bytes':resources,'signature':'ad-hoc','notarized':False,'native_start_tested':False}
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('zip');p.add_argument('version');p.add_argument('--output');a=p.parse_args();r=verify(a.zip,a.version);s=json.dumps(r,indent=2)+'\n';print(s)
    if a.output:pathlib.Path(a.output).write_text(s)
