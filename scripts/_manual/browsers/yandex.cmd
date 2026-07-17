:: ==============================================================
:: Blocks `Yandex` browser installation
:: by preventing the creation of the possible program folders
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if errorLevel 1 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: Constants
set "SID_ADMINISTRATORS=*S-1-5-32-544"
set "SID_SYSTEM=*S-1-5-18"
set "SID_EVERYONE=*S-1-1-0"

:: ======================
:: Starts the main procedure

:: Block in AppData folder
call :BlockYandex "%LocalAppData%\Yandex"

:: Block in Program Files folder
call :BlockYandex "%ProgramFiles%\Yandex"

:: Block in "Program Files (x86)" folder
if defined ProgramFiles(x86) (
    call :BlockYandex "%ProgramFiles(x86)%\Yandex"
)

exit /b 0


:: ======================
:: Helper Function to Safely Block Directory
:BlockYandex
set "ParentDir=%~1"
set "StubPath=%~1\YandexBrowser"

:: Cancels the procedure if the folder or stub-file exists
if exist "%StubPath%" (
    @echo Folder or file "%StubPath%" exists, cancelling the procedure.
    exit /b 1
)

:: Ensures parent directory exists
if not exist "%ParentDir%" (
    mkdir "%ParentDir%" || (
        @echo Failed to create "%ParentDir%"
        exit /b 1
    )
)

:: Creates the file-stub
echo This is a file-stub: do not delete!> "%StubPath%"
if not exist "%StubPath%" (
    @echo Failed to create "%StubPath%"
    exit /b 1
)

:: Secure the file-stub:
:: Remove inheritance
icacls "%StubPath%" /inheritance:r >nul || exit /b 1

:: Grant Administrators and SYSTEM read access
icacls "%StubPath%" /grant:r %SID_ADMINISTRATORS%:(R) >nul || exit /b 1
icacls "%StubPath%" /grant:r %SID_SYSTEM%:(R) >nul || exit /b 1

:: Deny Everyone write and execute permissions
icacls "%StubPath%" /deny %SID_EVERYONE%:(D,W,X) >nul || exit /b 1
exit /b 0
