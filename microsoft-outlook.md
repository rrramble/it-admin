# Microsoft Outlook useful tips

## Looking for previously opened files

`c:\Users\USER_LOGIN\AppData\Local\Microsoft\Windows\INetCache\Content.Outlook\`

or on the computer

`%localappdata%\Microsoft\Windows\INetCache\Content.Outlook\`

## Autocomplete cache of sent emails

`C:\Users\USER_ACCOUNT\AppData\Local\Microsoft\Outlook\RoamCache`

or on the computer:

`%localappdata%\Microsoft\Outlook\RoamCache`

Then find a file haveing 'autocomplete' word in it. Something like `Stream_Autocomplete_0_5A8EF643845BED5E925BC319EC43075D.dat`

## Clear email autocomplete chache

1. Delete files found in the autocomplete cache

or

2. Run Outlook in command line: `C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE" /cleanautocompletecache`

or

3. In Outlook open menu `File > Options`, switch to tab `Email`, click 'Clear autocomplete cache'` button

