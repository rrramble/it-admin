:: Adds a shared host (server) to Trusted Sites.
:: This allows (UNC) links to be opened in Microsoft Outlook/browsers
:: 1 = Local Intranet
:: 2 = Trusted Sites
:: 3 = Internet
:: 4 = Restricted Sites

set "HOST_NAME=..."

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\%HOST_NAME%" /v "*" /t REG_DWORD /d 2 /f
