:: ==============================================================
:: Removes Windows bloatware (noise)
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: Policy to disable Copilot

:: https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai#:~:text=TurnOffWindowsCopilot
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Copilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f


:: ======================
:: Deletes XPS writer
:: Relies on the exact printer name, will not work if the object is renamed
printui.exe /dl /n "Microsoft XPS Document Writer" /q
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Printers\Microsoft XPS Document Writer" /f


:: ======================
:: Deletes Fax
:: Relies on the exact printer name, will not work if the object is renamed
printui.exe /dl /n "Fax" /q
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Print\Printers\Fax" /f

:: ======================
:: Disables creating Thumbs.db files on network folders
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableThumbsDBOnNetworkFolders /t REG_DWORD /d 1 /f

:: Disable creating Thumbs.db files on local PC
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisableThumbnailCache /t REG_DWORD /d 1 /f
