INCLUDE Irvine32.inc

.data
myBytes   BYTE 10h,20h,30h,40h

.code
main PROC
	mov al,BYTE PTR myBytes
	mov bl,BYTE PTR myBytes+1
	mov cl,BYTE PTR myBytes+2
	exit
main ENDP
END main