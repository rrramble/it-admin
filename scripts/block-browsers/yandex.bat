:: ==============================================================
:: Blocks `Yandex` browser creation
:: by preventing of creation of the known program folder
:: ==============================================================

:: ======================
:: 1. In `AppData`
cd /d "%LocalAppData%"

if not exist "Yandex" mkdir "Yandex"
:: Deletes existing folder
rd /s /q "Yandex\YandexBrowser" 2>nul

:: Creates an empty file-stub instead of folder
@echo "This is a file-stub: do not delete!" > "Yandex\YandexBrowser"

:: Cancels rights inheritance and block other activities
icacls "Yandex\YandexBrowser" /inheritance:r
icacls "Yandex\YandexBrowser" /deny *S-1-1-0:(F)

:: ======================
:: 2. In `Program Files` 64-bit
if not exist "%ProgramFiles%\Yandex" mkdir "%ProgramFiles%\Yandex"
rd /s /q "%ProgramFiles%\Yandex\YandexBrowser" 2>nul
echo "This is a file-stub: do not delete!" > "%ProgramFiles%\Yandex\YandexBrowser"
icacls "%ProgramFiles%\Yandex\YandexBrowser" /inheritance:r
icacls "%ProgramFiles%\Yandex\YandexBrowser" /deny *S-1-1-0:(F)

:: ======================
:: 3. In `Program Files` 32-bit
if not exist "%ProgramFiles(x86)%\Yandex" mkdir "%ProgramFiles(x86)%\Yandex"
rd /s /q "%ProgramFiles(x86)%\Yandex\YandexBrowser" 2>nul
echo "This is a file-stub: do not delete!" > "%ProgramFiles(x86)%\Yandex\YandexBrowser"
icacls "%ProgramFiles(x86)%\Yandex\YandexBrowser" /inheritance:r
icacls "%ProgramFiles(x86)%\Yandex\YandexBrowser" /deny *S-1-1-0:(F)
