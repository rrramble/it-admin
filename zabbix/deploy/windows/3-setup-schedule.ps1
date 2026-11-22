# File: deploy-server/windows/3.ps1
# Sets up the Windows task schedule to run WSL on Windows startup

$TASK_NAME = "Custom WSL Start"
$WSL_EXE = Join-Path $env:SystemRoot "System32\wsl.exe"
$WindowsLogin = "$env:USERDOMAIN\$env:USERNAME"

# Escape values for XML.
$XML_ACCOUNT = [System.Security.SecurityElement]::Escape($WindowsLogin)
$XML_WSL_EXE = [System.Security.SecurityElement]::Escape($WSL_EXE)

# Defines the task in XML format
$XML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
        <Description>Run and keep the WSL running.</Description>
    </RegistrationInfo>
    <Triggers>
        <BootTrigger>
            <Enabled>true</Enabled>
            <Delay>PT1M</Delay>
        </BootTrigger>
    </Triggers>
    <Principals>
        <Principal id="Author">
            <UserId>$XML_ACCOUNT</UserId>
            <LogonType>Password</LogonType>
            <RunLevel>LeastPrivilege</RunLevel>
        </Principal>
    </Principals>
    <Settings>
        <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    </Settings>
    <Actions Context="Author">
        <Exec>
            <Command>$XML_WSL_EXE</Command>
            <Arguments>-d Ubuntu --exec /usr/bin/sleep infinity</Arguments>
        </Exec>
    </Actions>
</Task>
"@


try {
    $XML_TEMP_PATH = [System.IO.Path]::GetTempFileName()

    [System.IO.File]::WriteAllText(
        $XML_TEMP_PATH,
        $XML,
        [System.Text.Encoding]::Unicode
    )

    # Register the task and request the account password.
    & schtasks.exe /Create `
        /TN "$TASK_NAME" `
        /XML "$XML_TEMP_PATH" `
        /RP '*' `
        /RU $WindowsLogin `
        /F

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create scheduled task. Exit code: $LASTEXITCODE"
    }
}
finally {
    Remove-Item $XML_TEMP_PATH -Force -ErrorAction SilentlyContinue
}
