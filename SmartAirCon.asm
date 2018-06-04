;ENCODING: EUC-KR

INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SDWORD 10
b SDWORD 50      ;�Ʒ� automatic ��꿡�� �̰� 500���� �ٲ㼭 ����ص�. �ٲܰŸ� �ڵ��κе� �ٲ� ��
a1 SDWORD ?
b1 SDWORD ?
anew SDWORD ?
bnew SDWORD ?
k SDWORD 10
x SDWORD ?   ;�ڵ��϶� x(���� �µ�)�ϳ� �޴°� ������ ����
y SDWORD ?   ;�ڵ��϶� ��� �µ� ��ȯ�� ����
x1 SDWORD -50
y1 SDWORD -50
x2 SDWORD 1000
y2 SDWORD 1000
filename BYTE "input.txt",0
fileHandle DWORD ?   ;handle to output file
buffer BYTE BUFFER_SIZE DUP(?) ;���� ���� ����
readProgress DWORD 0 ;������ ������ �о�����. ReadInput���� ���

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
      INVOKE Manual
      INVOKE Output

      JMP next_line
   
   if_automatic:
      ;'a'�� ���� ���� �ϳ� �޴µ�, �̰� ���� �µ� x�̰� ebx�� ����Ǿ�����.
      ;���Ϸ��� �� y = a*x+b

      INVOKE Automatic
      
      ;���� y�� ����Ǿ� �ִ� ���� �Ҽ��� ���� ax+b�� ���! y �״�� ����ϸ� ��.

      INVOKE Output

   next_line:
      JMP readLoop

   readLoopEnd:

   jmp close_file



error_invalid_file_handle:
   mov edx, OFFSET errMsg1      ;file open �����߻�
   call WriteString
   jmp quit

error_file_read:
   mov edx, OFFSET errMsg2
   call WriteString
   jmp close_file

error_buffer_overflow:
   mov edx, OFFSET errMsg3         ;�ƴ�!
   call WriteString
   jmp quit

close_file:
   mov eax, fileHandle
   call CloseFile

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
	
	;Manual : ���� �µ��� ���� ���´� �ι� �������� �ʴ´�(?)
	;x1,x2,y1,y2,a,b�� ����ؼ� anew, bnew�� ���ϰ� k�� ����
	mov eax,x
	cmp eax,x1	
	jz equal1
	
	mov eax,x1
	mov ebx,y1
	mov x2,eax
	mov y2,ebx
	
	mov eax,x
	mov ebx,y
	mov x1,eax
	mov y1,ebx
	cmp x2,10000
	je equal1
	
	mov eax,y2
	sub eax,y1
	mov ebx,x2
	sub ebx,x1
	mov ecx,eax
	cdq
	mov edx,10
	imul edx
	idiv ebx
	mov a1,eax
	
	mov eax,ecx
	neg eax
	imul eax,x1
	cdq
	idiv ebx
	add eax,y1
	mov b1,eax
	
	mov eax,a
	mov ebx,10
	sub ebx,k
	imul ebx
	mov ecx,eax
	mov eax,a1
	imul k
	add eax,ecx
	cdq
	mov ebx,10
	idiv ebx
	mov anew,eax
	
	mov eax,b
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
	
	;a,b -> anew, bnew
	mov eax,anew
	cmp eax,0
	jge plus1
	
	sub eax,5
	jmp overend1
	plus1:
	add eax,5

	overend1:
	cdq
	mov ebx,10
	idiv ebx
	mov ebx,10
	imul ebx
	mov a,eax
	
	mov eax,bnew
	cmp eax,0
	jge plus2
	
	sub eax,5
	jmp overend2
	plus2:
	add eax,5

	overend2:
	cdq
	mov ebx,10
	idiv ebx
	mov ebx,10
	imul ebx
	mov b,eax
	
	cmp k,1
	jz equal1
	dec k
	;������
	
	equal1:
	RET
Manual ENDP

Automatic PROC

   ;edx = ��ȯ�� y��
   ;eax, ebx�� �ӽ÷� ���� �����̶� USES ��

   mov eax,a
   imul x
   mov ecx,10
   idiv ecx
   add eax,b
   add eax,5
   cdq
   idiv ecx
   imul ecx
   mov y, eax

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