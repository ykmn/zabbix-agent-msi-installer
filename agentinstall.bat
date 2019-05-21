@echo off
:: Installs Zabbix Agent MSI to remote computer
:: Have zabbix_agent-VER_ARCH.msi and psexec.exe in script folder.
::
:: History:
:: v1.3 2018-03-27 Auto-downloading .msi from http://www.suiviperf.com/zabbix - just set the version in %ZAGENT%
:: v1.2 2017-12-28 Some code cleanup.
:: v1.1 2017-03-15 Now asking for admin username; removed hardcoded drive letter for remote c$.
:: v1.0 2013-04-08 Initial release.
:: Roman Ermakov <r.ermakov@emg.fm>

setlocal ENABLEEXTENSIONS

set ZAGENT=zabbix_agent-4.2.1
set ZSERIP=172.16.100.100

if %1.==. (echo Usage: agentinstall \\COMPUTERNAME && echo.  && goto:eof)
if not exist psexec.exe (echo Sorry, no psexec.exe found. && echo Get it from Microsoft: https://docs.microsoft.com/en-us/sysinternals/downloads/psexec  && echo. && goto:eof)

if not exist %ZAGENT%*.msi (
echo No Zabbix Agent MSI installer found. Downloading from http://www.suiviperf.com/zabbix/ &&^
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Invoke-WebRequest http://www.suiviperf.com/zabbix/%ZAGENT%_x86.msi -OutFile %ZAGENT%_x86.msi" &&^
powershell -NoProfile -ExecutionPolicy unrestricted -Command "Invoke-WebRequest http://www.suiviperf.com/zabbix/%ZAGENT%_x64.msi -OutFile %ZAGENT%_x64.msi" )

if exist x:\ (net use x: /d)

set /P ADMIN=Enter remote PC adminisrtator username as DOMAIN\username or press Enter if you have admin rights:
set COMPUTERNAME=%1

:process
echo =====================================================================
echo Processing %COMPUTERNAME%.
echo Disconnecting admin share if any:
net use %COMPUTERNAME%\c$ /DELETE
if DEFINED ADMIN (
	net use %COMPUTERNAME%\c$ /user:%ADMIN% || (echo Error %ERRORLEVEL% && net helpmsg %ERRORLEVEL% && goto:eof)
) else (
	net use %COMPUTERNAME%\c$ || (echo Error %ERRORLEVEL% && net helpmsg %ERRORLEVEL% && goto:eof)
)


if not exist %COMPUTERNAME%\c$\temp mkdir %COMPUTERNAME%\c$\temp
if not exist "%COMPUTERNAME%\c$\Program Files (x86)" (set ARCH=x86) else (set ARCH=x64)
echo Detected remote Windows architecture: %ARCH%
echo Copying %ZAGENT%_%ARCH%.msi to remote folder:
copy %ZAGENT%_%ARCH%.msi %COMPUTERNAME%\c$\temp\
pause

::psexec \\%COMPUTERNAME% -u %ADMINUSER% C:\WINDOWS\SYSTEM32\msiexec.exe /I C:\TEMP\%ZAGENT%_%ARCH%.msi SERVER=%ZSERIP% SERVERACTIVE=%ZSERIP%:10050 LPORT=10050 RMTCMD=1 /qn

echo.
echo.
echo ---------------------------------------------------------------------
echo Stopping Zabbix Agent if any.
if DEFINED ADMIN (runas /noprofile /user:%ADMIN% "sc %COMPUTERNAME% stop 'Zabbix Agent' & pause") else (sc %COMPUTERNAME% stop "Zabbix Agent")
pause
echo.
echo.
echo ---------------------------------------------------------------------
echo Installing Zabbix Agent.
if DEFINED ADMIN (
	psexec %COMPUTERNAME% -u %ADMIN% -h cmd /c "msiexec.exe /i C:\TEMP\%ZAGENT%_%ARCH%.msi server=%ZSERIP% serveractive=%ZSERIP% lport=10050 rmtcmd=1 /qn"
) else (
	psexec %COMPUTERNAME% -h cmd /c "msiexec.exe /i C:\TEMP\%ZAGENT%_%ARCH%.msi server=%ZSERIP% serveractive=%ZSERIP% lport=10050 rmtcmd=1 /qn"
)
echo Errorlevel = %ERRORLEVEL% :
net helpmsg %ERRORLEVEL%
pause
echo.
echo.
echo ---------------------------------------------------------------------
echo Starting Zabbix Agent if any.
if DEFINED ADMIN (runas /noprofile /user:%ADMIN% "sc %COMPUTERNAME% start 'Zabbix Agent' & pause") else (sc %COMPUTERNAME% start "Zabbix Agent")
goto:eof

:cleanup
echo.
echo.
echo ---------------------------------------------------------------------
echo Cleaning up.
net use %COMPUTERNAME%\c$ /DELETE
set COMPUTERNAME=
set ZSERIP=
set ZAGENT=
set ARCH=
set ADMIN=
echo Done. Please check the output for errors.
echo =====================================================================
echo.
echo.
goto:eof
