;type
typeIfCommand:
    mov bp,0
    mov si,0

typeifCommand:
    mov ah,[input+si]
    mov al,[type+bp]

    cmp al,"$"
    je typecommand

    cmp ah,al
    je typeNextIfCommand

    jmp delIfCommand
    
typeNextIfCommand:
    add si,1
    add bp,1
    jmp typeifCommand