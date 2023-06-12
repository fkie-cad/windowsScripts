@echo off
setlocal enabledelayedexpansion

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set name=
set "pos_algorithms=RSA^|ED25519"
set algorithm=ED25519
set bits=4096
set /a convertType=0
set outForm=pem

set /a help=0
set /a verbose=0


set "openSslExe=openssl.exe"
"%openSslExe%" /? >nul 2>&1 
if %errorlevel% EQU 9009 (
    set "openSslExe=%ProgramFiles%\Git\usr\bin\openssl.exe"
)
"%openSslExe%" /? >nul 2>&1 
if %errorlevel% EQU 3 (
    echo [e] No openSsl.exe found, set a correct path.
    goto mainend
)

:: default
if [%1]==[] goto main

GOTO ParseParams

:ParseParams

    if [%1]==[/?] goto help
    if /i [%1]==[/h] goto help
    if /i [%1]==[/help] goto help
    
    IF /i "%~1"=="/a" (
        SET algorithm=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/b" (
        SET bits=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/c" (
        SET /a convertType=1
        goto reParseParams
    )
    IF /i "%~1"=="/n" (
        SET name=%~2
        SHIFT
        goto reParseParams
    )
    REM IF /i "%~1"=="/t" (
        REM SET outForm=%~2
        REM SHIFT
        REM goto reParseParams
    REM )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo Unknown option : "%~1"
    )
    
    :reParseParams
        SHIFT
        if [%1]==[] goto main

GOTO :ParseParams


:main

    if [%name%] EQU [] (
        echo [e] No name given!
        call
        goto mainend
    )

    set priv_key=%name%.priv.pem
    set pub_key=%name%.pub.pem
    set pem_cert=%name%.cert.pem
    set pfx_cert=%name%.pfx

    if %verbose% == 1 (
        echo name: %name%
        echo algorithm: %algorithm%
        echo bits: %bits%
        echo type: %outForm%
        echo convert: %convertType%
        echo priv_key: %priv_key%
        echo pub_key: %pub_key%
        echo pem_cert: %pem_cert%
        echo pfx_cert: %pfx_cert%
        echo.
    )

    set /a s=1
    if /i [%outForm%] EQU [der] set /a s=0
    if /i [%outForm%] EQU [pem] set /a s=0
    if s EQU 1 (
        echo [e] Type not supported!
        call
        goto mainend
    )

    call :createPem
    if !errorlevel! NEQ 0 (
        goto mainend
    )

    if %convertType% == 1 (
        call :convert %outForm%
    )

:mainend
    echo.
    echo exiting with code : %errorlevel%
    endlocal
    exit /b %errorlevel%



:createPem
setlocal
    echo Creating pem
    echo ============
    
    :: gen private key
    echo generating private key %priv_key%
    if /i [%algorithm%] == [rsa] ( 
        "%openSslExe%" genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:%bits% -outform %outForm% -out %priv_key%
    ) else (
    if /i [%algorithm%] == [ed25519] ( 
        "%openSslExe%" genpkey -algorithm ED25519 -outform %outForm% -out %priv_key%
    ) else (
        echo [e] Algorithm not supported!
        call
        goto createPemEnd
    ))
    if !errorlevel! NEQ 0 (
        echo [e] Generating private key failed.
        goto createPemEnd
    )

    :: gen pub key
    echo generating public key %pub_key%
    "%openSslExe%" pkey -in %priv_key% -pubout -out %pub_key%
    if !errorlevel! NEQ 0 (
        echo [e] Generating public key failed.
        goto createPemEnd
    )


    :: create a self-signed certi)cate using that key
    echo generating self signed certificate %pem_cert%
    "%openSslExe%"  req -new -x509 -key %priv_key% -out %pem_cert% -days 360
    if !errorlevel! NEQ 0 (
        echo [e] Generating certificate failed.
        goto createPemEnd
    )

    :: convert pem to pfx
    echo converting pem to pfx %pfx_cert%
    "%openSslExe%"  pkcs12 -export -inkey %priv_key% -in %pem_cert% -out %pfx_cert%
    if !errorlevel! NEQ 0 (
        echo [e] Converting to pfx failed.
        goto createPemEnd
    )

:createPemEnd
endlocal
    exit /b %errorlevel%



:convert
setlocal
    set inputType=%1
    set otherType=
    if [%inputType%] EQU [der] ( set "otherType=pem" )
    if [%inputType%] EQU [pem] ( set "otherType=der" )
    if [%otherType%] EQU [] (
        echo [e] Invalid input type!
        call
        goto convertEnd
    )
    
    echo.
    echo Converting %inputType% to %otherType%
    echo =====================
    
    set priv_ot=%name%.priv.%otherType%
    set pub_ot=%name%.pub.%otherType%
    set ot_cert=%name%.cert.%otherType%
    
    if %verbose% == 1 (
        echo priv_key: %priv_ot%
        echo pub_key: %pub_ot%
        echo cert: %ot_cert%
        echo.
    )
    
    echo converting private key
    "%openSslExe%"  pkey -in %priv_key% -outform %otherType% -out %priv_ot%
    if !errorlevel! NEQ 0 (
        echo [e] Converting private key to %otherType% failed.
        goto convertEnd
    )

    echo converting public key
    "%openSslExe%"  pkey -in %priv_key% -pubout -outform %otherType% -out %pub_ot%
    if !errorlevel! NEQ 0 (
        echo [e] Converting public key to %otherType% failed.
        goto convertEnd
    )

    :: "%openSslExe%"  rsa -inform %outForm% -in %priv_key% -outform %otherType% -out %priv_ot%
    :: "%openSslExe%"  rsa -pubin -inform %outForm% -in %pub_key% -outform %otherType% -out %pub_ot%
    echo converting certificate
    "%openSslExe%"  x509 -outform %otherType% -in %pem_cert% -out %ot_cert%
    if !errorlevel! NEQ 0 (
        echo [e] Converting certificate to %otherType% failed.
        goto convertEnd
    )
    
:convertEnd
endlocal
    exit /b %errorlevel%

:usage
    echo Usage: %my_name% /n ^<name^> [/a=^<algorithm^>] [/b=^<bits^>] [/c] [/h]
    
    exit /b %errorlevel%


:help
    call :usage
    echo.
    echo -n Base name of the files.
    echo -a Algorithm: %pos_algorithms%. Default: ED25519.
    echo -b Bits for RSA. Default: 4096.
    echo -c Additionally convert to .der format.
    echo -h Print this.
    
    endlocal
    exit /b %errorlevel%
