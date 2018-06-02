;------------------------------------------
; PURPOSE : Project "Type Fight"
; SYSTEM  : Turbo Assembler Ideal Mode
; AUTHOR  : Omer benisty
;------------------------------------------


    IDEAL

    MODEL small

    STACK 256

    P386

    DATASEG
    PRESS_ENTER                 db "Press ENTER to continue"

    include                     "rules.dat"
    include                     "intro.dat"
    include                     "about.dat"


    SPEC_START                  equ 9121
    SPEC_END                    equ 2559
    KEY_PAD_1                   equ 4Fh
    KEY_PAD_2                   equ 50h
    KEY_PAD_3                   equ 51h
    KEY_PAD_4                   equ 4Bh
    KEY_PAD_5                   equ 4Ch
    KEY_1                       equ 02h
    KEY_2                       equ 03h
    KEY_3                       equ 04h
    KEY_4                       equ 05h
    KEY_5                       equ 06h
    ENTER_KEY                   equ 1Ch
    ENTER_KEY_CHARACTER         equ 13
    DEL_KEY_CHARACTER           equ 8
    SPACE_KEY_CHARACTER         equ ' '
    ESC_KEY_CHARACTER           equ 27
    F1_KEY_CHARACTER            equ 0


;----------=Variables for the game itself
    SpeakerPower                db 1
    ScoreTitle                  db "Score:   "
    TimeTitle                   db "Time:   "
    CurrentWord                 db 43 dup (?)
    Time                        db ?
    TimeText                    db "  "
    Score                       db 0
    FinalScore                  dw 0
    ScoreText                   db "     "
    WordsCount                  db ?
    WordsCountText              db "  "
    Mistakes                    db 0
    MistakesText                db "  "
    PrevSecond                  db 0
    Difficulty                  db 0
    GhostPointer                dw 65535
    MiddleValue                 db 0
    FreqPointer                 dw 0
    FreqDirection               db 2
    DifficultyText              db " "
    Words                       db "word","$$$$$$","whale","$$$$$","terms","$$$$$","work","$$$$$$","focus","$$$$$","monday","$$$$","since","$$$$$","read","$$$$$$","tell","$$$$$$","warm","$$$$$$","long","$$$$$$","close","$$$$$"
                                db "remember","$$","thought","$$$","night","$$$$$","until","$$$$$","seven","$$$$$","head","$$$$$$","plane","$$$$$","reach","$$$$$","color","$$$$$","note","$$$$$$","need","$$$$$$","head","$$$$$$"
                                db "blue","$$$$$$","east","$$$$$$","should","$$$$","such","$$$$$$","young","$$$$$","travel","$$$$","age","$$$$$$$","though","$$$$","just","$$$$$$","heat","$$$$$$","rain","$$$$$$","voice","$$$$$"
                                db "road","$$$$$$","the","$$$$$$$","atomiqu","$$$","need","$$$$$$","hot","$$$$$$$","free","$$$$$$","father","$$$$","red","$$$$$$$","even","$$$$$$","many","$$$$$$","nine","$$$$$$","six","$$$$$$$"
                                db "try","$$$$$$$","late","$$$$$$","interest","$$","act","$$$$$$$","fact","$$$$$$","direct","$$$$","all","$$$$$$$","all","$$$$$$$","cause","$$$$$","rest","$$$$$$","correct","$$$","hard","$$$$$$"
                                db "deadly","$$$$","update","$$$$","charity","$$$","disaster","$$","twin","$$$$$$","complain","$$","pill","$$$$$$","ordinary","$$","war","$$$$$$$","marine","$$$$","socialist","$","barrier","$$$"
                                db "fare","$$$$$$","tender","$$$$","constant","$$","native","$$$$","activity","$$","theme","$$$$$","marble","$$$$","curl","$$$$$$","lecture","$$$","window","$$$$","disappear","$","economy","$$$"
                                db "dialogue","$$","pick","$$$$$$","xactshot","$$","decay","$$$$$","suite","$$$$$","feed","$$$$$$","dip","$$$$$$$","slide","$$$$$","heal","$$$$$$","shoulder","$$","absence","$$$","large","$$$$$"
                                db "handy","$$$$$","guitar","$$$$","frighten","$$","treatment","$","fence","$$$$$","favour","$$$$","behead","$$$$","poll","$$$$$$","amber","$$$$$","soil","$$$$$$","church","$$$$","speaker","$$$"
    Frequencies                 dw 9121,8609,9126,7670,7239,6833,6449,6087,5746,5426,5119,4831,4560,4304,4063,3834,3619,3416,3224,3043,2873,2711,2559,2415,2280,2152,2031,1917,1809,1715,1612,1521,1436,1355,1292,1207,1140



;42
;Variables for opening a pcx file & Drawing in general
    FileName                    db 17 dup (?)
    FileHandle                  dw ?
    FileSize                    dw ?
    PCXErrorMSG                 db "PCX ERROR$"
    ImageWidth                  dw ?
    ImageHeight                 dw ?
    Color                       db ?
    StartX                      dw ?
    StartY                      dw ?
    X                           dw ?
    Y                           dw ?
    EndX                        dw ?
    EndY                        dw ?
    File1                       db "Visual\Story.pcx"
    File2                       db "Visual\GameB.pcx"
    File3                       db "Visual\DifSc.pcx"
    File4                       db "Visual\WinSc.pcx"
    File5                       db "Visual\FailS.pcx"
    File6                       db "Visual\60Sec.pcx"

    CODESEG
Start:
    mov ax, @data
    mov ds, ax
;---------=Set text mode
    mov ax, 3h   ;Int requirement
    int 10h      ;Execute

;---------=Print the title and the options
    call PrintMenu

GameStart:
;---------=Show the story scene and the Game Board
    call MenuSound
    call Story
    call MenuSound
    call DifficultySelect
    call MenuSound
    call GameBoard



Exit:
;---------=Set text mode
    mov ax, 3h   ;Int requirement
    int 10h      ;Execute

    mov ax, 4C00h
    int 21h


;------------=METHODS=--------------

;This precedure exit the program, neutralizing the jmp distance
PROC ExitCall
    call MenuSound
    jmp Exit
ENDP ExitCall
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
    call MenuSound
    mov sp, 0100h
    call ClearScreen ;Clear the screen before printing out the menu

    mov ah, 01h
    mov ch, 01
    int 10h
;Prep for int 10h interupt that print with color
;-----------------------------------------------
    mov ah,13h     ;Int requirement
    mov bh,0       ;Page number
    mov al, 1     ;Mode
    push ds       ;ES as datasegment
    pop es         ;ES:BP

;Set the color for the *TITLE* and print it
;-----------------------------------------------
    mov bl, 10001110b  ;Color attribute
    mov cx, 384    ;Size of text
    mov dl, 0      ;Column
    mov dh, 0     ;row
    mov bp, offset intro  ;Title location
    int 10h        ;Execute

;Set the color for the *START* title and print it
;------------------------------------------------
    mov bl, 00001011b  ;Color attribute
    mov cx, 249    ;Size of text
    mov dl, 0      ;Column
    mov dh, 8     ;row
    mov bp, offset startT  ;Title location
    int 10h        ;Execute

;Print the *RULES* title
;------------------------------------------------
    mov cx, 241    ;Size of text
    mov dl, 0      ;Column
    mov dh, 13     ;row
    mov bp, offset rules  ;Title location
    int 10h        ;Execute

;Print the *ABOUT* title
;------------------------------------------------
    mov cx, 253    ;Size of text
    mov dl, 0      ;Column
    mov dh, 18     ;row
    mov bp, offset about  ;Title location
    int 10h        ;Execute

;Set the color for the *HINT:* and print it
;------------------------------------------------
    mov bl, 00001111b  ;Color attribute
    mov cx, 120    ;Size of text
    mov dl, 0      ;Column
    mov dh, 23     ;row
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

GameStart1:
    jmp GameStart


;------------------------------
;KeyCheckMenu - checks the key for the menu options
;------------------------------
;Input:
;
;Output:
;          Outcomes of menu
;Registers:
;      AX
;------------------------------
PROC KeyCheckMenu
@@Again:
;Clear keyboard buffer
    mov ah,0ch
    mov al,0h
    int 21h


;Read char from keyboard buffer (int 16h)
    mov ah, 0h  ;Int requirement
    int 16h     ;Execute

;Compare the input we got with all four possible keys
    cmp ah, KEY_PAD_1
    je @@KEYPAD1

    cmp ah, KEY_1
    je @@KEYPAD1

    cmp ah,KEY_PAD_2
    je @@KEYPAD2

    cmp ah, KEY_2
    je @@KEYPAD2

    cmp ah,KEY_PAD_3
    je @@KEYPAD3

    cmp ah, KEY_3
    je @@KEYPAD3

    dec ah
    jz @@Exit ;ESC keycode = 0, check if the button is ESC and if yes exit

    jmp @@Again ;If the button is not any of above, redo the process

;Any button action:

@@KEYPAD1:
    call ClearScreen
    jmp GameStart1
@@KEYPAD2:
    call ClearScreen
    call PrintRules
    call PrintMenu
@@KEYPAD3:
    call ClearScreen
    call PrintAbout
    call PrintMenu

    ret

@@Exit:
    call ExitCall
ENDP KeyCheckMenu

;------------------------------
;PrintRules - Print the rules tab accessed from the main menu
;------------------------------
;Input:
;
;Output:
;      Rules
;Registers:
;      AX,DX,BH,CX
;------------------------------
PROC PrintRules
    call MenuSound

    mov ah,13h     ;Int requirement
    mov bh,0       ;Page number
    mov al, 1       ;Mode
    push ds         ;ES as datasegment
    pop es         ;ES:BP

    mov bl, 00001011b  ;Color attribute
    mov cx, 325    ;Size of text
    mov dl, 0       ;Column
    mov dh, 4     ;row
    mov bp, offset rules1  ;Title location
    int 10h        ;Execute

    mov bl, 00001110b  ;Color attribute
    mov cx, 240     ;Size of text
    mov dl, 0      ;Column
    mov dh, 12     ;row
    mov bp, offset rules2  ;Title location
    int 10h        ;Execute

    mov bl, 00001111b  ;Color attribute
    mov cx, 23     ;Size of text
    mov dl, 28      ;Column
    mov dh, 24     ;row
    mov bp, offset PRESS_ENTER  ;Title location
    int 10h        ;Execute

    call PressEnter

    ret
ENDP PrintRules
;------------------------------
;ClearScreen - Clear the screen - black
;------------------------------
;Input:
;
;Output:
;       Paint the screen Black
;Registers:
;    AX,DX,ES,CX
;------------------------------
PROC ClearScreen
    mov cx,80*25  ;Size of the whole screen, 80x25
    xor di,di     ;Pointer to pixel
    mov ax,0B800h ;Start of screen in text mode
    mov es,ax     ;Start of segment to screen, ES:[DI]
    mov ax, 0h    ;Color black

@@Again:

    mov [es:di], ax ;Mov ax value to a pixel with the pointer di
    inc di
    inc di          ;Inc di twice to move to the next pixel
    dec cx          ;Loop size
    jnz @@Again      ;Loop execute

    ret
ENDP ClearScreen
;------------------------------
;PrintAbout - Print the about tab from menu
;------------------------------
;Input:
;
;Output:
;          About tab
;Registers:
;          AX,BX,CX,DX
;------------------------------
PROC PrintAbout
    call MenuSound
    mov ah,13h     ;Int requirement
    mov bh,0       ;Page number
    mov al, 1       ;Mode
    push ds         ;ES as datasegment
    pop es         ;ES:BP

    mov bl, 00001111b  ;Color attribute
    mov cx, 113    ;Size of text
    mov dl, 0       ;Column
    mov dh, 11     ;row
    mov bp, offset about1  ;Title location
    int 10h        ;Execute

    mov bl, 00001110b
    mov cx, 12
    mov dl, 25
    mov dh, 11
    mov bp, offset name1 ;Title location (Omer)
    int 10h

    mov bl, 00001011b  ;Color attribute
    mov cx, 14          ;Size of text
    mov dl, 38         ;Column
    mov dh, 12         ;Row
    mov bp, offset name2 ;Title location (Anatoly)
    int 10h            ;Execute

    mov bl, 00001111b  ;Color attribute
    mov cx, 23          ;Size of text
    mov dl, 29         ;Column
    mov dh, 14         ;Row
    mov bp, offset PRESS_ENTER ;Title location (Anatoly)
    int 10h            ;Execute
    call PressEnter



    ret
ENDP PrintAbout
;------------------------------
;MenuSound - Play a short sound
;------------------------------
;Input:
;
;Output:
;
;Registers:
;          AX, CX, BX, CX
;------------------------------
PROC MenuSound
    pusha
;-------------= Prepare the speaker for a note
    mov al, 182
    out 43h, al

    mov ax, 4063 ; Prepare the frequency

;-------------= Send the sound to the speakers
    out 42h, al
    mov al, ah
    out 42h, al

    in al, 61h ; Get value from speaker
    or al, 00000011b ; Turn on the last 2 bytes to start the speaker
    out 61h, al ; Send the value back to the speaker

;-------------= Waiting loop
    mov cx, 2
@@NewLoop:
    mov bx, 65535
@@Again:
    dec bx
    jnz @@Again
    dec cx
    jnz @@NewLoop

    mov ax, 2415 ; Prepare the frequency

;-------------= Send the sound to the speakers
    out 42h, al
    mov al, ah
    out 42h, al

;-------------= Waiting loop
    mov cx, 2
@@NewLoop1:
    mov bx, 65535
@@Again1:
    dec bx
    jnz @@Again1
    dec cx
    jnz @@NewLoop1

;-------------= Turn off speaker
    in al, 61h ; Get value from speaker
    and al, 11111100b ; Change the last 2 bytes to 0 to stop the speaker
    out 61h, al ; Send new value
    popa
    ret
ENDP MenuSound

;------------------------------
;PressEnter - Wait for user to press enter
;------------------------------
;Input:
;
;Output:
;
;Registers:
;          AX
;------------------------------
PROC PressEnter

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
    ret
ENDP PressEnter

include "game.dat"
include "draw.dat"

EndCall:
    END start
