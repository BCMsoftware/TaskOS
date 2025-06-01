    org 0x7c00+7168+512;偏移值


    %include "./Init.asm" ;
    %include "./compare/command.asm" ;
    %include "./command/command.asm" ;

    db 0xb8,0x00,0x00,0xcd,0x88 ;文件储存结束符
    times 0xf4ffe-7*1024-($-$$) db 0xe2
    db 0x55,0xaa