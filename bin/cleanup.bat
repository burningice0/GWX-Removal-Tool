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
echo Attempting to hide Update
powershell.exe -NoProfile -ExecutionPolicy Bypass -command "& '%0\..\hide.ps1'"
cd %windir%
echo Searching for remaining folders
for /f %%a IN ('dir /b /s /a:d *gwx*') DO CALL :delDr "%%a"
echo Searching for remaining folders
for /f %%a IN ('dir /b /s *gwx*') DO CALL :delFl "%%a"
CALL :delDr %userprofile%\AppData\Local\GWX
GOTO :EOF

:delDr
IF EXIST %1 (
echo Try to delete %1
takeown /f %1 /r /D Y
echo Take ownership
icacls %1 /GRANT administrators:F /T
echo Deleting file. 
echo.
rd %1 /q /s
)

:delFl
IF EXIST %1 (
echo Try to delete %1
takeown /f %1 
echo Take ownership
icacls %1 /GRANT administrators:F 
echo Deleting file.
echo.
del /q /f %1 
)

:EOF
