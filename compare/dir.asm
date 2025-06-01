;dir
dirIfCommand:
    mov bp,0
    mov si,0

dirifCommand:
    mov ah,[input+si]
    mov al,[dir+bp]

    cmp al,"$"
    je dircommand

    cmp ah,al
    je dirNextIfCommand

    jmp mkdirIfCommand

dirNextIfCommand:
    add si,1
    add bp,1
    jmp dirifCommand