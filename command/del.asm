;-----------------------------------------------------------del命令----------------------------------------------------------
delcommand:
    mov al,[input+15]
    cmp al,0x00
    jne delentryfiletobig
    ;还是先将0x00转成0x20
    mov cl,10
    mov si,4
    mov bl,0

delset0to20:
    mov al,[input+si]

    cmp al,0x00
    je delset0to20run

    cmp al,0x20
    je delset0to20run

    add si,1
    dec cl
    jnz delset0to20

    jmp delfindfile

delset0to20run:
    mov al,0x20
    mov [input+si],al
    add bl,1
    add si,1
    dec cl
    jnz delset0to20

    jmp delfindfile

delentryfiletobig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,delentryfiletobigmsg
    mov cx,32
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

delnoetryfile:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,delnoetryfilemsg
    mov cx,30
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

delentryfiletobigmsg db "No file is longer than 10 bytes."
delnoetryfilemsg db "You did not enter a file name."

delfindfile:
    cmp bl,10
    je delnoetryfile
    ;首先获取当前的文件夹id,搜索是否有这个文件

    pop ax
    push ax

    mov bl,218
    ;初始化指针
    mov si,0-0x8000+4096-512+3

delfindfilerun:
    mov cx,[input+4]
    cmp cx,[si]
    jne delfindnextfile

    mov cx,[input+6]
    cmp cx,[si+2]
    jne delfindnextfile

    mov cx,[input+8]
    cmp cx,[si+4]
    jne delfindnextfile

    mov cx,[input+10]
    cmp cx,[si+6]
    jne delfindnextfile

    mov cx,[input+12]
    cmp cx,[si+8]
    jne delfindnextfile

    mov ah,[si-1]
    cmp ah,al
    jne delfindnextfile

    jmp delfile

delfindnextfile:
    add si,14
    dec bl
    jnz delfindfilerun

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,delnofindfilemsg
    mov cx,15
    mov bl,0x07
    mov bh,0
    int 10h

    mov si,4
    mov cl,10

delshowfile:
    mov ah,0eh
    mov al,[input+si]
    int 10h

    add si,1
    dec cl
    jnz delshowfile

    jmp Command

delnofindfilemsg db "File not found:"

delfile:
    ;先将储存在文件名储存区的抹掉，之后再将在文件储存区的内容抹掉
    sub si,3
    mov bp,[si] ;保存所在扇区
    mov cl,14
    mov ah,"x"

delremovename:
    mov [si],ah
    add si,1
    dec cl
    jnz delremovename

    ;写入扇区
    mov bx,0-0x8000+7168-0xe00
    mov ah,03h
    mov al,6 ;写6个扇区
    mov ch,0
    mov cl,9 ;9扇区开始
    mov dl,0
    mov dh,0
    int 13h
    mov si,0;提前初始化指针si

    ;现在要抹掉文件内容
    mov ax,09a0h
    mov ds,ax ;初始化段

    ;高低位互换
    mov ax,bp
    mov cl,al
    mov al,ah
    mov ah,cl
    mov bp,ax
    mov bx,ds

    cmp bp,1 ;1直接去抹除文件
    je delremovefile

    mov ax,ds

 deldsset:
    add ax,0x20
    dec bp
    jnz deldsset
    mov ds,ax

delremovefile:
    ;现在可以开始抹除文件了
    mov al,[si]

    cmp al,0xb8 ;有可能抹除完了
    je delremovefileiffin

delremovebyte:
    mov al,0xe2
    mov [si],al

    add si,1
    cmp si,16;一段
    je deladdds

    jmp delremovefile

delremovefileiffin:
    mov cx,[si+1]
    cmp cx,0x0000
    jne delremovebyte

    mov cx,[si+3]
    cmp cx,0x88cd
    jne delremovebyte

    ;说明抹除完成，把5个字节都抹除再写入硬盘就可以
    mov al,0xe2
    mov ah,5

delremovew:
    mov [si],al
    add si,1
    dec ah
    jnz delremovew

    ;写硬盘
    mov bx,0x7c00+7168+512 ;文件起始段
    mov ah,03h
    mov al,51 ;写完剩下的扇区
    mov ch,0
    mov cl,15 ;15扇区开始
    mov dl,0
    mov dh,0
    int 13h

    mov bx,0
    mov ds,bx

    jmp Command
    
deladdds:
    add bx,0001
    mov ds,bx
    mov si,0
    jmp delremovefile
;----------------------------------------------------------------------------------------------------------------------------
