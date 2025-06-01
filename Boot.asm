;偏移
    org 0x7c00

;软盘头
    jmp Load
    db 0x00 ;可读可写
    db 0x01 ;版本1
    db 0x00 ;空着
    db "Task OS Disk " ;13字节磁盘名称
    db "AsmCaiNiao" ;10个字节制造商或开发者名称
    times 23 db 0x00 ;空23字节

BootSetCache:
    ;设置段
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    ret

Load: ;加载区
    call BootSetCache
    ;重置驱动器
    mov ah,0
    mov dl,0 ;A软驱
    int 13h
    mov bx,Dirname
    mov ah,2
    mov al,64 ;测试得来的64个扇区
    mov ch,0
    mov cl,2
    mov dl,0
    mov dh,0
    int 13h
    jc Return
    mov si,0
    ;读取内容，先搜索文件夹
    mov si,Dirname+512+3 ;空出前面的512字节和3个字节
    FindDir:
    mov bx,[si]
    mov cx,[si+2]
    mov dx,[si+4] ;读
    mov di,[si+6]
    mov bp,[si+8]
    ;比较
    cmp bx,"TA"
    je FindDirNext
    FindNextDir:
    cmp si,Dirname+512+3
    je BootSetStack
    BootStack:
    pop cx ;将cx出栈
    cmp cx,218 ;(4096-1024)/14-1=218个文件夹
    je LoadError
    add cx,1
    push cx
    add si,14
    jmp FindDir

BootSetStack:
    mov cx,1
    push cx
    jmp BootStack

FindDirNext:
    cmp cx,"SK"
    jne FindNextDir
    cmp dx,"  "
    jne FindNextDir
    cmp di,"  "
    jne FindNextDir
    cmp bp,"  "
    jne FindNextDir
    mov al,[si-3];获取文件夹ID

FindFile:
    mov si,Filename+512 ;跳过前面的512字节
    mov ah,[si]
    mov al,ah
    cmp ah,al
    je FindFileNext

FindNextFile:
    cmp si,Filename+512
    je BootSetStack2

BootStack2:
    pop cx ;将cx出栈
    cmp cx,218 ;(7168-4096)/14-1=218个文件
    je LoadError
    add cx,1
    push cx
    add si,14
    jmp FindFile

BootSetStack2:
    mov cx,1
    push cx
    jmp BootStack2

FindFileNext:
    add si,3
    mov bx,[si]
    mov cx,[si+2]
    mov dx,[si+4] ;读
    mov di,[si+6]
    mov bp,[si+8]
    cmp bx,"Ke"
    jne FindNextFile
    cmp cx,"rn"
    jne FindNextFile
    cmp dx,"el"
    jne FindNextFile
    cmp di,".s"
    jne FindNextFile
    cmp bp,"ys"
    jne FindNextFile
    call BootSetCache

    ;跳转前的准备
    mov cl,[si-2]
    mov ch,[si-3]
    and ch,0fh ;只取个位
    mov bx,0x9a00 ;初始化段

mulsq:
    cmp cx,1
    je JmpKernel
    add bx,0x20 ;bx是一个段，给cs
    dec cx
    jmp mulsq

JmpKernel:
    ;将bx拷贝到下方跳转的那里，
    mov [bootsetcs+1],bx
    bootsetcs equ $
    jmp 0000:0 ;空着，准备跳
    db "00"
    ;---------------------------------------

Return:
    cmp di,5 ;若5次仍然无法读取，抛出错误
    je ReadError
    add di,1
    jmp Load

ReadError:
    call BootSetCache
    mov ah,3
    int 10h
    mov ah,13h
    mov al,1
    mov bp,ReadErrorMsg
    mov cx,31
    mov bl,0xf4
    mov bh,0
    int 10h
    mov ah,0eh
    mov al,0x07
    int 10h ;鸣笛一次
    jmp CPUEXIT

LoadError:
    call BootSetCache
    mov ah,03h
    int 10h
    mov ah,13h
    mov al,1
    mov bp,LoadErrorMsg
    mov cx,45
    mov bl,0xf4
    mov bh,0
    int 10h
    mov ah,0eh
    mov al,0x07
    int 10h ;鸣笛一次
    jmp CPUEXIT

ReadErrorMsg db "Unable to read A: All sectors ."
LoadErrorMsg db "Unable to find the file: A:\Task\Kernel.sys ."

CPUEXIT:
    HLT
    jmp CPUEXIT

times 510-($-$$) db 0x00 ;空510字节
db 0x55,0xaa
times 512 db 0x00 ;再空512字节

;这里是文件夹名称储存区
Dirname:
db 0x01,0x00,0x00,"TASK      ",0x8e ;类似于C:\Windows 这里是A:\TASK，01这文件夹的id，00不隐藏，00所在文件夹id。
times 4096-($-$$) db 0xe1

;这里是文件名称储存区
Filename:
db 0x00,0x01,0x01,"Kernel.sys",0x8e ;0不隐藏，001第一个扇区
times 7168-($-$$) db "x"

File:
;Kernel内核部分