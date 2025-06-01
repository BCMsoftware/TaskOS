;rd
rdIfCommand:
    mov bp,0
    mov si,0

rdifCommand:
    mov ah,[input+si]
    mov al,[rd+bp]

    cmp al,"$"
    je rdcommand

    cmp ah,al
    je rdNextIfCommand

    jmp writeIfCommand

rdNextIfCommand:
    add si,1
    add bp,1
    jmp rdifCommand