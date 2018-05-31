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
errMsg2 BYTE "Error reading file.", 0dh, 0ah, 0
errMsg3 BYTE "Error: Buffer too small for the file", 0dh, 0ah, 0

debugMsg1 BYTE "Opening File...", 0dh, 0ah, 0
debugMsg2 BYTE "File opened successfully.", 0dh, 0ah, 0
debugMsg3 BYTE "File handle: ", 0
debugMsg4 BYTE "Read success. Bytes read: ", 0
debugMsg5 BYTE "ReadInput Finish", 0
debugMsg6 BYTE "Readinput Noline", 0
debugMsg7 BYTE "Readinput unexpected char: ", 0
debugMsg8 BYTE "ReadInput Loop1", 0
debugMsg9 BYTE "ReadInput Loop2", 0
debugMsg10 BYTE "ReadInput Loop3", 0
debugMsg11 BYTE "char:", 0

dwTempVar1 DWORD ?
dwTempVar2 DWORD ?
dwTempVar3 DWORD ?
dwTempVar4 DWORD ?
dwTempVar5 DWORD ?

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
	

	readLoop:
		INVOKE ReadInput				;ReadInput을 어떻게 구현할지 몰라서 파일 열어만 뒀엉

		ADD eax,0
		JZ readLoopEnd


		CALL WriteChar
		CALL Crlf
		MOV eax,ebx
		CALL WriteInt
		CALL Crlf
		MOV eax,ecx
		CALL WriteInt
		CALL Crlf
		CALL Crlf

		JMP readLoop

	readLoopEnd:

	jmp close_file

if_manual:


	
if_automatic:
	mov ax, x	;imul 쓰려고 ax에 x를 옮겨둠
	INVOKE Automatic
	mov y, ax	;y = a*x+b


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
	;eax -> 아스키? ('a'=97 | 'm'=109)
	;ebx -> 숫자*10
	;ecx -> 숫자*10 => 옵션
	;더 읽을 게 없다면 ax=0
	;찬솔


	; *** INTERNAL VARIABLES ***
	;ECX: currently reading char address
	;BL: current character value
	;EAX,EDX: temporary

	;dwTempVar1: 1st part result
	;dwTempVar2: 2nd part result
	;dwTempVar3: 3rd part result

	MOV dwTempVar1,0
	MOV dwTempVar2,0
	MOV dwTempVar3,0


	MOV ecx, OFFSET buffer
	ADD ecx, readProgress ;ECX=first char address

	firstPartLoop:
		;get current char
		MOV bl, BYTE PTR [ecx]
		INC ecx ;next character address

		;디버깅용 메시지
		;mov edx, OFFSET debugMsg8
		;call WriteString
		;call Crlf
		;mov edx, OFFSET debugMsg11
		;call WriteString
		;MOV al,bl
		;call WriteChar
		;call Crlf

		CMP bl, 13 ;compare BL to \r
		JE firstPartLoop ;ignore \r

		CMP bl, 10 ;compare BL to \n
		JE unexpected ;\n shouldn't appear in 1st part

		CMP bl, 0 ;compare BL to \0
		JE noline ;\0 in 1st part means there's no line here.

		CMP bl, 32 ;compare BL to space
		JE secondPartLoop ;if space, go to next part


		;dwTempVar1 should be zero here
		;if not, it means the first part is >=2 chars long.
		CMP dwTempVar1, 0 
		JNE unexpected

		;store in dwTempVar1
		MOVZX eax, bl
		MOV dwTempVar1,eax

		;loop forever
		JMP firstPartLoop



	secondPartLoop:

		;get current char
		MOV bl, BYTE PTR [ecx]
		INC ecx ;next character address

		;디버깅용 메시지
		;mov edx, OFFSET debugMsg9
		;call WriteString
		;call Crlf
		;mov edx, OFFSET debugMsg11
		;call WriteString
		;MOV al,bl
		;call WriteChar
		;call Crlf

		CMP bl, 13 ;compare BL to \r
		JE secondPartLoop ;continue if \r

		CMP bl, 10 ;compare BL to \n
		JE finished ;\n is the newline char - EOL, end!

		CMP bl, 0 ;compare BL to \0
		JE finished ;0 may appear is there is no newline at EOF.

		CMP bl, 32 ;compare BL to space
		JE thirdPartLoop ;goto next part

		CMP bl, 46 ;compare BL to .
		JE secondPartLoop ;ignore

		
		;dwTempVar2*=10
		MOV eax, dwTempVar2
		CDQ
		MOV edx,10
		MUL edx
		MOV dwTempVar2, eax

		SUB bl, 48 ; ascii('0')=48. This converts bl to int.
		MOVZX eax, bl
		ADD dwTempVar2, eax

		
		JMP secondPartLoop

	thirdPartLoop:
		
		;get current char
		MOV bl, BYTE PTR [ecx]
		INC ecx ;next character address

		;디버깅용 메시지
		;mov edx, OFFSET debugMsg10
		;call WriteString
		;call Crlf
		;mov edx, OFFSET debugMsg11
		;call WriteString
		;MOV al,bl
		;call WriteChar
		;call Crlf

		CMP bl, 13 ;compare BL to \r
		JE thirdPartLoop ;continue if \r

		CMP bl, 10 ;compare BL to \n
		JE finished ;\n is the newline char

		CMP bl, 0 ;compare BL to \0
		JE finished ;0 may appear is there is no newline at EOF.

		CMP bl, 32 ;compare BL to space
		JE unexpected ;Space must not appear in 3rd part.

		;dwTempVar3*=10
		MOV eax, dwTempVar3
		CDQ
		MOV edx,10
		MUL edx
		MOV dwTempVar3, eax

		SUB bl, 48 ; ascii('0')=48. This converts bl to int.
		MOVZX eax, bl
		ADD dwTempVar3, eax

		JMP thirdPartLoop
		
	unexpected: ;예상 밖의 문자가 나왔을시 점프됨
		;디버깅용 메시지
		mov edx, OFFSET debugMsg7
		call WriteString
		call Crlf
		mov edx, OFFSET debugMsg11
		call WriteString
		MOV al,bl
		call WriteChar
		call Crlf

		JMP finished
	noline: ;더 이상 줄이 없을때 점프됨
		;디버깅용 메시지
		mov edx, OFFSET debugMsg6
		call WriteString
		call Crlf

		JMP finished
	finished: ;정리 및 리턴
		;디버깅용 메시지
		;mov edx, OFFSET debugMsg5
		;call WriteString
		;call Crlf

		SUB ecx, OFFSET buffer
		MOV readProgress,ecx

		;디버깅용 메시지
		;MOV eax,ecx
		;CALL WriteInt
		;Call Crlf

		;dwTempVar3*=10
		MOV eax, dwTempVar3
		CDQ
		MOV edx,10
		MUL edx
		MOV dwTempVar3, eax

		MOV eax, dwTempVar1
		MOV ebx, dwTempVar2
		MOV ecx, dwTempVar3
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