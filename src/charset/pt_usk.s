.title pt_usk - print text: USKCG

;This file is part of Xperiment68k
;Copyright (C) 2025 TcbnErik
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <https://www.gnu.org/licenses/>.


.include macro.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


FILLER_CHAR: .reg '**'

;オプションのビット位置
PRINT_USK_A:  .equ 0
PRINT_USK_B:  .equ 1
PRINT_F4XX:   .equ 2
PRINT_F5XX:   .equ 3


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr GetArg
  move.l d0,d7

  suba.l a3,a3
  moveq #0,d3
  1:
    bclr d3,d7
    beq @f
      DOS_PRINT (Header,pc)

      move.l d3,d0  ;$f400 $f500があるので_PRINTではなく_WRITEで出力する
      bsr getText
      suba.l a0,a1
      move.l a1,-(sp)
      pea (a0)
      move #STDOUT,-(sp)
      DOS _WRITE
      lea (10,sp),sp

      tst d7
      beq @f
        DOS_PRINT_CRLF  ;他の外字グループも表示するなら行を空ける
    @@:
    addq #1,d3
  cmpi #PRINT_F5XX,d3
  bls 1b

  DOS _EXIT


getText:
  lsl #3,d0
  movem.l (@f,pc,d0.w),a0-a1
  rts

@@:
  .dc.l UskTextA,UskTextAEnd
  .dc.l UskTextB,UskTextBEnd
  .dc.l UskText4,UskText4End
  .dc.l UskText5,UskText5End


GetArg:
  moveq #0,d1
  bra 8f
  1:
    cmpi.b #'a',d0
    bne @f
      bset #PRINT_USK_A,d1
      bra 8f
    @@:
    cmpi.b #'b',d0
    bne @f
      bset #PRINT_USK_B,d1
      bra 8f
    @@:
    cmpi.b #'4',d0
    bne @f
      bset #PRINT_F4XX,d1
      bra 8f
    @@:
    cmpi.b #'5',d0
    bne @f
      bset #PRINT_F5XX,d1
      bra 8f
    @@:
  8:
  move.b (a0)+,d0
  bne 1b

  move.l d1,d0
  bne @f
    moveq #1<<PRINT_USK_A+1<<PRINT_USK_B,d0
  @@:
  rts


.data

DUMPL: .macro header,skipLen,code,codeLen
  .dc.b header
  .rept skipLen
    .dc.b ' ',FILLER_CHAR
  .endm
  @c:=code
  .rept codeLen
    .if code>=$f000
      .dc.b ' '
    .endif
    .dc.b ' ',@c>>8,@c.and.$ff
    @c:=@c+1
  .endm
  .rept 16-(skipLen+codeLen)
    .dc.b ' ',FILLER_CHAR
  .endm
  .dc.b CR,LF
.endm

Header:
  .dc.b '     | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +a +b +c +d +e +f',CR,LF
  .dc.b '-----+------------------------------------------------',CR,LF
  .dc.b 0

UskTextA:
  DUMPL '8690 |',15,$869f,1
  DUMPL '86a0 |', 0,$86a0,16
  DUMPL '86b0 |', 0,$86b0,16
  DUMPL '86c0 |', 0,$86c0,16
  DUMPL '86d0 |', 0,$86d0,16
  DUMPL '86e0 |', 0,$86e0,16
  DUMPL '86f0 |', 0,$86f0,13  ;～$86fc
  .dc.b CR,LF
  DUMPL '8740 |', 0,$8740,16
  DUMPL '8750 |', 0,$8750,16
  DUMPL '8760 |', 0,$8760,16
  DUMPL '8770 |', 0,$8770,15  ;～$877e
  DUMPL '8780 |', 0,$8780,16
  DUMPL '8790 |', 0,$8790,15  ;～$879e
UskTextAEnd:

UskTextB:
  DUMPL 'eb90 |',15,$eb9f,1
  DUMPL 'eba0 |', 0,$eba0,16
  DUMPL 'ebb0 |', 0,$ebb0,16
  DUMPL 'ebc0 |', 0,$ebc0,16
  DUMPL 'ebd0 |', 0,$ebd0,16
  DUMPL 'ebe0 |', 0,$ebe0,16
  DUMPL 'ebf0 |', 0,$ebf0,13  ;～$ebfc
  .dc.b CR,LF
  DUMPL 'ec40 |', 0,$ec40,16
  DUMPL 'ec50 |', 0,$ec50,16
  DUMPL 'ec60 |', 0,$ec60,16
  DUMPL 'ec70 |', 0,$ec70,15  ;～$ec7e
  DUMPL 'ec80 |', 0,$ec80,16
  DUMPL 'ec90 |', 0,$ec90,15  ;～$ec9e
UskTextBEnd:

UskText4:
  DUMPL 'f400 |',0,$f400,16
  DUMPL 'f410 |',0,$f410,16
  DUMPL 'f420 |',0,$f420,16
  DUMPL 'f430 |',0,$f430,16
  DUMPL 'f440 |',0,$f440,16
  DUMPL 'f450 |',0,$f450,16
  DUMPL 'f460 |',0,$f460,16
  DUMPL 'f470 |',0,$f470,16
  DUMPL 'f480 |',0,$f480,16
  DUMPL 'f490 |',0,$f490,16
  DUMPL 'f4a0 |',0,$f4a0,16
  DUMPL 'f4b0 |',0,$f4b0,16
  DUMPL 'f4c0 |',0,$f4c0,16
  DUMPL 'f4d0 |',0,$f4d0,16
  DUMPL 'f4e0 |',0,$f4e0,16
  DUMPL 'f4f0 |',0,$f4f0,16
UskText4End:

UskText5:
  DUMPL 'f500 |',0,$f500,16
  DUMPL 'f510 |',0,$f510,16
  DUMPL 'f520 |',0,$f520,16
  DUMPL 'f530 |',0,$f530,16
  DUMPL 'f540 |',0,$f540,16
  DUMPL 'f550 |',0,$f550,16
  DUMPL 'f560 |',0,$f560,16
  DUMPL 'f570 |',0,$f570,16
  DUMPL 'f580 |',0,$f580,16
  DUMPL 'f590 |',0,$f590,16
  DUMPL 'f5a0 |',0,$f5a0,16
  DUMPL 'f5b0 |',0,$f5b0,16
  DUMPL 'f5c0 |',0,$f5c0,16
  DUMPL 'f5d0 |',0,$f5d0,16
  DUMPL 'f5e0 |',0,$f5e0,16
  DUMPL 'f5f0 |',0,$f5f0,16
UskText5End:


.end ProgramStart
