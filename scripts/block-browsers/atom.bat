:: ======================
:: Blocks `Atom` browser creation
:: ======================

:: ======================
:: 1. In `AppData`
cd /d "%LocalAppData%"

:: Deletes existing folder
rd /s /q "atom" 2>nul

:: Creates an empty-stub instead of the folder
echo "This is a file-stub: do not delete!" > "atom"

:: Cancels rights inheritance and block other activities
icacls "atom" /inheritance:r
icacls "atom" /deny *S-1-1-0:(F)

:: ======================
:: 2. In `Program Files` 64-bit
rd /s /q "%ProgramFiles%\atom" 2>nul
echo "This is a file-stub: do not delete!" > "%ProgramFiles%\atom"
icacls "%ProgramFiles%\atom" /inheritance:r
icacls "%ProgramFiles%\atom" /deny *S-1-1-0:(F)

:: ======================
:: 3. In `Program Files` 32-bit
rd /s /q "%ProgramFiles(x86)%\atom" 2>nul
echo "This is a file-stub: do not delete!" > "%ProgramFiles(x86)%\atom"
icacls "%ProgramFiles(x86)%\atom" /inheritance:r
icacls "%ProgramFiles(x86)%\atom" /deny *S-1-1-0:(F)
