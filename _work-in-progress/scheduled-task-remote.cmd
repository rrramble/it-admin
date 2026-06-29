@REM Updates the scheduled task

@REM ------
@REM /SC - recurring, /MO - number of periods, /ST , /F - force (rewrite)
@REM ------
for %i in (PC1 PC2 PC3) do (
    schtasks /Create /S %i /U Administrator /P password ^
    /TN "MyTask" ^
    /TR "C:\Scripts\runme.bat" ^
    /SC HOURLY /MO 3 /F
    /ST 00:00 ^
    /F
)