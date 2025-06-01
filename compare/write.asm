;write
writeIfCommand:
    mov bp,0
    mov si,0

writeifCommand:
    mov ah,[input+si]
    mov al,[write+bp]

    cmp al,"$"
    je writecommand

    cmp ah,al
    je writeNextIfCommand
    
    jmp Commandfin

writeNextIfCommand:
    add si,1
    add bp,1
    jmp writeifCommand