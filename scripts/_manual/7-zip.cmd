:: ==============================================================
:: Tunes 7-Zip Shell Menu
:: ==============================================================

:: Command ID, mask, Descripiton
:: 0, 1, Open archive
:: 1, 2, Open archive (as ...)
:: 2, 4, Extract files...
:: 3, 8, Extract Here
:: 4, 16, "Extract to "<Folder>"
:: 5, 32, Test archive
:: 6, 64, Add to archive...
:: 7, 128 Compress and email...
:: 8, 256, Add to "<Name>.7z"
:: 9, 512, Compress to "<Name>.7z" and email
:: 10, 1024 Add to "<Name>.zip"
:: 11 Compress to "<Name>.zip" and email
:: 12 CRC-32CRC-32
:: 13 CRC-64CRC-64
:: 14 SHA-256SHA-256
:: 15 SHA-1SHA-1
:: 16, 65536, All SHA/CRC

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifing Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: Calculate
set /a "CUSTOM_NATIVE_MENU=16+1024+65536"
reg add "HKCU\Software\7-Zip\Options" /v "ContextMenu" /t REG_DWORD /d %CUSTOM_NATIVE_MENU% /f

:: ======================
:: Lock the default Compression Level 2 (Light)
reg add "HKCU\Software\7-Zip\Compression" /v "Level" /t REG_DWORD /d 2 /f
reg add "HKCU\Software\7-Zip\Compression" /v "ArcFormat" /t REG_SZ /d "zip" /f
