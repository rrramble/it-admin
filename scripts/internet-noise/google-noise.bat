:: ==============================================================
:: Google Chrome Enterprise Privacy Baseline
:: ==============================================================

:: ======================
@echo Pre-requisites
setlocal EnabledDelayedExpansion
chcp 65001 >nul

@echo Verifying Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
@echo 1. Deactivating Google Chrome browser ad tracking and metrics reporting
set "CHROME_POLICY=HKLM\SOFTWARE\Policies\Google\Chrome"
reg add "!CHROME_POLICY!" /v "PrivacySandboxPromptEnabled" /t REG_DWORD /d 0 /f
reg add "!CHROME_POLICY!" /v "PrivacySandboxAdTopicsEnabled" /t REG_DWORD /d 0 /f
reg add "!CHROME_POLICY!" /v "PrivacySandboxSiteEnabledAdsEnabled" /t REG_DWORD /d 0 /f
reg add "!CHROME_POLICY!" /v "PrivacySandboxAdMeasurementEnabled" /t REG_DWORD /d 0 /f
reg add "!CHROME_POLICY!" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f

:: ======================
@echo 2. Deactivating Google Update service crash reporting and usage telemetry
set "UPDATE_POLICY=HKLM\SOFTWARE\Policies\Google\Update"
reg add "!UPDATE_POLICY!" /v "SendUsageStats" /t REG_DWORD /d 0 /f
