:: ============================================================
:: CLIENT SETUP ON SERVER LOCALLY
:: ============================================================
:: Notes:
:: 1. The share and the users-group should exist.
:: 2. The share should be given needed: (a) share access, (b) and filesystem access.
:: Examples:
:: - `net share "_share=c:\_share" /GRANT:ShareUsers,FULL`
:: - `icacls "c:\_share" /grant ShareUsers:(OI)(CI)F`

set NETWORK_SHARE_LOGIN=alice_share
set NETWORK_SHARE_PASSWORD=VeryStrongPassword123!
set SERVER_GROUP_FOR_FILE_SHARE=ShareUsers

:: Creates a local account used for network authentication
net user %NETWORK_SHARE_LOGIN% %NETWORK_SHARE_PASSWORD% /add >nul 2>&1

:: Grants user permission via group membership
net localgroup %SERVER_GROUP_FOR_FILE_SHARE% %NETWORK_SHARE_LOGIN% /add >nul 2>&1
