:: github.com/yonesYN/SetDNSLine
@ECHO OFF
TITLE "Set DNS Line"
MODE con: cols=83 lines=19
SETLOCAL ENABLEDELAYEDEXPANSION
WHOAMI /GROUPS | findstr "S-1-16-12288" >NUL && GOTO S
SET "params=%*"
CD /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>NUL 2>NUL || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:S
CD /d "%~dp0"
IF NOT EXIST "config.txt" (GOTO ERROR)
FOR /F "tokens=2 delims=:" %%a in ('findstr /b "INTERFACE" "config.txt"') do (
	set "i=%%a"
	GOTO M
)
:SEL
CLS
SET "ct=0"
FOR /F "tokens=3*" %%a in ('netsh interface show interface ^| findstr /c:"Connected"') do (
	set /a ct+=1
	set "if!ct!=%%b"
	echo [!ct!] %%b
)

IF !ct!==0 (
    echo No connected interfaces found
	color 4
    pause
    exit
)

SET /p num="Interface: "
IF NOT DEFINED if%num% (GOTO SEL)
SET "i='!if%num%!'"

:M
SET "i=%i:	=%"
SET "m=%i: =%"
IF NOT DEFINED i (GOTO SEL)
IF NOT DEFINED m (GOTO SEL)
IF /I "%i: =%"=="auto" (
FOR /F "delims=" %%F in ('powershell -NoProfile -Command "$ap=(Get-NetAdapter | Where Status -eq 'Up' | Sort-Object InterfaceIndex)[0]; $DNS=(Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceIndex $ap.ifIndex).ServerAddresses -join ', '; Write-Output ($ap.Name + ': ' + $DNS + 'N')"') do (
    set "full=%%F"
	GOTO I)
)
FOR /F "delims=" %%F in ('powershell -NoProfile -Command "$DNS=(Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceAlias %i% -ErrorAction SilentlyContinue).ServerAddresses -join ', '; Write-Output (%i% + ': ' + $DNS + 'N')"') do (
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

SET "name="
SET "pattern=:[ 	]*'%dns1%"
IF DEFINED dns2 (
	FOR /F "delims=" %%a in ('findstr /r /c:"%pattern%" "config.txt" ^| findstr "%dns2%"') do (
		set "name=%%a"
		GOTO N
	)
)
FOR /F "delims=" %%a in ('findstr /r /c:"%pattern%" "config.txt" ^| findstr /v ","') do (
	set "name=%%a"
	GOTO N
)
:N
IF DEFINED name (
SET "name=%name::=" & rem %
)ELSE (SET "name=DNS")

FOR /F "tokens=9" %%F in ('ping -n 1 -w 1000 %dns1% ^| find "Minimum ="') do (SET ping=%%F)
COLOR B
CLS
IF NOT DEFINED ping (SET "ping=[31mTimeout[96m")
ECHO %name%: %adns:N=%		%ping%
SET "ping="

:D
IF "%adns%"=="N" (ECHO DNS: [31mNone[96m)
ECHO Interface: %ap%
ECHO:
SET "ct="
FOR /F "skip=1 tokens=1 delims=:" %%a in ('findstr /r "[0-9].[0-9]" "config.txt"') do (
    set /a ct+=1
    echo [!ct!] %%a
)
ECHO:
ECHO [D] Defualt DNS   [S] Select Interface
SET "dns="
SET "lin=a"
SET /p lin=type :

ECHO %lin% | findstr /r "[0-9]" >NUL && GOTO SET
IF /I "%lin%"=="D" (GOTO DHCP)
IF /I "%lin%"=="S" (GOTO SEL)
GOTO I

:SET
FOR /F "skip=%lin% tokens=2 delims=:" %%a in ('findstr /r "[0-9].[0-9]" "config.txt"') do (
	set "dns=%%a"
	GOTO NE
)
if not defined dns (GOTO I)
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
powershell -NoProfile -Command "Set-DnsClientServerAddress -InterfaceAlias '%ap%' -ServerAddresses (%dns%)" >NUL && COLOR A || COLOR 4
ipconfig /flushdns >NUL
GOTO M

:DHCP
CLS
ECHO Loading...
netsh interface ipv4 set dnsservers name="%ap%" source=dhcp >NUL && COLOR A || COLOR 4
ipconfig /flushdns >NUL
GOTO M

:ERROR
ECHO [31mconfig.txt not exist
timeout 6 >NUL
EXIT

