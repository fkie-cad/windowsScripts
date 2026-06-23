@echo off
setlocal 

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"


echo ========== disableVSTelemetryAndFeedback
CALL "%my_dir%\disableVSTelemetryAndFeedback.bat"

echo ========== disable services
CALL  "%my_dir%\disableVSServices.bat" /vsy %vsy%

echo ========== PerfWatson2
CALL  "%my_dir%\disablePerfWatson.bat"


set /a vsy=2022

echo ====== vs 2022
echo ========== disableVSNetConnections
CALL "%my_dir%\disableBuildToolsNetConnections.bat" /vsy %vsy%
CALL "%my_dir%\disableVSNetConnections.bat" /vsy %vsy%

echo ========== disableVSTasks
CALL  "%my_dir%\disableVSTasks.bat" /vsy %vsy%



set /a vsy=18

echo ====== vs 2026

echo ========== disableVSNetConnections
CALL "%my_dir%\disableBuildToolsNetConnections.bat" /vsy %vsy%
CALL "%my_dir%\disableVSNetConnections.bat" /vsy %vsy%

echo ========== disableVSTasks
CALL  "%my_dir%\disableVSTasks.bat" /vsy %vsy%


endlocal
exit /b %errorlevel%
