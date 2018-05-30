INCLUDE Irvine32.inc

.data
a SWORD 10
b SWORD 50
a1 SWORD ?
b1 SWORD ?
anew SWORD ?
bnew SWORD ?
k SWORD 10
x1 SWORD -50
y1 SWORD -50
x2 SWORD 1000
y2 SWORD 1000

.code
ReadInput  PROC
	;ax -> 아스키?
	;bx -> 숫자*10
	;cx -> 숫자*10 => 옵션
	;찬솔
	RET
ReadInput ENDP

Manual PROC
	;x1,x2,y1,y2,a,b를 사용해서 anew, bnew를 구하고 k를 감소
	;a,b -> anew, bnew
	;Manual : 현재 온도가 같은 상태는 두번 저장하지 않는다(?)
	;뀪뀪이
	RET
Manual ENDP

Automatic PROC
	;x -> ax 저장 -> 변환 후 -> y에 저장
	;누나
	RET
Automatic ENDP

Output PROC
	;ax로 숫자 * 10을 받고 출력함
	;찬솔
	RET
Output ENDP

JukJulHan PROC
	;적절하면 ax=1
	MOV ax,1
	RET
JukJulHan ENDP

main PROC
	ReadInput PROTO
	Manual PROTO
	Automatic PROTO
	Output PROTO
	JukJulHan PROTO
	;누나 잘 부탁해!
	exit
main ENDP
END main