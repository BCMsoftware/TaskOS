;del
delIfCommand:
    mov bp,0
    mov si,0

delifCommand:
    mov ah,[input+si]
    mov al,[del+bp]
    cmp al,"$"
    je delcommand

    cmp ah,al
    je delNextIfCommand

    jmp rdIfCommand

delNextIfCommand:
    add si,1
    add bp,1
    jmp delifCommand