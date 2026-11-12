:: ==============================================================
REM Installs Zabbix Agent v.8+ on Windows 11/10
:: ==============================================================

set "SERVER_TARGET_IP_FOR_FIREWALL=REPLACE_THIS_WITH_YOUR_SERVER_IP-ADDRESS"

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as Administrator!
    timeout /t 15 /nobreak >nul
    exit /b 1
)

:: ======================
:: Define paths and service names
set "SOURCE_DIR_WITH_BACKSLASH=%~dp0"
set "MSI_DISTRO_FILE=%SOURCE_DIR_WITH_BACKSLASH%zabbix_agent2.msi"
set "CONF_FILE=%SOURCE_DIR_WITH_BACKSLASH%custom.conf"
set "INSTALLATION_DIR=C:\Program Files\Zabbix Agent 2\"
set "DATA_DIR=%ALLUSERSPROFILE%\ZabbixAgent2"

:: ======================
echo [1/6] Stopping service if present...
call :CHECK_DISTRO_AND_CONFIG_FILES
if errorlevel 1 (
    echo [ERROR] Failed to find installation files.
    timeout /t 15 /nobreak >nul
    exit /b 1
)

:: ======================
echo [2/6] Stopping service if present...
set "EXISTING_SERVICE=0"

sc query "Zabbix Agent 2" >nul 2>&1

if not errorlevel 1 (
    set "EXISTING_SERVICE=1"
    call :STOP_ZABBIX_SERVICE

    if errorlevel 1 (
        echo [ERROR] Could not stop existing Zabbix Agent 2 service!
        timeout /t 15 /nobreak >nul
        exit /b 1
    )
) else (
    echo No existing Zabbix Agent 2 service detected.
)

:: ======================
echo [3/6] Installing Zabbix Agent 2 silently...
msiexec /i "%MSI_DISTRO_FILE%" /qn /norestart ^
    SKIP=fw ^
    NONMSICONFNAME="%CONF_FILE%" ^
    STARTUPTYPE=delayed ^
    /l*v "%SOURCE_DIR_WITH_BACKSLASH%zabbix_install.log" DONOTSTART=1

set "MSI_RC=!ERRORLEVEL!"

:: Notes:
:: 3010 is a success code requireing restart
:: 1641 is a success code showing that restart initiated
if "!MSI_RC!"=="0" (
    echo Installation successful.
) else if "!MSI_RC!"=="3010" (
    echo [WARNING] Installation successful. Reboot required.
) else if "!MSI_RC!"=="1641" (
    echo [WARNING] Installation successful. Reboot initiated.
) else (
    echo [ERROR] MSI installation failed. Exit code: !MSI_RC!
    echo Check installation log.
    timeout /t 5 /nobreak >nul
    exit /b 1
)

mkdir "%DATA_DIR%\logs" 2>nul
mkdir "%DATA_DIR%\scripts" 2>nul
mkdir "%DATA_DIR%\cache" 2>nul

:: ======================
echo [4/6] Copying configuration files...
call :COPY_CHILD_CONFIG_FILES
if errorlevel 1 (
    echo [ERROR] Failed to deploy additional configurations!
    timeout /t 15 /nobreak >nul
    exit /b 1
)

:: ======================
echo [5/6] Configuring Windows Firewall rule...
netsh advfirewall firewall delete rule ^
    name="Zabbix Agent 2" >nul 2>&1

netsh advfirewall firewall add rule ^
    name="Zabbix Agent 2" ^
    dir=in action=allow protocol=TCP ^
    localport=10050 ^
    remoteip=%SERVER_TARGET_IP_FOR_FIREWALL% >nul

if errorlevel 1 (
    echo.
    echo [WARNING] Failed to create Windows Firewall rule!
    echo Create the rule manually.
    echo.
)

:: ======================
echo [6/6] Starting Zabbix Agent service...
sc start "Zabbix Agent 2" >nul
if errorlevel 1 (
    echo [ERROR] Could not start Zabbix Agent 2.
    timeout /t 15 /nobreak >nul
    exit /b 1
)

echo Installation completed successfully.
echo ==========================================

timeout /t 15 /nobreak >nul
exit /b 0


:: ==============================================================
:: Subroutine: Check installation files
:: ==============================================================

:CHECK_DISTRO_AND_CONFIG_FILES

if not exist "%MSI_DISTRO_FILE%" (
    echo [ERROR] Zabbix MSI package not found!
    timeout /t 5 /nobreak >nul
    exit /b 1
)

if not exist "%CONF_FILE%" (
    echo [ERROR] Zabbix configuration file not found!
    timeout /t 5 /nobreak >nul
    exit /b 1
)

timeout /t 5 /nobreak >nul
exit /b 0


:: ==============================================================
:: Subroutine: Stop Zabbix Agent 2 service
:: ==============================================================

:STOP_ZABBIX_SERVICE

echo Existing Zabbix Agent 2 service detected.
echo Stopping service before upgrade...

sc stop "Zabbix Agent 2" >nul 2>&1

set "WAIT_COUNT=0"

:WAIT_SERVICE_STOP

sc query "Zabbix Agent 2" | findstr /C:"STOPPED" >nul

if not errorlevel 1 (
    echo Service successfully stopped.
    exit /b 0
)

set /a WAIT_COUNT+=1

if !WAIT_COUNT! GEQ 60 (
    echo [ERROR] Service did not stop within 60 seconds!
    exit /b 1
)

timeout /t 1 /nobreak >nul
goto WAIT_SERVICE_STOP


:: ==============================================================
:: Subroutine: Copy child-config files
:: ==============================================================

:COPY_CHILD_CONFIG_FILES

if exist "%INSTALLATION_DIR%\configs" (
    rmdir /S /Q "%INSTALLATION_DIR%\configs"

    if exist "%INSTALLATION_DIR%\configs" (
        echo [ERROR] Cannot remove existing configs directory!
        exit /b 1
    )
)

if exist "%SOURCE_DIR_WITH_BACKSLASH%configs\" (
    mkdir "%INSTALLATION_DIR%\configs"
    if errorlevel 1 (
        echo [ERROR] Cannot create configs directory!
        exit /b 1
    )

    xcopy "%SOURCE_DIR_WITH_BACKSLASH%configs\*.*" ^
        "%INSTALLATION_DIR%\configs\" /E /I /Y >nul
    if errorlevel 1 (
        echo [ERROR] Configuration files copying failed!
        exit /b 1
    )

) else (
    echo No additional configuration files supplied.
)
exit /b 0
