@echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

echo ========== disableVSNetConnections
REM CALL "%my_dir%\disableVSNetConnections.bat" /vsy 2019
CALL "%my_dir%\disableVSNetConnections.bat" /vsy 2022

echo ========== disableVSTasks
REM CALL  "%my_dir%\disableVSTasks.bat" /vsy 2019
CALL  "%my_dir%\disableVSTasks.bat" /vsy 2022

echo ========== disableVSTelemetryAndFeedback
CALL "%my_dir%\disableVSTelemetryAndFeedback.bat"

endlocal
exit /b %errorlevel%
