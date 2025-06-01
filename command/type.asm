;----------------------------------------------------------type命令--------------------------------------------------------------------------------
;通过获取当前文件id，寻找文件，之后将ds指向段，最后读出内容即可。
typecommand:
    ;先比较文件名是否超过10字节
    mov al,[input+16]

    cmp al,0x00
    jne typefilenamebig

    ;将0x00转换成0x20
    mov bp,5 ;指针初始化
    mov cl,0
    mov ch,10

typeset0to20:
    mov al,[input+bp]

    cmp al,0x00
    je typesjset0to20

    cmp al,0x20
    je typesjset0to20

    add bp,1
    dec ch
    jnz typeset0to20

    jmp typefindfile

typesjset0to20:
    mov al,0x20
    mov [input+bp],al

    add bp,1
    add cl,1

    dec ch
    jnz typeset0to20

    jmp typefindfile

typefilenamebig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,typefilenamebigmsg
    mov cx,39
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

typenoentryfilename:
    mov ah,03h
    int 10h
    
    mov ah,13h
    mov al,1
    mov bp,typenoentryfilenamemsg
    mov cx,30
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

typefilenamebigmsg db "No files with more than 10 bytes exist."
typenoentryfilenamemsg db "You did not enter a file name."

typefindfile:
    cmp cl,10
    je typenoentryfilename
    ;开始寻找文件
    pop ax
    push ax

    mov si,0-0x8000+4096-512+3
    mov bl,218 ;218个文件

typefindfilerun:
    mov cx,[si]
    cmp cx,[input+5]
    jne typefindnextfile

    mov cx,[si+2]
    cmp cx,[input+7]
    jne typefindnextfile

    mov cx,[si+4]
    cmp cx,[input+9]
    jne typefindnextfile

    mov cx,[si+6]
    cmp cx,[input+11]
    jne typefindnextfile

    mov cx,[si+8]
    cmp cx,[input+13]
    jne typefindnextfile

    ;还需要比较文件id
    mov ah,[si-1]
    cmp al,ah
    jne typefindnextfile

    ;确认有文件之后，ds指向文件段，开读
    mov ax,[si-3]
    and ah,0fh ;ax高位十位置0
    mov cl,al
    mov al,ah
    mov ah,cl ;高低位互换

    ;提前初始化指针si
    mov si,0

    ;初始化ds
    mov bx,0x09a0
    mov ds,bx

    ;ax=1直接去读
    cmp ax,1
    je typeread
    ;一段是16字节，512/16=32段

typedsset:
    add bx,0x20

    dec ax
    jnz typedsset

    mov ds,bx
    jmp typeread

typeread:
    mov ah,0eh
    mov al,[si]

    cmp al,0xb8 ;说明文件有可能已经读完
    je typeiffin

typeshow:
    int 10h;否则中断显示
    add si,1

    cmp si,16 ;一个段
    je typereadaddds

    jmp typeread

typereadaddds:
    add bx,1
    mov ds,bx
    mov si,0
    jmp typeread

typefindnextfile:
    add si,14
    dec bl
    jnz typefindfilerun
    ;说明不存在该文件，抛出错误

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,typenofilemsg
    mov cx,16
    mov bl,0x07
    mov bh,0
    int 10h

    mov cl,10
    mov si,5

typeshowfile:
    mov ah,0eh
    mov al,[input+si]
    int 10h

    add si,1
    dec cl
    jnz typeshowfile

    jmp Command

typenofilemsg db "File not found: "

typeiffin:
    mov cx,[si+1]
    cmp cx,0x0000
    jne typeshow

    mov cx,[si+3]
    cmp cx,0x88cd
    jne typeshow

    jmp typefin

typefin:
    mov bx,0
    mov ds,bx ;ds归0
    jmp Command
;----------------------------------------------------------------------------------------------------------------------------
