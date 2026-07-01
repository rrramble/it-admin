:: ============================================================
:: CLIENT'S PERIDICALLY RESET
:: Run it with Auto-Run or Scheduled Tasks
:: ============================================================

set "SERVER_COMPUTER_NAME=pc-share"
set "NETWORK_SHARE_NAME=_share"
set "NETWORK_SHARE_LOGIN=alice_share"


:: Wait for the server to become reachable on the network
:WAIT_FOR_NETWORK
ping -n 1 %SERVER_COMPUTER_NAME% >nul 2>&1
if errorlevel 1 (
    @timeout /t 5 /nobreak >nul
    @goto WAIT_FOR_NETWORK
)

:: Extra short delay to let SMB services initialize
timeout /t 2 /nobreak >nul

:: Removes and establishes SMB session
net use "\\%SERVER_COMPUTER_NAME%\%NETWORK_SHARE_NAME%" /delete /y >nul 2>&1
net use "\\%SERVER_COMPUTER_NAME%\%NETWORK_SHARE_NAME%" /user:%SERVER_COMPUTER_NAME%\%NETWORK_SHARE_LOGIN%
