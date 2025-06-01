;mkdir
mkdirIfCommand:
    mov bp,0
    mov si,0

mkdirifCommand:
    mov ah,[input+si]
    mov al,[mkdir+bp]

    cmp al,"$"
    je mkdircommand

    cmp ah,al
    je mkdirNextIfCommand

    jmp typeIfCommand

mkdirNextIfCommand:
    add si,1
    add bp,1
    jmp mkdirifCommand