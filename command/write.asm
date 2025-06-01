;-------------------------------------------------------------write命令------------------------------------------------------
writecommand:
    ;命灵格式:write 内容>>文件名，例如：write Hello>>My1.txt，将Hello写到My1.txt末尾，且会自动添加回车，文件不存在会报错。还可以write >>My1.txt，直接填回车。
    ;找终止符
    mov ah,03h
    int 10h

    mov di,dx
    mov si,6
    mov cl,114 ;最多120字节的命令，120-（6-1）=114

writefindexitcode:
    mov bx,[input+si]
    cmp bx,">>" ;匹配到终止符去找文件
    je writefindfile

    add si,1
    dec cl
    jnz writefindexitcode

    mov dx,di
    mov ah,13h
    mov al,1
    mov bp,writenoentryexitcodemsg
    mov cx,49
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

;找不到，说明没有输入>>，抛出错误
writenoentryexitcodemsg db "You did not enter the file content terminator: >>"

writefindfile:
    mov ah,02h
    mov dx,di
    int 10h

    ;检测是否输入文件名超10字节
    add si,2
    mov al,[input+si+11]
    cmp al,0x00
    jne writefiletobig

    ;先将0x00换成0x20
    mov cl,10
    mov ch,0

writeset0to20:
    mov al,[input+si]
    cmp al,0x00
    je writeset0to20run

    cmp al,0x20
    je writeset0to20run

    add si,1
    dec cl
    jnz writeset0to20

    jmp writefile

writeset0to20run:
    mov al,0x20
    mov [input+si],al

    add ch,1
    add si,1
    dec cl
    jnz writeset0to20

    jmp writefile

writenoentryfilename:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,writenoentryfilenamemsg
    mov cx,30
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

writefiletobig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,writefiletobigmsg
    mov cx,32
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

writenoentryfilenamemsg db "You did not enter a file name."
writefiletobigmsg db "No file is larger than 10 bytes."

writefile:
    cmp ch,10
    je writenoentryfilename

    sub si,10
    mov bp,0-0x8000+4096-512+3
    mov cl,218

    pop ax
    push ax

writefindfilename:
    mov cx,[bp]
    cmp cx,[input+si]
    jne writefindnextfile

    mov cx,[bp+2]
    cmp cx,[input+si+2]
    jne writefindnextfile

    mov cx,[bp+4]
    cmp cx,[input+si+4]
    jne writefindnextfile

    mov cx,[bp+6]
    cmp cx,[input+si+6]
    jne writefindnextfile

    mov cx,[bp+8]
    cmp cx,[input+si+8]
    jne writefindnextfile

    mov ah,[bp-1]
    cmp al,ah
    jne writefindnextfile

    mov ax,[bp-3]
    mov cl,al
    mov al,ah
    mov ah,cl
    and ah,0fh

    cmp ax,1
    je writefindend

    ;ds指向文件段
    mov bx,09a0h

writesetds:
    add bx,0x20
    dec ax
    jnz writesetds

writefindend:
    ;开始寻找结尾mov ax,0，int 88h
    mov ds,bx
    mov di,0

writefindendrun:
    mov al,[di]
    cmp al,0xb8
    je writeiffindend

writefindadddi:
    add di,1
    cmp di,16
    je writeaddds
    jmp writefindendrun

writeaddds:
    mov di,0
    mov bx,ds
    add bx,1
    mov ds,bx
    jmp writefindendrun

writefindnextfile:
    add bp,14
    dec cl
    jnz writefindfilename

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,writenofindfilemsg
    mov cx,14
    mov bl,0x07
    mov bh,0
    int 10h

    mov cl,10
        
    writeshowfile:
    mov ah,0eh
    mov al,[input+di]
    int 10h

    add di,1
    dec cl
    jnz writeshowfile

    jmp Command

writenofindfilemsg db "No find file: "

writeiffindend:
    mov cx,[di+1]
    cmp cx,0x0000
    jne writefindadddi

    mov cx,[di+3]
    cmp cx,0x88cd
    jne writefindadddi

    ;开始写入内存
    mov bp,6

writewritefile:
    mov ax,[input+bp]

    cmp ax,">>"
    je writewritefin

    mov al,[input+bp]
    mov [di],al
    add bp,1
    add di,1

    jmp writewritefile

writewritefin:
    ;写回车
    mov ax,0x0d0a
    mov [di],ax

    ;写入结束符
    mov al,0xb8
    mov [di+2],al
    mov ax,0x000
    mov [di+3],ax
    mov ax,0x88cd
    mov [di+5],ax

    ;写入扇区
    mov bx,0x7c00+7168+512 ;文件起始段
    mov ah,03h
    mov al,51 ;写完剩下的扇区
    mov ch,0
    mov cl,15 ;15扇区开始
    mov dl,0
    mov dh,0
    int 13h

    mov bx,0
    mov ds,bx
    
    jmp Command
;----------------------------------------------------------------------------------------------------------------------------
