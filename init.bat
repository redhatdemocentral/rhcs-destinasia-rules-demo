@ECHO OFF
setlocal enableextensions enabledelayedexpansion

set PROJECT_HOME=%~dp0
set DEMO=APAC Destinasia Travel Rules Demo
set AUTHORS=Andrew Block, Eric D. Schabell, Woh Shon Phoon
set PROJECT=git@github.com:redhatdemocentral/rhcs-destinasia-rules-demo.git
set SRC_DIR=%PROJECT_HOME%installs
set OPENSHIFT_USER=openshift-dev
set OPENSHIFT_PWD=devel
set HOST_IP=10.1.2.2
set BRMS=jboss-brms-6.4.0.GA-deployable-eap7.x.zip
set EAP=jboss-eap-7.0.0-installer.jar

REM wipe screen.
cls

echo.
echo ###################################################################
echo ##                                                               ##   
echo ##  Setting up the %DEMO%                 ##
echo ##                                                               ##
echo ##                                                               ##   
echo ##  ####  ####  #   #  ####        #### #      ###  #   # ####   ##
echo ##  #   # #   # ## ## #       #   #     #     #   # #   # #   #  ##
echo ##  ####  ####  # # #  ###   ###  #     #     #   # #   # #   #  ##
echo ##  #   # # #   #   #     #   #   #     #     #   # #   # #   #  ##
echo ##  ####  #  #  #   # ####         #### #####  ###   ###  ####   ##
echo ##                                                               ##   
echo ##  brought to you by,                                           ##   
echo ##             %AUTHORS%                    ##
echo ##                                                               ##
echo ##  %PROJECT%  ##
echo ##                                                               ##   
echo ###################################################################
echo.

REM Validate OpenShift 
set argTotal=0

for %%i in (%*) do set /A argTotal+=1

if %argTotal% EQU 1 (

    call :validateIP %1 valid_ip

	if !valid_ip! EQU 0 (
	    echo OpenShift host given is a valid IP...
	    set HOST_IP=%1
		echo.
		echo Proceeding with OpenShift host: !HOST_IP!...
	) else (
		echo Please provide a valid IP that points to an OpenShift installation...
		echo.
        GOTO :printDocs
	)

)

if %argTotal% GTR 1 (
    GOTO :printDocs
)


REM make some checks first before proceeding.	
call where oc >nul 2>&1
if  %ERRORLEVEL% NEQ 0 (
	echo OpenShift command line tooling is required but not installed yet... download here:
	echo https://access.redhat.com/downloads/content/290
	GOTO :EOF
)

if exist "%SRC_DIR%\%EAP%" (
        echo Product EAP sources are present...
        echo.
) else (
        echo Need to download %EAP% package from https://developers.redhat.com/products/eap/download
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

if exist "%SRC_DIR%\%BRMS%" (
        echo Product BPM Suite sources are present...
        echo.
) else (
        echo Need to download %BRMS% package from https://developers.redhat.com/products/bpmsuite/download
        echo and place it in the %SRC_DIR% directory to proceed...
        echo.
        GOTO :EOF
)

echo OpenShift commandline tooling is installed...
echo.
echo Logging in to OpenShift as %OPENSHIFT_USER%...
echo.
call oc login %HOST_IP%:8443 --password="%OPENSHIFT_PWD%" --username="%OPENSHIFT_USER%"

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc login' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating a new project...
echo.
call oc new-project rhcs-destinasia-travel

echo.
echo Setting up a new build...
echo.
call oc new-build "jbossdemocentral/developer" --name=destinasia-rules-demo --binary=true

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc new-build' command!
	echo.
	GOTO :EOF
)

REM need to wait a bit for new build to finish with developer image.
timeout 10 /nobreak

echo.
echo Importing developer image...
echo.
call oc import-image developer

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc import-image' command!
	echo.
	GOTO :EOF
)

echo.
echo Starting a build, this takes some time to upload all of the product sources for build...
echo.
call oc start-build destinasia-rules-demo --from-dir=. --follow=true  --wait=true

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc start-build' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating a new application...
echo.
call oc new-app destinasia-rules-demo

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc new-app' command!
	echo.
	GOTO :EOF
)

echo.
echo Creating an externally facing route by exposing a service...
echo.
call oc expose service destinasia-rules-demo --hostname=destinasia-rules-demo.%HOST_IP%.xip.io

if not "%ERRORLEVEL%" == "0" (
  echo.
	echo Error occurred during 'oc expose service' command!
	echo.
	GOTO :EOF
)

echo.
echo ====================================================================
echo =                                                                  =
echo =  Login to JBoss BRMS to start developing rules projects:         =
echo =                                                                  =
echo =  http://destinasia-rules-demo.%HOST_IP%.xip.io/business-central =
echo =                                                                  =
echo =  [ u:erics / p:jbossbrms1! ]                                     =
echo =                                                                  =
echo ====================================================================
echo.

GOTO :EOF
      

:validateIP ipAddress [returnVariable]

    setlocal 

    set "_return=1"

    echo %~1^| findstr /b /e /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >nul

    if not errorlevel 1 for /f "tokens=1-4 delims=." %%a in ("%~1") do (
        if %%a gtr 0 if %%a lss 255 if %%b leq 255 if %%c leq 255 if %%d gtr 0 if %%d leq 254 set "_return=0"
    )

:endValidateIP

    endlocal & ( if not "%~2"=="" set "%~2=%_return%" ) & exit /b %_return%
	
:printDocs
  echo This project can be installed on any OpenShift platform. It's possible to
  echo install it on any available installation by pointing this installer to an
  echo OpenShift IP address:
  echo.
  echo   $ ./init.sh IP
  echo.
  echo If using Red Hat OCP, IP should look like: 192.168.99.100
  echo.
