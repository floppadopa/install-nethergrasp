@echo off
REM Nether-Grasp Installer Batch Launcher
REM Alternative launcher if the .exe doesn't work

echo ============================================================
echo          NETHER-GRASP INSTALLER LAUNCHER
echo ============================================================
echo.
echo Starting installer...
echo.

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Check if PowerShell script exists
if not exist "%SCRIPT_DIR%installation-script-2.ps1" (
    echo [ERROR] installation-script-2.ps1 not found!
    echo.
    echo Please make sure the script is in the same directory as this batch file.
    echo.
    pause
    exit /b 1
)

REM Run PowerShell script with execution policy bypass
echo Running PowerShell launcher...
echo.
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%installation-script-2.ps1"

echo.
echo ============================================================
echo.
pause

