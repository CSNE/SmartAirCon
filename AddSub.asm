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
errMsg2 BYTE "Error reading file.", 0dh, 0ah, 0
errMsg3 BYTE "Error: Buffer too small for the file", 0dh, 0ah, 0

ReadInput PROTO
Manual PROTO
Automatic PROTO
Output PROTO
JukJulHan PROTO

.code
main PROC
	;input.txt 파일 열기
	mov edx, OFFSET filename
	call OpenInputFile
	mov fileHandle, eax
	;에러잡기
	cmp eax, INVALID_HANDLE_VALUE
	jne file_ok
	mov edx, OFFSET errMsg1		;file open 문제발생
	call WriteString
	jmp quit

file_ok:
	;input.txt 읽기
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile
	jnc check_buffer_size			;reading에 문제있는가?
	mov edx, OFFSET errMsg2
	call WriteString
	jmp close_file

check_buffer_size:
	call dumpRegs
	cmp eax, BUFFER_SIZE
	jb buf_size_ok					;buffer 크기가 충분히 큰가? 지금 input.txt는 크기가 878인듯 함
	mov edx, OFFSET errMsg3			;아니!
	call WriteString
	jmp quit

buf_size_ok:
	
	;모든 줄 읽으려면 루프 돌아야되는데 이거 메인에서 하나..? 메인 은근 할거 많은데?!!?!? 나중에 함수들 다짜고 짜야겄구만!
	
	INVOKE ReadInput				;ReadInput을 어떻게 구현할지 몰라서 파일 열어만 뒀엉

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