;ENCODING: EUC-KR

INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SDWORD 10
b SDWORD 50		;아래 automatic 계산에서 이걸 500으로 바꿔서 계산해둠. 바꿀거면 자동부분도 바꿀 것
a1 SDWORD ?
b1 SDWORD ?
anew SDWORD ?
bnew SDWORD ?
k SDWORD 10
x SDWORD ?	;자동일때 x(현재 온도)하나 받는거 저장할 변수
y SDWORD ?	;자동일때 결과 온도 반환할 변수
x1 SDWORD -50
y1 SDWORD -50
x2 SDWORD 1000
y2 SDWORD 1000
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

		CMP eax, 109		;eax = 'm'일 때(수동)
		JE if_manual
		JMP if_automatic	;eax = 'a'일 때(자동). 외에 잘못된 입력일 때는 아직 고려X
		;CALL WriteChar
		;CALL Crlf
		;MOV eax,ebx
		;CALL WriteInt
		;CALL Crlf
		;MOV eax,ecx
		;CALL WriteInt
		;CALL Crlf
		;CALL Crlf


	if_manual:
		INVOKE Manual

		JMP next_line
	
	if_automatic:
		;'a'일 때는 숫자 하나 받는데, 이게 현재 온도 x이고 ebx에 저장되어있음.
		;구하려는 건 y = a*x+b

		INVOKE Automatic
		MOV y, edx	;y = a*x+b
		
		;현재 y에 저장되어 있는 값은 소수점 없는 ax+b의 결과! y 그대로 출력하면 됨.

		INVOKE Output

	next_line:
		JMP readLoop

	readLoopEnd:

	jmp close_file



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

Automatic PROC USES eax ebx

	MOV eax, 10
	IMUL b			
	MOV b, eax		;b = 500
	MOV eax, a
	IMUL ebx		;eax = a*x(10곱해진 수끼리의 곱셈이므로 100을 나눠야함)

	ADD eax, b		;eax = a*x+b(구하려는 값보다 100배인 상태)
	MOV ebx, 100
	IDIV ebx
	MOV edx, eax

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