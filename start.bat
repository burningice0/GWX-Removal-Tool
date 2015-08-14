@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

echo Check: Admin
echo killing gwx.exe
taskkill /f /im gwx.exe
echo uninstalling kb:3035583
wusa /uninstall /kb:3035583 /quiet /norestart
echo Stopping trustedinstaller 
net stop trustedinstaller 
echo Setting registry entries
reg ADD HKLM\Software\Policies\Microsoft\Windows\GWX /v DisableGWX /t REG_DWORD /d 1 /f
reg ADD HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate /v DisableOSUpgrade /t REG_DWORD /d 1 /f
reg ADD HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade /v AllowOSUpgrade /t REG_DWORD /d 0 /f
reg ADD HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade /v ReservationsAllowed /t REG_DWORD /d 0 /f
reg ADD HKCU\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade /v ReservationsAllowed /t REG_DWORD /d 0 /f
reg ADD HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce /v CleanupGWX /t REG_SZ /d "cmd.exe /c call %~dp0bin\cleanup.bat"
echo restarting
shutdown.exe /r /f /t 0