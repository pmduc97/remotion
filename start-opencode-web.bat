@echo off
setlocal
title OpenCode Web - LAN
cd /d "%~dp0"

echo ==========================================================
echo                  OPENCODE WEB - LAN
echo ==========================================================
echo.
set /p "OPENCODE_SERVER_PASSWORD=Nhap mat khau de dang nhap tu dien thoai: "
if not defined OPENCODE_SERVER_PASSWORD (
    echo Mat khau khong duoc de trong.
    pause
    exit /b 1
)

echo.
echo Dia chi IPv4 cua laptop:
ipconfig | findstr /i "IPv4"
echo.
echo Tren dien thoai cung Wi-Fi, mo http://DIA-CHI-IP-CUA-LAPTOP:4096
echo Giu cua so nay mo trong khi su dung OpenCode.
echo.

opencode web --hostname 0.0.0.0 --port 4096
pause
