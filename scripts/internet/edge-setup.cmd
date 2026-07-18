:: =========================================================================
:: MICROSOFT EDGE POLICY & SETTINGS CONFIGURATION MASTER SCRIPT
:: Open URL `edge://policy` to check the result
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
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/restoreonstartup

:: Startup URLs
:: 1 = Restore previous open tabs | 4 = Open a list of URLs | 5 = Open New Tab Page (Default)
:: 6 = Open a list of URLs and restore the last session
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f

:: Fallback startup URL list if startup mode is changed to "Open specific pages"
reg add "HKLM\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs" /v "1" /t REG_SZ /d "%HOME_PAGE_URL%" /f

:: New Tab Page URL
:: Options: Forces the New Tab page to load a custom URL instead of the default layout.
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "NewTabPageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f

:: Home Button on Toolbar
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HomepageLocation" /t REG_SZ /d "%HOME_PAGE_URL%" /f
:: 0 = Disabled (Hidden) | 1 = Enabled (Visible, Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ShowHomeButton" /t REG_DWORD /d 0 /f



:: ======================
:: PRIVACY, DATA PROTECTION, AND TRACKING

:: Tracking Prevention Level
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/trackingprevention
:: Options: 0 = Off | 1 = Basic | 2 = Balanced (Default) | 3 = Strict
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "TrackingPrevention" /t REG_DWORD /d 2 /f

:: "Do Not Track" Header Sending
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/configuredonottrack
:: Options: 0 = Disabled (Default) | 1 = Enabled
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f

:: Diagnostic Data Collection (Telemetry)
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/diagnosticdata
:: Options: 0 = Off | 1 = Required Data | 2 = Optional Data (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f


:: ======================
:: CREDENTIALS, COOKIES, AND AUTOFILL

:: Third-Party Cookies
:: Options: 0 = Allow All (Default) | 1 = Block Third-Party | 2 = Block All Cookies
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f


:: ======================
:: SEARCH ENGINE

:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/managedsearchengines
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ManagedSearchEngines" /t REG_SZ /f ^
    /d "[{\"name\":\"Google\",\"keyword\":\"google.com\",\"shortcut\":\"google\",\"url\":\"https://www.google.com/search?q={searchTerms}\",\"is_default\":true}]"

:: Block adding new search engines via UI
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "EditSearchEnginesEnabled" /t REG_DWORD /d 0 /f

reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderEnabled" /t REG_DWORD /d 1 /f


:: ======================
:: SYSTEM, HARDWARE, AND PERFORMANCE

:: Background Processing / Run Apps After Closing
:: Options: 0 = Disabled | 1 = Enabled (Default - Keeps background process alive for speed)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f


:: ======================
:: DOWNLOADS

:: Allowing / Disabling downloads
:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/downloadrestrictions
:: Options: (0) = No special restrictions | 1 = Block malicious downloads and dangerous file types
:: (2) = Block potentially dangerous or unwanted downloads and dangerous file types
:: (3) = Block all downloads, (4) = Block malicious downloads
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DownloadRestrictions" /t REG_DWORD /d 0 /f


:: ======================
:: COPILOT

:: https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/microsoft365copilotchaticonenabled
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "Microsoft365CopilotChatIconEnabled" /t REG_DWORD /d 0 /f

:: Disable Edge sidebar (where Copilot is integrated in newer Edge versions)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t REG_DWORD /d 0 /f
