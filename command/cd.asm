;---------------------------------cd命令------------------------------------------------
cdcommand:
    ;cd 有5种命令。直接填写cd，打印当前目录；cd+目录，进入该目录；cd \ 或 cd /，进入根目录；cd ..；返回上一级；cd .>+文件名，创建文件
    mov cl,120
    mov al,[input+3]
    cmp al,0x00
    je cd1

    cmp ah,"\"
    je cd2

    cmp ah,"/"
    je cd2

    mov ax,[input+3]
    cmp ax,".."
    je cd3

    cmp ax,".>"
    je cd4

    ;通过现在目录的id，遍历目录，若检测到有目录所在id和当前目录的id一样，则进行比较
    mov cl,218 ;218个文件夹
    mov si,0-0x8000+0x200+2 ;设置指针

finddir: ;开始遍历目录
    pop ax
    push ax

    mov ah,[si]
    cmp ah,al ;比较到一样的id比较名称
    je comdir

    add si,14 ;否则指针+14
    dec cl
    jnz finddir

    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,DirNotfind
    mov cx,12
    mov bl,0x07
    mov bh,0
    int 10h

    add dl,13
    mov ah,13h
    mov al,1
    mov bp,input+3
    mov cx,117
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

    DirNotfind db "No find dir:"

comsetah0x20:
    mov ah,0x20
    jmp comsetah0x20fin

comdir:
    mov di,si ;备份si
    mov bp,3 ;input指针归0
    add si,1 ;si加1，指向文件夹名称的第一个字符
    mov ch,9

comcmpdir:
    mov ah,[input+bp]
    cmp ah,0x00
    je comsetah0x20

comsetah0x20fin:
    mov al,[si]
    cmp ah,al
    jne finnextdir

comnextfin:
    add si,1
    add bp,1

    dec ch
    jnz comcmpdir

    ;确认一样后，获取文件夹id
    pop ax
    mov ah,0
    mov al,[di-2]

    push ax
    mov si,0 ;指针归0

writepath:
    mov ah,[path+si]

    cmp ah,0xee
    je writepathcode

    add si,1
    jmp writepath

writepathcode:
    mov [path+si],al
    jmp Command

findnext:
    add si,1
    add bp,1

    dec ch
    jmp comnextfin

finnextdir:
    dec cl
    mov si,di
    add si,14

    jmp finddir

    cdCommandDisk db "A:\"
    path times 218 db 0xee ;218个文件夹
    db 0xee;预留

cd1:
    call showpath
    jmp Command

cd2:
    pop ax
    mov ax,0x0000 ;设置根目录
    push ax
    mov si,0
    mov cl,218
    mov al,0xee

clearpath: ;清空path
    mov [path+si],al
    add si,1
    dec cl
    jnz clearpath

cd3:
    ;通过获取当前文件夹id，在文件夹中搜索该文件，之后获取所在文件夹id。
    pop ax
    push ax

    cmp al,0x00 ;al为0x00就是在根目录，直接返回comand
    je Command

    mov si,0-0x8000+0x200;设置指针
    mov cl,218 ;218个文件夹

finddircode:
    mov ah,[si]

    cmp ah,al
    je getlastdircode

    add si,14
    jmp finddircode

getlastdircode:
    pop ax
    add si,2
    mov al,[si]
    mov ah,0

    push ax
    mov si,0

writepath2:
    mov al,[path+si]

    cmp al,0xee
    je writepath2code

    add si,1
    jmp writepath2

writepath2code:
    sub si,1
    mov al,0xee
    mov [path+si],al
    jmp Command

showpath:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,cdCommandDisk
    mov cx,3
    mov bl,0x07
    mov bh,0
    int 10h

    pop ax
    push ax

    cmp al,0x00
    je dirfin

    ;通过获取path来显示目录
    mov si,0xffff ;指针

cdshow:
    mov bp,0-0x8000+0x200 ;初始化指针
    add si,1
    mov al,[path+si]
    cmp al,0xee
    jne cdshowfinddir
    jmp dirfin

cdshowfinddir:
    mov ah,[bp]

    cmp al,ah
    je cdshowpath

    add bp,14
    jmp cdshowfinddir

cdshowpath:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    add bp,3
    mov cx,10
    mov bl,0x07
    mov bh,0
    int 10h

    mov ah,03h
    int 10h

set_cursor:
    mov ah,02h
    sub dl,1
    int 10h

    mov ah,08h
    int 10h

    cmp al,0x20
    je set_cursor

    mov ah,02h
    add dl,1
    int 10h

    mov ah,0eh
    mov al,'\'
    int 10h

    jmp cdshow

dirfin:
    ret

cd4:
    mov al,[input+15]

    cmp al,0x00
    je makefile

    cmp al,0x20
    je makefile

filenametobig:
    mov ah,03h
    int 10h

    mov ah,13h
    mov al,1
    mov bp,filenametobigmsg
    mov cx,36
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

filenametobigmsg db "The file name can be up to 10 bytes."

setinput:
    mov al,[input+16]

    cmp al,0x00
    jne filenametobig

    mov al,0x20
    mov [input+si],al

    inc si
    inc ch

    dec cl
    jnz setinput0to20

    jmp setinput0to20fin

makefile:
    ;首先，需要输入中的将0x00替换为0x20
    mov cl,10 ;字节文件名
    mov si,5 ;指针初始化
    mov ch,0

setinput0to20:
    mov al,[input+si]

    cmp al,0x00
    je setinput

    cmp al,0x20
    je setinput ;用于ch+1

    inc si

    dec cl
    jnz setinput0to20

setinput0to20fin:
    cmp ch,10
    je NoEntryfilename

    mov ah,03h
    int 10h

    mov bp,dx
    mov cl,218 ;218个文件
    mov si,0-0x8000+0x200+0xc00+3 ;初始化指针
    mov di,input+5

makefilefindfile:
    mov ax,[si]
    mov bx,[di]
    cmp ax,bx
    jne makefindnextfile

    mov ax,[si+2]
    mov bx,[di+2]
    cmp ax,bx
    jne makefindnextfile

    mov ax,[si+4]
    mov bx,[di+4]
    cmp ax,bx
    jne makefindnextfile

    mov ax,[si+6]
    mov bx,[di+6]
    cmp ax,bx
    jne makefindnextfile

    mov ax,[si+8]
    mov bx,[di+8]
    cmp ax,bx
    jne makefindnextfile

    mov di,bp
    ;之后比较文件夹id
    pop ax
    push ax

    mov ah,[si-1]
    cmp ah,al
    jne makenewfile

    ;说明已经在该目录下有该文件了，抛出错误
    mov ah,13h
    mov al,1
    mov bp,filehavemsg
    mov cx,42
    mov bl,0x07
    mov bh,0
    mov dx,di
    int 10h

    jmp Command

    filehavemsg db "The file already exists in this directory."

makenewfile:
    mov bp,dx
    ;先获取当前id，之后在文件名称储存位置创建一个文件名，之后遍历储存目录
    pop ax
    push ax
    mov si,0-0x8000+0x200+0xc00+13 ;初始化指针
    mov cl,218 ;218个文件夹

makenewfilefindfile: ;遍历文件以获取储存空间，若218个文件仍然没有找到可储存的地方，说明储存空间已经满了，抛出异常
    mov al,[si]
    cmp al,"x"
    je makefilename

    add si,1
    dec cl
    jnz makenewfilefindfile

    ;抛出异常
    mov dx,bp
    mov ah,13h
    mov al,1
    mov bp,filetobigmsg
    mov cx,36
    mov bl,0x07
    mov bh,0
    int 10h
    jmp Command

filetobigmsg db 0x0d,"There can be only 218 files at most."

makefilename:
    ;现在si指向创建新文件名的地址
    ;先要在文件区申请创建一个储存位置，所以要遍历文件的储存扇区
    ;一个段是16字节
    mov ax,0x09a0 ;文件储存空间在09a0h段
    mov ds,ax
    mov cx,0
    mov bp,973*2 ;973kb的储存区，2扇区=1kb。

makefilefindMemory:
    mov al,[0]

    cmp al,0xe2 ;说明有空扇区
    je makenewfilewrite

    mov ax,ds
    add ax,32 ;一个段16字节，512/16=32个段。
    mov ds,ax
    add cx,1
    dec bp
    jnz makefilefindMemory

;说明储存空间又又又又满了，抛出错误
    mov ax,0
    mov ds,ax ;ds归0
    mov ah,03h
    int 10h
    mov ah,13h
    mov al,1
    mov bp,floppymemoryfullmsg
    mov cx,34
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

floppymemoryfullmsg db "Floppy disk storage space is full."
makenewfilewrite:
mov di,cx ;备份cx
    ;先要在当前ds写入结束符
    mov cl,0xb8
    mov [0],cl
    mov cx,0x0000
    mov [1],cx
    mov cx,0x88cd
    mov [3],cx
    ;写硬盘
    mov bx,0x7c00+7168+512 ;文件起始段
    mov ah,03h
    mov al,51 ;写完剩下的扇区
    mov ch,0
    mov cl,15 ;15扇区开始
    mov dl,0
    mov dh,0
    int 13h
    ;特别重要！！！要将ds置回0！不然乱读段导致系统崩溃！
    mov ax,0
    mov ds,ax
    ;写文件名
    ;先写入内存
    mov cx,di
    and ch,0fh ;只取个位
    mov [si],ch
    mov [si+1],cl
    pop ax
    push ax
    mov [si+2],al
    mov cl,10
    add si,3
    mov bp,5

makenewfilewritefilename:
    mov ah,[input+bp]
    mov [si],ah

    add si,1
    add bp,1

    dec cl
    jnz makenewfilewritefilename

    mov ah,0x8e
    mov [si],ah ;结束符
    mov bx,0-0x8000+7168-0xe00
    mov ah,03h
    mov al,6 ;写6个扇区
    mov ch,0
    mov cl,9 ;9扇区开始
    mov dl,0
    mov dh,0
    int 13h

    mov ah,0
    mov al,2
    int 10h

    jmp Command

makefindnextfile:
    cmp cl,0
    je makenewfile

    dec cl
    add si,14
    mov di,input+5

    jmp makefilefindfile

NoEntryfilename:
    mov ah,03h
    int 10h
    mov ah,13h
    mov al,1
    mov bp,NoEntryfilenamemsg
    mov cx,26
    mov bl,0x07
    mov bh,0
    int 10h

    jmp Command

NoEntryfilenamemsg db "You didn't type file name."
;---------------------------------------------------------------