"""Deterministic original mechanical/weapon sounds. No third-party recordings."""
import math, random, struct, wave
from pathlib import Path
rng = random.Random(2534)
root = Path(__file__).resolve().parents[1] / 'assets/audio'
def render(name, seconds, sample):
    with wave.open(str(root / ('drive_' + name + '.wav')), 'wb') as out:
        out.setparams((1, 2, 22050, 0, 'NONE', 'not compressed'))
        out.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, sample(i/22050))) * 25000)) for i in range(int(seconds*22050))))
def tone(hz, t): return math.sin(math.tau*hz*t)
render('knock', .18, lambda t: (tone(155,t)*.65+tone(410,t)*.2+rng.uniform(-.12,.12))*math.exp(-t*36))
render('engine_fail', 1.25, lambda t: (tone(100-35*t,t)*.35+rng.uniform(-.22,.22))*(.5+.5*math.sin(t*45))*max(0,1-t/1.25))
render('engine_restart', 1.3, lambda t: (math.sin(math.tau*(40*t+145*t*t))*.45+rng.uniform(-.13,.13))*min(1,t*8)*min(1,(1.3-t)*3))
render('shot', .13, lambda t: (rng.uniform(-.65,.65)+tone(130,t)*.3)*math.exp(-t*40))
render('explosion', .9, lambda t: (rng.uniform(-.6,.6)+tone(48,t)*.4)*math.exp(-t*6)*min(1,t*120))
