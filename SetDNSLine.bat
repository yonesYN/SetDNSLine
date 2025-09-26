@echo off
title "Set DNS Line"
mode con: cols=83 lines=19
setlocal enabledelayedexpansion
whoami /groups | findstr "S-1-16-12288" >nul && GOTO S
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:S
cd /d "%~dp0"
if not exist "config.txt" (
	GOTO ERROR
)
CLS
ECHO Loading...
for /f "tokens=2 delims=:" %%a in ('findstr /b "INTERFACE" "config.txt"') do (
	set "cfg=%%~a"
	GOTO M
)
:M
if defined cfg (
for /f "delims=" %%F in ('powershell -NoProfile -Command "$DNS=(Get-DnsClientServerAddress -InterfaceAlias %cfg% | Where AddressFamily -eq 2).ServerAddresses -join ', '; Write-Output (%cfg% + ': ' + $DNS + 'N')"') do (
    set "full=%%F"
	GOTO I
)
)
for /f "delims=" %%F in ('powershell -NoProfile -Command "$ap=(Get-NetAdapter | Where Status -eq 'Up' | Sort-Object InterfaceIndex)[0]; $DNS=(Get-DnsClientServerAddress -InterfaceIndex $ap.ifIndex | Where AddressFamily -eq 2).ServerAddresses -join ', '; Write-Output ($ap.Name + ': ' + $DNS + 'N')"') do (
    set "full=%%F"
)
:I
SET "ap=%full:: =" & rem %
SET "adns=%full:*: =%"
IF "%adns%"=="N" (
COLOR B
CLS
GOTO D
)
SET "adns=%adns:N=%"
SET "dns1=%adns:,=" & SET "dns2=%"

set "name="
set "pattern=:[ 	]*'%dns1%"
if defined dns2 (
	for /f "delims=" %%a in ('findstr /r /c:"%pattern%" "config.txt" ^| findstr "%dns2%"') do (
		set "name=%%a"
		GOTO N
	)
)
for /f "delims=" %%a in ('findstr /r /c:"%pattern%" "config.txt" ^| findstr /v ","') do (
	set "name=%%a"
	GOTO N
)
:N
if defined name (
SET "name=%name::=" & rem %
)else (SET "name=DNS")

FOR /F "tokens=* USEBACKQ" %%F IN (`ping %dns1% -n 1 -w 1000`) DO (SET ping=%%F)
COLOR B
CLS
SET "ping=%ping:,="& rem %
IF "%ping:~,1%" == "M" (ECHO %name%: %adns:N=%		%ping:Minimum =Ping%
GOTO D)
ECHO [96m%name%: %adns%		Ping=[31mTimeout[96m


:D
IF "%adns%"=="N" (ECHO [96mDNS: [31mNone[96m)
ECHO Interface: %ap%
ECHO:
set "count="
for /f "skip=1 tokens=1 delims=:" %%a in ('findstr /r "[0-9].[0-9]" "config.txt"') do (
    set /a count+=1
    echo [!count!] %%a
)

SET "lin=a"
SET /p lin=type :

echo %lin% | findstr /r "[0-9]" >nul
if %errorlevel% equ 0 (
	GOTO SET
) else (
	GOTO S
	IF %lin%==d (GOTO DHCP)
)

:SET
for /f "skip=%lin% tokens=2 delims=:" %%a in ('findstr /r "[0-9].[0-9]" "config.txt"') do (
	set "dns=%%~a"
	GOTO NE
)
:NE
SET "dns=%dns: =%"
SET "dns=%dns:	=%"
CLS
COLOR 6
ECHO Loading...
ECHO:
ECHO Y88b   d88P 888b    888
ECHO  Y88b d88P  8888b   888
ECHO   Y88o88P   88888b  888
ECHO    Y888P    888Y88b 888
ECHO     888     888 Y88b888
ECHO     888     888  Y88888
ECHO     888     888   Y8888
ECHO     888     888    Y888
powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '%ap%' -ServerAddresses (%dns%)" >nul && COLOR A || COLOR 4
ipconfig /flushdns >nul
GOTO M

:DHCP
CLS
netsh interface ipv4 set dnsservers name="%inter%" source=dhcp >nul
GOTO M

:ERROR
ECHO [31mconfig.txt not exist
timeout 6 >nul

exit
