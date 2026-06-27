:: ==============================================================
@echo Prevents auto-running of removable devices (USB-flash, CD/DVD)
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    endlocal
    exit /b 1
)

:: ==============================================================
echo 1. Disables AutoRun policies on 64-bit machines (HKLM)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HonorAutoRunSetting" /t REG_DWORD /d 1 /f

:: ==============================================================
echo 2. Disables AutoRun policies for the 32-bit subsystem (Wow6432Node)
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HonorAutoRunSetting" /t REG_DWORD /d 1 /f

:: ==============================================================
echo 3. Disables the global AutoPlay "Choose what to do" pop-up handlers
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d 1 /f

:: ==============================================================
echo 4. Injects AutoRun restrictions into the Default User profile template for future users
reg load HKLM\TempDefaultProfile "C:\Users\Default\NTUSER.DAT" >nul 2>&1
if %errorLevel% == 0 (
    reg add "HKLM\TempDefaultProfile\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f >nul
    reg add "HKLM\TempDefaultProfile\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f >nul
    reg add "HKLM\TempDefaultProfile\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d 1 /f >nul
    reg unload HKLM\TempDefaultProfile >nul
) else (
    echo [WARNING] Could not load Default User NTUSER.DAT template.
)

:: ==============================================================
echo 5. Injects AutoRun restrictions into all existing and active user profiles
for /f "tokens=1,2 delims=\" %%a in ('reg query HKEY_USERS ^| findstr /r /c:"S-1-5-21-[0-9\-]*$"') do (
    reg add "HKU\%%b\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f >nul
    reg add "HKU\%%b\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f >nul
    reg add "HKU\%%b\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d 1 /f >nul
)

:: ==============================================================
echo 6. Safe refreshes the Windows environment parameters to apply changes
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters
