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
	;ax -> �ƽ�Ű?
	;bx -> ����*10
	;cx -> ����*10 => �ɼ�
	;����
	RET
ReadInput ENDP

Manual PROC
	;x1,x2,y1,y2,a,b�� ����ؼ� anew, bnew�� ���ϰ� k�� ����
	;a,b -> anew, bnew
	;Manual : ���� �µ��� ���� ���´� �ι� �������� �ʴ´�(?)
	;������
	RET
Manual ENDP

Automatic PROC
	;x -> ax ���� -> ��ȯ �� -> y�� ����
	;����
	RET
Automatic ENDP

Output PROC
	;ax�� ���� * 10�� �ް� �����
	;����
	RET
Output ENDP

JukJulHan PROC
	;�����ϸ� ax=1
	MOV ax,1
	RET
JukJulHan ENDP

main PROC
	ReadInput PROTO
	Manual PROTO
	Automatic PROTO
	Output PROTO
	JukJulHan PROTO
	;���� �� ��Ź��!
	exit
main ENDP
END main