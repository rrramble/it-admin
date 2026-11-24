SET "APP_PATH=C:\Program Files\_BgInfo\BgInfo64.exe"
SET "CONFIG_PATH=C:\Program Files\_BgInfo\setup.bgi"

schtasks.exe /CREATE /F /SC minute /MO 5 /TN "Custom BgInfo" ^
    /TR "\"%APP_PATH%\" \"%CONFIG_PATH%\" /TIMER:0 /SILENT /NOLICPROMPT"
