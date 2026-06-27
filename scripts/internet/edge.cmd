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
net session >nul 2>&1
if !errorLevel! neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    endlocal
    exit /b 1
)

:: ======================
:: STARTUP, HOME PAGE, AND NEW TAB
:: ======================

:: Action on Startup
:: Options: 1 = Restore last session | 4 = Open a list of URLs | 5 = Open New Tab Page (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "RestoreOnStartup" /t REG_DWORD /d 1 /f

:: Configure Startup URLs (applies only if RestoreOnStartup is set to 4)
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

:: Show Home Button on Toolbar
:: Options: 0 = Disabled (Hidden) | 1 = Enabled (Visible, Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ShowHomeButton" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ShowHomeButton" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "ShowHomeButton" /t REG_DWORD /d 0 /f


:: ======================
:: PRIVACY, DATA PROTECTION, AND TRACKING
:: ======================

:: Tracking Prevention Level
:: Options: 0 = Off | 1 = Basic | 2 = Balanced (Default) | 3 = Strict
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "TrackingPrevention" /t REG_DWORD /d 3 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "TrackingPrevention" /t REG_DWORD /d 3 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "TrackingPrevention" /t REG_DWORD /d 3 /f

:: Send "Do Not Track" Header
:: Options: 0 = Disabled (Default) | 1 = Enabled
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ConfigureDoNotTrack" /t REG_DWORD /d 1 /f

:: Diagnostic Data Collection (Telemetry)
:: Options: 0 = Off | 1 = Required Data | 2 = Optional Data (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DiagnosticData" /t REG_DWORD /d 0 /f

:: Clear Browsing Data on Exit
:: Options: 0 = Disabled (Default) | 1 = Enabled (Wipes history, cache, cookies on browser close)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ClearBrowsingDataOnExit" /t REG_DWORD /d 0 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ClearBrowsingDataOnExit" /t REG_DWORD /d 0 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "ClearBrowsingDataOnExit" /t REG_DWORD /d 0 /f

:: Allow InPrivate (Incognito) Browsing
:: Options: 0 = Enabled (Default) | 1 = Disabled | 2 = Forced (Always InPrivate)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "InPrivateModeAvailability" /t REG_DWORD /d 0 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "InPrivateModeAvailability" /t REG_DWORD /d 0 /f


:: ======================
:: SECURITY AND SMARTSCREEN
:: ======================

:: Microsoft Defender SmartScreen
:: Options: 0 = Disabled | 1 = Enabled (Default)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "SmartScreenEnabled" /t REG_DWORD /d 1 /f

:: Block Potentially Unwanted Apps (PUA) via SmartScreen
:: Options: 0 = Disabled | 1 = Enabled (Default)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "SmartScreenPuaEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "SmartScreenPuaEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "SmartScreenPuaEnabled" /t REG_DWORD /d 1 /f

:: Force Minimum TLS Version
:: Options: "tls1.2" = TLS 1.2 | "tls1.3" = TLS 1.3
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "SupportedTLSMin" /t REG_SZ /d "tls1.2" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "SupportedTLSMin" /t REG_SZ /d "tls1.2" /f


:: ======================
:: CREDENTIALS, COOKIES, AND AUTOFILL
:: ======================

:: Save Passwords to Password Manager
:: Options: 0 = Disabled | 1 = Enabled (Default)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "PasswordManagerEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "PasswordManagerEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "PasswordManagerEnabled" /t REG_DWORD /d 1 /f

:: Address Autofill
:: Options: 0 = Disabled | 1 = Enabled (Default)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "AutofillAddressEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "AutofillAddressEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "AutofillAddressEnabled" /t REG_DWORD /d 1 /f

:: Credit Card Autofill
:: Options: 0 = Disabled | 1 = Enabled (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "AutofillCreditCardEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "AutofillCreditCardEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "AutofillCreditCardEnabled" /t REG_DWORD /d 0 /f

:: Block Third-Party Cookies
:: Options: 0 = Allow All (Default) | 1 = Block Third-Party | 2 = Block All Cookies
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "BlockThirdPartyCookies" /t REG_DWORD /d 1 /f


:: ======================
:: EXTENSIONS AND DEVELOPER TOOLS
:: ======================

:: Control Developer Tools (F12) Availability
:: Options: 0 = Fully Enabled (Default) | 1 = Disallowed | 2 = Allowed except for extension contexts
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DeveloperToolsAvailability" /t REG_DWORD /d 0 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DeveloperToolsAvailability" /t REG_DWORD /d 0 /f

:: Extensions Blocklist Policy :: TODO: research it
:: Options: 0 = Blocklist Disabled.
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ExtensionInstallBlocklist" /t REG_DWORD /d 0 /f


:: ======================
:: SEARCH ENGINE AND ADDRESS BAR
:: ======================

:: Enable Search Suggestions in Address Bar
:: Options: 0 = Disabled | 1 = Enabled (Default)
:: This setting is already set as default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "SearchSuggestEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "SearchSuggestEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "SearchSuggestEnabled" /t REG_DWORD /d 1 /f

:: ======================
:: Enforce only Google and Bing as search providers

:: 1. Force Google as the Default Active Engine
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderName" /t REG_SZ /d "Google" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderSearchURL" /t REG_SZ /d "https://google.com/?q={searchTerms}" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderKeyword" /t REG_SZ /d "google.com" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderEnabled" /t REG_DWORD /d 1 /f

:: 2. Current User Duplication for Default Engine
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderName" /t REG_SZ /d "Google" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderSearchURL" /t REG_SZ /d "https://google.com/?q={searchTerms}" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DefaultSearchProviderEnabled" /t REG_DWORD /d 1 /f

:: 3. Recommended Template (Allows user to switch between Google and Bing manually)
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "DefaultSearchProviderName" /t REG_SZ /d "Google" /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "DefaultSearchProviderSearchURL" /t REG_SZ /d "https://google.com/?q={searchTerms}" /f

:: 4. Whitelist Only Google and Bing (Deletes/Blocks everything else)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "ManagedSearchEngines" /t REG_SZ /d "[{\"name\":\"Google\",\"keyword\":\"google.com\",\"url\":\"https://google.com/?q={searchTerms}\",\"is_default\":true},{\"name\":\"Bing\",\"keyword\":\"bing.com\",\"url\":\"https://bing.com/search?q={searchTerms}\",\"is_default\":false}]" /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "ManagedSearchEngines" /t REG_SZ /d "[{\"name\":\"Google\",\"keyword\":\"google.com\",\"url\":\"https://google.com/?q={searchTerms}\",\"is_default\":true},{\"name\":\"Bing\",\"keyword\":\"bing.com\",\"url\":\"https://bing.com/search?q={searchTerms}\",\"is_default\":false}]" /f


:: ======================
:: SYSTEM, HARDWARE, AND PERFORMANCE
:: ======================
:: Hardware Acceleration Mode
:: Options: 0 = Disabled | 1 = Enabled (Default - Leverages local GPU)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HardwareAccelerationModeEnabled" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "HardwareAccelerationModeEnabled" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "HardwareAccelerationModeEnabled" /t REG_DWORD /d 1 /f

:: Background Processing / Run Apps After Closing
:: Options: 0 = Disabled | 1 = Enabled (Default - Keeps background process alive for speed)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f

:: Sleeping Tabs Management:: Options: 0 = Disabled | 1 = Enabled (Default - Freezes inactive tabs to minimize RAM usage)
:: It is already On by default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "SleepingTabsEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "SleepingTabsEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v "SleepingTabsEnabled" /t REG_DWORD /d 1 /f


:: ======================
:: PRINTING AND DOWNLOADS
:: ======================

:: Prompt User for Save Location
:: Options: 0 = Auto-save directly | 1 = Ask user where to save file (Default)
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "DownloadRestrictions" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Edge" /v "DownloadRestrictions" /t REG_DWORD /d 0 /f

:: Print Capability Access
:: Options: 0 = Printing function blocked entirely | 1 = Allowed (Default)
:: It is already On by default
:: reg add "HKLM\Software\Policies\Microsoft\Edge" /v "PrintingEnabled" /t REG_DWORD /d 1 /f
:: reg add "HKCU\Software\Policies\Microsoft\Edge" /v "PrintingEnabled" /t REG_DWORD /d 1 /f
