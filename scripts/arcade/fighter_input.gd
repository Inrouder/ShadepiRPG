extends RefCounted
## v0.67.0 · CodexAI. Bounded absolute-direction ring, mirrored at recognition time.
const CAPACITY := 64
const MOTION_WINDOW := 0.38
const NEUTRAL_GRACE := 0.10
const CHARGE_SECONDS := 45.0/60.0
const RELEASE_WINDOW := 0.20
var ring: Array[Dictionary] = []
var head := 0
var count := 0
var serial := 0
var consumed := -1
var clock := 0.0
var facing := 1
var current := 5
var back_time := 0.0
var down_time := 0.0
var back_until := -1.0
var down_until := -1.0

func _init(): reset()
func reset():
	ring.clear(); ring.resize(CAPACITY)
	head=0;count=0;serial=0;consumed=-1;clock=0;current=5
	back_time=0;down_time=0;back_until=-1;down_until=-1
func set_facing(value: int):
	value=1 if value>=0 else -1
	if value!=facing:
		# A side switch cannot turn a held forward direction into a free charged release.
		back_time=0;back_until=-1
	facing=value
static func direction(x: int,y: int) -> int:
	return (8 if y<0 else 2 if y>0 else 5)+clampi(x,-1,1)
static func relative(code: int,face: int) -> int:
	if face>=0: return code
	return {1:3,3:1,4:6,6:4,7:9,9:7}.get(code,code)
func sample(x: int,y: int,face: int,delta: float):
	set_facing(face)
	var step:=clampf(delta,0,0.1)
	clock+=step
	var backward:=x*facing<0
	if backward: back_time+=step
	else:
		if back_time+0.00001>=CHARGE_SECONDS:back_until=clock+RELEASE_WINDOW
		back_time=0
	if y>0: down_time+=step
	else:
		if down_time+0.00001>=CHARGE_SECONDS:down_until=clock+RELEASE_WINDOW
		down_time=0
	var code:=direction(x,y)
	if count>0 and code==current:
		ring[posmod(head-1,CAPACITY)].end=clock
	else:
		current=code
		ring[head]={"code":code,"start":clock,"end":clock,"serial":serial}
		serial+=1;head=(head+1)%CAPACITY;count=mini(count+1,CAPACITY)
func recent_codes(after_serial: int=-1) -> Array[int]:
	var codes: Array[int]=[]
	for i in count:
		var entry: Dictionary=ring[posmod(head-1-i,CAPACITY)]
		if int(entry.serial)<=after_serial or clock-float(entry.end)>MOTION_WINDOW:break
		var code:=relative(int(entry.code),facing)
		if code==5:
			if float(entry.end)-float(entry.start)>NEUTRAL_GRACE:break
			continue
		if codes.is_empty() or code!=codes[0]:codes.push_front(code)
	return codes
func _suffix(codes: Array[int],pattern: Array) -> bool:
	if codes.size()<pattern.size():return false
	for i in pattern.size():
		if codes[codes.size()-pattern.size()+i]!=pattern[i]:return false
	return true
func _consume():
	consumed=serial-1
	back_time=0;down_time=0;back_until=-1;down_until=-1
func take_motion() -> String:
	if count==0:return ""
	var codes:=recent_codes(consumed)
	if codes.is_empty():return ""
	var last: int=codes.back()
	if last in [7,8,9] and down_until>=clock:
		_consume();return "charge_up"
	if last in [3,6,9] and back_until>=clock:
		_consume();return "charge_forward"
	if serial-1<=consumed:return ""
	for pattern in [[6,2,3,6],[6,2,3],[6,2,6],[6,3,2,3]]:
		if _suffix(codes,pattern):consumed=serial-1;return "dragon"
	for pattern in [[2,3,6],[2,6]]:
		if _suffix(codes,pattern):consumed=serial-1;return "quarter"
	return ""
func charge_fraction() -> float:
	return clampf(maxf(back_time,down_time)/CHARGE_SECONDS,0,1)
