@echo off
setlocal enabledelayedexpansion

REM cls

set "letters.free=Z Y X W V U T S R Q P O N M L K J I H G F E D C B A "
for /f "skip=1 tokens=1,2 delims=: " %%a in ('wmic logicaldisk get deviceid^,volumename') do (
   set "letters.used=!letters.used!%%a:%%b, "
   set "letters.free=!letters.free:%%a =!"
)
set letters.used=%letters.used:~0,-6%
set letters.used=%letters.used:,@=, @%
set letters

endlocal
exit /b %errorlevel%