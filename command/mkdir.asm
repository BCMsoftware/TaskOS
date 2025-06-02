;---------------------------------------------------mkdir命令----------------------------------------------------------------------
mkdircommand:
    mov al,[input+17]
    cmp al,0x00
    jne mkdirnametobig
    mov cl,10
    mov si,6 ;指针初始化
    mov ch,0

mkdirset0to20:
    mov al,[input+si]
    cmp al,0x00
    je mkdirset

    cmp al,0x20
    je mkdirset

    inc si
    dec cl
    jnz mkdirset0to20

    jmp mkdirwritemem

mkdirset:
    mov al,0x20
    mov [input+si],al
    add si,1

    add ch,1
    dec cl
    jnz mkdirset0to20

    jmp mkdirwritemem

mkdirwritemem:
    cmp ch,10
    je mkdirnoentrydir

    mov si,0-0x8000+0x200+3
    mov cl,218
    mov ah,03h
    int 10h

    mov di,dx

mkdirfindcmfile: ;遍历218个目录看是否有重名的目录
    mov ax,[si]
    mov bx,[input+6]
    cmp ax,bx
    jne mkdirfindnextdir

    mov ax,[si+2]
    mov bx,[input+6+2]
    cmp ax,bx
    jne mkdirfindnextdir

    mov ax,[si+4]
    mov bx,[input+6+4]
    cmp ax,bx
    jne mkdirfindnextdir

    mov ax,[si+6]
    mov bx,[input+6+6]
    cmp ax,bx
    jne mkdirfindnextdir

    mov ax,[si+8]
    mov bx,[input+6+8]
    cmp ax,bx
    jne mkdirfindnextdir

;还要比较当前目录id
    pop ax
    push ax
    mov ah,[si-1]
    cmp al,ah
    jne mkdirfindnextdir

;说明有同名文件夹，抛出异常
    mov dx,di
    mov ah,13h
    mov al,1
    mov bp,mkdircmmsg
    mov cx,22
    mov bl,0x07
    mov bh,0
    int 10h
    jmp Command

mkdirfindnextdir:
    add si,14
    dec cl
    jnz mkdirfindcmfile

    ;遍历目录id，若检测到空储存目录
    mov si,0-0x8000+0x200
    mov cl,218
    mov ch,1

mkdirfinddir:
    mov al,[si]
    cmp al,0xe1
    je mkdirdir

    add si,14
    inc ch
    dec cl
    jnz mkdirfinddir

    ;如果检测了218个文件夹后，仍然没找到文件夹空着的储存空间，说明文件夹已经满了，抛出错误。
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,mkdirerrormsg
    mov cx,36
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

mkdirnoentrydir:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,mkdirnoentrymsg
    mov cx,36
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

mkdirnametobig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,mkdirnametobigmsg
    mov cx,34
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

mkdirdir:
    ;先写入内存
    mov [si],ch ;写入文件id
    mov al,0x00
    mov [si+1],al ;0x00不隐藏

    pop ax
    push ax

    mov [si+2],al ;所在文件夹id
    mov cl,10
    mov bp,6
    add si,3

mkdirwritememwhile:
    mov al,[input+bp]
    mov [si],al
    add si,1
    add bp,1

    dec cl
    jnz mkdirwritememwhile

    mov al,0x8e
    mov [si],al

    ;写入硬盘
    mov bx,0-0x8000+0x200
    mov ah,03h
    mov al,6 ;写6个扇区
    mov ch,0
    mov cl,3 ;3扇区开始
    mov dl,0
    mov dh,0
    int 13h

    mov ah,02h
    mov dx,di
    int 10h

    jmp Command
    
mkdirerrormsg db "Only 218 files can be saved at most."
mkdirnoentrymsg db "You You did not enter a folder name."
mkdirnametobigmsg db "The maximum file name is 10 bytes."
mkdircmmsg db "Folder already exists."
;--------------------------------------------------------------------------------------------------------------------------------------------------
