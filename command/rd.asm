;------------------------------------------------------------rd命令----------------------------------------------------------
;删除目录必须要空目录才可以，否则抛出错误
rdcommand:
    ;查看文件名是否大于10字节
    mov al,[input+14]
    cmp al,0x00
    jne rdentryfiletobig

    ;将0x00转换成0x20
    mov cl,10
    mov si,3
    mov bl,0

rdset0to20:
    mov al,[input+si]
    cmp al,0x00
    je rdset0to20run

    cmp al,0x20
    je rdset0to20run

    add si,1
    dec cl
    jnz rdset0to20

    jmp rddir

rdset0to20run:
    mov al,0x20
    mov [input+si],al
    add bl,1
    add si,1

    dec cl
    jnz rdset0to20

    jmp rddir

rdentryfiletobig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,rdentryfiletobigmsg
    mov cx,34
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

rdnoentryfilename:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,rdnoentryfilenamemsg
    mov cx,32
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

rdentryfiletobigmsg db "No folder is larger than 10 bytes."
rdnoentryfilenamemsg db "You did not enter a folder name."
rddir:
    cmp bl,10
    je rdnoentryfilename
    ;搜索文件夹

    mov si,0-0x8000+0x200+3
    mov bl,218

    pop ax
    push ax

rdfinddir:
    mov cx,[si]
    cmp cx,[input+3]
    jne rdfindnextdir

    mov cx,[si+2]
    cmp cx,[input+3+2]
    jne rdfindnextdir

    mov cx,[si+4]
    cmp cx,[input+3+4]
    jne rdfindnextdir

    mov cx,[si+6]
    cmp cx,[input+3+6]
    jne rdfindnextdir

    mov cx,[si+8]
    cmp cx,[input+3+8]
    jne rdfindnextdir

    ;比较id
    mov ah,[si-1]
    cmp al,ah
    jne rdfindnextdir

    mov al,[si-3]

    ;查看文件夹是否还有文件
    mov cl,218
    mov bp,0-0x8000+4096-0x200+2

rdfinddirhavefile:
    mov ah,[bp]
    cmp al,ah
    je rddirhavefile

    add bp,14
    dec cl
    jnz rdfinddirhavefile

    ;删除文件夹
    sub si,3
    mov cl,14
    mov al,0xe1

rddeldir:
    mov [si],al
    add si,1
    dec cl
    jnz rddeldir

    mov ah,03h
    int 10h

    mov di,dx
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

rdfindnextdir:
    add si,14
    dec bl
    jnz rdfinddir

    ;说明没有这个文件
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,rdnofinddirmsg
    mov cx,13
    mov bl,0x07
    mov bh,0
    int 10h

    mov bl,10
    mov si,3

rdshowdir:
    mov ah,0eh
    mov al,[input+si]
    int 10h

    add si,1
    dec bl
    jnz rdshowdir

    jmp Command

rddirhavefile:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,rddirhavefilemsg
    mov cx,50
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command
    
rddirhavefilemsg db "This folder still has files and cannot be deleted."
rdnofinddirmsg db "No find dir: "
