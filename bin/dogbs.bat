@echo off
setlocal

if not exist %MAKE%\NUL mkdir %MAKE%

set CUR_DIR=%CD%
cd /d %MAKE%
cd ..\GBS
tasm -b -69 -fff -Q gbsplay.asm
cd /d %MAKE%


copy /Y /b ..\gbs\gbsplay.obj + ..\resource\audio2o.bin + ..\resource\audio1o.bin + ..\resource\audio1.bin + ..\resource\audio2.bin + ..\resource\audio3.bin + ..\resource\audio4.bin + ..\resource\audio5.bin + ..\resource\audio6.bin + ..\resource\audio7.bin + ..\resource\audio8.bin + ..\resource\audio9.bin + ..\resource\audio10.bin + ..\resource\audio11.bin + ..\resource\audio12.bin + ..\resource\audio13.bin + ..\resource\audio14.bin + ..\resource\audio15.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin + ..\gbs\blank.bin infinity-gbc_gbs.gb
fixgb infinity-gbc_gbs.gb "INFINITY GBS   "
fixgbs infinity-gbc_gbs.gb infinity-gbc.gbs
copy /Y ..\gbs\infinity-gbc.m3u .
copy /Y ..\gbs\readme.txt .
cd ..\GBS
del gbsplay.obj
cd /d %CUR_DIR%
