:: ==============================================================
:: Blocks Mozilla Firefox browser installation in `Program Files...`
:: allowing it only in local user profiles
:: ==============================================================

:: ======================
:: Pre-requisites
setlocal enabledelayedexpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges...
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
:: Block in Program Files
call :BlockFolder "%ProgramFiles%" "%ProgramFiles%\Mozilla Firefox"

:: Block in 32-bit Program Files folder
if defined ProgramFiles(x86) (
    call :BlockFolder "%ProgramFiles(x86)%" "%ProgramFiles(x86)%\Mozilla Firefox"
)

exit /b 0

:: ======================
:: Helper Function to Safely Block Directory
:BlockFolder
set "ParentDir=%~1"
set "StubPath=%~2"

:: Cancels if the folder or stub-file exists
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
:: Removes inheritance
icacls "%StubPath%" /inheritance:r >nul || exit /b 1

:: Grants Administrators and SYSTEM read access
icacls "%StubPath%" /grant:r %SID_ADMINISTRATORS%:(R) >nul || exit /b 1
icacls "%StubPath%" /grant:r %SID_SYSTEM%:(R) >nul || exit /b 1

:: Denies Everyone delete, write and execute permissions
icacls "%StubPath%" /deny %SID_EVERYONE%:(D,W,X) >nul || exit /b 1

exit /b 0
