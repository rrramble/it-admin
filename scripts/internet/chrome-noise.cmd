:: ==============================================================
:: Google Chrome Enterprise Privacy Baseline
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
@echo 1. Deactivates ad tracking and metrics reporting
set "CHROME_POLICY=HKLM\SOFTWARE\Policies\Google\Chrome"
reg add "%CHROME_POLICY%" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f
reg add "%CHROME_POLICY%" /v "EnableDoNotTrack" /t REG_DWORD /d 1 /f
reg add "%CHROME_POLICY%" /v "NetworkPredictionOptions" /t REG_DWORD /d 2 /f
reg add "%CHROME_POLICY%" /v "MetricsReportingEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "PrivacySandboxAdMeasurementEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "PrivacySandboxAdTopicsEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "PrivacySandboxPromptEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "PrivacySandboxSiteEnabledAdsEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "SearchSuggestEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "UrlKeyedAnonymizedDataCollectionEnabled" /t REG_DWORD /d 0 /f
reg add "%CHROME_POLICY%" /v "SafeBrowsingEnabled" /t REG_DWORD /d 1 /f

:: ======================
@echo 2. Deactivates Update service crash reporting and usage telemetry
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v "SendUsageStats" /t REG_DWORD /d 0 /f
