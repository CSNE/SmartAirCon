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
x SWORD ?	;자동일때 x(현재 온도)하나 받는거 저장할 변수
y SWORD ?	;자동일때 결과 온도 반환할 변수
x1 SWORD -50
y1 SWORD -50
x2 SWORD 1000
y2 SWORD 1000
filename BYTE "input.txt",0
fileHandle DWORD ?	;handle to output file
buffer BYTE BUFFER_SIZE DUP(?)
errMsg1 BYTE "Cannot open file", 0dh, 0ah, 0

ReadInput PROTO
Manual PROTO
Automatic PROTO
Output PROTO
JukJulHan PROTO

.code
main PROC
	
	INVOKE CreateFile,
		ADDR filename,GENERIC_READ,
		DO_NOT_SHARE, NULL, OPEN_EXISTING,
		FILE_ATTRIBUTE_READONLY, 0

	mov fileHandle, eax

	.IF eax == INVALID_HANDLE_VALUE
		mov edx, OFFSET errMsg1
		call WriteString
		jmp quit

	.ENDIF

	INVOKE ReadFile,
		fileHandle, ADDR buffer,
		BUFFER_SIZE, ADDR byteCount, 0

	INVOKE CloseHandle, fileHandle

	;-------------여기까지가 ppt에 나와있는 input파일 읽어서 buffer에 넣는 부분-------------




if_manual:


	
if_automatic:
	mov ax, x	;imul 쓰려고 ax에 x를 옮겨둠
	INVOKE Automatic
	mov y, ax	;y = a*x+b


close_file:
	mov eax, fileHandle
	call CloseFile

quit:
	exit
main ENDP

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

	imul a		;ax = a*x 
	add ax, b	;ax = a*x+b

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

END main