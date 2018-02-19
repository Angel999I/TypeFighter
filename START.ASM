;------------------------------------------
; PURPOSE : Project "Type Fight"
; SYSTEM  : Turbo Assembler Ideal Mode  
; AUTHOR  : Omer benisty 
;------------------------------------------

		IDEAL
		
		MODEL small

		STACK 256

		DATASEG
		include "rules.dat"
        include "intro.dat"
		KEY_PAD_1 equ 4Fh
		KEY_PAD_2 equ 50h
		KEY_PAD_3 equ 51h

                                                                                                                                                     
		CODESEG
Start:
        mov ax, @data
        mov ds, ax
        

        ;Set text mode
        mov ax, 3h   ;Int requirement
        int 10h      ;Execute

        ;Print the title and the options
        call PrintMenu
        
        

     
	 ;Check keyboard input for menu
        call KeyCheckMenu

Exit:
        mov ax, 4C00h
        int 21h

;-------------------------------
;This block is used for methods:
;-------------------------------

;------------------------------
;PrintMenu - Print the text for of menu (Uses include Intro.dat + int 21h)  
;------------------------------
;Input:
;       None                                                                                                                                                                                                 
;Output:
;       Menu title + options
;Registers:
;       AX,BX,CX,DX
;------------------------------
PROC PrintMenu
;Prep for int 10h interupt theat print with color
;-----------------------------------------------
		mov ah,13h     ;Int requirement
		mov bh,0       ;Page number
		mov al, 1	   ;Mode
		push ds		   ;ES as datasegment
		pop es         ;ES:BP

;Set the color for the TITLE and print it
;-----------------------------------------------       
		mov bl, 10001110b  ;Color attribute  
		mov cx, 384    ;Size of text
        mov dl, 0      ;Column
		mov dh, 0	   ;row
		mov bp, offset intro  ;Title location
		int 10h        ;Execute		

;Set the color for the START title and print it
;------------------------------------------------
		mov bl, 00001011b  ;Color attribute  
		mov cx, 249    ;Size of text
        mov dl, 0      ;Column
		mov dh, 8	   ;row
		mov bp, offset startT  ;Title location
		int 10h        ;Execute	
	
;Set the color for the RULES title and print it
;------------------------------------------------
		mov bl, 00001011b  ;Color attribute  
		mov cx, 241    ;Size of text
        mov dl, 0      ;Column
		mov dh, 13	   ;row
		mov bp, offset rules  ;Title location
		int 10h        ;Execute	
	
;Set the color for the ABOUT title and print it
;------------------------------------------------
		mov bl, 00001011b  ;Color attribute  
		mov cx, 253    ;Size of text
        mov dl, 0      ;Column
		mov dh, 18	   ;row
		mov bp, offset about  ;Title location
		int 10h        ;Execute		

;Set the color for the HINT: text of the sentence
;------------------------------------------------
		mov bl, 00001111b  ;Color attribute  
		mov cx, 120    ;Size of text
        mov dl, 0      ;Column
		mov dh, 23	   ;row
		mov bp, offset hint  ;Title location
		int 10h        ;Execute		
        ret  ;Return to the main block

ENDP PrintMenu
;------------------------------
;KeyCheckMenu - checks the key for the menu options 
;------------------------------
;Input:
;
;Output:
;	     
;Registers:
;			AX
;------------------------------
PROC KeyCheckMenu

KeyCheckMenuStart:                                       
;Clear keyboard buffer
        mov ah,0ch
        mov al,0h
        int 21h


;Read char from keyboard buffer (int 16h)
        mov ah, 0h  ;Int requirement
        int 16h     ;Execute

		cmp ah, KEY_PAD_1
		je KEYPAD1

		cmp ah,KEY_PAD_2
		je KEYPAD2

		cmp ah,KEY_PAD_3
		je KEYPAD3

		dec ah
		jz Exit

		jmp KeyCheckMenuStart
		
KEYPAD1:
		call ClearScreen
		jmp KeyCheckMenuExit
KEYPAD2:
		call ClearScreen
		call PrintRules
		jmp KeyCheckMenuExit
KEYPAD3:
		call ClearScreen
		jmp KeyCheckMenuExit

                                                 
KeyCheckMenuExit:
        ret
ENDP KeyCheckMenu

;------------------------------
;PrintRules - Print the rules tab accessed from the main menu
;------------------------------
;Input:
;			
;Output:
;			Rules 
;Registers:
;			AX,DX,BH,CX
;------------------------------
PROC PrintRules

		mov ah,13h     ;Int requirement
		mov bh,0       ;Page number
		mov al, 1	   ;Mode
		push ds		   ;ES as datasegment
		pop es         ;ES:BP

		mov bl, 00001011b  ;Color attribute  
		mov cx, 321    ;Size of text
        mov dl, 0       ;Column
		mov dh, 0	   ;row
		mov bp, offset rules1  ;Title location
		int 10h        ;Execute	

		mov bl, 00001110b  ;Color attribute  
		mov cx, 64     ;Size of text
        mov dl, 0      ;Column
		mov dh, 7	   ;row
		mov bp, offset rules2  ;Title location
		int 10h        ;Execute	

		ret
ENDP PrintRules
;------------------------------
;ClearScreen - Clear the screen - black
;------------------------------
;Input:
;
;Output:
;		Black screen
;Registers:
;		AX,DX,ES,CX
;------------------------------
PROC ClearScreen
		mov cx,80*25  ;Size of the whole screen, 80x25 
		xor di,di     ;Pointer to pixel
		mov ax,0B800h ;Start of screen in text mode
		mov es,ax     ;Start of segment to screen, ES:[DI]
		mov ax, 0h    ;Color black

Again:

		mov es:[di], ax ;Mov ax value to a pixel with the pointer di
		inc di          
		inc di          ;Inc di twice to move to the next pixel
		dec cx          ;Loop size
		jnz Again       ;Loop execute

		ret
ENDP ClearScreen
EndCall:
		END start
