::
:: renaming PerfWatson2 to disable them
:: at least in vs 2026 (18) PerfWatson2 throws annoying errors because of not found (disabled) services
:: which is circumvented this way
:: 

@echo off
setlocal

for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles%\Microsoft Visual Studio" *PerfWatson2.exe') do (
        
    echo renaming "%%H" to "%%H.disabled"
    move "%%H" "%%H.disabled"
    
)

for /F "tokens=1 delims=" %%H in ('where /r "%ProgramFiles(x86)%\Microsoft Visual Studio" *PerfWatson2.exe') do (
        
    echo renaming "%%H" to "%%H.disabled"
    move "%%H" "%%H.disabled"
    
)

endlocal
exit /b %errorlevel%