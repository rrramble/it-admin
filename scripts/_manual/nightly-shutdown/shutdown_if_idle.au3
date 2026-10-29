; Shuts down a PC if time is passed
; usage:
; shut_down_if_idle.exe <NUMBER_OF_SECONDS>
;
; Written in AutoIt Script Language https://www.autoitscript.com/site/autoit/downloads/
; Use `Aut2Exe` to make it executable under Microsoft Windows

#NoTrayIcon
#RequireAdmin

Opt("MustDeclareVars", 1)

Global Const $EXIT_SHUTDOWN = 0
Global Const $EXIT_ACTIVE = 1
Global Const $EXIT_ERROR = 2
Global Const $EXIT_SHUTDOWN_FAILED = 3

Global Const $DEFAULT_SHUTDOWN_WATCHDOG_DELAY = 60
Global Const $MAX_IDLE_SECONDS = 604800 ; 7 days
Global Const $MIN_IDLE_SECONDS = 60 ; 1 minute

Global Const $CONSOLE_VISIBILITY = @SW_SHOW ; `@SW_HIDE` and `@SW_SHOW` are available

_Main()
Exit

;;; Functions ;;;

Func _Main()
    If $CmdLine[0] = 0 Then
        _PrintHelp()
        Exit $EXIT_ERROR
    EndIf

    If $CmdLine[0] > 1 Then
        _PrintHelp()
        Exit $EXIT_ERROR
    EndIf

    Local $iIdleThreshold = _ParseIdleThreshold($CmdLine[1])

    If @error Then
        _PrintHelp()
        Exit $EXIT_ERROR
    EndIf

    Local $iIdleSeconds = _GetIdleSeconds()

    If @error Then
        ConsoleWrite("ERROR: Unable to determine idle time." & @CRLF)
        Exit $EXIT_ERROR
    EndIf

    ConsoleWrite("Idle time: " & $iIdleSeconds & " seconds." & @CRLF)

    If $iIdleSeconds < $iIdleThreshold Then
        ConsoleWrite("User is active. Shutdown skipped." & @CRLF)
        Exit $EXIT_ACTIVE
    EndIf

    If Not _InitiateShutdown($DEFAULT_SHUTDOWN_WATCHDOG_DELAY) Then
        ConsoleWrite("ERROR: Shutdown command failed." & @CRLF)
        Exit $EXIT_SHUTDOWN_FAILED
    EndIf

    ConsoleWrite("Shutdown initiated." & @CRLF)
    Exit $EXIT_SHUTDOWN
EndFunc


Func _ParseIdleThreshold($sArgument)
    If Not StringRegExp($sArgument, "^[0-9]{1,7}$") Then
        Return SetError(1, 0, 0)
    EndIf

    Local $iSeconds = Number($sArgument)

    If $iSeconds < $MIN_IDLE_SECONDS Or $iSeconds > $MAX_IDLE_SECONDS Then
        Return SetError(1, 0, 0)
    EndIf

    Return $iSeconds
EndFunc


Func _GetIdleSeconds()
    Local $tInputInfo = DllStructCreate("uint cbSize;dword dwTime")
    DllStructSetData($tInputInfo, "cbSize", DllStructGetSize($tInputInfo))

    Local $aInput = DllCall( _
        "user32.dll", _
        "bool", "GetLastInputInfo", _
        "struct*", $tInputInfo _
    )

    If @error Or Not IsArray($aInput) Then Return SetError(1, 0, 0)
    If Not $aInput[0] Then Return SetError(1, 0, 0)

    Local $aTick = DllCall("kernel32.dll", "dword", "GetTickCount")

    If @error Or Not IsArray($aTick) Then Return SetError(1, 0, 0)

    Local $iNow = $aTick[0]
    Local $iLastInput = DllStructGetData($tInputInfo, "dwTime")

    ; Unsigned 32-bit arithmetic handles tick counter rollover.
    Local $iElapsedMs = Mod($iNow - $iLastInput + 4294967296, 4294967296)

    Return Int($iElapsedMs / 1000)
EndFunc


Func _InitiateShutdown($iDelaySeconds = -1)
    If Not IsNumber($iDelaySeconds) Then Return False
    If $iDelaySeconds < 0 Or $iDelaySeconds > 315360000 Then Return False

    Local $sCommand = 'shutdown.exe /s /t ' & $iDelaySeconds

    Local $iResult = RunWait($sCommand, "", $CONSOLE_VISIBILITY)
    If @error Then Return False

    Return ($iResult = 0)
EndFunc


Func _PrintHelp()
    ConsoleWrite( _
        "Shutdown_if_idle.exe - Shutdown after keyboard/mouse inactivity." & @CRLF & _
        @CRLF & _
        "Usage:" & @CRLF & _
        "  Shutdown_if_idle.exe <idle_seconds>" & @CRLF & _
        @CRLF & _
        "Examples:" & @CRLF & _
        "  Shutdown_if_idle.exe 3600" & @CRLF & _
        @CRLF & _
        "Behavior:" & @CRLF & _
        "  Checks idle time immediately; does not wait for idle." & @CRLF & _
        "  If the threshold is met, starts a " & $DEFAULT_SHUTDOWN_WATCHDOG_DELAY & _
        "-second shutdown countdown." & @CRLF & _
        "  If the user is active (the idle condition is not met), exits without shutting down." & @CRLF & _
        @CRLF & _
        "Exit codes:" & @CRLF & _
        "  0 = Shutdown initiated" & @CRLF & _
        "  1 = User is active" & @CRLF & _
        "  2 = Invalid arguments or API failure" & @CRLF & _
        "  3 = Shutdown command failed" & @CRLF _
    )
EndFunc
