
; GBS PLAYER 1.04u
; An emulator/hardware GBS file player
; By Scott Worley <ripsaw8080@hotmail.com>
; Edit by ugetab
; Heavily modified by CaitSith2 for the Infinity GBC soundtrack
;
; Note about interrupt coding:
;  The GBS' TAC should have bits 2 and 6 enabled (0x44)
;  You should have an RST table at the start(00-3F from game, or custom code if unused)
;  With the RST table in place, add 0x10 more bytes after the RST table.
;  The 1st 8 new bytes are for vblank's code, or a jump
;  The last 8 new bytes are for timer interrupt code, or a jump
;  Make sure to keep your play routine compatible with not using this setup,
;   because not all players will support it, being that it's unofficial
;
; Jan-09-2008:
; Added some experimental code for $40(vblank) and $50(timer) interrupts.
; (It shouldn't be enabled by default in this ASM file, just easy to edit afterwards)
; Extra NOP space still available due to an optimization I found.
;
; Compiles correctly with TASM 3.0.1 (TASM69.ZIP)

; This allows you to load VBlank+Timer GBSs using just TASM.
; To enable Timer+Vblank mode, uncomment the #DEFINE
; To disable it, and enable non-Timer+VBlank GBSs, comment it out
; #DEFINE  TimeVBlank

#IFDEF   TimeVBlank
JMPRETI .equ    $C3 ; Jump ; Jumps to the address used for VBlank/Timer
VBlankV .equ    $05 ; Timer+VBlank written to FFFF
TimerV  .equ    $05 ; Timer+VBlank written to FFFF
#ELSE
JMPRETI .equ    $D9 ; RETI ; do nothing, "wakes up" CPU after HALT
VBlankV .equ    $01 ; Default. VBlank only
TimerV  .equ    $04 ; Default. Timer only
#ENDIF

; Origin for $150-$400 code. Will need to hexedit the code to the right address,
; and overwrite the data at that address in the resulting .GB file.
; This is done automatically in GBS2GB.
Origin  .equ    $0150


;enable either timer or v-blank interrupt

;load    .equ    $3f70           ; set to load address of GBS file

; header fields relative to load address

;header  .equ    load-$70
;count   .equ    load-$6c
;first   .equ    load-$6b
;init    .equ    load-$68
;play    .equ    load-$66
;stack   .equ    load-$64
;TMA     .equ    load-$62
;TAC     .equ    load-$61
;title   .equ    load-$60
;author  .equ    load-$40
;copyr   .equ    load-$20

; RST vector redirects - display table data here to save space

        .org    $00
        jp      load+$00        ; RST 00
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$08        ; RST 08
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$10        ; RST 10
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$18        ; RST 18
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$20        ; RST 20
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$28        ; RST 28
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$30        ; RST 30
        .dw		$0000
        .dw		$0000
        .db		$00

        jp      load+$38        ; RST 38
        .dw		$0000
        .dw		$0000
        .db		$00

; v-blank interrupt handler

        .db JMPRETI ;reti  ; do nothing, "wakes up" CPU after HALT
        .dw     load+$40

        ; ugetab: JMPRETI defined at the start of the file

        ;nop                     ; these 2 bytes can be used for a jump, optionally
        ;nop                     ; I intend it to follow the RST table around. Use TAC


        .db     $00              ; MUST be a zero to keep next .dw in line
        .dw     $0000            ; MUST be zeros to end display table data
        .dw     $0000            ; Unavailable for moving
        

; subroutine to wait for v-blank

vbwait: ldh     a,($44)
        cp      $90             ; loop until scan line is barely into VBI
        jr      nz,vbwait
        ret
        .db     $00

; timer interrupt handler

        .db JMPRETI ;reti  ; do nothing, "wakes up" CPU after HALT
        .dw     load+$48
        nop
        nop

        ; ugetab: JMPRETI defined at the start of the file

        ;nop                     ; these 2 bytes can be used for a jump
        ;nop                     ; I intend it to follow the RST table around. Use TAC

; subroutine to display a 16-byte character string

text:   ;call    vbwait
tloop:  ld      a,(de)
        and     $7f             ; return on zero or bad char
        ret     z
        cp      $20
        ret     c
        cp      $5b
        jr      c,clow
        sub     $20             ; convert lower case to upper
clow:   ldi     (hl),a
        inc     de
        dec     c
        jr      nz,tloop
        ret

; subroutine to display a byte value as numeric characters

decb:   ;ld      b,a
        ;call    vbwait
        ;ld      a,b
        ;call    div10           ; get 1's digit
        call    div10           ; get 10's digit
        add     a,$30           ; add offset to tile #
        ld      (hl),a          ; write 100's digit
        ret

div10:  ld      c,0             ; divide by 10
d1:     ld      b,a
        sub     10
        jr      c,d2
        inc     c
        jr      d1
d2:     ld      a,b
        add     a,$30           ; add offset to tile #
        ldd     (hl),a          ; write it
        ld      a,c
        ret

; subroutine to initialize video hardware

setup:  call    vbwait
        ld      a,$11           ; disable video display
        ldh     ($40),a
        xor     a
        ldh     ($42),a         ; X offset = 0
        ldh     ($43),a         ; Y offset = 0
        ld      a,$63           ; palette map for 3D effect on font
        ldh     ($47),a
        ldh     a,($80)         ; check hardware type for CGB
        cp      $11
        call    z,cgb           ; go do the CGB stuff
        ld      de,font         ; tile data (font table)
        ld      hl,$8200        ; tile memory
        ld      b,$3b           ; characters to move
char1:  ld      c,$07           ; bytes per character
char2:  ld      a,(de)
        ldi     (hl),a
        srl     a               ; creates the 3D effect on font
        ldi     (hl),a
        inc     de
        dec     c
        jr      nz,char2
        xor     a               ; last scan row is always $00
        ldi     (hl),a
        ldi     (hl),a
        dec     b
        jr      nz,char1

        ld      hl,$9800        ; clear video buffer memory
        ld      bc,$0400
clear:  ld      a,$20           ; space character
        ldi     (hl),a
        dec     bc
        ld      a,b
        or      c
        jr      nz,clear

        ld      a,$91           ; enable video display
        ldh     ($40),a

        ld      a,$0a           ; RAM enable
        ld      ($0000),a

        ret

; subroutine to read the state of buttons and joypad

input:  ld      a,$20
        ld      c,$03
        call joysub
        ;ldh     ($00),a
        ;ldh     a,($00)
        ;ldh     a,($00)
        ;ldh     a,($00)
	;cpl
        ;and     $0f (0B NOPs)
	swap	a
        ld      b,a
        ld      a,$10
        ld      c,$06
        call joysub
        ;ldh     ($00),a
        ;ldh     a,($00)
        ;ldh     a,($00)
        ;ldh     a,($00)
        ;ldh     a,($00)
        ;ldh     a,($00)
        ;ldh     a,($00)
	;cpl
        ;and     $0f (11 NOPs)
        or      b
        swap    a
        ret

;0x1C nops - 0x11 = 0xB nops to add
;        0E06:
;        ld      c,$06

; subroutine to reduce space used for controller input grabbing
; ugetab: I think this will work because, according to GBCPUMan.pdf,
;         the extra reads are there just to waste cycles.

joysub: ldh     ($00),a
jloop:  ldh     a,($00)
        dec c
        jr nz,jloop
	cpl
        and     $0f
        ret
; E000 F000 0D 20FB 2F E60F C9 (0x11 bytes used)

; Some spare NOPs to redistribute through the prog as needed

        nop

colors: .dw     $0000           ; black
        .dw     $7fff           ; white
        .dw     $2d6b           ; dark gray
        .dw     $56b5           ; light gray

        .org    $100            ; entry point
        nop                     ; this nop is customary
        jp      start           ; jump to the start
        
        .db		$CE, $ED, $66, $66, $CC, $0D, $00, $0B
        .db		$03, $73, $00, $83, $00, $0C, $00, $0D
        .db		$00, $08, $11, $1F, $88, $89, $00, $0E
        .db		$DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
        .db		$BB, $BB, $67, $63, $6E, $0E, $EC, $CC
        .db		$DD, $DC, $99, $9F, $BB, $B9, $33, $3E

name:   .db     "INFINITY GBS   " ; cart name   15 chars
        .db     $80             ; CGB features  yes
        .db     "SW"            ; new licensee  graffiti
        .db     $00             ; SGB features  no
        .db     $01             ; cart type     0=ROM ONLY,1=ROM+MBC1
        .db     $04             ; ROM size      0=32K,1=64K,2=128K,3=256K
        .db     $00             ; RAM size      none
        .db     $01             ; country       non-japan
        .db     $33             ; old licensee  see new licensee
        .db     $02             ; version
        .db     $BC             ; complement
        .dw     $0000           ; checksum

; start procedure
        .org    Origin          ; See start of file.
        
nowplaying:
	.db "Now Playing:"
	
selectsong:
	.db	"Select song:"
	
smess:  .db     "SFX:   /"        ; constant string for "### OF ###"

start:  di                      ; disable interrupts

        ldh     ($80),a         ; save the hardware type indicator

        call    setup           ; initialize video

        ld      hl,stack        ; set stack
        ldi     a,(hl)
        ld      h,(hl)
        ld      l,a
        ld      sp,hl

; display information on screen according to table data

		call	vbwait
		ld		hl, $9824
		ld		de, title
		ld		c, $0C
		call	text
		ld		hl,	$9865
		ld		de, author
		ld		c, $0A
		call	text
		ld		hl, $98A2
		ld		de, copyr
		ld		c, $11
		call	text
		call	vbwait
		ld		hl, $98C4
		inc		de
		ld		c, $0D
		call	text
		ld		hl, $9A01
		ld		de, smess
		ld		c, $08
		call	text
		call	vbwait
		ld		hl, $9901
		ld		de, nowplaying
		ld		c, $0C
		call	text
		ld		hl, $9981
		ld		de, selectsong
		ld		c, $0C
		call	text

xtext:  ld      a,sfxcount       ; display total number of songs
        ld      hl,$9A0A
        call    decb

; enable either timer or v-blank interrupt

        ld      a,(TAC)         ; check for timer flag
        bit     2,a
        jr      nz,timer
        ld      a,VBlankV           ; v-blank IRQ bit
        jr      intr
timer:  and     $07             ; mask off lower 3 bits
        ldh     ($07),a         ; set Timer Control register (TAC)

        ld      a,(TAC)         ; check for 2x clock rate flag
        bit     7,a
        jr      z,tma1
        ldh     a,($80)         ; check hardware type for CGB
        cp      $11
tma1:   ld      a,(TMA)         ; load base TMA value
        jr      z,tma2
        xor     $ff             ; convert TMA to divisor value
        srl     a               ; cut divisor in half
        xor     $ff             ; convert back to TMA value
tma2:   ldh     ($06),a         ; set Timer Modulus register (TMA)
        ldh     ($05),a         ; set Timer Counter register (TIMA)

        ld      a,TimerV           ; timer IRQ bit
intr:   ldh     ($ff),a         ; set interrupt

        ei                      ; enable interrupts

        xor		a
        ld		(joypad),a
        inc		a
        ld		(sfx),a
        
        ld      a,(first)       ; song counter
        ld		(song),a

        call    playmusic           ; start the first song
        call	vbwait
        call	printcurrentsong
        ld		a,1
        call	cursfx
        jp		mplay

; set the GGB background palette and 2x CPU clock rate if indicated

cgb:    ld      bc,$0008        ; count up from 0, down from 8
        ld      de,colors       ; point to palette data
        ld      hl,$ff68        ; palette control register
pal:    ld      a,b
        ldi     (hl),a          ; select palette entry with control reg
        ld      a,(de)          ; read palette data
        ldd     (hl),a          ; write to data reg
        inc     de              ; next data byte
        inc     b               ; next palette entry
        dec     c               ; count down until done
        jr      nz,pal

        ld      a,(TAC)         ; check for 2x clock rate flag
        bit     7,a
        ;ret     z
        ld      hl,$ff4d        ; CPU clock speed control register
        bit     7,(hl)
        ret     nz
        set     0,(hl)          ; set registers for 2x rate
        xor     a
        ldh     ($0f),a
        ldh     ($ff),a
        ld      a,$30
        ldh     ($00),a
        stop
        ret

; PLAY ROUTINE

; It is often recommended that GameBoy programs employ a HALT instruction
; in their main loop to conserve battery life, because the CPU consumes
; less power while "sleeping" on a HALT instruction. It is advantageous
; to use it here because it also generically handles timing from either
; the v-blank or timer interrupts. Note that interrupts MUST be enabled!

;mplay:  halt                    ; CPU will "sleep" until interrupt occurs
;        nop                     ; This reduces crashing for some newer GBS files(ugetab)

;ugetab: Program can have either of these modes, but the one below is the default.
mplay:  ei                      ; enable interrupts. 'HALT' always halts until interrupt
        halt                    ; CPU will "sleep" until interrupt occurs
        call	Audio_FrameProcess
        
        
        ld		bc,Duration
        ld		a,(cursong)
        ld		l,a
        ld		h,0
        add		hl,hl
        add		hl,bc
        
		ld		a,(stimer)
		cp		(hl)
		jr		nz, inct
		ld		a,(stimer+1)
		inc		hl
		cp		(hl)
		jr		nz,	inct
		ld		a,(cursong)
		inc		a
		ld		(song),a
		call	songup
		call	playmusic
		jr		mplay

inct:   ld		hl,stimer
        inc		(hl)
        jr		nz, scan
        inc		hl
        inc		(hl)

scan:   ld		a,(joypad)
		ld		d,a
		call    input           ; read buttons/joypad
		ld		(joypad),a
        cp      d
        call    nz,change       ; if input state changes, go do something
cplay:  jr      mplay           ; keep playing

change: bit     4,a             ; A
        jr      nz,playmusic
        bit		5,a				; B
        jr		nz,playsfx
        bit		1,a             ; left
        jr		nz,songdn
        bit		3,a				; down
        jr		nz,sfxdn		
        bit		0,a             ; right
        jr		nz,songup       
        bit		2,a				; up
        jr		nz,sfxup
        bit		7,a				; start
        jr		nz,stopall
        ret						; go back to playing

songup: ld      a,(song)
        cp      songcount
        jr      nz,wrapup
        xor		a             ; wrap to first song
wrapup: inc     a               ; increment song
		ld		(song),a
        call	printcurrentsong
        ret

songdn: ld      a,(song)
        dec     a               ; decrement song
        jr      nz,wrapdn
        ld      a,songcount     ; wrap to last song
wrapdn: ld      (song),a           		; fall through to init
        call	printcurrentsong
		ret
		
sfxup:	ld		a,(sfx)
		cp		sfxcount
		jr		nz,wrapups
		xor		a
wrapups:inc		a
		ld		(sfx),a
		ld      hl,$9A07
        call    decb
		ret
		
sfxdn:	ld		a,(sfx)
		dec		a
		jr		nz,wrapdns
		ld		a,sfxcount
wrapdns:ld		(sfx),a
cursfx:	ld      hl,$9A07
        call    decb
		ret

playmusic:
		ld		a,(song)
		dec     a               ; make it zero-based
        ld		(cursong),a
        call	printnewsong
        ld		a,(cursong)
		call	GBS_Init
		ret

playsfx:
		ld		a,(sfx)
		dec		a
		add		a,songcount
		call	GBS_Init
		ret
		
stopall:
		call	Audio_Music_Stop
		jp		Audio_SFX_Stop
		
		
;-----------------------------------------
		
		
printnewsong:
		ld		hl, $9942
		push	hl
		ld		hl,	$9922
		push	hl
		jr		printsongtitle
		
printcurrentsong:
		ld		a,(song)
		dec		a
		ld		hl, $99C2
		push	hl
		ld		hl, $99A2
		push	hl
		
printsongtitle:
		ld		bc, songtitles	; print the song title
		ld		l, a
		ld		h, 0
		add		hl, hl
		add		hl, hl
		add		hl, hl
		add		hl, hl
		add		hl, hl
		add		hl,	bc
		ld 		d, h
		ld 		e, l
		pop		hl
		ld		a, $10
		ld		c, a
		call 	text
		pop		hl
		ld		a, $10
		ld		c, a
		jp	 	text

; ripped and slightly tweaked from the 8x8 font of a video card BIOS

; Font address in normal compilation
; (7 * ([20-5A] - 20)) + 25C
; (7 * (31 - 20)) + 25C =

font:   .db     $00,$00,$00,$00,$00,$00,$00 ; $20 space
        .db     $30,$78,$78,$30,$30,$00,$30 ; $21 !
        .db     $6c,$6c,$6c,$00,$00,$00,$00 ; $22 "
        .db     $6c,$6c,$fe,$6c,$fe,$6c,$6c ; $23 #
        .db     $30,$7c,$c0,$78,$0c,$f8,$30 ; $24 $
        .db     $00,$c6,$cc,$18,$30,$66,$c6 ; $25 %
        .db     $38,$6c,$38,$76,$dc,$cc,$76 ; $26 &
        .db     $60,$60,$c0,$00,$00,$00,$00 ; $27 '
        .db     $18,$30,$60,$60,$60,$30,$18 ; $28 (
        .db     $60,$30,$18,$18,$18,$30,$60 ; $29 )
        .db     $00,$6c,$38,$fe,$38,$6c,$00 ; $2a * - ugetab: Reduced width by 1 pixel in middle
        .db     $00,$30,$30,$fc,$30,$30,$00 ; $2b +
        .db     $00,$00,$00,$00,$30,$30,$60 ; $2c ,
        .db     $00,$00,$00,$fc,$00,$00,$00 ; $2d -
        .db     $00,$00,$00,$00,$00,$30,$30 ; $2e .
        .db     $06,$0c,$18,$30,$60,$c0,$80 ; $2f /
        .db     $7c,$c6,$ce,$de,$f6,$e6,$7c ; $30 0
        .db     $30,$70,$30,$30,$30,$30,$fc ; $31 1
        .db     $78,$cc,$0c,$38,$60,$cc,$fc ; $32 2
        .db     $78,$cc,$0c,$38,$0c,$cc,$78 ; $33 3
        .db     $1c,$3c,$6c,$cc,$fe,$0c,$1e ; $34 4
        .db     $fc,$c0,$f8,$0c,$0c,$cc,$78 ; $35 5
        .db     $38,$60,$c0,$f8,$cc,$cc,$78 ; $36 6
        .db     $fc,$cc,$0c,$18,$30,$30,$30 ; $37 7
        .db     $78,$cc,$cc,$78,$cc,$cc,$78 ; $38 8
        .db     $78,$cc,$cc,$7c,$0c,$18,$70 ; $39 9
        .db     $00,$30,$30,$00,$30,$30,$00 ; $3a :
        .db     $00,$30,$30,$00,$30,$30,$60 ; $3b ;
        .db     $18,$30,$60,$c0,$60,$30,$18 ; $3c <
        .db     $00,$00,$fc,$00,$00,$fc,$00 ; $3d =
        .db     $60,$30,$18,$0c,$18,$30,$60 ; $3e >
        .db     $78,$cc,$0c,$18,$30,$00,$30 ; $3f ?
        .db     $7c,$c6,$de,$de,$de,$c0,$78 ; $40 @
        .db     $30,$78,$cc,$cc,$fc,$cc,$cc ; $41 A
        .db     $fc,$66,$66,$7c,$66,$66,$fc ; $42 B
        .db     $3c,$66,$c0,$c0,$c0,$66,$3c ; $43 C
        .db     $f8,$6c,$66,$66,$66,$6c,$f8 ; $44 D
        .db     $fe,$62,$68,$78,$68,$62,$fe ; $45 E
        .db     $fe,$62,$68,$78,$68,$60,$f0 ; $46 F
        .db     $3c,$66,$c0,$c0,$ce,$66,$3e ; $47 G
        .db     $cc,$cc,$cc,$fc,$cc,$cc,$cc ; $48 H
        .db     $78,$30,$30,$30,$30,$30,$78 ; $49 I
        .db     $1e,$0c,$0c,$0c,$cc,$cc,$78 ; $4a J
        .db     $e6,$66,$6c,$78,$6c,$66,$e6 ; $4b K
        .db     $f0,$60,$60,$60,$62,$66,$fe ; $4c L
        .db     $c6,$ee,$fe,$fe,$d6,$c6,$c6 ; $4d M
        .db     $c6,$e6,$f6,$de,$ce,$c6,$c6 ; $4e N
        .db     $38,$6c,$c6,$c6,$c6,$6c,$38 ; $4f O
        .db     $fc,$66,$66,$7c,$60,$60,$f0 ; $50 P
        .db     $78,$cc,$cc,$cc,$dc,$78,$1c ; $51 Q
        .db     $fc,$66,$66,$7c,$6c,$66,$e6 ; $52 R
        .db     $78,$cc,$e0,$70,$1c,$cc,$78 ; $53 S
        .db     $fc,$b4,$30,$30,$30,$30,$78 ; $54 T
        .db     $cc,$cc,$cc,$cc,$cc,$cc,$78 ; $55 U - ugetab: Angled the bottom. $fc > $78
        .db     $cc,$cc,$cc,$cc,$cc,$78,$30 ; $56 V
        .db     $c6,$c6,$c6,$d6,$fe,$ee,$c6 ; $57 W
        .db     $c6,$c6,$6c,$38,$38,$6c,$c6 ; $58 X
        .db     $cc,$cc,$cc,$78,$30,$30,$78 ; $59 Y
        .db     $fe,$c6,$8c,$18,$32,$66,$fe ; $5a Z
        
songtitles:
;            0123456789ABCDEF
		.db "  Title (new)   "
		.db "                "
		
		.db "  Title (old)   "
		.db "                "
		
		.db "   Mysterious   "
		.db "   Happenings   "
		
		.db "  Town I (new)  "
		.db "                "
		
		.db "  Town I (old)  "
		.db "                "
		
		.db "Nostalgic Sorrow"
		.db "                "
		
		.db "Overworld (new) "
		.db "                "
		
		.db "Overworld (old) "
		.db "                "
		
		.db "  Inconvenient  "
		.db " Nuisances (new)"
		
		.db "  Inconvenient  "
		.db " Nuisances (old)"
		
		.db "    Victory!    "
		.db "                "
		
		.db " Castle I (new) "
		.db "                "
		
		.db " Castle I (old) "
		.db "                "
		
		.db "   The Madman   "
		.db "     Parade     "
		
		.db "     Until      "
		.db "Tomorrow...(new)"
		
		.db "     Until      "
		.db "Tomorrow...(old)"
		
		.db "  Stillness of  "
		.db "     Night      "
		
		.db "  The Prophecy  "
		.db "                "
		
		.db " Northern Pass  "
		.db "     (new)      "
		
		.db " Northern Pass  "
		.db "     (old)      "
		
		.db "   Irritable    "
		.db " Nuisances (new)"
		
		.db "   Irritable    "
		.db " Nuisances (old)"
		
		.db "  Defeat (new)  "
		.db "                "
		
		.db "  Defeat (old)  "
		.db "                "
		
		.db "The Desert City "
		.db "                "
		
		.db "Uncertain Depths"
		.db "                "
		
		.db "  Dark Forest   "
		.db "                "
		
		.db "    Town II     "
		.db "                "
		
		.db "   Castle II    "
		.db "                "
		
		.db "   The Madman   "
		.db "    Revealed    "
		
		.db "    Trouble!    "
		.db "                "
		
		.db " Frozen Cavern  "
		.db "                "
		
		.db "   Travelling   "
		.db "     Waters     "
		
		.db "     Mystic     "
		.db "                "
		
		.db "  Infiltrating  "
		.db "    the Dark    "
		
		.db "     He Who     "
		.db "   Is Unnamed   "
		
		.db "    Epilogue    "
		.db "                "
		
		.db "  Credit Roll   "
		.db "                "
		
Duration:
		.dw 3840,3840	;Title
		.dw 7800		;Mysterious Happenings
		.dw 3600,3600	;Town I
		.dw 6900		;Nostalgic Sorrow
		.dw 6240,6240	;Overworld
		.dw 5700,5700	;Inconvenient Nussances
		.dw 240			;Victory!
		.dw 8100,8100	;Castle I
		.dw 8340		;The Madman Parade
		.dw 600,600		;Until Tomorrow�
		.dw 4080		;Stillness of Night
		.dw 3000		;The Prophecy
		.dw 4680,4680	;Northern Pass
		.dw 3300,3300	;Irritable Nuisances
		.dw 720,720		;Defeat
		.dw 7020		;The Desert City
		.dw 4920		;Uncertain Depths
		.dw 4200		;Dark Forest
		.dw 6360		;Town II
		.dw 8400		;Castle II
		.dw 7200		;The Madman Revealed
		.dw 8700		;Trouble!
		.dw 7860		;Frozen Cavern
		.dw 4200		;Travelling Waters
		.dw 6000		;Mystic
		.dw 9600		;Infiltrating the Dark
		.dw 7680		;He Who Is Unnamed
		.dw 10020		;Epilogue
		.dw 17400		;Credit Roll

		
		.org $3E00
header:	.db "GBS", $01
count:	.db songcount+sfxcount
first:	.db $01
		.dw load
init:	.dw GBS_Init
play:	.dw Audio_FrameProcess
stack:	.dw $df80
TAC:	.db $00
TMA:	.db $00
title:	.db "Infinity GBC"
		.fill 20, 0
author:	.db "Eric Hache"
		.fill 22, 0
copyr:	.db "1999-2016 Affinix Software, LLC"
		.db 0

load:
Song_Table_Begin:
	.DB   $0C,2         ; 01n - title
	.DB   $01,4         ; 01o - title
	.DB   $0C,1         ; 17 - mystery
	.DB   $0F,1         ; 03n - town1
	.DB   $01,5         ; 03o - town1
	.DB   $0E,1         ; 20 - sadness
	.DB   $0E,0         ; 02n - overworld
	.DB   $01,1         ; 02o - overworld
	.DB   $0B,0         ; 06n - fight1
	.DB   $02,2         ; 06o - fight1
	.DB   $11,2         ; 19 - victory
	.DB   $05,0         ; 04n - castle
	.DB   $02,1         ; 04o - castle
	.DB   $09,1         ; 11 - creator
	.DB   $11,0         ; 08n - rest
	.DB   $01,3         ; 08o - rest
	.DB   $11,3         ; 28 - nighttime
	.DB   $01,2         ; 01 - prophecy
	.DB   $0C,0         ; 05n - mountain
	.DB   $01,0         ; 05o - mountain
	.DB   $10,1         ; 07n - boss1
	.DB   $02,0         ; 07o - boss1
	.DB   $11,1         ; 09n - game over
	.DB   $02,3         ; 09o - game over
	.DB   $0B,1         ; 14 - kassim
	.DB   $09,0         ; 10 - cave
	.DB   $0D,1         ; 15 - forest
	.DB   $0F,2         ; 13 - town 2
	.DB   $10,0         ; 16 - alutha
	.DB   $0A,0         ; 12 - creator evil
	.DB   $06,0         ; 18 - trouble
	.DB   $0A,1         ; 22 - icecavern
	.DB   $0F,0         ; 21 - sailing
	.DB   $0D,0         ; 02 - mystic
	.DB   $07,0         ; 24 - great dark
	.DB   $08,0         ; 25 - lastboss
	.DB   $04,0         ; 26 - ending1
	.DB   $03,0         ; 27 - ending2
Song_Table_End:

SFXMax:
	.db	0,30,30,56,56,56,56,56,56,56,56,56,56,56,56,56,56,56

song		.equ	$d000
cursong		.equ	$d001
songcount	.equ	((Song_Table_End-Song_Table_Begin)/2)
sfx			.equ	$d002
sfxcount	.equ	56
joypad		.equ	$d003
stimer		.equ	$d004
curbank		.equ	$d006

Audio_Init				.equ	$4000
Audio_FrameProcess		.equ	$4003
Audio_Music_Play		.equ	$4006
Audio_Music_Stop		.equ	$4009
Audio_Music_Resume		.equ	$400C
Audio_SFX_Play			.equ	$400F
Audio_SFX_Stop			.equ	$4012
Audio_SFX_LockChnl3		.equ	$4015
Audio_SFX_UnlockChnl3	.equ	$4018


GBS_Init:
	push bc
	push de
	
	cp songcount
	jr c, Play_Song
	jp Play_SFX
	
Play_Song:
	ld de, $2000
	ld hl, Song_Table_Begin
	add a, a
	add a, l
	ld l, a
	ld a, (hl)
	ld (de), a
	ld (curbank), a
	inc l
	push hl
	
	call Audio_Init
	pop hl
	ld a, (hl)
	pop bc
	pop de
	call Audio_Music_Play
	xor	a
	ld	hl, stimer
	ldi	(hl), a
	ld	(hl), a
	ld a,(curbank)
	ld bc,SFXMax
	ld l,a
	ld h,0
	add hl,bc
	ld a,(hl)
	ld hl, $9A0A
	call decb
	ret
	
Play_SFX:
	sub songcount
	push af
	ld a,(curbank)
	ld bc,SFXMax
	ld l,a
	ld h,0
	add hl,bc
	ld h,(hl)
	pop af
	pop bc
	pop de
	cp	h
	ret nc
	
	cp 44
	jr c, Skip_Increment
	inc a
Skip_Increment:
	jp Audio_SFX_Play
	
	
.org $3fff
	.db $ff
.end

