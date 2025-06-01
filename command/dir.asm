;------------------------------------------------------------------dir命令-----------------------------------------------------------------------------
;dir需要先获取当前文件夹id，之后遍历所有文件和文件夹。
dircommand:
    mov ah,3
    int 10h

    mov ah,13h
    mov al,1
    mov bp,Nowdirmsg
    mov cx,9
    mov bl,0x07
    mov bh,0
    int 10h

    call showpath

;开始打印文件夹
    mov si,0-0x8000+0x200 ;初始化指针
    mov ah,0eh
    mov al,0x0d
    int 10h

    mov al,0x0a
    int 10h

    mov al,0x0a
    int 10h

Dirprint:
    pop ax
    push ax

    mov ah,[si+2]
    cmp al,ah
    je dirprint

    add si,14
    dec cl
    jnz Dirprint

Fileprintinit:
    mov si,0-0x8000+0x200+0xc00;初始化指针
    mov cl,218

Fileprint:
    pop ax
    push ax

    mov ah,[si+2]
    cmp al,ah
    je fileprint

    add si,14
    dec cl
    jnz Fileprint

    jmp Command

dirprint:
    mov ah,03h
    int 10h

    mov bp,si
    add bp,3
    mov ah,13h
    mov al,1
    mov cx,10
    mov bl,0x07
    mov bh,0
    int 10h

    mov ah,03h
    int 10h

    mov dl,15
    mov ah,02h
    int 10h

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,Diratt
    mov cx,5
    mov bl,0x07
    mov bh,0
    int 10h

    mov ah,0eh
    mov al,0x0d
    int 10h

    mov al,0x0a
    int 10h

    add si,14
    dec cl
    jnz Dirprint

    jmp Fileprintinit

fileprint:
    mov ah,03h
    int 10h

    mov bp,si
    add bp,3
    mov ah,13h
    mov al,1
    mov cx,10
    mov bl,0x07
    mov bh,0
    int 10h

    mov ah,03h
    int 10h

    mov dl,15
    mov ah,02h
    int 10h

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,Fileatt
    mov cx,6
    mov bl,0x07
    mov bh,0
    int 10h

    mov ah,0eh
    mov al,0x0d
    int 10h

    mov al,0x0a
    int 10h

    add si,14
    dec cl
    jnz Fileprint
    
    jmp Command

Nowdirmsg db "Now Dir: "
Diratt db "<dir>"
Fileatt db "<file>"
;------------------------------------------------------------------------------------------------------------------------------------------------------
