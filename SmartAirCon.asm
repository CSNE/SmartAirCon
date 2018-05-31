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
x SWORD ?	;자동일때 x(현재 온도)하나 받는거 저장할 변수
y SWORD ?	;자동일때 결과 온도 반환할 변수
x1 SWORD -50
y1 SWORD -50
x2 SWORD 1000
y2 SWORD 1000
filename BYTE "input.txt",0
fileHandle DWORD ?	;handle to output file
buffer BYTE BUFFER_SIZE DUP(?) ;파일 내용 저장
readProgress DWORD 0 ;파일을 어디까지 읽었는지. ReadInput에서 사용

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
	;디버깅용 메시지
	mov edx, OFFSET debugMsg1
	call WriteString

	;input.txt 파일 열기 (핸들 취득)
	mov edx, OFFSET filename
	call OpenInputFile
	mov fileHandle, eax

	;디버깅용 메시지
	mov edx, OFFSET debugMsg3
	call WriteString
	call WriteHex
	call Crlf

	;파일 핸들 에러잡기 (에러있으면 -> error_invalid_file_handle)
	cmp eax, INVALID_HANDLE_VALUE
	je error_invalid_file_handle

read_file:
	;디버깅용 메시지
	mov edx, OFFSET debugMsg2
	call WriteString

	;input.txt 읽기
	mov edx, OFFSET buffer
	mov ecx, BUFFER_SIZE
	call ReadFromFile

	;Read에 에러났는지 체크 (에러있으면 -> error_file_read)
	jc error_file_read		

	;buffer 크기가 충분한지 체크. 지금 input.txt는 크기가 878인듯 함
	;(충분하지 않으면 -> error_buffer_overflow)
	cmp eax, BUFFER_SIZE
	jnb error_buffer_overflow

	;디버깅용 메시지
	mov edx, OFFSET debugMsg4
	call WriteString
	call WriteInt
	call Crlf
	
mainloop:
	
	;모든 줄 읽으려면 루프 돌아야되는데 이거 메인에서 하나..? 메인 은근 할거 많은데?!!?!? 나중에 함수들 다짜고 짜야겄구만!
	

if_manual:


	
if_automatic:
	mov ax, x		;imul 쓰려고 ax에 x를 옮겨둠
	INVOKE Automatic
	mov y, ax		;y = a*x+b
	jmp close_file	;에러 안나고 정상적으로 자동 수행했을 경우 파일 닫기

error_invalid_file_handle:
	mov edx, OFFSET errMsg1		;file open 문제발생
	call WriteString
	jmp quit

error_file_read:
	mov edx, OFFSET errMsg2
	call WriteString
	jmp close_file

error_buffer_overflow:
	mov edx, OFFSET errMsg3			;아니!
	call WriteString
	jmp quit

close_file:
	mov eax, fileHandle
	call CloseFile

quit:
	exit
main ENDP

ReadInput  PROC
	;ax -> 아스키? ('a'=97 | 'm'=109)
	;bx -> 숫자*10
	;cx -> 숫자*10 => 옵션
	;더 읽을 게 없다면 ax=0
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
	add ax, b		;ax = a*x+b

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