@echo off

echo Build Boot.bin...
nasm\nasm.exe Boot.asm -o build\Boot.bin
echo Build Kernel.bin...
nasm\nasm.exe Kernel.asm -o build\Kernel.sys

echo.

cd build
copy /b Boot.bin + Kernel.sys Task.img

echo.

echo Succeed.
pause>nul