echo off
setlocal 

set vdisk=""
set size=10
set type=fixed
set format=ntfs
set label="the label"
set vletter=V
set verbose=0

set prog_name=%~n0%~x0
set user_dir="%~dp0"
set dp_file="%tmp%\createvhd.txt"


if [%1]==[] goto usage

GOTO :ParseParams

:ParseParams

    REM IF "%~1"=="" GOTO Main
    if [%1]==[/?] goto help
    if [%1]==[/h] goto help
    if [%1]==[/help] goto help

    IF "%~1"=="/o" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/of" (
        SET vdisk=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/s" (
        SET size=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/size" (
        SET size=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/t" (
        SET type=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/type" (
        SET type=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/f" (
        SET format=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/filesystem" (
        SET format=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/n" (
        SET label=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/label" (
        SET label=%2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/l" (
        SET vletter=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/volume" (
        SET vletter=%~2
        SHIFT
        goto reParseParams
    )
    IF "%~1"=="/v" (
        SET verbose=1
        goto reParseParams
    )
    IF "%~1"=="/h" (
        goto help
    )
    
    :reParseParams
    SHIFT
    if [%1]==[] goto main

GOTO :ParseParams


:main

    if [%vdisk%]==[""] goto usage

    if [%verbose%]==[1] (
        echo vdisk=%vdisk%
        echo size=%size%
        echo type=%type%
        echo format=%format%
        echo label=%label%
        echo vletter=%vletter%
        echo dp_file=%dp_file%
        echo user_dir=%user_dir%
        echo prog_name=%prog_name%
    )
    
    :checkPermissions
        net session >nul 2>&1
        if %errorlevel% NEQ 0 (
            echo [e] Admin privileges required!
            call
            goto mainend
        )

    call :create
    call :clean
    
    :mainend
    endlocal
    exit /B %errorlevel%


:create
    echo Create vdisk file=%vdisk% type=%type% maximum=%size% > %dp_file%
    echo Attach vdisk >> %dp_file%
    echo Create Partition primary >> %dp_file%
    echo Format fs=%format% label=%label% quick >> %dp_file%
    echo assign letter=%vletter% >> %dp_file%
    echo Detach vdisk >> %dp_file%
    echo Exit >> %dp_file%
    REM echo the script:
    REM type %dp_file%
    
    diskpart /s %dp_file%
    
    exit /B %errorlevel%

:clean
    del %dp_file%
    exit /B %errorlevel%
    
    
    
:usage
    echo Usage: %prog_name% /o ^<path^> [/s ^<size^>] [/t ^<type^>] [/f ^<filesystem^>] [/n ^<label^>] [/l ^<volume^>]
    exit /B 0

:help
    call :usage
    echo.
    echo Options:
    echo /o Path to the disk.vhd
    echo /s (Maximum) size of the vhd in MB. Defaults to 10.
    echo /t Tpye of the vhd. Static size (fixed) or dynamic size (expandable). Defaults to "fixed".
    echo /f Format of the vhd: ntfs^|fat^|fat32]. Defaults to ntfs.
    echo /n A string label for the vhd.
    echo /l The letter of the volume of the (mounted) vhd.
    exit /B 0
