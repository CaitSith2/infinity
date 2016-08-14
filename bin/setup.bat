:: set up affinix development environment
::
:: set up j:\project\project_name as the build root
@echo off

if "%1"=="" set DRIVELETTER=j
if "%1"=="" goto setup
set DRIVELETTER=%1

:setup
if %PROJECT%.==infinity. goto :EOF
set PROJECT=infinity

set PROJECT_ROOT=%~dp0\..

set BUILDER=%DRIVELETTER%:\sdk\gbz80-gb\2-1-5\bin
set BIN=%DRIVELETTER%:\bin
set MAKE=%DRIVELETTER%:\build
set RELEASE=%DRIVELETTER%:\release
set SOURCE=%DRIVELETTER%:\source
set RESOURCE=%DRIVELETTER%:\resource
set PATH=%PATH%;%BIN%;%BUILDER%

if not exist %BIN% subst %DRIVELETTER%: %PROJECT_ROOT%
cd /d %DRIVELETTER%:\
