:: ==============================================================
:: Security
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnabledDelayedExpansion
chcp 65001

@echo Verifying Administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
@echo Blocks remote administrative share exploitation (LocalAccountTokenFilterPolicy)
:: so accesing c$ on other computers is prohibited for power users and local adimistrators except
:: for the standard `administrator` with SID RID 500
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d 0 /f

:: ======================
@echo Sets computer description to the currently logged-in user
set "REG_PATH=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
set "REG_VALUE=DefaultUserName"

:: NOTE: "delims=	" contains a literal TAB character to prevent names with spaces from breaking
for /f "tokens=3 delims=	" %%a in ('reg query "!REG_PATH!" /v !REG_VALUE!') do set TRUE_USER=%%a
if "!TRUE_USER!"=="" set "TRUE_USER=!USERNAME!"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "srvcomment" /t REG_SZ /d "Username=!TRUE_USER!" /f

:: ======================
@echo Enforces local account lockout thresholds
net accounts /lockoutthreshold:5 /lockoutwindow:1 /lockoutduration:1
