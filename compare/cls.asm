;cls
clsIfCommand:
    mov bp,0
    mov si,0

clsifCommand:
    mov ah,[input+si]
    mov al,[cls+bp]
    cmp al,"$"
    je clscommand
    
    cmp ah,al
    je clsNextIfCommand
    jmp dirIfCommand
    
clsNextIfCommand:
    add si,1
    add bp,1
    jmp clsifCommand
    