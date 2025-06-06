@echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a vsy=2022

echo ========== disableVSNetConnections
CALL "%my_dir%\disableBuildToolsNetConnections.bat" /vsy %vsy%
CALL "%my_dir%\disableVSNetConnections.bat" /vsy %vsy%

echo ========== disableVSTasks
CALL  "%my_dir%\disableVSTasks.bat" /vsy %vsy%

echo ========== disableVSTelemetryAndFeedback
CALL "%my_dir%\disableVSTelemetryAndFeedback.bat"

endlocal
exit /b %errorlevel%
