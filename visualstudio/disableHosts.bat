::
:: Adds entries to hosts.
:: Just one direction (add active entries).
::
:: Could do some
:: powershell -Command "(Get-Content ...) -replace ..."
:: logic to disable/comment entries too
::

@echo off
setlocal

set "hosts=%SystemRoot%\System32\drivers\etc\hosts"
    
:main
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )
    
    echo Adding host entries to "%hosts%"
    echo -------------------------------

    REM ################################
    REM copilot
    call :addEntry "copilot-proxy.githubusercontent.com"
    call :addEntry "api.github.com"
    call :addEntry "githubcopilot.com"
    call :addEntry "default.exp-tas.com"
    call :addEntry "github.copilot.githubassets.com"

    REM ################################
    call :addEntry "settings-win.data.microsoft.com"

    REM ################################
    REM #   Visual Studio Community telemetry from:- https://gist.github.com/zeffy/f0fe4be391a2f1a4246d0482bbf57c1a
    call :addEntry "vortex.data.microsoft.com"
    call :addEntry "dc.services.visualstudio.com"
    call :addEntry "visualstudio-devdiv-c2s.msedge.net"
    call :addEntry "az667904.vo.msecnd.net"
    call :addEntry "az700632.vo.msecnd.net"
    call :addEntry "sxpdata.microsoft.com"
    call :addEntry "sxp.microsoft.com"

    REM ################################
    REM # More telemetry from:- https://www.reddit.com/r/pihole/comments/a12zwl/does_anyone_have_an_extensive_list_of_microsoft/
    call :addEntry "geo.settings-win.data.microsoft.com.akadns.net"
    call :addEntry "db5-eap.settings-win.data.microsoft.com.akadns.net"
    call :addEntry "db5.settings-win.data.microsoft.com.akadns.net"
    call :addEntry "db5.vortex.data.microsoft.com.akadns.net"
    call :addEntry "asimov-win.settings.data.microsoft.com.akadns.net"
    call :addEntry "v10-win.vortex.data.microsft.com.akadns.net"
    call :addEntry "v10.vortex-win.data.microsft.com"
    call :addEntry "geo.vortex.data.microsoft.com.akadns.net"
    call :addEntry "us.vortex-win.data.microsft.com"
    call :addEntry "eu.vortex-win.data.microsft.com"
    call :addEntry "vortex-win-sandbox.data.microsoft.com"
    call :addEntry "alpha.telemetry.microsft.com"
    call :addEntry "oca.telemetry.microsft.com"
    call :addEntry "weus2watcab02.blob.core.windows.net"
    call :addEntry "weus2watcab01.blob.core.windows.net"
    call :addEntry "eaus2watcab02.blob.core.windows.net"
    call :addEntry "eaus2watcab01.blob.core.windows.net"
    call :addEntry "ceuswatcab02.blob.core.windows.net"
    call :addEntry "ceuswatcab01.blob.core.windows.net"

    echo -------------------------------
    
    endlocal
    exit /b 0


:addEntry
setlocal
    set "host=%~1"
    
    findstr /i /c:"%host%" "%hosts%" >nul 2>&1
    
    if %errorlevel% NEQ 0 (
        echo Adding %host%
        echo 0.0.0.0       %host%>> "%hosts%"
    ) else (
        echo Already present: %host%
    )
    
    endlocal
    exit /b 0