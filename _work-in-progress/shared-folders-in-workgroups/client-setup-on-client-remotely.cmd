:: ============================================================
:: CLIENT SETUP ON CLIENT - REMOTELY
:: Stores credentials to access shared folder
:: ============================================================
set "SERVER_COMPUTER_NAME=pc-share"
set "USER_PC=pc-alice"
set USER_LOCAL_LOGIN=alice
set NETWORK_SHARE_LOGIN=alice_share
set NETWORK_SHARE_PASSWORD=VeryStrongPassword

:: Finds session-id of the needed user on the remote client machine
set "SESSION_ID="

:: Query `qwinsta` on the remote client machine and search for the target user line
for /f "tokens=2,3" %%A in ('qwinsta /server:%USER_PC% 2^>nul ^| findstr /i "%USER_LOCAL_LOGIN%"') do (
    :: Check if the second column is the Session ID (numeric) or if it's the third column
    echo %%A| findstr /r "^[0-9][0-9]*$" >nul
    if not errorlevel 1 (
        set "SESSION_ID=%%A"
    ) else (
        set "SESSION_ID=%%B"
    )
)

:: MANUALLY: check the session/user
psexec \\%USER_PC% -i %SESSION_ID% whoami

:: Stores credentials remotely,
:: targeting a logged-in user session on the client
psexec \\%USER_PC% -i %SESSION_ID% cmdkey /add:%SERVER_COMPUTER_NAME% /user:%SERVER_COMPUTER_NAME%\%NETWORK_SHARE_LOGIN% /pass:%NETWORK_SHARE_PASSWORD%
