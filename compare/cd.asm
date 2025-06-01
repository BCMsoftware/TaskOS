;cd
cdIfCommand:
    mov ah,[input+si]
    mov al,[cd+bp]
    cmp al,"$" ;比较到终止符直接跳转至命令
    je cdcommand

    cmp ah,al
    je cdNextIfCommand
    
    jmp clsIfCommand

cdNextIfCommand:
    add si,1
    add bp,1
    jmp cdIfCommand
