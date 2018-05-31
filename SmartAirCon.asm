;ENCODING: EUC-KR

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
buffer BYTE BUFFER_SIZE DUP(?) ;���� ���� ����
readProgress DWORD 0 ;������ ������ �о�����. ReadInput���� ���

errMsg1 BYTE "Cannot open file", 0dh, 0ah, 0

debugMsg1 BYTE "Opening File...", 0dh, 0ah, 0
debugMsg2 BYTE "File opened successfully.", 0dh, 0ah, 0
debugMsg3 BYTE "File handle: ", 0
debugMsg4 BYTE "Read success. Bytes read: ", 0

ReadInput PROTO
Manual PROTO
Automatic PROTO
Output PROTO
JukJulHan PROTO

.code
main PROC

get_file_handle:
	;������ �޽���
	mov edx, OFFSET debugMsg1
	call WriteString

	;input.txt ���� ���� (�ڵ� ���)
	mov edx, OFFSET filename
	call OpenInputFile
	mov fileHandle, eax

	;������ �޽���
	mov edx, OFFSET debugMsg3
	call WriteString
	call WriteHex
	call Crlf

	;���� �ڵ� ������� (���������� -> error_invalid_file_handle)
	cmp eax, INVALID_HANDLE_VALUE
	je error_invalid_file_handle

read_file:
	;������ �޽���
	mov edx, OFFSET debugMsg2
	call WriteString

	;input.txt �б�
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile

	;Read�� ���������� üũ (���������� -> error_file_read)
	jc error_file_read		

	;buffer ũ�Ⱑ ������� üũ. ���� input.txt�� ũ�Ⱑ 878�ε� ��
	;(������� ������ -> error_buffer_overflow)
	cmp eax, BUFFER_SIZE
	jnb error_buffer_overflow

	;������ �޽���
	mov edx, OFFSET debugMsg4
	call WriteString
	call WriteInt
	call Crlf
	
mainloop:
	
	;��� �� �������� ���� ���ƾߵǴµ� �̰� ���ο��� �ϳ�..? ���� ���� �Ұ� ������?!!?!? ���߿� �Լ��� ��¥�� ¥�߰α���!
	

if_manual:


	
if_automatic:
	mov ax, x		;imul ������ ax�� x�� �Űܵ�
	INVOKE Automatic
	mov y, ax		;y = a*x+b
	jmp close_file	;���� �ȳ��� ���������� �ڵ� �������� ��� ���� �ݱ�

error_invalid_file_handle:
	mov edx, OFFSET errMsg1		;file open �����߻�
	call WriteString
	jmp quit

error_file_read:
	mov edx, OFFSET errMsg2
	call WriteString
	jmp close_file

error_buffer_overflow:
	mov edx, OFFSET errMsg3			;�ƴ�!
	call WriteString
	jmp quit

close_file:
	mov eax, fileHandle
	call CloseFile

quit:
	exit
main ENDP

ReadInput  PROC
	;ax -> �ƽ�Ű? ('a'=97 | 'm'=109)
	;bx -> ����*10
	;cx -> ����*10 => �ɼ�
	;�� ���� �� ���ٸ� ax=0
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
	add ax, b		;ax = a*x+b

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