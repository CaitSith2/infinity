@echo off
setlocal

if not exist %MAKE%\NUL mkdir %MAKE%

set CUR_DIR=%CD%

cd /d %RESOURCE%\eve
itemconv --defs items.ref
copy /Y itemdefs.h %SOURCE%\eve
call e
call d
call c
call build

cd /d %RESOURCE%\ext
call build

cd /d %CUR_DIR%
call do
