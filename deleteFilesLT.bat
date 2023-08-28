echo off
setlocal

set my_name=%~n0%~x0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a verbose=0

set /a CHECK_FLAG=1

set dir=
set type=*
set /a min=0
SET /a recursive=0
SET /a flags=0

GOTO :ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help

    IF /i "%~1"=="/c" (
        SET /a "flags=%flags%|CHECK_FLAG"
        goto reParseParams
    )
    IF /i "%~1"=="/d" (
        SET "dir=%~2"
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/m" (
        SET /a min=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/r" (
        SET /a recursive=1
        goto reParseParams
    )
    IF /i "%~1"=="/t" (
        SET "type=%~2"
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    ) else (
        echo Skipping unknown option "%~1"
        goto reParseParams
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main
    if %min% EQU 0 goto usage
    if ["%dir%"] == [] goto usage
    if ["%dir%"] == [""] goto usage

    call :isDir "%dir%"
    if [%errorlevel%] == [0] (
        echo %in% is not a directory!
        goto usage
    )

    set /a "check=%flags%&CHECK_FLAG"
    
    if %verbose% EQU 1 (
        echo dir=%dir%
        echo min=%min%
        echo type = %type%
        echo recursive = %recursive%
        echo check = %check%
        echo.
    )
    
    if %check% NEQ 0 echo [i] Running in check mode
    
    if %recursive% == 0 (
        if %verbose% EQU 1 echo iterating %dir%
        
        for %%p in ("%dir%\*.%type%") do (
            if %verbose% EQU 1 echo %%p  %%~zp
            If %%~zp LSS %min% (
                if %verbose% EQU 1 echo   deleting %%p
                if %check% NEQ 0 (
                    echo del "%%p"
                ) else (
                    del "%%p"
                )
            )
        )
    ) else (
        for /r "%dir%" %%p in (*.%type%) do (
            if %verbose% EQU 1 echo %%p  %%~zp
            If %%~zp LSS %min% (
                if %verbose% EQU 1 echo   deleting %%p
                if %check% NEQ 0 (
                    echo del "%%p"
                ) else (
                    del "%%p"
                )
            )
        )
    )

    exit /B 0


:usage
    echo Usage: %prog_name% /d ^<targetPath^> /m ^<minSize^> /t ^<fileType^> [/r] [/c] [/v] [/h]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /d Target directory.
    echo /m Minimum file size. All files below the minimum file size will be deleted.
    echo /t File type filter. I.e. "log"
    echo /r Iterate dir recursively.
    echo /c Checking mode. Don't delete files, just print, what would be deleted, if this flag would not have been set.
    echo /v Verbose mode.
    echo /h Print this.
    exit /B 0

:isDir
    setlocal
    set "v=%~1"
    if ["%v:~0,-1%\"] == ["%v%"] (
        if exist "%v%" exit /b 1
    ) else (
        if exist "%v%\" exit /b 1
    )
    exit /b 0
    endlocal