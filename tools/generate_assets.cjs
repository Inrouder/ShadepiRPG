// Original raster art for ShadepiRPG. Rebuild with `npm ci && npm run assets`.
const { createCanvas } = require('@napi-rs/canvas');
const fs = require('node:fs'); const path = require('node:path');
const ROOT=path.resolve(__dirname, '..');
const document={createElement:()=>createCanvas(48,64)};
const colors={outline:'#080c16',black:'#111724',deep:'#182336',mid:'#26364a',light:'#405570',rim:'#7195ad',cyan:'#52d9ed',red:'#ff4265',cloth:'#242235'};
function rect(c,x,y,w,h,col){c.fillStyle=col;c.fillRect(Math.round(x),Math.round(y),w,h)}
function line(c,x0,y0,x1,y1,col,w=1){x0=Math.round(x0);y0=Math.round(y0);x1=Math.round(x1);y1=Math.round(y1);let dx=Math.abs(x1-x0),sx=x0<x1?1:-1,dy=-Math.abs(y1-y0),sy=y0<y1?1:-1,e=dx+dy;for(let n=0;n<500;n++){rect(c,x0,y0,w,w,col);if(x0===x1&&y0===y1)break;let e2=2*e;if(e2>=dy){e+=dy;x0+=sx}if(e2<=dx){e+=dx;y0+=sy}}}
function poly(c,pts,col){const ys=pts.map(p=>p[1]),lo=Math.ceil(Math.min(...ys)),hi=Math.floor(Math.max(...ys));for(let y=lo;y<=hi;y++){let cuts=[];for(let i=0;i<pts.length;i++){const a=pts[i],b=pts[(i+1)%pts.length];if((a[1]<=y&&b[1]>y)||(b[1]<=y&&a[1]>y))cuts.push(a[0]+(y-a[1])*(b[0]-a[0])/(b[1]-a[1]));}cuts.sort((a,b)=>a-b);for(let i=0;i+1<cuts.length;i+=2)rect(c,Math.ceil(cuts[i]),y,Math.floor(cuts[i+1])-Math.ceil(cuts[i])+1,1,col)}}
function sprite(state,f){const cv=document.createElement('canvas');cv.width=48;cv.height=64;const c=cv.getContext('2d');const P=colors,phase=f*Math.PI/4,walking=state==='walk',attack=state==='attack';let bob=walking?[0,1,1,0,0,1,1,0][f]:((f===3||f===4)?1:0);const sway=walking?Math.round(Math.sin(phase)*2):0,step=walking?Math.round(Math.sin(phase)*4):0;
 c.save();c.translate(0,bob);
 // Far arm, trailing fabric, sword sheath.
 poly(c,[[10,24],[15,22],[20,34],[15,44],[7+sway,49],[10,36]],P.outline);
 line(c,15,28,5,10,P.mid,2);line(c,5,10,4,7,P.red,2);
 poly(c,[[13,30],[31,31],[34-sway,49],[29-sway,47],[25,53],[21,48],[17,51],[10+sway,48]],P.outline);
 poly(c,[[14,32],[27,32],[27-sway,47],[24,49],[21,44],[17,48],[12+sway,46]],P.cloth);
 line(c,15,34,13+sway,44,P.mid);line(c,21,35,20,45,P.mid);
 // Leg silhouettes have opposite forward/backward travel; boots and knees move per frame.
 function leg(x,offset,far){const kneeY=44-Math.max(0,-offset)/2,footY=58-Math.max(0,-offset),footX=x+offset;poly(c,[[x-3,37],[x+4,37],[x+4,kneeY],[footX+3,footY],[footX-4,footY],[x-3,kneeY]],P.outline);rect(c,x-2,39,5,7,far?P.deep:P.mid);rect(c,x-3,kneeY,7,4,P.light);rect(c,x-2,kneeY,5,2,P.mid);line(c,x+1,kneeY+4,footX+1,footY-3,P.mid,3);rect(c,footX-4,footY-2,8,4,P.black);rect(c,footX-4,footY+1,9,2,P.outline);rect(c,footX-3,footY-2,5,1,P.rim);rect(c,x+2,41,1,3,far?P.mid:P.red)}
 leg(26,-step,true);leg(17,step,false);
 // Fitted segmented torso.
 poly(c,[[13,21],[27,20],[32,25],[30,36],[27,40],[15,39],[11,31]],P.outline);
 poly(c,[[15,22],[25,22],[29,26],[26,34],[16,34],[13,28]],P.mid);
 poly(c,[[15,23],[21,24],[20,30],[14,28]],P.light);
 poly(c,[[23,24],[27,23],[29,27],[26,31],[22,30]],P.deep);
 line(c,14,23,20,24,P.rim);rect(c,16,26,2,1,P.cyan);
 rect(c,16,31,11,2,P.black);rect(c,16,34,10,2,P.mid);rect(c,15,37,13,3,P.black);rect(c,22,37,3,2,P.rim);
 rect(c,12,34,3,6,P.deep);rect(c,12,34,3,1,P.light);
 // Hood and mask, asymmetric red optics.
 poly(c,[[16,11],[26,11],[29,17],[27,23],[20,25],[14,20]],P.outline);
 poly(c,[[17,13],[26,13],[27,18],[24,22],[18,21],[15,18]],P.black);
 rect(c,17,15,4,1,P.red);rect(c,24,15,2,1,'#ff6d85');rect(c,18,16,2,1,'#922b48');
 poly(c,[[18,18],[25,18],[23,22],[20,23]],P.deep);line(c,19,19,23,19,P.mid);
 // Kasa in discrete raster layers, broad silhouette and restrained metal highlights.
 poly(c,[[22,3],[41,15],[28,18],[7,17],[3,15]],P.outline);
 poly(c,[[22,4],[37,14],[27,16],[7,15]],P.deep);
 poly(c,[[22,4],[24,14],[8,14]],P.mid);
 line(c,22,5,7,14,P.light);line(c,23,5,36,14,P.light);line(c,7,15,26,17,P.rim);line(c,27,16,38,14,P.mid);
 line(c,22,6,20,13,P.light);line(c,23,7,28,13,P.mid);
 rect(c,17,18,4,1,P.red);rect(c,24,18,2,1,'#ff8194');
 // Forearm and katana, with different arm/key poses for the slash.
 let hx=32,hy=38;
 if(attack){hx=[31,32,28,34,36,35,33,32][f];hy=[36,29,23,27,33,38,39,38][f]}
 poly(c,[[28,23],[33,25],[34,32],[hx+2,hy],[hx-3,hy+2],[28,32],[26,28]],P.outline);
 rect(c,29,25,4,5,P.light);rect(c,29,26,3,4,P.mid);line(c,31,31,hx,hy-2,P.mid,3);rect(c,hx-2,hy-2,4,5,P.black);rect(c,hx-2,hy-2,3,1,P.rim);
 const angle=attack?[-1.2,-1.8,-2.1,-.7,.3,.85,.8,.75][f]:.76;
 const ex=hx+Math.cos(angle)*18,ey=hy+Math.sin(angle)*18;
 line(c,hx-2,hy-2,hx+Math.cos(angle)*3,hy+Math.sin(angle)*3,P.black,2);
 line(c,hx+Math.cos(angle)*4,hy+Math.sin(angle)*4,ex,ey,'#9e2549',3);
 line(c,hx+Math.cos(angle)*4,hy+Math.sin(angle)*4,ex,ey,P.red,2);
 line(c,hx+Math.cos(angle)*5,hy+Math.sin(angle)*5,ex,ey,'#ffbfd0');
 if(attack&&f>=3&&f<=5){for(let k=0;k<16;k++){let a=-1.4+k*.12;const r=20;rect(c,23+Math.cos(a)*r,30+Math.sin(a)*r,2,2,k>10?'#ff92a5':'#8c294b')}}
 c.restore();
 if(state==='cloak'){const pixels=c.getImageData(0,0,48,64);for(let i=0;i<pixels.data.length;i+=4){if(pixels.data[i+3]){const n=i/4,x=n%48,y=Math.floor(n/48);pixels.data[i]=40;pixels.data[i+1]=150+((x+y+f)%3)*30;pixels.data[i+2]=210;pixels.data[i+3]=((y+f*2)%9===0)?210:(((x*13+y*7+f)%11<2)?100:30)}}c.putImageData(pixels,0,0)}
 return cv}
function save(canvas, file) {const dest=path.join(ROOT,'assets',file);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.writeFileSync(dest,canvas.toBuffer('image/png'));}
function other(kind,state,f,back=false){
 const cv=createCanvas(48,64),c=cv.getContext('2d'),walk=state==='walk',p=f*Math.PI/4,bob=walk?[0,1,1,0,0,1,1,0][f]:0,step=walk?Math.round(Math.sin(p)*3):0;
 c.translate(0,bob);
 if(kind==='raven'){
  poly(c,[[16,7],[29,7],[34,15],[34,40],[29+Math.round(Math.sin(p)),48],[13,44],[10,23]],'#090c17');
  poly(c,[[16,8],[28,8],[31,19],[30,41],[26,45],[24,29],[14,37],[12,19]],'#172238');
  for(const [x,s] of [[18,step],[26,-step]]){poly(c,[[x-3,36],[x+3,36],[x+2,48],[x+s+3,58],[x+s-4,58],[x-3,48]],'#080c16');line(c,x+1,39,x+s+1,54,'#24364b',2);rect(c,x+s-4,57,8,4,'#0c1221');rect(c,x+s-3,57,5,1,'#50788b');line(c,x,40,x+s,51,'#338caa')}
  poly(c,[[17,22],[26,21],[30,27],[27,36],[29,40],[16,40],[17,34],[13,27]],'#0b1221');
  poly(c,[[18,24],[24,24],[26,29],[24,34],[19,34],[16,28]],'#2b3e56');line(c,17,25,19,33,'#46d8ec');line(c,26,26,24,35,'#227b99');rect(c,17,37,11,2,'#26394c');
  for(const x of [12,29]){rect(c,x,25,4,8,'#203249');rect(c,x,33,3,7,'#111a29');rect(c,x,38,4,3,'#26394c');rect(c,x,25,2,1,'#d3425c')}
  if(!back){poly(c,[[18,12],[27,12],[28,18],[24,23],[20,22],[16,17]],'#d2a49a');rect(c,19,17,2,1,'#ba3959');rect(c,25,17,2,1,'#ba3959');line(c,18,10,16,17,'#0c1323',3);line(c,27,10,29,19,'#121b2d',3);poly(c,[[18,9],[28,10],[26,15],[23,13],[20,16],[17,14]],'#101b30')}
  else{poly(c,[[17,10],[29,10],[31,28],[27,45],[22,39],[15,44],[13,24]],'#142239');line(c,29,17,27,37,'#1b4c72');line(c,17,20,16,37,'#2a3e58')}
  line(c,15,11,12,26,'#405b81');line(c,29,12,32,33,'#304867');
  line(c,18,23,25,23,'#83e7f0',2);
  rect(c,20,37,5,2,'#6c8ca8');rect(c,21,37,2,1,'#9be8ef');
  if(state==='attack'){
   line(c,29,30,25,40,'#354d6a',4);
   rect(c,22,38,7,9,'#101827');rect(c,23,39,4,6,'#57718b');
   rect(c,24,44,3,2,'#6ce6f0');if(f<2)rect(c,23,47,5,2,'#adf8ff');
  }
 }else{
  for(const [x,s]of [[15,step],[29,-step]]){poly(c,[[x-5,35],[x+5,35],[x+5,47],[x+s+5,58],[x+s-6,58],[x-5,47]],'#101522');rect(c,x-4,42,8,6,'#4a5366');rect(c,x-3,43,6,2,'#718696');rect(c,x+s-6,56,12,5,'#182235');rect(c,x+s-5,56,9,1,'#657184')}
  poly(c,[[12,19],[33,19],[39,28],[35,40],[10,40],[6,28]],'#111824');poly(c,[[13,21],[30,21],[34,28],[30,36],[14,35],[10,27]],'#414658');rect(c,17,25,12,7,'#283244');rect(c,19,25,7,2,'#7b6875');line(c,15,33,29,33,'#72798c');rect(c,12,37,22,4,'#192333');rect(c,21,38,5,2,'#ac5a77');
  for(const x of [4,34]){rect(c,x,23,9,11,'#566071');rect(c,x+1,24,7,3,'#89919e');rect(c,x+1,30,6,2,'#b3487b');rect(c,x,34,9,9,'#263447');rect(c,x+1,41,9,6,'#172231');rect(c,x+2,42,7,2,'#728091')}
  poly(c,[[17,8],[27,8],[30,13],[29,20],[23,24],[16,20],[15,13]],'#ad8b87');poly(c,[[16,9],[26,8],[29,12],[25,13],[20,11],[17,15]],'#3c3544');rect(c,16,17,5,2,'#291e2e');rect(c,24,16,5,2,back?'#5b5360':'#ee4c8f');rect(c,23,21,5,1,'#6a4b52');
  if(back){rect(c,17,12,11,10,'#584b59');rect(c,19,15,7,3,'#333649')}
 }
 return cv;
}
// Draw a profile or a three-quarter view with a walk cycle along the heading.
function directionalHero(kind, state, frame, view) {
 const canvas = createCanvas(48, 64);
 const c = canvas.getContext('2d');
 const shadepi = kind === 'shadepi';
 const rear = view === 'back' || view === 'back-right';
 const profile = view === 'right';
 const back = view === 'back';
 const walk = state === 'walk';
 const stride = walk ? Math.sin(frame * Math.PI / 4) : 0;
 const bob = walk ? [0, -1, -1, 0, 0, -1, -1, 0][frame] : 0;
 const outline = '#080c17';
 const dark = shadepi ? '#192337' : '#182941';
 const mid = shadepi ? '#304259' : '#27435b';
 const edge = shadepi ? '#56728a' : '#48a6c7';
 const accent = shadepi ? '#ff5276' : '#44d7e8';
 const shoulder = profile ? 6 : back ? 11 : 9;
 const head = back ? 23 : profile ? 26 : 25;
 c.translate(0, bob);

 // The trailing foot passes the planted foot. Diagonal steps also change depth.
 function boot(hipX, swing, far) {
  const toe = Math.round(hipX + (back ? 0 : swing * 6));
  const rise = Math.round(Math.max(0, swing) * (back ? 6 : 4));
  const floor = 59 - rise - (far ? 2 : 0);
  const knee = Math.round((hipX + toe) / 2);
  poly(c, [[hipX - 4, 35], [hipX + 4, 35], [knee + 4, 47],
   [toe + 4, floor - 2], [toe - 3, floor - 2], [knee - 4, 47]], outline);
  line(c, hipX, 38, knee, 47, far ? dark : mid, 4);
  line(c, knee, 47, toe, floor - 2, far ? dark : mid, 4);
  rect(c, knee - 2, 46, 5, 3, far ? mid : edge);
  rect(c, toe - 3, floor - 3, back ? 7 : 9, 5, outline);
  rect(c, toe - 2, floor - 3, back ? 5 : 7, 2, far ? dark : mid);
 }
 boot(profile ? 25 : 28, -stride, true);
 boot(profile ? 21 : 19, stride, false);
 if (shadepi) {
  const tail = Math.round(stride * 2);
  poly(c, [[16, 32], [28, 33], [29, 48], [24, 45], [19 + tail, 51], [12 + tail, 47]], outline);
  poly(c, [[17, 34], [26, 34], [25, 44], [19 + tail, 48], [14 + tail, 46]], '#2b2b40');
  line(c, 19, 36, 17 + tail, 46, dark);
 }
 // Asymmetric shoulders and armour distinguish the side and rear silhouettes.
 poly(c, [[23 - shoulder, 23], [22, 20], [24 + shoulder, 24],
  [29, 35], [28, 40], [17, 40], [15, 32]], outline);
 poly(c, [[25 - shoulder, 24], [22, 22], [22 + shoulder, 25],
  [27, 36], [18, 37], [17, 30]], dark);
 poly(c, [[19, 24], [profile ? 27 : 30, 25], [26, 34], [18, 34]], mid);
 line(c, 17, 36, 28, 36, '#0c1322', 2);
 if (rear) {
  line(c, 17, 26, 26, 23, edge);
  rect(c, 22, 27, 3, 8, '#132437');
  rect(c, 22, 29, 2, 2, accent);
 } else {
  line(c, 26, 24, 29, 28, edge);
  rect(c, 26, 28, 3, 2, accent);
 }
 // The nearer arm swings with the opposite leg.
 const handX = 23 + Math.round(-stride * 4) + (state === 'attack' ? 7 : 0);
 const handY = state === 'attack' ? 30 : 39;
 line(c, 20, 26, handX, handY, outline, 6);
 line(c, 20, 27, handX, handY - 2, mid, 4);
 rect(c, 19, 26, 5, 3, edge);
 rect(c, handX, handY, 4, 3, dark);

 if (shadepi) {
  // Hat brim stays in world orientation while the mask turns under it.
  poly(c, [[head - 7, 13], [head + 6, 13], [head + 9, 19],
   [head + 5, 24], [head - 6, 23]], outline);
  poly(c, [[head - 5, 16], [head + 5, 16], [head + 6, 21], [head - 3, 23]], dark);
  const left = back ? 5 : profile ? 8 : 7;
  const right = back ? 41 : profile ? 41 : 43;
  poly(c, [[head - 3, 3], [right, 15], [head + 5, 18], [left, 16]], outline);
  poly(c, [[head - 3, 5], [right - 3, 14], [head + 4, 16], [left + 3, 15]], mid);
  line(c, head - 3, 5, left + 3, 15, edge);
  line(c, head - 3, 6, head + 1, 15, dark);
  line(c, left + 3, 16, right - 2, 15, rear ? '#435368' : edge);
  if (!rear) rect(c, head + 4, 19, profile ? 3 : 4, 1, accent);
  const bladeX = state === 'attack' ? 44 : rear ? 37 : 43;
  const bladeY = state === 'attack' ? (rear ? 12 : 24) : rear ? 25 : 46;
  line(c, handX + 2, handY + 1, bladeX, bladeY, '#a32f53', 3);
  line(c, handX + 4, handY, bladeX, bladeY, accent, 2);
  line(c, handX + 5, handY, bladeX, bladeY, '#ffd0df');
 } else {
  const hair = Math.round(stride * 2);
  poly(c, [[head - 9, 10], [head - 3, 6], [head + 5, 7], [head + 9, 13],
   [head + 5, 22], [head + 2 + hair, 40], [head - 5 + hair, 45],
   [head - 12 + hair, 41], [head - 9, 26]], outline);
  poly(c, [[head - 7, 12], [head - 2, 8], [head + 5, 10], [head + 6, 17],
   [head + hair, 38], [head - 7 + hair, 42], [head - 9, 36]], '#1b2d4a');
  line(c, head - 5, 13, head - 8 + hair, 39, '#405b81');
  line(c, head - 7, 19, head - 10 + hair, 34, '#293f62');
  line(c, head + 1, 23, head + 5, 24, '#83e7f0', 2);
  rect(c, 25, 37, 5, 2, '#607791');
  line(c, head, 12, head - 3 + hair, 35, '#264465');
  if (!rear) {
   poly(c, [[head + 1, 12], [head + 6, 13], [head + 8, 18],
    [head + 5, 22], [head + 1, 21]], '#d2a49a');
   rect(c, head + 5, 16, 2, 1, '#9c405f');
   line(c, head - 1, 10, head + 5, 13, '#152238', 2);
  }
  // Cyan sleeve and device remain visible in the back view.
  line(c, 24, 26, handX + 4, handY, mid, 4);
  rect(c, handX + 4, handY - 2, 3, 3, accent);
  if (state === 'attack') {
   rect(c, handX + 5, handY - 3, 9, 5, '#1e7790');
   rect(c, handX + 7, handY - 2, 6, 2, '#62e7fa');
  }
 }
 return canvas;
}

const modes = ['idle', 'walk', 'attack', 'hurt'];
const heroViews = ['front', 'right', 'right', 'back', 'back-right', 'back-right', 'front-right', 'front-right'];
// Each gang member has a separate silhouette, cyberware palette and metal weapon.
function punkFrame(variant, state, frame, view) {
 const canvas = createCanvas(48, 64);
 const c = canvas.getContext('2d');
 const side = view === 2, back = view === 3;
 const walking = state === 'walk', attacking = state === 'attack';
 const step = walking ? Math.round(Math.sin(frame * Math.PI / 4) * 5) : 0;
 const swing = attacking ? Math.sin(frame / 7 * Math.PI) : 0;
 const dark = '#0a0e17', metal = '#768b99', shine = '#c1d4d9';
 const [coat, lapel, hair, trousers] = [
  ['#782d41','#bf4b56','#fa6035','#292b43'],
  ['#3e6354','#70957c','#94eea8','#302b38'],
  ['#53356e','#9564ae','#bc61f3','#32374b'],
  ['#8d602a','#c38e45','#e7d689','#383139'],
 ][variant];
 const head = side ? 26 : 23;
 c.translate(state === 'hurt' ? -3 : 0, Math.abs(step) > 3 ? 1 : 0);
 for (const direction of [-1, 1]) {
  const x = 23 + direction * (side ? 3 : 5);
  line(c, x, 39, x + direction * step, 53, dark, 7);
  line(c, x + 1, 39, x + direction * step + 1, 49, trousers, 5);
  rect(c, x + direction * step - 1, 52, 9, 5, dark);
  rect(c, x + direction * step, 53, 6, 2, '#4b5264');
 }
 const handX = Math.round((side ? 31 : 34) + swing * 5);
 const handY = Math.round(39 - swing * 14 + step * 0.25);
 line(c, 13, 28, 10, 38 - step * 0.5, dark, 7);
 line(c, 14, 28, 12, 37 - step * 0.5, coat, 4);
 poly(c, [[12,24],[31,23],[34,33],[30,44],[16,44],[11,33]], dark);
 poly(c, [[14,26],[30,25],[31,32],[28,42],[17,42],[14,33]], coat);
 line(c, 16, 28, 20, 40, lapel, 2);
 line(c, 25, 27, 28, 38, lapel, 2);
 rect(c, 18, 39, 12, 2, '#202435');
 rect(c, 23, 39, 3, 2, metal);
 rect(c, 20, 31, 6, 2, back ? '#e85455' : '#303143');
 line(c, 28, 28, handX, handY, dark, 7);
 line(c, 29, 29, handX + 1, handY, coat, 4);
 rect(c, handX, handY, 4, 5, metal);
 const tipX = Math.round(handX + swing * 8 - 3), tipY = Math.round(handY - 17 + swing * 13);
 line(c, handX + 1, handY + 2, tipX, tipY, dark, 4);
 line(c, handX + 2, handY + 1, tipX + 1, tipY, metal, 2);
 line(c, tipX + 2, tipY, tipX + 3, tipY + 6, shine, variant % 2 === 0 ? 3 : 1);
 rect(c, head - 8, 9, 17, 16, dark);
 rect(c, head - 6, 11, 13, 12, back ? '#403549' : '#a37770');
 if (variant === 0) {
  rect(c, head - 3, 3, 6, 10, hair);
  rect(c, head, 2, 4, 5, hair);
 } else if (variant === 1) {
  poly(c, [[head-8,11],[head-7,6],[head+1,4],[head+7,8],[head+5,14],[head-3,12]], hair);
 } else if (variant === 2) {
  for (const offset of [-6, -1, 4]) line(c, head + offset, 10, head + offset + 2, 4, hair, 3);
 } else {
  rect(c, head - 7, 7, 13, 5, hair);
  line(c, head - 5, 9, head - 8, 22, hair, 3);
 }
 if (!back) {
  rect(c, head - 6, 15, side ? 13 : 14, 7, '#2c2334');
  for (const offset of (side ? [2, 5] : [-4, 0, 4])) rect(c, head + offset, 16, 2, 2, '#ff4f5e');
  rect(c, head - 3, 21, 8, 3, metal);
  rect(c, head - 1, 22, 4, 1, dark);
 } else {
  line(c, head, 15, head, 24, metal, 2);
  rect(c, head - 1, 20, 2, 2, '#ff4f5e');
 }
 return canvas;
}

for (let variant = 0; variant < 4 && !process.argv.includes("--raven-only"); variant++) {
 const sheet = createCanvas(384, 1024);
 const c = sheet.getContext('2d');
 modes.forEach((state, group) => {
  for (let direction = 0; direction < 4; direction++) {
   for (let frame = 0; frame < 8; frame++) {
    c.save();
    c.translate(frame * 48 + (direction === 1 ? 48 : 0), (group * 4 + direction) * 64);
    if (direction === 1) c.scale(-1, 1);
    c.drawImage(punkFrame(variant, state, frame, direction === 1 ? 2 : direction), 0, 0);
    c.restore();
   }
  }
 });
 save(sheet, 'sprites/punk-' + (variant + 1) + '.png');
}
// Bingo Street's west block, aligned with the chapter's pavement and collision lines.
function bingoStreet() {
 const canvas = createCanvas(640, 640);
 const c = canvas.getContext('2d');
 rect(c, 0, 0, 640, 640, '#182332');
 for (let y = 272; y < 496; y += 16) {
  line(c, 0, y, 639, y, '#293549');
  for (let x = -(y % 32); x < 640; x += 46) line(c, x, y, x + 5, y + 15, '#111d2e');
 }
 let seed = 61;
 const random = () => (seed = seed * 16807 % 2147483647) / 2147483647;
 for (let i = 0; i < 2600; i++) {
  rect(c, random() * 640, 274 + random() * 219, 1 + Math.floor(random() * 5), 1, random() > 0.56 ? '#293e4e' : '#202c3c');
 }
 for (const [x, y, tint] of [[95,309,'#57354e'],[272,413,'#48384d'],[436,351,'#374957'],[551,452,'#4c3047']]) {
  for (let i = 0; i < 35; i++) rect(c, x + random() * 56, y + random() * 23, 3 + Math.floor(random() * 14), 1, tint);
 }
 for (const [y, height] of [[0,272],[496,144]]) {
  rect(c, 0, y, 640, height, '#121b2c');
  for (let yy = y + 7; yy < y + height; yy += 10) {
   for (let x = -(yy % 20); x < 640; x += 32) rect(c, x, yy, 30, 8, yy < y + height - 48 ? '#222d3e' : '#28364b');
  }
  rect(c, 0, y + height - 2, 640, 2, '#475467');
 }
 for (const x of [73, 301, 485, 574]) {
  rect(c, x - 2, 223, 37, 49, '#101827');
  rect(c, x, 226, 33, 44, '#38455c');
  for (let y = 229; y < 269; y += 5) rect(c, x + 2, y, 29, 1, '#1e2d40');
  rect(c, x + 24, 250, 3, 5, '#73bfbc');
 }
 for (const x of [160, 372, 522]) {
  rect(c, x, 159, 47, 48, '#101d30');
  for (let i = 0; i < 4; i++) rect(c, x + 5 + i * 10, 164, 6, 36, '#344c60');
  line(c, x + 44, 199, x + 44, 269, '#536373', 3);
 }
 for (let x = 24; x < 622; x += 26) rect(c, x, 482, 12, 2, '#515262');
 save(canvas, 'world/bingo-street.png');
}
if (!process.argv.includes('--sprites-only') && !process.argv.includes('--raven-only')) bingoStreet();
if (process.argv.includes('--chapter-only')) process.exit(0);

for (const kind of process.argv.includes('--raven-only') ? ['raven'] : ['shadepi', 'raven', 'jackal']) {
 const views = kind === 'jackal' ? heroViews.slice(0, 4) : heroViews;
 const sheet = createCanvas(384, modes.length * views.length * 64);
 const c = sheet.getContext('2d');
 c.imageSmoothingEnabled = false;
 modes.forEach((state, group) => {
  views.forEach((view, direction) => {
   for (let frame = 0; frame < 8; frame++) {
    let spriteFrame;
    if (kind === 'jackal') {
     spriteFrame = other(kind, state, frame, direction === 3);
    } else if (view === 'front') {
     spriteFrame = kind === 'shadepi' ? sprite(state === 'hurt' ? 'idle' : state, frame) : other(kind, state, frame);
    } else {
     spriteFrame = directionalHero(kind, state, frame, view);
    }
    const mirror = direction === 1 || direction === 4 || direction === 6;
    c.save();
    c.translate(frame * 48 + (mirror ? 48 : 0), (group * views.length + direction) * 64);
    if (mirror) c.scale(-1, 1);
    c.drawImage(spriteFrame, 0, 0);
    c.restore();
   }
  });
 });
 save(sheet, 'sprites/' + kind + '.png');
}
if (process.argv.includes('--sprites-only') || process.argv.includes('--raven-only')) process.exit(0);
const ground=createCanvas(1024,640),g=ground.getContext('2d');rect(g,0,0,1024,640,'#182332');
for(let y=0;y<640;y+=16){line(g,0,y,1024,y,'#263345');for(let x=-(y%32);x<1024;x+=48)line(g,x,y,x+8,y+15,'#0c1829')}
let seed=81;function rnd(){seed=seed*16807%2147483647;return seed/2147483647}
for(let i=0;i<6200;i++)rect(g,rnd()*1024,rnd()*640,1+Math.floor(rnd()*5),1,rnd()>.6?'#344557':'#202e40');
for(const [x,y,w,col]of [[70,327,78,'#4c294a'],[172,450,93,'#255162'],[338,332,60,'#35344d'],[622,440,110,'#284852'],[820,306,120,'#34345d'],[726,219,80,'#493454']]){
 for(let i=0;i<36;i++)rect(g,x+rnd()*w,y+rnd()*20,3+Math.floor(rnd()*16),1,col);
}
function building(x,y,w,h){
 rect(g,x,y,w,h,'#0c1321');rect(g,x+3,y+3,w-6,h-48,'#273143');
 for(let yy=y+8;yy<y+h-48;yy+=14)line(g,x+4,yy,x+w-5,yy,'#303b4d');
 rect(g,x,y+h-48,w,48,'#172235');
 for(let yy=y+h-47;yy<y+h;yy+=8)for(let xx=x-12;xx<x+w;xx+=25)rect(g,xx+((yy%16)?12:0),yy,24,7,((xx+yy)%3===0)?'#283448':'#202d40');
 rect(g,x,y+h-50,w,3,'#4c5869');rect(g,x,y+h-3,w,3,'#0a1220');
}
building(0,0,400,272);building(452,0,572,256);building(0,496,1024,144);
function door(x,y,w=30){rect(g,x-2,y-2,w+4,48,'#0a1220');rect(g,x,y,w,44,'#2d3d50');for(let yy=y+3;yy<y+44;yy+=5)line(g,x+2,yy,x+w-3,yy,'#1c2c3e');rect(g,x+w-6,y+22,2,4,'#68b2bd')}
door(166,225);door(912,209);door(720,593,42);
function neon(x,y,text,color){g.font='bold 13px monospace';const width=g.measureText(text).width+14;rect(g,x-2,y-2,width+4,25,'#0b1322');rect(g,x,y,width,1,color);rect(g,x,y+1,1,20,color);rect(g,x+width-1,y+1,1,20,color);g.fillStyle=color;g.fillText(text,x+7,y+15);rect(g,x,y+21,width,1,color)}
neon(40,203,'NEON / 07','#e25e9a');neon(582,199,'KOBAN-TEC','#62bfd1');neon(840,197,'NO SIGNAL','#ba6baf');
for(const [x,y]of [[258,221],[750,213],[362,590]]){rect(g,x,y,34,30,'#09121e');rect(g,x+2,y+2,30,26,'#2c4b5d');for(let n=0;n<3;n++)rect(g,x+5+n*9,y+5,4,20,'#4c8090')}
for(const x of [316,783]){rect(g,x,30,5,210,'#2b4253');rect(g,x,30,1,210,'#50788a');for(const y of [80,160,220])rect(g,x-2,y,9,3,'#1a2d40')}
// Ground markings and drains.
for(let x=50;x<1000;x+=28){rect(g,x,484,15,2,'#5d5960');rect(g,x,166,15,2,'#434c5d')}
for(const x of [204,664,923]){rect(g,x,474,36,8,'#0a1420');for(let k=0;k<8;k++)rect(g,x+2+k*4,476,2,4,'#394a5a')}
// Small raster dragon mural.
for(let i=0;i<36;i++){let a=i*.19;rect(g,350+Math.sin(a)*12,203+i,2,2,'#718195')}line(g,352,204,366,199,'#9dabb5',2);line(g,363,199,369,201,'#9dabb5',2);rect(g,365,201,1,1,'#f35c7e');
save(ground,'world/alley.png');
const props=createCanvas(128,96),pc=props.getContext('2d');
// Dumpster, 64x48; crate, 32x32; terminal, 32x48.
rect(pc,2,13,59,30,'#10212c');rect(pc,4,14,55,25,'#2b4750');rect(pc,0,8,64,7,'#3b5961');rect(pc,2,9,60,2,'#698185');rect(pc,7,39,6,5,'#0b1621');rect(pc,50,39,6,5,'#0b1621');for(const x of [14,44])line(pc,x,18,x,35,'#17313e');
rect(pc,66,11,28,20,'#352b30');poly(pc,[[65,10],[75,4],[94,6],[94,13]],'#78604d');rect(pc,68,14,23,16,'#554534');line(pc,68,15,90,29,'#a17c55');line(pc,90,15,68,29,'#9a7652');rect(pc,66,30,28,2,'#241f2a');
rect(pc,99,14,24,29,'#122130');rect(pc,101,16,20,23,'#354957');rect(pc,103,18,16,11,'#256b7f');rect(pc,105,20,12,1,'#6ce2dd');rect(pc,105,23,8,1,'#6ce2dd');rect(pc,103,32,12,2,'#182b3c');rect(pc,99,42,25,3,'#0a1320');save(props,'world/props.png');
const light=createCanvas(128,128),lc=light.getContext('2d');const grad=lc.createRadialGradient(64,64,0,64,64,64);grad.addColorStop(0,'rgba(255,255,255,0.8)');grad.addColorStop(.25,'rgba(255,255,255,0.38)');grad.addColorStop(1,'rgba(255,255,255,0)');lc.fillStyle=grad;lc.fillRect(0,0,128,128);save(light,'world/light.png');
const icon=createCanvas(128,128),ic=icon.getContext('2d');ic.imageSmoothingEnabled=false;rect(ic,0,0,128,128,'#101829');ic.drawImage(sprite('idle',0),16,-6,96,128);save(icon,'icon.png');
function wav(file,seconds,fun){const rate=22050,n=Math.floor(seconds*rate),out=Buffer.alloc(44+n*2);out.write('RIFF',0);out.writeUInt32LE(36+n*2,4);out.write('WAVEfmt ',8);out.writeUInt32LE(16,16);out.writeUInt16LE(1,20);out.writeUInt16LE(1,22);out.writeUInt32LE(rate,24);out.writeUInt32LE(rate*2,28);out.writeUInt16LE(2,32);out.writeUInt16LE(16,34);out.write('data',36);out.writeUInt32LE(n*2,40);for(let i=0;i<n;i++)out.writeInt16LE(Math.round(Math.max(-1,Math.min(1,fun(i/rate,i,n)))*32767),44+i*2);fs.writeFileSync(path.join(ROOT,'assets/audio',file),out)}
const tau=Math.PI*2;
wav('neon-loop.wav',16,t=>{const beat=t%0.5,notes=[110,130.8128,146.8324,130.8128],hz=notes[Math.floor(t/4)%4];const bass=Math.sin(tau*hz*t)*.08*(.6+.4*Math.cos(tau*t/4));const pulse=Math.sin(tau*hz*2*t)*.035*Math.exp(-beat*10);const pad=(Math.sin(tau*220*t)+Math.sin(tau*261.6256*t)+Math.sin(tau*329.6276*t))*.016;return(bass+pulse+pad)*Math.min(1,t*4,(16-t)*4)});
wav('slash.wav',.2,t=>(rnd()*2-1)*.25*Math.exp(-t*24)+Math.sin(tau*(700*t-900*t*t))*.14*Math.exp(-t*25));
wav('hit.wav',.17,t=>((rnd()*2-1)*.23+Math.sin(tau*90*t)*.25)*Math.exp(-t*32));
wav('hack.wav',.5,t=>Math.sin(tau*(420*t+600*t*t))*.1*Math.pow(Math.sin(Math.PI*t/.5),2));
console.log('Generated original raster sprites, alley, props, lights and audio.');
