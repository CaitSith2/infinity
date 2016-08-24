@echo off
setlocal

if not exist %MAKE%\NUL mkdir %MAKE%

set CUR_DIR=%CD%
cd /d %MAKE%

lcc -c ..\gbs\gbs_songs.s
lcc -c ..\gbs\gbs.c
lcc -Wl-yo32 -o infinity-gbc_gbs.gb gbs_songs.o gbs.o
inspage infinity-gbc_gbs.gb ..\resource\audio1o.bin 2
inspage infinity-gbc_gbs.gb ..\resource\audio2o.bin 1
inspage infinity-gbc_gbs.gb ..\resource\audio1.bin 3
inspage infinity-gbc_gbs.gb ..\resource\audio2.bin 4
inspage infinity-gbc_gbs.gb ..\resource\audio3.bin 5
inspage infinity-gbc_gbs.gb ..\resource\audio4.bin 6
inspage infinity-gbc_gbs.gb ..\resource\audio5.bin 7
inspage infinity-gbc_gbs.gb ..\resource\audio6.bin 8
inspage infinity-gbc_gbs.gb ..\resource\audio7.bin 9
inspage infinity-gbc_gbs.gb ..\resource\audio8.bin 10
inspage infinity-gbc_gbs.gb ..\resource\audio9.bin 11
inspage infinity-gbc_gbs.gb ..\resource\audio10.bin 12
inspage infinity-gbc_gbs.gb ..\resource\audio11.bin 13
inspage infinity-gbc_gbs.gb ..\resource\audio12.bin 14
inspage infinity-gbc_gbs.gb ..\resource\audio13.bin 15
inspage infinity-gbc_gbs.gb ..\resource\audio14.bin 16
inspage infinity-gbc_gbs.gb ..\resource\audio15.bin 17
rem Alutha (old) was removed by request of Eric Hache. Don't ask me where to get it. (Hint, it did once exist on a much older gbs release that tssf had me do.)
rem inspage infinity-gbc_gbs.gb ..\gbs\audio14.bin 18
fixgb infinity-gbc_gbs.gb "INFINITY GBS"
fixgbs infinity-gbc_gbs.gb infinity-gbc.gbs
copy /Y ..\gbs\infinity-gbc.m3u .
cd /d %CUR_DIR%
