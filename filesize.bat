@echo off
setlocal enabledelayedexpansion

if [%1]==[] goto end

echo bytes ^| filename
echo ----------------------
    
:ParseParams

    if [%1]==[] goto end
    echo %~znx1
    REM call :tohex %~z1
    SHIFT

GOTO :ParseParams


:end
exit /b 0


:tohex
setlocal
    set /a dec=%~1
    set "hex="
    set "map=0123456789ABCDEF"
    for /L %%N in (1,1,8) do (
        set /a "d=dec&15,dec>>=4"
        for /f %%D in ("!d!") do (
            set "hex=!map:~%%D,1!!hex!"
        )
    )
    echo hex : !hex!
    endlocal
    exit /b %errorlevel%
    
