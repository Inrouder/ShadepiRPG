#!/usr/bin/env python3
"""v0.62.0 CodexAI: run two independent peers; never reuse real player saves."""
import argparse
import os
from pathlib import Path
import subprocess
import socket
import tempfile

parser=argparse.ArgumentParser()
parser.add_argument('--native',action='store_true',help='requires a native DISPLAY, captures actual video')
parser.add_argument("--capture",action="store_true",help="also save native client film frames in /tmp")
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
out=Path(tempfile.mkdtemp(prefix='shadepi-lan-'))
sock=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
sock.bind(("127.0.0.1",0))
port=sock.getsockname()[1]
sock.close()
jobs=[]
try:
    for role in ['host','client']:
        log=(out/(role+'.log')).open('w')
        mode=['--audio-driver','Dummy'] if args.native else ['--headless']
        test='lan_native' if args.native else 'lan_peer'
        cmd=[os.environ.get('GODOT_BIN','godot'),*mode,'--script','res://tests/'+test+'.gd','--','--lan-'+role,'--test-port='+str(port)]
        if args.native and role=='client':
            cmd+=['--touch-controls']
            if args.capture:cmd+=['--lan-film']
        process=subprocess.Popen(cmd,cwd=root,env=dict(os.environ,XDG_DATA_HOME=str(out/role)),stdout=log,stderr=subprocess.STDOUT)
        jobs.append((role,process,log))
    bad=False
    for role,process,log in jobs:
        try: code=process.wait(timeout=45 if args.native else 25)
        except subprocess.TimeoutExpired:process.kill();process.wait();code=124
        log.close()
        text=(out/(role+'.log')).read_text()
        print(role, 'exit', code, text[-1800:])
        bad |= code!=0 or any(term in text for term in ['SCRIPT ERROR','ERROR:','FAIL:'])
    print('Peer logs:',out)
    raise SystemExit(1 if bad else 0)
finally:
    for _,process,log in jobs:
        if process.poll() is None:process.kill();process.wait()
        if not log.closed:log.close()
