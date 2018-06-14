;ENCODING: EUC-KR

INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SDWORD 100
b SDWORD -500      ;�Ʒ� automatic ��꿡�� �̰� 5000���� �ٲ㼭 ����ص�. �ٲܰŸ� �ڵ��κе� �ٲ� ��
a1 SDWORD ?
b1 SDWORD ?
anew SDWORD ?
bnew SDWORD ?
k SDWORD 10
x SDWORD ?   ;�ڵ��϶� x(���� �µ�)�ϳ� �޴°� ������ ����
y SDWORD ?   ;�ڵ��϶� ��� �µ� ��ȯ�� ����
x1 SDWORD 10000
y1 SDWORD 10000
x2 SDWORD 10000
y2 SDWORD 10000
filename BYTE "input.txt",0
fileHandle DWORD ?   ;handle to input file
buffer BYTE BUFFER_SIZE DUP(?) ;���� ���� ����
readProgress DWORD 0 ;������ ������ �о�����. ReadInput���� ���

outputFilename BYTE "output.txt",0
outputBuffer BYTE BUFFER_SIZE DUP(0) ;��� ���� ���� ����
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

   ;������ �޽���
   mov edx, OFFSET debugMsg16
   call WriteString

   readLoop:
      INVOKE ReadInput            ;ReadInput�� ��� �������� ���� ���� ��� �׾�

      ADD eax,0
      JZ readLoopEnd

      CMP eax, 109      ;eax = 'm'�� ��(����)
      JE if_manual
      JMP if_automatic   ;eax = 'a'�� ��(�ڵ�). �ܿ� �߸��� �Է��� ���� ���� ���X
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
   
     MOV x, ebx      ;input���� ���� ó�� ��(���� �µ�) x�� ����
     MOV y, ecx      ;input���� ���� ���� ��(���ϴ� �µ�) y�� ����
     
     ;�н� ���ν����� '������' �ֱ�� �����ϱ� ���� �߰� �˰���
     CMP ebx, x1
     JE for_output      ; x == x1�� �� �н� �н��ϰ� ����Ѵ�.

     CMP ebx,x2
     JNE execute_manual
     CMP ecx,y2
     JE for_output ;(x,y)=(x2,y2)

execute_manual:

      INVOKE Manual      ;�����ѿ� �Ȱɸ��� 

     ;y���� 10 �������ִ� ���·� �����Ϸ� �׷��Ŷ� y�� 10������ ����ؾ� ��.
     ;print(y)
     MOV eax, y
     CDQ
     MOV ebx, 10
     IDIV ebx

   for_output:

      INVOKE Output

      JMP next_line
   
   if_automatic:
      ;'a'�� ���� ���� �ϳ� �޴µ�, �̰� ���� �µ� x�̰� ebx�� ����Ǿ�����.
      ;���Ϸ��� �� y = a*x+b

      INVOKE Automatic
      
      ;���� y�� ����Ǿ� �ִ� ���� y=(ax+b)*10�� ���!
     ;y���� 10 �������ִ� ���·� �����Ϸ� �׷��Ŷ� y�� 10������ ����ؾ� ��.

     ;print(y)
     MOV eax, y
     CDQ
     MOV ebx, 10
     IDIV ebx

      INVOKE Output

   next_line:
      JMP readLoop

   readLoopEnd:

   ;������ �޽���
   mov edx, OFFSET debugMsg17
   call WriteString

   ;�� �κ��� output.txt�� ���� ����
   ;input.txt�� Irvine�� �ִ� ���ν����� ��µ�,
   ;���⼭�� windows���� �����ϴ� ���ν����� �ٷ� ��.
   ;(���� Irvine å�� ��� ���� ���ν����� ���� ��...)
   ;������ ���� ���̴� �ȳ�. �ణ CALL �ϴ� ����� �ٸ� ��

   ;�� �κ��� ���� ���ν����� ���� �� ��������...?

   ;print("Getting handle to output.txt")
   mov edx, OFFSET debugMsg12
   call WriteString

   ;���� file handle ��û. �����ϸ� error_invalid_file_handle
   INVOKE CreateFile, ADDR outputFilename, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
   MOV outputFileHandle, eax;
   CMP eax, INVALID_HANDLE_VALUE
   JE error_invalid_file_handle

   ;print("Calculating string length...")
   mov edx, OFFSET debugMsg13
   call WriteString

   ;outputBuffer�� ���̸� ����.
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

   ;WriteFile�� ���� ������ ���Ͽ� �����͸� ��.
   INVOKE WriteFile, outputFileHandle, ADDR outputBuffer, eax, outputBytesWritten, 0
   
   ;output.txt �۾� ��.

   jmp close_file

error_invalid_file_handle:
   mov edx, OFFSET errMsg1      ;file open �����߻�
   call WriteString
   jmp quit

error_file_read: ;���� �д� �� ����
   mov edx, OFFSET errMsg2
   call WriteString
   jmp close_file

error_buffer_overflow: ;���� ����
   mov edx, OFFSET errMsg3         ;�ƴ�!
   call WriteString
   jmp quit

close_file:
   ;print("Closing file handles...")
   mov edx, OFFSET debugMsg15
   call WriteString

   mov eax, fileHandle
   call CloseFile ;input �ݱ�

   INVOKE CloseHandle, outputFileHandle ;output.txt �ݱ�


quit:
   exit
main ENDP

ReadInput  PROC
   ;eax -> �ƽ�Ű? ('a'=97 | 'm'=109)
   ;ebx -> ����*10
   ;ecx -> ����*10 => �ɼ�
   ;�� ���� �� ���ٸ� ax=0
   ;����


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

      ;������ �޽���
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

      ;������ �޽���
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

      ;������ �޽���
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
      
   unexpected: ;���� ���� ���ڰ� �������� ������
      ;������ �޽���
      mov edx, OFFSET debugMsg7
      call WriteString
      call Crlf
      mov edx, OFFSET debugMsg11
      call WriteString
      MOV al,bl
      call WriteChar
      call Crlf

      JMP finished
   noline: ;�� �̻� ���� ������ ������
      ;������ �޽���
      mov edx, OFFSET debugMsg6
      call WriteString
      call Crlf

      JMP finished
   finished: ;���� �� ����
      ;������ �޽���
      ;mov edx, OFFSET debugMsg5
      ;call WriteString
      ;call Crlf

      SUB ecx, OFFSET buffer
      MOV readProgress,ecx

      ;������ �޽���
      ;MOV eax,ecx
      ;CALL WriteInt
      ;Call Crlf

      ;dwTempVar3*=10
      MOV eax, dwTempVar3
      CDQ ;<<���� CDQ ��� ���� �ʳ�????
      MOV edx,10
      MUL edx
      MOV dwTempVar3, eax

      MOV eax, dwTempVar1
      MOV ebx, dwTempVar2
      MOV ecx, dwTempVar3
      RET
ReadInput ENDP

Manual PROC
   
   ;Manual : ���� �µ��� ���� ���´� �ι� �������� �ʴ´�(?)
   ;x1,x2,y1,y2,a,b�� ����ؼ� anew, bnew�� ���ϰ� k�� ����


   mov eax,x1      ;������ x1,y1�� x2,x2�� �Űܵ�. x1,y1 �ٲٷ���
   mov ebx,y1
   mov x2,eax
   mov y2,ebx
   
   mov eax,x      ;���� x,y�� x1, y1�� �־� ������ ������ ������ 
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
   cdq            ;eax�� edx�� Ȯ��
   mov edx,100
   imul edx      ;eax*edx = 100*(y2-y1)
   idiv ebx      ;eax/ebx = 100*(y2-y1) / (x2-x1) -> ������ 10������ �������ϱ� ���� 100������
   mov a1,eax      ;a1 = 100*(y2-y1) / (x2-x1). a1�� 100 ������ ����
   
   mov eax,ecx      ;ecx�� �����ߴ� y2-y1 eax�� �ٽ� �ű��
   neg eax         ;eax = -(y2-y1)
   imul x1         ;�Ű����� �ΰ��淡 �ϳ��� ���ƾ�! eax = -x1(100*(y2-y1) / (x2-x1)))
   cdq
   idiv ebx      ;eax = eax/ebx �� ��
   add eax,y1      ;-x1(y2-y1)/(x2-x1) + y1
   mov b1,eax      ;b1 = -x1(y2-y1)/(x2-x1) + y1
   
   mov eax,a      ;eax = a
   mov ebx,10      ;ebx = 10
   sub ebx,k      ;ebx = ebx - k = 10 - k
   imul ebx      ;eax = a*(10-k)
   mov ecx,eax      ;ecx = eax = a*(10-k)
   mov eax,a1      ;eax = a1
   imul k         ;eax = a1*k
   add eax,ecx      ;eax = eax + ecx = a1*k + a*(10-k) -> �̷��� 1000 ��°����� ������ ����
   cdq
   mov ebx,10
   idiv ebx      ;eax = eax/10 = (a1*k + a*(10-k))/10 -> �̷��� �� 100������ ���� ��
   mov anew,eax   ;anew�� eax�� ����
   
   mov eax,b      ;�ݺ��ؼ� bnew = (10-k)b + kb1 ����
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

   ;y=ax+b�� y�� 10������ ���·� ��ȯ�ؾ��ϴµ�..
   ;�̹� ���� �Ĵϱ� eax, ebx, ecx ����� �����!
   ;a,x,b,y ��� 100 �������ִ� ����

   MOV x, ebx

   cmp x,301
   jne debugif
   mov eax,100
   debugif:

   MOV ecx, b      ;���� b�� ecx�� �����ص�
   MOV eax, 100
   IMUL b
   MOV b, eax      ;b = b*100(100������ �ִ� ����)
   MOV eax, a
   IMUL x         ;eax = a*x

   ADD eax, b      ;eax = ax+b
   MOV ebx, 100
   cdq
   IDIV ebx         ;eax = (ax+b)/100
   MOV y, eax      ;y�� 10�������ִ� ����
   
   mov ebx,10
   cdq
   idiv ebx
   cmp edx,5
   jb not_plus
   add eax,1
   not_plus:
   imul ebx

   mov y,eax

   MOV b, ecx      ;b�� ����. 10�� �������ִ� ���·�

   RET
Automatic ENDP

Output PROC
   ;ax�� ���� * 10�� �ް� �����
   ;����
   
   
   ;esi: ���� ���� �ִ� string �ּ�
   ;ecx: ���� ����
   ;eax,edx,ebx: DIV ��ɾ ����

   ;dwTempVar1: ù��° �ڸ�
   ;dwTempVar2: �ι�° �ڸ�
   ;dwTempVar3: ����° �ڸ�(�Ҽ��� �Ʒ�)


   ;string�� �� ���� ã��
   MOV ecx, LENGTHOF outputBuffer
   MOV esi, OFFSET outputBuffer
   stringloop:
      MOV bl, BYTE PTR[esi]  ;bl=string[esi]
      ADD bl, 0
      JZ endloop           ;if bl==0: break

      DEC ecx                ;ecx-- (ecx=�����ִ� byte ����)
      
      MOV edx,ecx
      SUB edx,10
      CMP edx,0
      JNG bufferOverrun     ;if ecx<10: goto bufferOverrun

      INC esi                ;esi++ (next character...)

      JMP stringloop         ;loop forever
   endloop:

   ;��� ax�� ecx�� �Űܵ�
   MOVZX ecx, ax




   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax�� �ְ�
   CDQ          ;edx�� Ȯ��
   MOV ebx,10   ;���� �� ����
   DIV ebx      ;DIV

   ; �� --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar3=edx
   MOV dwTempVar3,edx

   ;ecx=ecx/10
   MOV ecx, eax


   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax�� �ְ�
   CDQ          ;edx�� Ȯ��
   MOV ebx,10   ;���� �� ����
   DIV ebx      ;DIV

   ; �� --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar2=edx
   MOV dwTempVar2,edx

   ;ecx=ecx/10
   MOV ecx, eax


   ; eax=ecx/10
   ; edx=ecx%10
   MOV eax, ecx ;eax�� �ְ�
   CDQ          ;edx�� Ȯ��
   MOV ebx,10   ;���� �� ����
   DIV ebx      ;DIV

   ; �� --> ascii
   ; '0'=48
   ; edx=toString(edx)
   ADD edx, 48

   ;dwTempVar1=edx
   MOV dwTempVar1,edx


   ;ù° �ڸ� [DISABLED]
   ;MOV eax, dwTempVar1;
   ;MOV BYTE PTR[esi], al;
   ;INC esi

   ;��°
   MOV eax, dwTempVar2;
   MOV BYTE PTR[esi], al;
   INC esi

   ;�Ҽ��� [DISABLED]
   ;MOV BYTE PTR[esi], 46; ;'.'
   ;INC esi

   ;��°
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


   bufferOverrun: ;���� ��������
      mov edx, OFFSET errMsg4
      call WriteString
   

   terminate:
   
   RET
Output ENDP



END main