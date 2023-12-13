@echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

echo ========== disableVSNetConnections
CALL "%my_dir%\disableVSNetConnections.bat"

echo ========== disableVSTasks
CALL  "%my_dir%\disableVSTasks.bat"

echo ========== disableVSTelemetryAndFeedback
CALL "%my_dir%\disableVSTelemetryAndFeedback.bat"

endlocal
exit /b %errorlevel%
