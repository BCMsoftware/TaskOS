;cls命令
clscommand:
    mov ah,0
    mov al,2
    int 10h
    jmp Command