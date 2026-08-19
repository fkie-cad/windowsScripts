@echo off
setlocal enabledelayedexpansion

set my_name=%~n0
set my_dir="%~dp0"
set "my_dir=%my_dir:~1,-2%"

set /a TYPE_PRIV_PUB=1
set /a TYPE_CRT=2
set /a TYPE_PFX=4
set /a types=%TYPE_PRIV_PUB%

set name=
set def_algorithm=ed25519
set algorithm=%def_algorithm%
set /a def_rsa_bits=4096
set /a bits=%def_rsa_bits%
set /a convertType=0
set /a check=0
set outForm=pem

set subj=
set pfxPass=

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
    
    IF /i "%~1"=="/ec" (
        SET algorithm=ed25519
        goto reParseParams
    )
    IF /i "%~1"=="/ed25519" (
        SET algorithm=ed25519
        goto reParseParams
    )
    IF /i "%~1"=="/rsa" (
        SET algorithm=rsa
        goto reParseParams
    )
    
    IF /i "%~1"=="/crt" (
        SET /a "types=types|TYPE_CRT"
        goto reParseParams
    )
    IF /i "%~1"=="/pfx" (
        SET /a "types=types|TYPE_CRT|TYPE_PFX"
        goto reParseParams
    )
    
    IF /i "%~1"=="/c" (
        SET /a convertType=1
        goto reParseParams
    )
    IF /i "%~1"=="/convert" (
        SET /a convertType=1
        goto reParseParams
    )
    
    IF /i "%~1"=="/d" (
        SET outForm=der
        goto reParseParams
    )
    IF /i "%~1"=="/der" (
        SET outForm=der
        goto reParseParams
    )
    
    IF /i "%~1"=="/p" (
        SET outForm=pem
        goto reParseParams
    )
    IF /i "%~1"=="/pem" (
        SET outForm=pem
        goto reParseParams
    )
    
    IF /i "%~1"=="/b" (
        SET /a bits=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/bit-length" (
        SET /a bits=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/t" (
        SET /a check=1
        goto reParseParams
    )
    IF /i "%~1"=="/check" (
        SET /a check=1
        goto reParseParams
    )
    IF /i "%~1"=="/n" (
        SET name=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/name" (
        SET name=%~2
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/subj" (
        SET "subj=%~2"
        SHIFT
        goto reParseParams
    )
    
    IF /i "%~1"=="/pass" (
        SET pfxPass=%~2
        SHIFT
        goto reParseParams
    )
    IF /i "%~1"=="/nopass" (
        SET pfxPass=PASS_EMPTY
        goto reParseParams
    )
    
    IF /i "%~1"=="/v" (
        SET /a verbose=1
        goto reParseParams
    ) ELSE (
        echo [e] Unknown option : "%~1"
        exit /b 1
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

    set /a s=1
    if /i [%outForm%] EQU [der] set /a s=0
    if /i [%outForm%] EQU [pem] set /a s=0
    if %s% EQU 1 (
        echo [e] Type not supported!
        call
        goto mainend
    )

    set priv_key=%name%.priv.%outForm%
    set pub_key=%name%.pub.%outForm%
    set x509_cert=%name%.cert.%outForm%
    set pfx_cert=%name%.pfx
    
    if ["%subj%"] EQU [""] (
        set "subj=/CN=%name%"
    )

    if %verbose% == 1 (
        echo name: %name%
        echo algorithm: %algorithm%
        echo types: %types%
        echo bits: %bits%
        echo check: %check%
        echo type: %outForm%
        echo convert: %convertType%
        echo priv_key: %priv_key%
        echo pub_key: %pub_key%
        echo x509_cert: %x509_cert%
        echo pfx_cert: %pfx_cert%
        echo subj: %subj%
        echo pfxPass: %pfxPass%
        echo.
    )

    call :create %outForm% %types% "%subj%"
    if !errorlevel! NEQ 0 (
        goto mainend
    )

    if %convertType% == 1 (
        call :convert %outForm% %types%
    )


    if %check% EQU 1 (
        call :check %outForm% "%priv_key%" "%pub_key%" "%x509_cert%" "%pfx_cert%" %types% "%pfxPass%"
    )
    
    :mainend
    echo.
    echo exiting with code : %errorlevel%
    endlocal
    exit /b %errorlevel%



:create
setlocal
    set keytype=%~1
    set /a types=%~2
    set "subj=%~3"

    echo Creating %keytype%
    echo ============
    
    set /a "crt=types&TYPE_CRT"
    set /a "pfx=types&TYPE_PFX"
    
    :: gen private key
    echo generating private key %priv_key%
    if /i [%algorithm%] == [rsa] ( 
        "%openSslExe%" genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:%bits% -outform %keytype% -out "%priv_key%"
    ) else if /i [%algorithm%] == [ed25519] ( 
        "%openSslExe%" genpkey -algorithm ED25519 -outform %keytype% -out "%priv_key%"
    ) else (
        echo [e] Algorithm not supported!
        call
        goto createEnd
    )
    if %errorlevel% NEQ 0 (
        echo [e] Generating private key failed.
        goto createEnd
    )

    :: gen pub key
    echo generating public key %pub_key%
    "%openSslExe%" pkey -in "%priv_key%" -inform %keytype% -pubout -out "%pub_key%" -outform %keytype%
    if %errorlevel% NEQ 0 (
        echo [e] Generating public key failed.
        goto createEnd
    )

    :: create a self-signed certi)cate using that key
    if %crt% GTR 0 (
    
        echo generating self signed certificate %x509_cert%
        "%openSslExe%"  req -new -x509 -key "%priv_key%" -out "%x509_cert%" -outform %keytype% -days 360 -subj "%subj%"
        if !errorlevel! NEQ 0 (
            echo [e] Generating certificate failed.
            goto createEnd
        )
        
    )

    :: convert to pfx
    if %pfx% GTR 0 (
        
        set "passoutArg="
        if ["%pfxPass%"] EQU ["PASS_EMPTY"] (
            set "passoutArg=-passout pass:"
        ) else if ["%pfxPass%"] NEQ [""] (
            set "passoutArg=-passout pass:%pfxPass%"
        )
        
        
        if ["%keytype%"] EQU ["der"] (
            
            echo [i] Building pfx via temp PEM. pkcs12 cannot read DER key in openssl 3.x
            set tmp_pem_priv=%name%.~priv.tmp
            set tmp_pem_crt=%name%.~crt.tmp
            
            call :createTmpCrt "%priv_key%" "%x509_cert%" "!tmp_pem_priv!" "!tmp_pem_crt!" "%pfx_cert%" "!passoutArg!"
            set "pfxErr=!errorlevel!"
            del "!tmp_pem_priv!" "!tmp_pem_crt!" 2>nul 
            if !pfxErr! NEQ 0 ( for %%E in (!pfxErr!) do ( endlocal & exit /b %%E ) )
            
        ) else (
            "%openSslExe%" pkcs12 !passoutArg! -export -inkey "%priv_key%" -in "%x509_cert%" -out "%pfx_cert%"
            if !errorlevel! NEQ 0 (
                echo [e] Converting to pfx failed.
                goto createEnd
            )
        )
    )

    :createEnd
    endlocal
    exit /b %errorlevel%


:createTmpCrt
setlocal
    set "priv_key=%~1"
    set "x509_cert=%~2"
    set "pem_priv=%~3"
    set "pem_crt=%~4"
    set "pfx_cert=%~5"
    set "passoutArg=%~6"

    "%openSslExe%" pkey -in "%priv_key%" -inform DER -outform PEM -out "%pem_priv%"
    if %errorlevel% NEQ 0 ( 
        echo [e] Temp priv conversion failed.
        endlocal
        exit /b %errorlevel%
    )
    
    "%openSslExe%" x509 -in "%x509_cert%" -inform DER -outform PEM -out "%pem_crt%"
    if !errorlevel! NEQ 0 (
        echo [e] Temp cert conversion failed.
        endlocal
        exit /b %errorlevel%
    )
    
    "%openSslExe%" pkcs12 !passoutArg! -export -inkey "%pem_priv%" -in "%pem_crt%" -out "%pfx_cert%"
    if !errorlevel! NEQ 0 (
        echo [e] Converting to pfx failed.
        endlocal
        exit /b %errorlevel%
    )
            
    endlocal
    exit /b %errorlevel%


:convert
setlocal
    set inputType=%~1
    set /a types=%~2
    
    set otherType=
    if [%inputType%] EQU [der] ( set "otherType=pem" )
    if [%inputType%] EQU [pem] ( set "otherType=der" )
    if ["%otherType%"] EQU [""] (
        echo [e] Invalid input type!
        call
        goto convertEnd
    )
    
    set /a "crt=types&TYPE_CRT"
    set /a "pfx=types&TYPE_PFX"
    
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
    "%openSslExe%"  pkey -in "%priv_key%" -inform %inputType% -outform %otherType% -out "%priv_ot%"
    if !errorlevel! NEQ 0 (
        echo [e] Converting private key to %otherType% failed.
        goto convertEnd
    )

    echo converting public key
    "%openSslExe%"  pkey -pubin -in "%pub_key%" -inform %inputType% -pubout -outform %otherType% -out "%pub_ot%"
    if !errorlevel! NEQ 0 (
        echo [e] Converting public key to %otherType% failed.
        goto convertEnd
    )

    :: "%openSslExe%"  rsa -inform %outForm% -in "%priv_key%" -outform %otherType% -out %priv_ot%
    :: "%openSslExe%"  rsa -pubin -inform %outForm% -in "%pub_key%" -outform %otherType% -out %pub_ot%
    if %crt% GTR 0 (
        echo converting certificate
        "%openSslExe%"  x509 -inform %inputType% -in "%x509_cert%" -out "%ot_cert%" -outform %otherType%
        if !errorlevel! NEQ 0 (
            echo [e] Converting certificate to %otherType% failed.
            goto convertEnd
        )
    )
    
    :: convert to pfx
    if %pfx% GTR 0 (
        echo [i] pfx already created in :create step
    )
    
    :convertEnd
    endlocal
    exit /b %errorlevel%


:check
setlocal
    
    set "keytype=%~1"
    set "priv_key=%~2"
    set "pub_key=%~3"
    set "x509_cert=%~4"
    set "pfx_cert=%~5"
    set /a types=%~6
    set "pfxPass=%~7"

    set /a "crt=types&TYPE_CRT"
    set /a "pfx=types&TYPE_PFX"
    
    set "passinArg="
    if ["%pfxPass%"] EQU ["PASS_EMPTY"] (
        set "passinArg=-passin pass:"
    ) else if ["%pfxPass%"] NEQ [""] (
        set "passinArg=-passin pass:%pfxPass%"
    )
        
    echo.
    echo Checking
    echo ========
    echo crt : %crt%
    echo pfx : %pfx%
    
    
    if ["%priv_key%"] NEQ [""] (
        echo.
        echo Checking Private key
        echo --------------------
        "%openSslExe%" pkey -noout -text -in "%priv_key%" -inform %keytype%
        "%openSslExe%" pkey -noout -check -in "%priv_key%" -inform %keytype%
    )
    
    if ["%pub_key%"] NEQ [""] (
        echo.
        echo Checking Public key
        echo -------------------
        "%openSslExe%" pkey -noout -text -pubin -in "%pub_key%" -inform %keytype%
    )
    
    if %crt% GTR 0 (
        echo.
        echo Checking Cert
        echo -------------
        "%openSslExe%" x509 -noout -text -in "%x509_cert%" -inform %keytype%
    )
    
    if %pfx% GTR 0 (
        echo.
        echo Checking PFX
        echo -------------
        "%openSslExe%" pkcs12 !passinArg! -info -noout -in "%pfx_cert%
    )
    
    endlocal
    exit /b %errorlevel%


:usage
    echo Usage: %my_name% /n ^<name^> [/rsa^|/ed25519] [/crt] [/pfx] [/b ^<bits^>] [/subj ^<value^>] [/pass ^<value^>|/nopass] [/d] [/t] [/h]
    
    exit /b %errorlevel%


:help
    call :usage
    echo.
    echo /n : Base name of the files to create.
    echo /rsa : Create rsa key pair.
    echo /ed25519, /ec : Create ed25519 key pair (default).
    echo /b : Bits for RSA. Default: %def_rsa_bits%.
    echo /crt : Create certificate out of the keys.
    echo    /subj : Subject for certificate, e.g. "/CN=bla". Default: /CN=^<name^>.
    echo /pfx : Create pfx out of the priv key and cert.
    echo    /pass : Password for pfx. Suppresses prompt.
    echo    /nopass : No password for pfx. Suppresses prompt.
    echo /d, /der : Create .der formatted files. Default is .pem.
    echo /c : Convert the created files to other type (pem=>der, der=>pem)
    echo /t : Check the created files.
    echo /h : Print this.
    
    endlocal
    exit /b %errorlevel%
