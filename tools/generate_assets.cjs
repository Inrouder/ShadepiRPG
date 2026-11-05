// Generates only lighting and basic sounds; no character/level art.
// Run: npm ci && npm run assets
"use strict";
const { createCanvas } = require("@napi-rs/canvas");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
function save(canvas, filename) {
  const dest = path.join(root, "assets", filename);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, canvas.toBuffer("image/png"));
}
function light() {
  const c = createCanvas(128,128), p = c.getContext("2d");
  const gradient = p.createRadialGradient(64,64,0,64,64,64);
  gradient.addColorStop(0,"rgba(255,255,255,0.8)");
  gradient.addColorStop(.25,"rgba(255,255,255,0.38)");
  gradient.addColorStop(1,"rgba(255,255,255,0)");
  p.fillStyle=gradient; p.fillRect(0,0,128,128);
  save(c,"world/light.png");
}
let seed=81;
function rnd() { seed=seed*16807%2147483647; return seed/2147483647; }
function wav(filename, seconds, fn) {
  const rate=22050, samples=Math.floor(seconds*rate);
  const output=Buffer.alloc(44+samples*2);
  output.write("RIFF",0); output.writeUInt32LE(36+samples*2,4);
  output.write("WAVEfmt ",8); output.writeUInt32LE(16,16);
  output.writeUInt16LE(1,20); output.writeUInt16LE(1,22);
  output.writeUInt32LE(rate,24); output.writeUInt32LE(rate*2,28);
  output.writeUInt16LE(2,32); output.writeUInt16LE(16,34);
  output.write("data",36); output.writeUInt32LE(samples*2,40);
  for(let i=0;i<samples;i++) {
    const amp=Math.max(-1,Math.min(1,fn(i/rate,i,samples)));
    output.writeInt16LE(Math.round(amp*32767),44+i*2);
  }
  fs.writeFileSync(path.join(root,"assets/audio",filename),output);
}
function audio() {
  const tau=Math.PI*2;
  wav("neon-loop.wav",16,t=>{
    const beat=t%0.5,notes=[110,130.8128,146.8324,130.8128],hz=notes[Math.floor(t/4)%4];
    const bass=Math.sin(tau*hz*t)*.08*(.6+.4*Math.cos(tau*t/4));
    const pulse=Math.sin(tau*hz*2*t)*.035*Math.exp(-beat*10);
    const pad=(Math.sin(tau*220*t)+Math.sin(tau*261.6256*t)+Math.sin(tau*329.6276*t))*.016;
    return (bass+pulse+pad)*Math.min(1,t*4,(16-t)*4);
  });
  wav("slash.wav",.2,t=>(rnd()*2-1)*.25*Math.exp(-t*24)+Math.sin(tau*(700*t-900*t*t))*.14*Math.exp(-t*25));
  wav("hit.wav",.17,t=>((rnd()*2-1)*.23+Math.sin(tau*90*t)*.25)*Math.exp(-t*32));
  wav("hack.wav",.5,t=>Math.sin(tau*(420*t+600*t*t))*.1*Math.pow(Math.sin(Math.PI*t/.5),2));
}
light(); audio();
console.log("Light and sound rebuilt; HQ sprites, painted levels and app icon untouched.");
