Command:
    mov ah,0eh
    mov al,0x0d
    int 10h
    mov al,0x0a
    int 10h

    call showpath

    mov ah,0eh
    mov al,">"
    int 10h

    mov si,0
    mov cl,121
    mov al,0x00

clearinput:
    mov [input+si],al
    add si,1
    dec cl
    jnz clearinput

    mov si,0
    InputKey:
    mov ah,0
    int 16h ;读键盘

    ;禁用键盘：
    cmp al,0x00
    je InputKey

    cmp al,0x0a
    je InputKey

    cmp al,0x07
    je InputKey

    ;特殊处理键盘
    cmp al,0x08
    je back

    cmp al,0x0d
    je GetCommand

    ;命令最多120字节
    cmp si,120
    je InputKey

    mov [input+si],al ;si=命令偏移地址，存到内存后，si偏移指针+1，用来下一次的储存
    add si,1

    mov ah,0eh
    int 10h

    jmp InputKey

back:
    cmp si,0
    je InputKey

    sub si,1
    mov al,0x00
    mov [input+si],al ;将指针-1，空0x00
    mov ah,0eh
    mov al,0x08
    int 10h

    mov al,0x00
    int 10h

    mov al,0x08
    int 10h

    jmp InputKey

GetCommand:
    mov ah,0eh
    cmp si,120
    je IfCommand

    mov al,0x20
    mov [input+si],al

IfCommand:
    mov al,0x0d
    int 10h

    mov al,0x0a
    int 10h

    mov cl,120
    ;指针归0
    mov si,0
    mov bp,0

%include "./compare/cd.asm"
%include "./compare/dir.asm"
%include "./compare/cls.asm"
%include "./compare/mkdir.asm"
%include "./compare/type.asm"
%include "./compare/del.asm"
%include "./compare/rd.asm"
%include "./compare/write.asm"

Commandfin:
    jmp IfBadCommand
    input times 120 db 0x00 ;定义一个地址，空着，里面保存输入的内容
    db 0x00 ;空一字节用来被填充0x20

;-------------命令定义区--------------
    cd db "cd $"
    cls db "cls $"
    dir db "dir $"
    mkdir db "mkdir $"
    type db "type $"
    del db "del $"
    rd db "rd $"
    write db "write $"
;-------------------------------------

IfBadCommand:
    mov ah,[input+si]

    cmp ah,0x00
    je SubBad

    cmp ah,0x20
    je SubBad

    jmp BadCommand

SubBad:
    dec cl
    jnz IfBadCommand
    jmp Command

BadCommand:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,BadCommandmsg
    mov cx,13
    mov bl,0x07
    mov bh,0
    int 10h

    mov si,0
    mov cl,120

printBadCommand:
    mov ah,0eh
    mov al,[input+si]
    int 10h

    add si,1
    dec cl
    jnz printBadCommand

    jmp Command

BadCommandmsg db "Bad Command: "