::
:: Adds entries to hosts.
:: Just one direction (add active entries).
::
:: Commented lines are not distinguished
:: Could do some
:: powershell -Command "(Get-Content ...) -replace ..."
:: logic to disable/comment entries too
::
:: https://docs.github.com/en/copilot/reference/copilot-allowlist-reference
:: https://learn.microsoft.com/en-us/visualstudio/ide/visual-studio-experience-improvement-program?view=visualstudio
:: https://github.com/StevenBlack/hosts
:: https://github.com/hagezi/dns-blocklists
::
::
::
::

@echo off
setlocal

set "hosts=%SystemRoot%\System32\drivers\etc\hosts"

REM real wireshark capture of vs2022, vs2026
REM all other disabling scripts already run
REM to be rerun and extended with less disabling soon 
set wsc_names=(^
    settings.visualstudio.microsoft.com^
    go.microsoft.com^
    aka.ms^
    telemetry.visualstudio.microsoft.com^
    targetednotifications-tm.trafficmanager.net^
    aka.ms^
)

REM suspected copilot names
set copilot_names=(^
    copilot-proxy.githubusercontent.com^
    api.github.com^
    githubcopilot.com^
    default.exp-tas.com^
    github.copilot.githubassets.com^
)

REM Visual Studio Community telemetry from:- https://gist.github.com/zeffy/f0fe4be391a2f1a4246d0482bbf57c1a
set zeffy_names=(^
    vortex.data.microsoft.com^
    dc.services.visualstudio.com^
    visualstudio-devdiv-c2s.msedge.net^
    az667904.vo.msecnd.net^
    az700632.vo.msecnd.net^
    sxpdata.microsoft.com^
    sxp.microsoft.com^
)

REM More telemetry from:- https://www.reddit.com/r/pihole/comments/a12zwl/does_anyone_have_an_extensive_list_of_microsoft/
REM maybe move to other script
set pihole_names=(^
    settings-win.data.microsoft.com^
    geo.settings-win.data.microsoft.com.akadns.net^
    db5-eap.settings-win.data.microsoft.com.akadns.net^
    db5.settings-win.data.microsoft.com.akadns.net^
    db5.vortex.data.microsoft.com.akadns.net^
    asimov-win.settings.data.microsoft.com.akadns.net^
    v10-win.vortex.data.microsft.com.akadns.net^
    v10.vortex-win.data.microsft.com^
    geo.vortex.data.microsoft.com.akadns.net^
    us.vortex-win.data.microsft.com^
    eu.vortex-win.data.microsft.com^
    vortex-win-sandbox.data.microsoft.com^
    alpha.telemetry.microsft.com^
    oca.telemetry.microsft.com^
    weus2watcab02.blob.core.windows.net^
    weus2watcab01.blob.core.windows.net^
    eaus2watcab02.blob.core.windows.net^
    eaus2watcab01.blob.core.windows.net^
    ceuswatcab02.blob.core.windows.net^
    ceuswatcab01.blob.core.windows.net^
)

:main
    :: Admin check
    fltmc >nul 2>&1 || (
        echo [e] Administrator privileges required.
        call
        goto mainend
    )
    
    echo Adding host entries to "%hosts%"
    echo -------------------------------

    

    for /d %%n in %wsc_names% do (
        call :addEntry "%%n"
    )

    for /d %%n in %copilot_names% do (
        call :addEntry "%%n"
    )

    for /d %%n in %zeffy_names% do (
        call :addEntry "%%n"
    )

    for /d %%n in %pihole_names% do (
        call :addEntry "%%n"
    )

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