"""Original synthesized cybernetic grunts, groans and weapon SFX (no recordings)."""
import math,random,wave,struct
from pathlib import Path
RATE=24000
ROOT=Path(__file__).resolve().parents[1]/'assets/audio'
def save(name,data):
 peak=max(abs(x) for x in data) or 1
 with wave.open(str(ROOT/(name+'.wav')),'wb') as w:
  w.setparams((1,2,RATE,0,'NONE','PCM'))
  w.writeframes(b''.join(struct.pack('<h',round(x/peak*26000)) for x in data))
def voice(name,duration,seed,death=False):
 rng=random.Random(seed);phase=0;states=[[0.,0.] for _ in range(3)];result=[]
 for i in range(int(duration*RATE)):
  t=i/RATE;u=t/duration
  hz=(115-38*u if death else 145-32*u)+math.sin(t*39)*3
  phase=(phase+hz/RATE)%1
  glottal=(math.sin(math.pi*phase/.43)**2 if phase<.43 else -.13)*.55
  breath=rng.uniform(-1,1)*(.05+.23*u if death else .08)
  source=glottal+breath;sample=0
  for j,(freq,bw,gain) in enumerate([(530-170*u,90,1),(1150-250*u,130,.65),(2450,210,.25)]):
   r=math.exp(-math.pi*bw/RATE);coef=2*r*math.cos(math.tau*freq/RATE)
   y=source*(1-r)+coef*states[j][0]-r*r*states[j][1]
   states[j]=[y,states[j][0]];sample+=y*gain
  envelope=min(1,t/.025)*max(0,1-u)**(.7 if death else 1.6)
  if death: envelope*=.72+.28*math.sin(t*12)**2
  result.append(math.tanh(sample*2)*envelope)
 save(name,result)
for n in range(3):
 voice('enemy_hurt_'+str(n),.23+n*.045,100+n)
 voice('enemy_death_'+str(n),.85+n*.14,200+n,True)
for n in range(2):voice('enemy_attack_'+str(n),.18+n*.06,300+n)
for name,duration,zap in [('pistol',.19,False),('electric',.35,True)]:
 rng=random.Random(818);data=[]
 for i in range(int(duration*RATE)):
  t=i/RATE
  wavelet=math.sin(math.tau*(830*t+950*t*t)) if zap else math.sin(math.tau*90*t)
  data.append((rng.uniform(-1,1)*(.45 if zap else .8)+wavelet*.35)*math.exp(-t*(12 if zap else 36))*min(1,t*1500))
 save(name,data)
