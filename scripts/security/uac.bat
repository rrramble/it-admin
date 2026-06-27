:: ==============================================================
:: UAC (User Access Control)
::
:: UAC Levels in GUI:
:: 4 (highest security) - ConsentPromptBehaviorAdmin=2, PromptOnSecureDesktop=1, EnableLUA=1
:: 3 - ConsentPromptBehaviorAdmin=5, PromptOnSecureDesktop=1, EnableLUA=1
:: 2 - ConsentPromptBehaviorAdmin=5, PromptOnSecureDesktop=0, EnableLUA=1
:: 1 (lowest secrurity) - ConsentPromptBehaviorAdmin=0, PromptOnSecureDesktop=0, EnableLUA=1
::
:: A special case:
:: ConsentPromptBehaviorAdmin=3, PromptOnSecureDesktop=0 : Forces asking for a username/password but Remote user can enter it.
:: ==============================================================

:: ======================
:: Pre-requisites
@setlocal EnableDelayedExpansion
chcp 65001

@echo Verifying Administrator privileges
@net session >nul 2>&1
@if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator!
    @exit /b 1
)

:: ======================
:: Set UAC behavior for administrators to prompt for consent without dimming the desktop
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f

:: Set the secure desktop prompt feature to disabled to prevent screen dimming
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f

:: Set Limited User Account behavior to enabled to activate the UAC subsystem
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
