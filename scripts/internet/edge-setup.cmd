:: =========================================================================
:: MICROSOFT EDGE POLICY & SETTINGS CONFIGURATION MASTER SCRIPT
:: =========================================================================
:: Hierarchy Level Summary:
:: 1. HKLM\...\Edge             - Machine-Wide Mandatory (Overriding Priority)
:: 2. HKCU\...\Edge             - Current User Mandatory
:: 3. HKLM\...\Edge\Recommended - Default Template (Pre-sets value, user can change)
:: =========================================================================

:: ======================
@echo Pre-requisites
setlocal EnableDelayedExpansion

:: Restrict PATH variable to secure system binaries to prevent binary hijacking
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\Wbem"

:: Variables
set "HOME_PAGE_URL=about:blank"

chcp 65001

@echo Verifying Administrator privileges
fltmc >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    exit /b 1
)

:: ======================
:: STARTUP, HOME PAGE, AND NEW TAB

:: Startup actions
:: Options: 1 = Restore last session | 4 = Open a list of URLs | 5 = Open New Tab Page (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f

:: Startup URLs (applies only if RestoreOnStartup is set to 4)
reg add "HKLM\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" /v "1" /t REG_SZ /d "%HOME_PAGE_URL%" /f
reg add "HKCU\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" /v "1" /t REG_SZ /d "%HOME_PAGE_URL%" /f

:: Home Page URL Configuration
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HomepageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "HomepageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "HomepageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f

:: New Tab Page URL
:: Options: Forces the New Tab page to load a custom URL instead of the default layout.
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "NewTabPageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "NewTabPageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f

:: Home Button on Toolbar
:: Options: 0 = Disabled (Hidden) | 1 = Enabled (Visible, Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ShowHomeButton" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ShowHomeButton" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "ShowHomeButton" /t REG_DWORD /d 0 /f


:: ======================
:: PRIVACY, DATA PROTECTION, AND TRACKING

:: Tracking Prevention Level
:: Options: 0 = Off | 1 = Basic | 2 = Balanced (Default) | 3 = Strict
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "TrackingPrevention" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "TrackingPrevention" /t REG_DWORD /d 3 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "TrackingPrevention" /t REG_DWORD /d 3 /f

:: "Do Not Track" Header Sending
:: Options: 0 = Disabled (Default) | 1 = Enabled
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f

:: Diagnostic Data Collection (Telemetry)
:: Options: 0 = Off | 1 = Required Data | 2 = Optional Data (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f


:: ======================
:: CREDENTIALS, COOKIES, AND AUTOFILL

:: Third-Party Cookies
:: Options: 0 = Allow All (Default) | 1 = Block Third-Party | 2 = Block All Cookies
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f


:: ======================
:: SEARCH ENGINE AND ADDRESS BAR

:: Search provider usage (Google default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderEnabled" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderName" /t REG_SZ /d "Google" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderSearchURL" /t REG_SZ /d "https://www.google.com/search?q={searchTerms}" /f

:: Only Google and Bing are allowed
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ManagedSearchEngines" /t REG_SZ /d "[{\"name\":\"Google\",\"keyword\":\"google.com\",\"url\":\"https://www.google.com/search?q={searchTerms}\",\"is_default\":true},{\"name\":\"Bing\",\"keyword\":\"bing.com\",\"url\":\"https://www.bing.com/search?q={searchTerms}\",\"is_default\":false}]" /f

:: Block adding new search engines via UI
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "EditSearchEnginesEnabled" /t REG_DWORD /d 0 /f

:: Prevent per-user (HKCU) override
reg delete "HKCU\Software\Policies\Microsoft\Edge" /f >nul 2>&1


:: ======================
:: SYSTEM, HARDWARE, AND PERFORMANCE

:: Background Processing / Run Apps After Closing
:: Options: 0 = Disabled | 1 = Enabled (Default - Keeps background process alive for speed)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f


:: ======================
:: PRINTING AND DOWNLOADS

:: Prompt User for Save Location
:: Options: 0 = Auto-save directly | 1 = Ask user where to save file (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DownloadRestrictions" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DownloadRestrictions" /t REG_DWORD /d 0 /f
