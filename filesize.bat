@echo off

:ParseParams

    if [%1]==[] goto end
    echo %~zn1
    SHIFT

GOTO :ParseParams

:end
exit /b 0