@echo off
setlocal

if not exist %MAKE%\NUL mkdir %MAKE%

set CUR_DIR=%CD%
cd /d %MAKE%

lcc -c gbs_songs.o ..\gbs\gbs_songs.s
lcc -c gbs.o ..\gbs\gbs.c
lcc -o gbs_songs.gb gbs_songs.o gbs.o
inspage gbs_songs.gb ..\resource\audio1o.bin 2
inspage gbs_songs.gb ..\resource\audio2o.bin 1
inspage gbs_songs.gb ..\resource\audio1.bin 3
inspage gbs_songs.gb ..\resource\audio2.bin 4
inspage gbs_songs.gb ..\resource\audio3.bin 5
inspage gbs_songs.gb ..\resource\audio4.bin 6
inspage gbs_songs.gb ..\resource\audio5.bin 7
inspage gbs_songs.gb ..\resource\audio6.bin 8
inspage gbs_songs.gb ..\resource\audio7.bin 9
inspage gbs_songs.gb ..\resource\audio8.bin 10
inspage gbs_songs.gb ..\resource\audio9.bin 11
inspage gbs_songs.gb ..\resource\audio10.bin 12
inspage gbs_songs.gb ..\resource\audio11.bin 13
inspage gbs_songs.gb ..\resource\audio12.bin 14
inspage gbs_songs.gb ..\resource\audio13.bin 15
inspage gbs_songs.gb ..\resource\audio14.bin 16
inspage gbs_songs.gb ..\resource\audio15.bin 17
inspage gbs_songs.gb ..\gbs\audio14.bin 18
fixgbs gbs_songs.gb infinity-gbc.gbs
copy /Y ..\gbs\infinity-gbc.m3u .
cd /d %CUR_DIR%
