;ENCODING: EUC-KR

INCLUDE Irvine32.inc
BUFFER_SIZE = 5000

.data
a SDWORD 100
b SDWORD -500      ;¾Æ·¡ automatic °è»ê¿¡¼­ ÀÌ°É 5000À¸·Î ¹Ù²ã¼­ °è»êÇØµÒ. ¹Ù²Ü°Å¸é ÀÚµ¿ºÎºÐµµ ¹Ù²Ü °Í
a1 SDWORD ?
b1 SDWORD ?
anew SDWORD ?
bnew SDWORD ?
k SDWORD 10
x SDWORD ?   ;ÀÚµ¿ÀÏ¶§ x(ÇöÀç ¿Âµµ)ÇÏ³ª ¹Þ´Â°Å ÀúÀåÇÒ º¯¼ö
y SDWORD ?   ;ÀÚµ¿ÀÏ¶§ °á°ú ¿Âµµ ¹ÝÈ¯ÇÒ º¯¼ö
x1 SDWORD 10000
y1 SDWORD 10000
x2 SDWORD 10000
y2 SDWORD 10000
filename BYTE "input.txt",0
fileHandle DWORD ?   ;handle to input file
buffer BYTE BUFFER_SIZE DUP(?) ;ÆÄÀÏ ³»¿ë ÀúÀå
readProgress DWORD 0 ;ÆÄÀÏÀ» ¾îµð±îÁö ÀÐ¾ú´ÂÁö. ReadInput¿¡¼­ »ç¿ë

outputFilename BYTE "output.txt",0
outputBuffer BYTE BUFFER_SIZE DUP(0) ;Ãâ·Â ÆÄÀÏ ³»¿ë ÀúÀå
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
   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg1
   call WriteString

   ;input.txt ÆÄÀÏ ¿­±â (ÇÚµé Ãëµæ)
   mov edx, OFFSET filename
   call OpenInputFile
   mov fileHandle, eax

   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg3
   call WriteString
   call WriteHex
   call Crlf

   ;ÆÄÀÏ ÇÚµé ¿¡·¯Àâ±â (¿¡·¯ÀÖÀ¸¸é -> error_invalid_file_handle)
   cmp eax, INVALID_HANDLE_VALUE
   je error_invalid_file_handle

read_file:
   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg2
   call WriteString

   ;input.txt ÀÐ±â
   mov edx, OFFSET buffer
   mov ecx, BUFFER_SIZE
   call ReadFromFile

   ;Read¿¡ ¿¡·¯³µ´ÂÁö Ã¼Å© (¿¡·¯ÀÖÀ¸¸é -> error_file_read)
   jc error_file_read      

   ;buffer Å©±â°¡ ÃæºÐÇÑÁö Ã¼Å©. Áö±Ý input.txt´Â Å©±â°¡ 878ÀÎµí ÇÔ
   ;(ÃæºÐÇÏÁö ¾ÊÀ¸¸é -> error_buffer_overflow)
   cmp eax, BUFFER_SIZE
   jnb error_buffer_overflow

   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg4
   call WriteString
   call WriteInt
   call Crlf
   
mainloop:
   
   ;¸ðµç ÁÙ ÀÐÀ¸·Á¸é ·çÇÁ µ¹¾Æ¾ßµÇ´Âµ¥ ÀÌ°Å ¸ÞÀÎ¿¡¼­ ÇÏ³ª..? ¸ÞÀÎ Àº±Ù ÇÒ°Å ¸¹Àºµ¥?!!?!? ³ªÁß¿¡ ÇÔ¼öµé ´ÙÂ¥°í Â¥¾ß°Î±¸¸¸!

   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg16
   call WriteString

   readLoop:
      INVOKE ReadInput            ;ReadInputÀ» ¾î¶»°Ô ±¸ÇöÇÒÁö ¸ô¶ó¼­ ÆÄÀÏ ¿­¾î¸¸ µ×¾û

      ADD eax,0
      JZ readLoopEnd

      CMP eax, 109      ;eax = 'm'ÀÏ ¶§(¼öµ¿)
      JE if_manual
      JMP if_automatic   ;eax = 'a'ÀÏ ¶§(ÀÚµ¿). ¿Ü¿¡ Àß¸øµÈ ÀÔ·ÂÀÏ ¶§´Â ¾ÆÁ÷ °í·ÁX
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

	  ;y°ªÀÌ 10 °öÇØÁ®ÀÖ´Â »óÅÂ·Î º¸Á¸ÇÏ·Á ±×·±°Å¶ó y¿¡ 10³ª´²¼­ Ãâ·ÂÇØ¾ß µÊ.
	  ;print(y)
	  MOV eax, y
	  CDQ
	  MOV ebx, 10
	  IDIV ebx
<<<<<<< HEAD
	  CALL WriteDec
	  Call Crlf
=======
>>>>>>> parent of 6dc3f1a... ì ì ˆí•œì„ ë©”ì¸ìœ¼ë¡œ ì˜®ê²¼ëŠ”ë° x=x1ì¼ë•Œ ë§žëŠ”ì§€ ë´ì¤˜!

      INVOKE Output

      JMP next_line
   
   if_automatic:
      ;'a'ÀÏ ¶§´Â ¼ýÀÚ ÇÏ³ª ¹Þ´Âµ¥, ÀÌ°Ô ÇöÀç ¿Âµµ xÀÌ°í ebx¿¡ ÀúÀåµÇ¾îÀÖÀ½.
      ;±¸ÇÏ·Á´Â °Ç y = a*x+b

      INVOKE Automatic
      
      ;ÇöÀç y¿¡ ÀúÀåµÇ¾î ÀÖ´Â °ªÀº y=(ax+b)*10ÀÇ °á°ú!
	  ;y°ªÀÌ 10 °öÇØÁ®ÀÖ´Â »óÅÂ·Î º¸Á¸ÇÏ·Á ±×·±°Å¶ó y¿¡ 10³ª´²¼­ Ãâ·ÂÇØ¾ß µÊ.

	  ;print(y)
	  MOV eax, y
	  CDQ
	  MOV ebx, 10
	  IDIV ebx
	  CALL WriteDec
	  Call Crlf

      INVOKE Output

   next_line:
      JMP readLoop

   readLoopEnd:

   ;µð¹ö±ë¿ë ¸Þ½ÃÁö
   mov edx, OFFSET debugMsg17
   call WriteString

   ;ÀÌ ºÎºÐÀº output.txt¸¦ ¾²´Â °úÁ¤
   ;input.txt´Â Irvine¿¡ ÀÖ´Â ÇÁ·Î½ÃÁ®¸¦ ½è´Âµ¥,
   ;¿©±â¼­´Â windows¿¡¼­ Á¦°øÇÏ´Â ÇÁ·Î½ÃÁ®¸¦ ¹Ù·Î ¾¸.
   ;(³»°¡ Irvine Ã¥ÀÌ ¾ø¾î¼­ ¹«½¼ ÇÁ·Î½ÃÁ®°¡ ¹ºÁö ¸ð¸§...)
   ;¾îÂ÷ÇÇ º°·Î Â÷ÀÌ´Â ¾È³². ¾à°£ CALL ÇÏ´Â ¹æ¹ýÀÌ ´Ù¸¦ »Ó

   ;ÀÌ ºÎºÐÀ» µû·Î ÇÁ·Î½ÃÁ®·Î »©´Â °Ô ³ªÀ¸·Á³ª...?

   ;print("Getting handle to output.txt")
   mov edx, OFFSET debugMsg12
   call WriteString

   ;ÀÌÁ¦ file handle ¿äÃ». ½ÇÆÐÇÏ¸é error_invalid_file_handle
   INVOKE CreateFile, ADDR outputFilename, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
   MOV outputFileHandle, eax;
   CMP eax, INVALID_HANDLE_VALUE
   JE error_invalid_file_handle

   ;print("Calculating string length...")
   mov edx, OFFSET debugMsg13
   call WriteString

   ;outputBufferÀÇ ±æÀÌ¸¦ ÃøÁ¤.
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

   ;WriteFileÀ» ÅëÇØ ½ÇÁ¦·Î ÆÄÀÏ¿¡ µ¥ÀÌÅÍ¸¦ ¾¸.
   INVOKE WriteFile, outputFileHandle, ADDR outputBuffer, eax, outputBytesWritten, 0
   
   ;output.txt ÀÛ¾÷ ³¡.

   jmp close_file

error_invalid_file_handle:
   mov edx, OFFSET errMsg1      ;file open ¹®Á¦¹ß»ý
   call WriteString
   jmp quit

error_file_read: ;ÆÄÀÏ ÀÐ´Â Áß ¹®Á¦
   mov edx, OFFSET errMsg2
   call WriteString
   jmp close_file

error_buffer_overflow: ;¹öÆÛ ÅÍÁü
   mov edx, OFFSET errMsg3         ;¾Æ´Ï!
   call WriteString
   jmp quit

close_file:
   ;print("Closing file handles...")
   mov edx, OFFSET debugMsg15
   call WriteString

   mov eax, fileHandle
   call CloseFile ;input ´Ý±â

   INVOKE CloseHandle, outputFileHandle ;output.txt ´Ý±â


quit:
   exit
main ENDP

ReadInput  PROC
   ;eax -> ¾Æ½ºÅ°? ('a'=97 | 'm'=109)
   ;ebx -> ¼ýÀÚ*10
   ;ecx -> ¼ýÀÚ*10 => ¿É¼Ç
   ;´õ ÀÐÀ» °Ô ¾ø´Ù¸é ax=0
   ;Âù¼Ö


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

      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
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

      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
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

      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
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
      
   unexpected: ;¿¹»ó ¹ÛÀÇ ¹®ÀÚ°¡ ³ª¿ÔÀ»½Ã Á¡ÇÁµÊ
      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
      mov edx, OFFSET debugMsg7
      call WriteString
      call Crlf
      mov edx, OFFSET debugMsg11
      call WriteString
      MOV al,bl
      call WriteChar
      call Crlf

      JMP finished
   noline: ;´õ ÀÌ»ó ÁÙÀÌ ¾øÀ»¶§ Á¡ÇÁµÊ
      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
      mov edx, OFFSET debugMsg6
      call WriteString
      call Crlf

      JMP finished
   finished: ;Á¤¸® ¹× ¸®ÅÏ
      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
      ;mov edx, OFFSET debugMsg5
      ;call WriteString
      ;call Crlf

      SUB ecx, OFFSET buffer
      MOV readProgress,ecx

      ;µð¹ö±ë¿ë ¸Þ½ÃÁö
      ;MOV eax,ecx
      ;CALL WriteInt
      ;Call Crlf

      ;dwTempVar3*=10
      MOV eax, dwTempVar3
      CDQ ;<<¿©±â CDQ ¾ø¾îµµ µÇÁö ¾Ê³ª????
      MOV edx,10
      MUL edx
      MOV dwTempVar3, eax

      MOV eax, dwTempVar1
      MOV ebx, dwTempVar2
      MOV ecx, dwTempVar3
      RET
ReadInput ENDP

Manual PROC
	
	;Manual : ÇöÀç ¿Âµµ°¡ °°Àº »óÅÂ´Â µÎ¹ø ÀúÀåÇÏÁö ¾Ê´Â´Ù(?)
	;x1,x2,y1,y2,a,b¸¦ »ç¿ëÇØ¼­ anew, bnew¸¦ ±¸ÇÏ°í k¸¦ °¨¼Ò

	;¾ß 0ÀÇ ÀÌÀ¯¸¦ ¾Ë¾Ò¾î ¹ÞÀº ÀÔ·Â°ªÀ» x,y¿¡ ³Ö´Â ÀÛ¾÷À» ¾ÈÇÑ°Å°°¾Æ!!! °¨ÂÊ°°³×..
	MOV x, ebx		;inputÀ¸·Î ¹ÞÀº Ã³À½ °ª(ÇöÀç ¿Âµµ) x¿¡ ÀúÀå
	MOV y, ecx		;inputÀ¸·Î ¹ÞÀº ³ªÁß °ª(¿øÇÏ´Â ¿Âµµ) y¿¡ ÀúÀå

	mov eax,x
	cmp eax,x1	
	jz equal1			;x°¡ x1°ú °°À» ¶§ Á¦¿Ü
					;³»°¡ ÀÌÇØÇÑ´ë·Î ÁÖ¼®´Þ¾ÆºÃ´Âµ¥ ÀÌ°Ô ¾Æ´Ñµ¥? ÇÑ ºÎºÐÀº °íÃÄÁà!
	mov eax,x1		;¿ø·¡ÀÇ x1,y1À» x2,x2·Î ¿Å°ÜµÒ. x1,y1 ¹Ù²Ù·Á°í
	mov ebx,y1
	mov x2,eax
	mov y2,ebx
	
	mov eax,x		;¹ÞÀº x,y¸¦ x1, y1¿¡ ³Ö¾î ÃàÀû¿ë µ¥ÀÌÅÍ °»½ÅÇÔ 
	mov ebx,y
	mov x1,eax
	mov y1,ebx
	cmp x2,10000	;
	je equal1
	
	mov eax,y2
	sub eax,y1		;eax = y2-y1
	mov ebx,x2		
	sub ebx,x1		;ebx = x2-x1
	mov ecx,eax		;eax = ecx = y2-y1
	cdq				;eax¸¦ edx·Î È®Àå
	mov edx,100
	imul edx		;eax*edx = 100*(y2-y1)
	idiv ebx		;eax/ebx = 100*(y2-y1) / (x2-x1) -> ³ª´©¸é 10³¢¸®µµ ³ª´²Áö´Ï±î µû·Î 100°öÇØÁÜ
	mov a1,eax		;a1 = 100*(y2-y1) / (x2-x1). a1Àº 100 °öÇØÁø »óÅÂ
	
	mov eax,ecx		;ecx¿¡ ÀúÀåÇß´ø y2-y1 eax·Î ´Ù½Ã ¿Å±â°í
	neg eax			;eax = -(y2-y1)
	imul x1			;¸Å°³º¯¼ö µÎ°³±æ·¡ ÇÏ³ª·Î °íÃÆ¾î! eax = -x1(100*(y2-y1) / (x2-x1)))
	cdq
	idiv ebx		;eax = eax/ebx ÀÇ ¸ò
	add eax,y1		;-x1(y2-y1)/(x2-x1) + y1
	mov b1,eax		;b1 = -x1(y2-y1)/(x2-x1) + y1
	
	mov eax,a		;eax = a
	mov ebx,10		;ebx = 10
	sub ebx,k		;ebx = ebx - k = 10 - k
	imul ebx		;eax = a*(10-k)
	mov ecx,eax		;ecx = eax = a*(10-k)
	mov eax,a1		;eax = a1
	imul k			;eax = a1*k
	add eax,ecx		;eax = eax + ecx = a1*k + a*(10-k) -> ÀÌ·¯¸é 1000 Ãâ·Â°ªº¸´Ù °öÇØÁø »óÅÂ
	cdq
	mov ebx,10
	idiv ebx		;eax = eax/10 = (a1*k + a*(10-k))/10 -> ÀÌ·¯¸é µü 100°öÇØÁø »óÅÂ ±Â
	mov anew,eax	;anew¸¦ eax·Î °»½Å
	
	mov eax,b		;¹Ýº¹ÇØ¼­ bnew = (10-k)b + kb1 ±¸ÇÔ
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

	;y=ax+bÀÇ y¸¦ 10°öÇØÁø »óÅÂ·Î ¹ÝÈ¯ÇØ¾ßÇÏ´Âµ¥..
	;ÀÌ¹Ì ¹ÞÀº ÈÄ´Ï±î eax, ebx, ecx ¸¾´ë·Î ½á¹ö¸²!
	;a,x,b,y ¸ðµÎ 100 °öÇØÁ®ÀÖ´Â »óÅÂ

	MOV x, ebx

	cmp x,301
	jne debugif
	mov eax,100
	debugif:

	MOV ecx, b		;¿ø·¡ b°ª ecx¿¡ ÀúÀåÇØµÒ
	MOV eax, 100
	IMUL b
	MOV b, eax		;b = b*100(100°öÇØÁ® ÀÖ´Â »óÅÂ)
	MOV eax, a
	IMUL x			;eax = a*x

	ADD eax, b		;eax = ax+b
	MOV ebx, 100
	cdq
	IDIV ebx			;eax = (ax+b)/100
	MOV y, eax		;y´Â 10°öÇØÁ®ÀÖ´Â »óÅÂ
	
	mov ebx,10
	cdq
	idiv ebx
	cmp edx,5
	jb not_plus
	add eax,1
	not_plus:
	imul ebx

	mov y,eax

	MOV b, ecx		;b°ª º¹¿ø. 10¸¸ °öÇØÁ®ÀÖ´Â »óÅÂ·Î

	RET
Automatic ENDP

Output PROC
	;ax·Î ¼ýÀÚ * 10À» ¹Þ°í Ãâ·ÂÇÔ
	;Âù¼Ö
	
	
	;esi: Áö±Ý ¾²°í ÀÖ´Â string ÁÖ¼Ò
	;ecx: Áö±Ý ¼ýÀÚ
	;eax,edx,ebx: DIV ¸í·É¾î¿¡ ¾²ÀÓ

	;dwTempVar1: Ã¹¹øÂ° ÀÚ¸®
	;dwTempVar2: µÎ¹øÂ° ÀÚ¸®
	;dwTempVar3: ¼¼¹øÂ° ÀÚ¸®(¼Ò¼öÁ¡ ¾Æ·¡)


	;stringÀÇ ¸Ç ³¡À» Ã£À½
	MOV ecx, LENGTHOF outputBuffer
	MOV esi, OFFSET outputBuffer
	stringloop:
		MOV bl, BYTE PTR[esi]  ;bl=string[esi]
		ADD bl, 0
		JZ endloop           ;if bl==0: break

		DEC ecx                ;ecx-- (ecx=³²¾ÆÀÖ´Â byte °³¼ö)
		
		MOV edx,ecx
		SUB edx,10
		CMP edx,0
		JNG bufferOverrun     ;if ecx<10: goto bufferOverrun

		INC esi                ;esi++ (next character...)

		JMP stringloop         ;loop forever
	endloop:

	;°è»ê ax¸¦ ecx·Î ¿Å°ÜµÒ
	MOVZX ecx, ax




	; eax=ecx/10
	; edx=ecx%10
	MOV eax, ecx ;eax¿¡ ³Ö°í
	CDQ          ;edx·Î È®Àå
	MOV ebx,10   ;³ª´­ ¼ö ³ÖÀ½
	DIV ebx      ;DIV

	; ¼ö --> ascii
	; '0'=48
	; edx=toString(edx)
	ADD edx, 48

	;dwTempVar3=edx
	MOV dwTempVar3,edx

	;ecx=ecx/10
	MOV ecx, eax


	; eax=ecx/10
	; edx=ecx%10
	MOV eax, ecx ;eax¿¡ ³Ö°í
	CDQ          ;edx·Î È®Àå
	MOV ebx,10   ;³ª´­ ¼ö ³ÖÀ½
	DIV ebx      ;DIV

	; ¼ö --> ascii
	; '0'=48
	; edx=toString(edx)
	ADD edx, 48

	;dwTempVar2=edx
	MOV dwTempVar2,edx

	;ecx=ecx/10
	MOV ecx, eax


	; eax=ecx/10
	; edx=ecx%10
	MOV eax, ecx ;eax¿¡ ³Ö°í
	CDQ          ;edx·Î È®Àå
	MOV ebx,10   ;³ª´­ ¼ö ³ÖÀ½
	DIV ebx      ;DIV

	; ¼ö --> ascii
	; '0'=48
	; edx=toString(edx)
	ADD edx, 48

	;dwTempVar1=edx
	MOV dwTempVar1,edx


	;Ã¹Â° ÀÚ¸® [DISABLED]
	;MOV eax, dwTempVar1;
	;MOV BYTE PTR[esi], al;
	;INC esi

	;µÑÂ°
	MOV eax, dwTempVar2;
	MOV BYTE PTR[esi], al;
	INC esi

	;¼Ò¼öÁ¡ [DISABLED]
	;MOV BYTE PTR[esi], 46; ;'.'
	;INC esi

	;¼ÂÂ°
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


	bufferOverrun: ;¹öÆÛ ÅÍÁ³À»¶§
		mov edx, OFFSET errMsg4
		call WriteString
	

	terminate:
	
	RET
Output ENDP

JukJulHan PROC
   ;ÀûÀýÇÏ¸é ax=1
   MOV ax,1
   RET
JukJulHan ENDP

END main