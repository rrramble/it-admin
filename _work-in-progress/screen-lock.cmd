:: ==============================================================
@echo Screen Lock
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnableExtensions EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\system32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: Variables
set /a INACTIVITY_TIMER_SEC=1200
set "TEMP_HIVE_NAME=ScreenSaverDeploy_%RANDOM%_%RANDOM%"
set "SCREEN_SAVE_EXECUTABLE=%SystemRoot%\system32\scrnsave.scr"

:: ======================
:: Run
if not exist "%SCREEN_SAVE_EXECUTABLE%" (
    @echo [ERROR] Missing screensaver executable: %SCREEN_SAVE_EXECUTABLE%
    exit /b 1
)

:: Current user
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive"         /t REG_SZ /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure"      /t REG_SZ /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut"        /t REG_SZ /d %INACTIVITY_TIMER_SEC% /f
reg add "HKCU\Control Panel\Desktop" /v "LockScreenAutoLockActive" /t REG_SZ /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "%SystemRoot%\system32\scrnsave.scr" /f

:: Other users
set "CURRENT_PROFILE=%USERPROFILE%"

for /D %%P in ("%SystemDrive%\Users\*") do (
    set "ProfilePath=%%~fP"
    set "HiveFile=%%~fP\NTUSER.DAT"

    rem Exclude system profile
    if /I not "%%~nxP"=="Public" (
        rem Exludes current user
        if /I not "!ProfilePath!"=="%CURRENT_PROFILE%" (
            if exist "!HiveFile!" (
                @echo %DATE% %TIME% - Loading !HiveFile!
                reg load "HKU\%TEMP_HIVE_NAME%" "!HiveFile!" >nul 2>&1

                if errorlevel 1 (
                    @echo [ERROR] Failed loading !HiveFile!
                ) else (
                    reg add "HKU\%TEMP_HIVE_NAME%\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 1 /f >nul
                    reg add "HKU\%TEMP_HIVE_NAME%\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d 1 /f >nul
                    reg add "HKU\%TEMP_HIVE_NAME%\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d %INACTIVITY_TIMER_SEC% /f >nul
                    reg add "HKU\%TEMP_HIVE_NAME%\Control Panel\Desktop" /v LockScreenAutoLockActive /t REG_SZ /d 1 /f >nul
                    reg add "HKU\%TEMP_HIVE_NAME%\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "%SCREEN_SAVE_EXECUTABLE%" /f >nul
                    reg unload "HKU\%TEMP_HIVE_NAME%" >nul 2>&1
                    echo %DATE% %TIME% - Ended !ProfilePath!
                )
            )
        )
    )
)

:: `endlocal` is useful if the script will continue; can be removed if the scipt ends here
endlocal
