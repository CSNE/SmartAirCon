;ENCODING: EUC-KR

INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SDWORD 100
b SDWORD -500      ;아래 automatic 계산에서 이걸 5000으로 바꿔서 계산해둠. 바꿀거면 자동부분도 바꿀 것
a1 SDWORD ?
b1 SDWORD ?
anew SDWORD ?
bnew SDWORD ?
k SDWORD 10
x SDWORD ?   ;자동일때 x(현재 온도)하나 받는거 저장할 변수
y SDWORD ?   ;자동일때 결과 온도 반환할 변수
x1 SDWORD 10000
y1 SDWORD 10000
x2 SDWORD 10000
y2 SDWORD 10000
filename BYTE "input.txt",0
fileHandle DWORD ?   ;handle to input file
buffer BYTE BUFFER_SIZE DUP(?) ;파일 내용 저장
readProgress DWORD 0 ;파일을 어디까지 읽었는지. ReadInput에서 사용

outputFilename BYTE "output.txt",0
outputBuffer BYTE BUFFER_SIZE DUP(0) ;출력 파일 내용 저장
outputFileHandle DWORD ?   ;handle to output file
outputBytesWritten DWORD 0

errMsg1 BYTE "Cannot open file", 0dh, 0ah, 0
errMsg2 BYTE "Error reading file.", 0dh, 0ah, 0
errMsg3 BYTE "Error: Buffer too small for the file", 0dh, 0ah, 0
errMsg4 BYTE "Error: Buffer overrun at Output", 0dh, 0ah, 0

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
debugMsg12 BYTE "Getting handle to output.txt", 0dh, 0ah, 0
debugMsg13 BYTE "Calculating string length...", 0dh, 0ah, 0
debugMsg14 BYTE "Writing to file...", 0dh, 0ah, 0
debugMsg15 BYTE "Closing file handles...", 0dh, 0ah, 0
debugMsg16 BYTE "Entering main loop...", 0dh, 0ah, 0
debugMsg17 BYTE "Main loop terminated.", 0dh, 0ah, 0

tempMsg1 BYTE "1", 0dh, 0ah, 0
tempMsg2 BYTE "2", 0dh, 0ah, 0
tempMsg3 BYTE "3", 0dh, 0ah, 0
tempMsg4 BYTE "4", 0dh, 0ah, 0
tempMsg5 BYTE "5", 0dh, 0ah, 0

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

   ;디버깅용 메시지
   mov edx, OFFSET debugMsg16
   call WriteString

   readLoop:
      INVOKE ReadInput            ;ReadInput을 어떻게 구현할지 몰라서 파일 열어만 뒀엉

      ADD eax,0
      JZ readLoopEnd

      CMP eax, 109      ;eax = 'm'일 때(수동)
      JE if_manual
      JMP if_automatic   ;eax = 'a'일 때(자동). 외에 잘못된 입력일 때는 아직 고려X
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
   
     MOV x, ebx      ;input으로 받은 처음 값(현재 온도) x에 저장
     MOV y, ecx      ;input으로 받은 나중 값(원하는 온도) y에 저장
     
     ;학습 프로시져를 '적절한' 주기로 수행하기 위한 추가 알고리즘
     CMP ebx, x1
     JE for_output      ; x == x1일 때 학습 패스하고 출력한다.

     CMP ebx,x2
     JNE execute_manual
     CMP ecx,y2
     JE for_output ;(x,y)=(x2,y2)

execute_manual:

      INVOKE Manual      ;적절한에 안걸리면 

     ;y값이 10 곱해져있는 상태로 보존하려 그런거라 y에 10나눠서 출력해야 됨.
     ;print(y)
     MOV eax, y
     CDQ
     MOV ebx, 10
     IDIV ebx

   for_output:

      INVOKE Output

      JMP next_line
   
   if_automatic:
      ;'a'일 때는 숫자 하나 받는데, 이게 현재 온도 x이고 ebx에 저장되어있음.
      ;구하려는 건 y = a*x+b

      INVOKE Automatic
      
      ;현재 y에 저장되어 있는 값은 y=(ax+b)*10의 결과!
     ;y값이 10 곱해져있는 상태로 보존하려 그런거라 y에 10나눠서 출력해야 됨.

     ;print(y)
     MOV eax, y
     CDQ
     MOV ebx, 10
     IDIV ebx

      INVOKE Output

   next_line:
      JMP readLoop

   readLoopEnd:

   ;디버깅용 메시지
   mov edx, OFFSET debugMsg17
   call WriteString

   ;이 부분은 output.txt를 쓰는 과정
   ;input.txt는 Irvine에 있는 프로시져를 썼는데,
   ;여기서는 windows에서 제공하는 프로시져를 바로 씀.
   ;(내가 Irvine 책이 없어서 무슨 프로시져가 뭔지 모름...)
   ;어차피 별로 차이는 안남. 약간 CALL 하는 방법이 다를 뿐

   ;이 부분을 따로 프로시져로 빼는 게 나으려나...?

   ;print("Getting handle to output.txt")
   mov edx, OFFSET debugMsg12
   call WriteString

   ;이제 file handle 요청. 실패하면 error_invalid_file_handle
   INVOKE CreateFile, ADDR outputFilename, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
   MOV outputFileHandle, eax;
   CMP eax, INVALID_HANDLE_VALUE
   JE error_invalid_file_handle

   ;print("Calculating string length...")
   mov edx, OFFSET debugMsg13
   call WriteString

   ;outputBuffer의 길이를 측정.
   MOV esi, OFFSET outputBuffer
   MOV eax,0
   stringLengthLoop:
     MOV bl, BYTE PTR[esi]

     CMP bl,0
     JE stringLengthLoopExit
     INC eax

     INC esi
     JMP stringLengthLoop
   stringLengthLoopExit:

   ;print("Writing to file...")
   mov edx, OFFSET debugMsg14
   call WriteString

   ;WriteFile을 통해 실제로 파일에 데이터를 씀.
   INVOKE WriteFile, outputFileHandle, ADDR outputBuffer, eax, outputBytesWritten, 0
   
   ;output.txt 작업 끝.

   jmp close_file

error_invalid_file_handle:
   mov edx, OFFSET errMsg1      ;file open 문제발생
   call WriteString
   jmp quit

error_file_read: ;파일 읽는 중 문제
   mov edx, OFFSET errMsg2
   call WriteString
   jmp close_file

error_buffer_overflow: ;버퍼 터짐
   mov edx, OFFSET errMsg3         ;아니!
   call WriteString
   jmp quit

close_file:
   ;print("Closing file handles...")
   mov edx, OFFSET debugMsg15
   call WriteString

   mov eax, fileHandle
   call CloseFile ;input 닫기

   INVOKE CloseHandle, outputFileHandle ;output.txt 닫기


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
      CDQ ;<<여기 CDQ 없어도 되지 않나????
      MOV edx,10
      MUL edx
      MOV dwTempVar3, eax

      MOV eax, dwTempVar1
      MOV ebx, dwTempVar2
      MOV ecx, dwTempVar3
      RET
ReadInput ENDP

Manual PROC
   
   ;Manual : 현재 온도가 같은 상태는 두번 저장하지 않는다(?)
   ;x1,x2,y1,y2,a,b를 사용해서 anew, bnew를 구하고 k를 감소


   mov eax,x1      ;원래의 x1,y1을 x2,x2로 옮겨둠. x1,y1 바꾸려고
   mov ebx,y1
   mov x2,eax
   mov y2,ebx
   
   mov eax,x      ;받은 x,y를 x1, y1에 넣어 축적용 데이터 갱신함 
   mov ebx,y
   mov x1,eax
   mov y1,ebx
   cmp x2,10000   ;
   je equal1
   
   mov eax,y2
   sub eax,y1      ;eax = y2-y1
   mov ebx,x2      
   sub ebx,x1      ;ebx = x2-x1
   mov ecx,eax      ;eax = ecx = y2-y1
   cdq            ;eax를 edx로 확장
   mov edx,100
   imul edx      ;eax*edx = 100*(y2-y1)
   idiv ebx      ;eax/ebx = 100*(y2-y1) / (x2-x1) -> 나누면 10끼리도 나눠지니까 따로 100곱해줌
   mov a1,eax      ;a1 = 100*(y2-y1) / (x2-x1). a1은 100 곱해진 상태
   
   mov eax,ecx      ;ecx에 저장했던 y2-y1 eax로 다시 옮기고
   neg eax         ;eax = -(y2-y1)
   imul x1         ;매개변수 두개길래 하나로 고쳤어! eax = -x1(100*(y2-y1) / (x2-x1)))
   cdq
   idiv ebx      ;eax = eax/ebx 의 몫
   add eax,y1      ;-x1(y2-y1)/(x2-x1) + y1
   mov b1,eax      ;b1 = -x1(y2-y1)/(x2-x1) + y1
   
   mov eax,a      ;eax = a
   mov ebx,10      ;ebx = 10
   sub ebx,k      ;ebx = ebx - k = 10 - k
   imul ebx      ;eax = a*(10-k)
   mov ecx,eax      ;ecx = eax = a*(10-k)
   mov eax,a1      ;eax = a1
   imul k         ;eax = a1*k
   add eax,ecx      ;eax = eax + ecx = a1*k + a*(10-k) -> 이러면 1000 출력값보다 곱해진 상태
   cdq
   mov ebx,10
   idiv ebx      ;eax = eax/10 = (a1*k + a*(10-k))/10 -> 이러면 딱 100곱해진 상태 굿
   mov anew,eax   ;anew를 eax로 갱신
   
   mov eax,b      ;반복해서 bnew = (10-k)b + kb1 구함
   mov ebx,10
   sub ebx,k
   imul ebx
   mov ecx,eax
   mov eax,b1
   imul k
   add eax,ecx
   mov ebx,10
   cdq
   idiv ebx
   mov bnew,eax

   cmp k,1
   je k_decrease
   dec k
   k_decrease:

   
   ;a,b -> anew, bnew
   mov eax,anew
   mov a,eax
   mov eax,bnew
   mov b,eax
   

equal1:
   RET
Manual ENDP

Automatic PROC

   ;y=ax+b의 y를 10곱해진 상태로 반환해야하는데..
   ;이미 받은 후니까 eax, ebx, ecx 맘대로 써버림!
   ;a,x,b,y 모두 100 곱해져있는 상태

   MOV x, ebx

   cmp x,301
   jne debugif
   mov eax,100
   debugif:

   MOV ecx, b      ;원래 b값 ecx에 저장해둠
   MOV eax, 100
   IMUL b
   MOV b, eax      ;b = b*100(100곱해져 있는 상태)
   MOV eax, a
   IMUL x         ;eax = a*x

   ADD eax, b      ;eax = ax+b
   MOV ebx, 100
   cdq
   IDIV ebx         ;eax = (ax+b)/100
   MOV y, eax      ;y는 10곱해져있는 상태
   
   mov ebx,10
   cdq
   idiv ebx
   cmp edx,5
   jb not_plus
   add eax,1
   not_plus:
   imul ebx

   mov y,eax

   MOV b, ecx      ;b값 복원. 10만 곱해져있는 상태로

   RET
Automatic ENDP

Output PROC
   ;ax로 숫자 * 10을 받고 출력함
   ;찬솔
   
   
   ;esi: 지금 쓰고 있는 string 주소
   ;ecx: 지금 숫자
   ;eax,edx,ebx: DIV 명령어에 쓰임

   ;dwTempVar1: 첫번째 자리
   ;dwTempVar2: 두번째 자리
   ;dwTempVar3: 세번째 자리(소수점 아래)


   ;string의 맨 끝을 찾음
   MOV ecx, LENGTHOF outputBuffer
   MOV esi, OFFSET outputBuffer
   stringloop:
      MOV bl, BYTE PTR[esi]  ;bl=string[esi]
      ADD bl, 0
      JZ endloop           ;if bl==0: break

      DEC ecx                ;ecx-- (ecx=남아있는 byte 개수)
      
      MOV edx,ecx
      SUB edx,10
      CMP edx,0
      JNG bufferOverrun     ;if ecx<10: goto bufferOverrun

      INC esi                ;esi++ (next character...)

      JMP stringloop         ;loop forever
   endloop:

   ;계산 ax를 ecx로 옮겨둠
   MOVZX ecx, ax




   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax에 넣고
   CDQ          ;edx로 확장
   MOV ebx,10   ;나눌 수 넣음
   DIV ebx      ;DIV

   ; 수 --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar3=edx
   MOV dwTempVar3,edx

   ;ecx=ecx/10
   MOV ecx, eax


   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax에 넣고
   CDQ          ;edx로 확장
   MOV ebx,10   ;나눌 수 넣음
   DIV ebx      ;DIV

   ; 수 --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar2=edx
   MOV dwTempVar2,edx

   ;ecx=ecx/10
   MOV ecx, eax


   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax에 넣고
   CDQ          ;edx로 확장
   MOV ebx,10   ;나눌 수 넣음
   DIV ebx      ;DIV

   ; 수 --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar1=edx
   MOV dwTempVar1,edx


   ;첫째 자리 [DISABLED]
   ;MOV eax, dwTempVar1;
   ;MOV BYTE PTR[esi], al;
   ;INC esi

   ;둘째
   MOV eax, dwTempVar2;
   MOV BYTE PTR[esi], al;
   INC esi

   ;소수점 [DISABLED]
   ;MOV BYTE PTR[esi], 46; ;'.'
   ;INC esi

   ;셋째
   MOV eax, dwTempVar3;
   MOV BYTE PTR[esi], al;
   INC esi

   ;Carriage return
   MOV BYTE PTR[esi], 13;'\r'
   INC esi

   ;Newline
   MOV BYTE PTR[esi], 10;'\n'
   INC esi


   JMP terminate


   bufferOverrun: ;버퍼 터졌을때
      mov edx, OFFSET errMsg4
      call WriteString
   

   terminate:
   
   RET
Output ENDP



END main