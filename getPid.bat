@echo off
setlocal

set prog_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

if ["%~1"] EQU [""] (
    echo [e] No name given!
    goto printUsage
)

tasklist /fi "imagename eq %~1*"

exit /B %errorlevel%

:printUsage
    echo Usage: %prog_name% ^<name^>
    exit /B 0