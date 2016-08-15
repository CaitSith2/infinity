
	.area	_HEADER (ABS)
	.org 0x3F00
GBS_Begin:

	.DB 0x47,0x42,0x53,1				; GBS File marker
	.DB ((Song_Table_End-Song_Table_Begin)/2)+30	;Number of Songs
	.DB 1						;Starting Song
	.dw Song_Table_Begin				;Loading Address
	.dw GBS_Init					;Init Address
	.dw 0x4003					;Play Address
	.dw 0xDF80					;Stack Pointer
	.db 0x00, 0x00					;Timer Controls
	.org 0x3F10			;Title String
	.ascii "Infinity GBC"
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.org 0x3F30			;Author String
	.ascii "Eric Hache"
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.org 0x3F50			;Copyright String
	       ;0123456789ABCDEF0123456789ABCDE
	.asciz "1999-2016 Affinix Software, LLC"
	.org 0x3F70


Song_Table_Begin:
.DB   0x0C,2         ; 00 - title
	;.DB   0x01,4         ; 00o - title
.DB   0x01,2         ; 01 - prophecy
.DB   0x0E,0         ; 02 - overworld
.DB   0x01,1         ; 02o - overworld
.DB   0x0F,1         ; 03 - town1
	;.DB   0x01,5         ; 03o - town1
.DB   0x05,0         ; 04 - castle
.DB   0x02,1         ; 04o - castle
.DB   0x0C,0         ; 05 - mountain
.DB   0x01,0         ; 05o - mountain
.DB   0x0B,0         ; 06 - fight1
.DB   0x02,2         ; 06o - fight1
.DB   0x10,1         ; 07 - boss1
.DB   0x02,0         ; 07o - boss1	(Mountain)
.DB   0x11,0         ; 08 - rest
.DB   0x01,3         ; 08o - rest
.DB   0x11,1         ; 09 - game over
.DB   0x02,3         ; 09o - game over
.DB   0x09,0         ; 10 - cave
.DB   0x09,1         ; 11 - creator
.DB   0x0A,0         ; 12 - creator evil
.DB   0x0F,2         ; 13 - town 2
.DB   0x0B,1         ; 14 - kassim
.DB   0x0D,1         ; 15 - forest
.DB   0x10,0         ; 16 - alutha
.DB   0x12,0         ; 16o - alutha
.DB   0x0C,1         ; 17 - mystery
.DB   0x06,0         ; 18 - trouble
.DB   0x11,2         ; 19 - victory
.DB   0x0E,1         ; 20 - sadness
.DB   0x0F,0         ; 21 - sailing
.DB   0x0A,1         ; 22 - icecavern
.DB   0x0D,0         ; 23 - mystic
.DB   0x07,0         ; 24 - great dark
.DB   0x08,0         ; 25 - lastboss
.DB   0x04,0         ; 26 - ending1
.DB   0x03,0         ; 27 - ending2
.DB   0x11,3         ; 28 - nighttime
Song_Table_End:

GBS_Init:
	PUSH BC
	PUSH DE

	CP A, #((Song_Table_End-Song_Table_Begin)/2)	; There are 28 songs in this GBS.  After that, are SFX.
	JR  C, Play_Song	; Coninue to Song playback code, if song select is < 28. (0 based counting.)
	JP  Play_SFX	; Skip to SFX playback.

Play_Song:
	LD DE, #0x2000	;Bank selection is done by writing to Address 0x2000.
	LD HL, #Song_Table_Begin
	ADD A, A	
	ADD A, L
	LD L, A
	LD A, (HL)	;Load desired bank number
	LD (DE), A	;And select that bank.
	INC L		;Next will be the song number within that bank.
	PUSH HL
	
	

    call 0x4000		;Call the sound system initialize routine in selected bank.
	POP HL
	LD A, (HL)	;Now load A with desired song number in the bank
	POP BC
	POP DE
    	jp 0x4006	;And jump to start music in that bank.

Play_SFX:
	sub A, #((Song_Table_End-Song_Table_Begin)/2)	;Since we are here, SFX start from 0, not 28, so, we must
	LD DE, #0x2000	;subtract 28 from the selection.
	PUSH AF
	LD A, #0x01	;Select Bank 1.  (All banks have same SFX.
	ld (DE), A
	call 0x4000	;Initialize sound engine.
	POP AF
	POP BC
	POP DE
	CP A, #44	;SFX 44 is reset_sound_chip, aka silence. Skip it.
	JR C, Skip_Increment
	INC A
Skip_Increment:
	jp  0x400F	;and play selected SFX.

GBS_End:
