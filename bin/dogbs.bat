@echo off
set CUR_DIR=%CD%
cd /d %DRIVELETTER%:\gbs

lcc -c gbs_songs.o gbs_songs.s
lcc -c gbs.o gbs.c
lcc -o gbs_songs.gbs gbs_songs.o gbs.o
inspage gbs_songs.gbs ..\resource\audio1o.bin 1
inspage gbs_songs.gbs ..\resource\audio2o.bin 2
inspage gbs_songs.gbs ..\resource\audio1.bin 3
inspage gbs_songs.gbs ..\resource\audio2.bin 4
inspage gbs_songs.gbs ..\resource\audio3.bin 5
inspage gbs_songs.gbs ..\resource\audio4.bin 6
inspage gbs_songs.gbs ..\resource\audio5.bin 7
inspage gbs_songs.gbs ..\resource\audio6.bin 8
inspage gbs_songs.gbs ..\resource\audio7.bin 9
inspage gbs_songs.gbs ..\resource\audio8.bin 10
inspage gbs_songs.gbs ..\resource\audio9.bin 11
inspage gbs_songs.gbs ..\resource\audio10.bin 12
inspage gbs_songs.gbs ..\resource\audio11.bin 13
inspage gbs_songs.gbs ..\resource\audio12.bin 14
inspage gbs_songs.gbs ..\resource\audio13.bin 15
inspage gbs_songs.gbs ..\resource\audio14.bin 16
inspage gbs_songs.gbs ..\resource\audio15.bin 17
inspage gbs_songs.gbs audio14.bin 18
fixgbs gbs_songs.gbs infinity.gbs
cd /d %CUR_DIR%
