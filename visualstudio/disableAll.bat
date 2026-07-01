@echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"


echo ========== disableVSTelemetryAndFeedback
CALL "%my_dir%\disableVSTelemetryAndFeedback.bat"

echo ========== disable services
CALL  "%my_dir%\disableVSServices.bat"

echo ========== PerfWatson2
CALL  "%my_dir%\disablePerfWatson.bat"

echo ========== hosts
CALL  "%my_dir%\disableHosts.bat"

echo ========== common net connections
CALL  "%my_dir%\disableMsBuildNetConnections.bat"
CALL "%my_dir%\disableVctipNetConnections.bat"

echo ========== vs net connections
CALL "%my_dir%\disableVSNetConnections.bat"
CALL  "%my_dir%\disableVSTasks.bat"


endlocal
exit /b %errorlevel%
