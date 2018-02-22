;------------------------------------------
; PURPOSE : Project "Type Fight"
; SYSTEM  : Turbo Assembler Ideal Mode
; AUTHOR  : Omer benisty
;------------------------------------------

		IDEAL

		MODEL small

		STACK 256

		DATASEG
		PRESS_ENTER db "Press ENTER to continue"
		include "rules.dat"
	  include "intro.dat"
		include "about.dat"
		KEY_PAD_1 equ 4Fh
		KEY_PAD_2 equ 50h
		KEY_PAD_3 equ 51h
		ENTER_KEY equ 1Ch

;Variables for opening a pcx file/Drawing is general

		FileHandle dw ?
		FileSize dw ?
		PCXErrorMSG db "PCX ERROR$"
		ImageWidth dw ?
		ImageHeight dw ?
		Color db ?
		StartX dw ?
		StartY dw ?
		X dw ?
		Y dw ?
		StoryText db "Story.pcx"
		FileName db 9 dup (?)


		CODESEG
Start:
        mov ax, @data
        mov ds, ax


        ;Set text mode
        mov ax, 3h   ;Int requirement
        int 10h      ;Execute

        ;Print the title and the options
        call PrintMenu


Exit:
        mov ax, 4C00h
        int 21h


;-------------METHODS---------------

;------------------------------
;PrintMenu - Print the text for of menu (Uses include Intro.dat + int 21h)
;------------------------------
;Input:
;       None
;Output:
;       Menu title + options
;Registers:
;       AX,BX,CX,DXp
;------------------------------
PROC PrintMenu

call ClearScreen ;Clear the screen before printing out the menu

;Prep for int 10h interupt that print with color
;-----------------------------------------------
		mov ah,13h     ;Int requirement
		mov bh,0       ;Page number
		mov al, 1	   ;Mode
		push ds		   ;ES as datasegment
		pop es         ;ES:BP

;Set the color for the *TITLE* and print it
;-----------------------------------------------
		mov bl, 10001110b  ;Color attribute
		mov cx, 384    ;Size of text
    mov dl, 0      ;Column
		mov dh, 0	   ;row
		mov bp, offset intro  ;Title location
		int 10h        ;Execute

;Set the color for the *START* title and print it
;------------------------------------------------
		mov bl, 00001011b  ;Color attribute
		mov cx, 249    ;Size of text
    mov dl, 0      ;Column
		mov dh, 8	   ;row
		mov bp, offset startT  ;Title location
		int 10h        ;Execute

;Print the *RULES* title
;------------------------------------------------
		mov cx, 241    ;Size of text
    mov dl, 0      ;Column
		mov dh, 13	   ;row
		mov bp, offset rules  ;Title location
		int 10h        ;Execute

;Print the *ABOUT* title
;------------------------------------------------
		mov cx, 253    ;Size of text
    mov dl, 0      ;Column
		mov dh, 18	   ;row
		mov bp, offset about  ;Title location
		int 10h        ;Execute

;Set the color for the *HINT:* and print it
;------------------------------------------------
		mov bl, 00001111b  ;Color attribute
		mov cx, 120    ;Size of text
    mov dl, 0      ;Column
		mov dh, 23	   ;row
		mov bp, offset hint2  ;Title location
		int 10h        ;Execute

;Set the color for the *HINT:* text and print it
;------------------------------------------------
    mov bl, 00001011b  ;Color attribute
		mov cx, 5    ;Size of text
		mov dl, 12      ;Column
		mov bp, offset hint1  ;Title location
		int 10h        ;Execute
		call KeyCheckMenu
    ret  ;Return to the main block

ENDP PrintMenu

Exit1:
		jmp Exit

;------------------------------
;KeyCheckMenu - checks the key for the menu options
;------------------------------
;Input:
;
;Output:
;					Outcomes of menu
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

;Compare the input we got with all four possible keys
		cmp ah, KEY_PAD_1
		je KEYPAD1

		cmp ah,KEY_PAD_2
		je KEYPAD2

		cmp ah,KEY_PAD_3
		je KEYPAD3

		dec ah
		jz Exit1 ;ESC keycode = 0, check if the button is ESC and if yes exit

		jmp KeyCheckMenuStart ;If the button is not any of above, redo the process

;Any button action:

KEYPAD1:
		call ClearScreen
		call Story
		jmp Exit1
KEYPAD2:
		call ClearScreen
		call PrintRules
		call PrintMenu
KEYPAD3:
		call ClearScreen
		call PrintAbout

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
		mov al, 1	     ;Mode
		push ds		     ;ES as datasegment
		pop es         ;ES:BP

		mov bl, 00001011b  ;Color attribute
		mov cx, 321    ;Size of text
    mov dl, 0       ;Column
		mov dh, 8	   ;row
		mov bp, offset rules1  ;Title location
		int 10h        ;Execute

		mov bl, 00001110b  ;Color attribute
		mov cx, 64     ;Size of text
    mov dl, 0      ;Column
		mov dh, 15	   ;row
		mov bp, offset rules2  ;Title location
		int 10h        ;Execute

		mov bl, 00001111b  ;Color attribute
		mov cx, 23     ;Size of text
		mov dl, 28      ;Column
		mov dh, 24	   ;row
		mov bp, offset PRESS_ENTER  ;Title location
		int 10h        ;Execute


@@Again:

;Clear keyboard buffer
	  mov ah,0ch
	  mov al,0h
	  int 21h


;Read char from keyboard buffer (int 16h)
    mov ah, 0h  ;Int requirement
	  int 16h     ;Execute

		cmp ah, ENTER_KEY  ;If the key is not equel to enter jmp @@Again:
		jne @@Again

		call PrintMenu ;Print back the menu



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
;------------------------------
;PrintAbout - Print the about tab from menu
;------------------------------
;Input:
;
;Output:
;					About tab
;Registers:
;
;------------------------------
PROC PrintAbout
		mov ah,13h     ;Int requirement
		mov bh,0       ;Page number
		mov al, 1	     ;Mode
		push ds		     ;ES as datasegment
		pop es         ;ES:BP

		mov bl, 00001111b  ;Color attribute
		mov cx, 113    ;Size of text
		mov dl, 0       ;Column
		mov dh, 11	   ;row
		mov bp, offset about1  ;Title location
		int 10h        ;Execute

		mov bl, 00001110b
		mov cx, 12
		mov dl, 25
		mov dh, 11
		mov bp, offset name1 ;Title location (Omer)
		int 10h

		mov bl, 00001011b  ;Color attribute
		mov cx, 14 				 ;Size of text
		mov dl, 38         ;Column
		mov dh, 12         ;Row
		mov bp, offset name2 ;Title location (Anatoly)
		int 10h            ;Execute

		mov bl, 00001111b  ;Color attribute
		mov cx, 23 				 ;Size of text
		mov dl, 29         ;Column
		mov dh, 14         ;Row
		mov bp, offset PRESS_ENTER ;Title location (Anatoly)
		int 10h            ;Execute

@@Again:
;Clear keyboard buffer
	  mov ah,0ch
		mov al,0h
	  int 21h


;Read char from keyboard buffer (int 16h)
		mov ah, 0h  ;Int requirement
	  int 16h     ;Execute

		cmp ah,ENTER_KEY
		jne @@Again

		call PrintMenu

		ret
ENDP PrintAbout

include "game.dat"
include "draw.inc"

EndCall:
		END start
