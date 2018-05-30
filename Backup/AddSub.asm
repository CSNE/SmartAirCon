INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SWORD 10
b SWORD 50
a1 SWORD ?
b1 SWORD ?
anew SWORD ?
bnew SWORD ?
k SWORD 10
x SWORD ?	;�ڵ��϶� x(���� �µ�)�ϳ� �޴°� ������ ����
y SWORD ?	;�ڵ��϶� ��� �µ� ��ȯ�� ����
x1 SWORD -50
y1 SWORD -50
x2 SWORD 1000
y2 SWORD 1000
filename BYTE "input.txt",0
fileHandle DWORD ?	;handle to output file
buffer BYTE BUFFER_SIZE DUP(?)
errMsg1 BYTE "Cannot open file", 0dh, 0ah, 0
errMsg2 BYTE "Error reading file.", 0dh, 0ah, 0
errMsg3 BYTE "Error: Buffer too small for the file", 0dh, 0ah, 0

ReadInput PROTO
Manual PROTO
Automatic PROTO
Output PROTO
JukJulHan PROTO

.code
main PROC
	;input.txt ���� ����
	mov edx, OFFSET filename
	call OpenInputFile
	mov fileHandle, eax
	;�������
	cmp eax, INVALID_HANDLE_VALUE
	jne file_ok
	mov edx, OFFSET errMsg1		;file open �����߻�
	call WriteString
	jmp quit

file_ok:
	;input.txt �б�
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile
	jnc check_buffer_size			;reading�� �����ִ°�?
	mov edx, OFFSET errMsg2
	call WriteString
	jmp close_file

check_buffer_size:
	call dumpRegs
	cmp eax, BUFFER_SIZE
	jb buf_size_ok					;buffer ũ�Ⱑ ����� ū��? ���� input.txt�� ũ�Ⱑ 878�ε� ��
	mov edx, OFFSET errMsg3			;�ƴ�!
	call WriteString
	jmp quit

buf_size_ok:
	
	;��� �� �������� ���� ���ƾߵǴµ� �̰� ���ο��� �ϳ�..? ���� ���� �Ұ� ������?!!?!? ���߿� �Լ��� ��¥�� ¥�߰α���!
	
	INVOKE ReadInput				;ReadInput�� ��� �������� ���� ���� ��� �׾�

if_manual:


	
if_automatic:
	mov ax, x	;imul ������ ax�� x�� �Űܵ�
	INVOKE Automatic
	mov y, ax	;y = a*x+b


close_file:
	mov eax, fileHandle
	call CloseFile

quit:
	exit
main ENDP

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

	imul a		;ax = a*x 
	add ax, b	;ax = a*x+b

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

END main