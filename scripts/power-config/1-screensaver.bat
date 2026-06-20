@ECHO Run it as administrator!
@REM ===========================
REM 1. Screensaver timeout (seconds)
reg add "HKCU\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d 1800 /f

@REM ===========================
REM 2. Require password on resume
reg add "HKCU\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d 1 /f
