;Init
    mov ah,0
    mov al,2
    int 10h
    mov ah,03h
    int 10h
    mov ah,13h
    mov al,1
    mov bp,Welcomemsg
    mov cx,Welcomemsglen
    mov bl,0x07
    mov bh,0
    int 10h
    jmp $+Welcomemsglen ;跳到字符串后面
    Welcomemsg db "Welcome to Task DOS!",0x0d,0x0a,"  Make of CSDN AsmCaiNiao.",0x0d,0x0a,"Vesion 1.0",0x0d,0x0a,0x0a,"Init DOS..."
    Welcomemsglen equ $-Welcomemsg

    ;InitDOS
    ;重读驱动器
    mov ah,0
    mov dl,0 ;A软驱
    int 13h
    mov bx,0-0x8000
    mov ah,2
    mov al,64 ;测试得来的64个扇区
    mov ch,0
    mov cl,2
    mov dl,0
    mov dh,0
    int 13h
    mov ah,02h
    mov dl,0
    mov dh,5
    int 10h ;设置光标
    jmp cd2 ;去设置根目录
    Disk db 0x0d,0x0a,"A:"
    jmpStartdz equ $