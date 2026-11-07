"""Original procedural nanite-transfer crackles; no recordings or external samples."""
from pathlib import Path
import math, random, struct, wave
rng=random.Random(2607)
rate=44100
length=1.1
samples=[0.0]*int(rate*length)
for _ in range(42):
 start=rng.randrange(len(samples)-1500)
 size=rng.randrange(70,1150)
 pitch=rng.uniform(1200,6800)
 gain=rng.uniform(.08,.32)
 for i in range(size):
  envelope=(1-i/size)**3
  samples[start+i]+=gain*envelope*(rng.uniform(-1,1)*.72+math.sin(i/rate*pitch*math.tau)*.28)
for i in range(len(samples)):
 t=i/rate
 samples[i]+=.012*math.sin(math.tau*(540*t+650*t*t))*math.sin(math.pi*t/length)**2
peak=max(abs(v) for v in samples)
output=Path(__file__).resolve().parents[1]/'assets/audio/legacy_transfer.wav'
with wave.open(str(output),'wb') as file:
 file.setnchannels(1);file.setsampwidth(2);file.setframerate(rate)
 file.writeframes(b''.join(struct.pack('<h',int(v/peak*.48*32767)) for v in samples))
print(output.name,len(samples),'samples, original seeded synthesis')
# Seamless low energy roar with periodic harmonics, no external sound source.
rate=44100
length=1.0
rng=random.Random(2807)
noise=0.0
values=[]
for i in range(rate):
 t=i/rate
 noise=noise*.88+rng.uniform(-1,1)*.12
 envelope=.85+.15*math.sin(math.tau*2*t)
 values.append(envelope*(.11*math.sin(math.tau*84*t)+.07*math.sin(math.tau*168*t)+.025*math.sin(math.tau*420*t)+noise*.16))
# Noise vanishes at the seam while the integer-period tones remain continuous.
for i in range(rate):
 t=i/rate
 tonal=.11*math.sin(math.tau*84*t)+.07*math.sin(math.tau*168*t)+.025*math.sin(math.tau*420*t)
 values[i]=tonal+(values[i]-tonal)*math.sin(math.pi*t)**2
output=output.with_name('legacy_aura.wav')
with wave.open(str(output),'wb') as file:
 file.setnchannels(1);file.setsampwidth(2);file.setframerate(rate)
 file.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,v))*32767)) for v in values))
print(output.name,'1-second original looping aura sound')
