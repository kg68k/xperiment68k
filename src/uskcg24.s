.title uskcg24 - draw uskcg table with 24dot font

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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
.include iocscall.mac
.include doscall.mac

.include xputil.mac

FILLER_CHAR: .reg '**'


TVRAM: .equ $00e00000
CRTC_R21: .equ $00e8002a

TEXTLINE_TO_BYTE_SHIFT: .equ 7
BYTES_PER_TEXTLINE: .equ 1<<TEXTLINE_TO_BYTE_SHIFT

CONSOLE_WIDTH: .equ 768
CONSOLE_LINE_TO_TEXTLINE_SHIFT: .equ 4
CONSOLE_FONT_HEIGHT: .equ 1<<CONSOLE_LINE_TO_TEXTLINE_SHIFT

DOT_TO_BYTE_SHIFT: .equ 3
DOTS_PER_BYTE:     .equ 1<<DOT_TO_BYTE_SHIFT

FONT_HEIGHT:     .equ 24
FONT_WIDTH_HALF: .equ 12
FONT_WIDTH_FULL: .equ FONT_WIDTH_HALF*2

FNTGET_BUF_SIZE: .equ 4+FONT_WIDTH_FULL/DOTS_PER_BYTE*FONT_HEIGHT


.cpu 68000
.text

Start:
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d0,d7
  bne @f
    DOS_PRINT (Usage,pc)
    DOS _EXIT
  @@:

  moveq #2,d1  ;画面全体を消去
  IOCS _B_CLR_ST
  IOCS _B_CUROFF

  moveq #0,d6  ;Y座標

  moveq #0,d0
  bsr getText
  move.l d6,d0
  bsr PrintLines
  move.l d0,d6

  move.l d7,d0
  bsr getText
  move.l d6,d0
  bsr PrintLines

  moveq #CONSOLE_FONT_HEIGHT-1,d2
  add d0,d2
  lsr #CONSOLE_LINE_TO_TEXTLINE_SHIFT,d2
  moveq #0,d1
  IOCS _B_LOCATE

  IOCS _B_CURON
  DOS _EXIT


getText:
  lsl #3,d0
  movem.l (@f,pc,d0.w),a0-a1
  rts

@@:
  .dc.l Header,HeaderEnd
  .dc.l UskTextA,UskTextAEnd
  .dc.l UskTextB,UskTextBEnd
  .dc.l UskText4,UskText4End
  .dc.l UskText5,UskText5End


AnalyzeArgument:
  bra 8f
  1:
    cmpi.b #'a',d0
    bne @f
      moveq #1,d0
      rts
    @@:
    cmpi.b #'b',d0
    bne @f
      moveq #2,d0
      rts
    @@:
    cmpi.b #'4',d0
    bne @f
      moveq #3,d0
      rts
    @@:
    cmpi.b #'5',d0
    bne @f
      moveq #4,d0
      rts
    @@:
  8:
  move.b (a0)+,d0
  bne 1b
  moveq #0,d0
  rts


PrintLines:
  PUSH d6/a2-a3
  move.l d0,d6
  lea (a0),a2
  lea (a1),a3
  @@:
    lea (a2),a0
    move.l d6,d0
    bsr Putmes24
    1:
      bsr getCharCode  ;$f400 $f500 があるので @@: tst.b (a2)+ || bne @b は不可
    bne 1b
    addi #FONT_HEIGHT,d6
  cmpa.l a2,a3
  bhi @b
  move.l d6,d0
  POP d6/a2-a3
  rts


Putmes24:
  PUSH d6-d7/a2
  lsl #TEXTLINE_TO_BYTE_SHIFT,d0
  addi.l #TVRAM,d0
  move.l d0,d6

  lea (CompositeBuffer,pc),a1
  bsr getBitmap
  move d0,d7

  move d7,d0
  addq #DOTS_PER_BYTE-1,d0
  lsr #DOT_TO_BYTE_SHIFT,d0  ;横幅バイト数
  moveq #FONT_HEIGHT,d1      ;ライン数
  lea (CompositeBuffer,pc),a0
  movea.l d6,a1
  bsr putBitmap

  POP d6-d7/a2
  rts


putBitmap:
  PUSH d5-d7/a2-a4
  move d0,d7
  beq 9f
  subq #1,d1
  beq 9f
  movea.l a1,a2

  suba.l a1,a1
  IOCS _B_SUPER
  movea.l d0,a4
  lea (CRTC_R21),a1
  move (a1),d5
  move #%01_0011_0000,(a1)  ;プレーン0,1同時アクセス

  move #BYTES_PER_TEXTLINE,d6
  sub d7,d6  ;バッファとTVRAMの1行あたりの転送しないバイト数
  1:
    move d7,d0
    subq #1,d0
    @@:
      move.b (a0)+,(a2)+
    dbra d0,@b
    adda d6,a0
    adda d6,a2
  dbra d1,1b

  move d5,(a1)
  movea.l a4,a1
  IOCS _B_SUPER
9:
  POP d5-d7/a2-a4
  rts


getBitmap:
  PUSH d6-d7/a2-a3
  lea (-FNTGET_BUF_SIZE,sp),sp
  lea (a0),a2  ;string
  lea (a1),a3  ;composite buffer

  move #CONSOLE_WIDTH,d6  ;残り横ドット数
  moveq #0,d7  ;書き込んだ横ドット数
  1:
    bsr getCharCode
    beq 9f
      moveq #FONT_WIDTH_HALF,d1
      swap d1
      move d0,d1
      lea (sp),a1
      IOCS _FNTGET

      sub (0,sp),d6
      bcs 9f  ;表示する幅が残っていない

      lea (sp),a0
      lea (a3),a1
      move d7,d0
      bsr compositeFont
      add (0,sp),d7
    bra 1b
  9:
  move.l d7,d0
  lea (FNTGET_BUF_SIZE,sp),sp
  POP d6-d7/a2-a3
  rts

getCharCode:
  moveq #0,d0
  move.b (a2)+,d0
  beq @f
    move.b d0,d1
    lsr.b #5,d1
    btst d1,#%10010000
    beq 1f
      lsl #8,d0
      move.b (a2)+,d0
    1:
    tst d0
  @@:
  rts

compositeFont:
  move d0,d1
  lsr #DOT_TO_BYTE_SHIFT,d1
  adda d1,a1
  moveq #DOTS_PER_BYTE-1,d1
  and d0,d1

  move.l (a0)+,d0
  subq #1,d0  ;height-1

  cmpi #24,(-4,a0)
  beq compositeFont24
  bra compositeFont12

;半角(12x24ドット)
compositeFont12:
  tst d1
  bne compositeFont0PPP
  bra compositeFontPPP0

;バイト境界から12ドット
compositeFontPPP0:
  @@:
    move.b (a0)+,(a1)+
    move.b (a0)+,(a1)+
    lea (BYTES_PER_TEXTLINE-2,a1),a1
  dbra d0,@b
  rts

;バイト境界+4から12ドット
compositeFont0PPP:
  @@:
    move.b (a0)+,-(sp)
    move (sp)+,d1
    move.b (a0)+,d1
    lsr #4,d1  ;0PPP
    rol #8,d1
    or.b d1,(a1)+
    rol #8,d1
    move.b d1,(a1)+
    lea (BYTES_PER_TEXTLINE-2,a1),a1
  dbra d0,@b
  rts

;全角(24x24ドット)
compositeFont24:
  tst d1
  bne compositeFont0PPPPPP0
  bra compositeFontPPPPPP

;バイト境界から24ドット
compositeFontPPPPPP:
  @@:
    move.b (a0)+,(a1)+
    move.b (a0)+,(a1)+
    move.b (a0)+,(a1)+
    lea (BYTES_PER_TEXTLINE-3,a1),a1
  dbra d0,@b
  rts

;バイト境界+4から24ドット
compositeFont0PPPPPP0:
  @@:
    moveq #0,d1
    move.b (a0)+,d1
    swap d1
    move.b (a0)+,-(sp)
    move (sp)+,d1
    move.b (a0)+,d1
    lsl.l #4,d1  ;0PPP_PPP0
    rol.l #8,d1
    or.b d1,(a1)+
    .rept 3
      rol.l #8,d1
      move.b d1,(a1)+
    .endm
    lea (BYTES_PER_TEXTLINE-4,a1),a1
  dbra d0,@b
  rts


.data

Usage:
  .dc.b 'uskcg24: 外字の一覧を24ドットフォントで表示します。',CR,LF
  .dc.b '  a ... 外字A',CR,LF
  .dc.b '  b ... 外字B',CR,LF
  .dc.b '  4 ... 半角外字 $f400-$f4ff',CR,LF
  .dc.b '  5 ... 半角外字 $f500-$f5ff',CR,LF
  .dc.b 0


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
  .dc.b 0
.endm

Header:
  .dc.b '     | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +a +b +c +d +e +f',0
  .dc.b '-----+------------------------------------------------',0
HeaderEnd:

UskTextA:
  DUMPL '8690 |',15,$869f,1
  DUMPL '86a0 |', 0,$86a0,16
  DUMPL '86b0 |', 0,$86b0,16
  DUMPL '86c0 |', 0,$86c0,16
  DUMPL '86d0 |', 0,$86d0,16
  DUMPL '86e0 |', 0,$86e0,16
  DUMPL '86f0 |', 0,$86f0,13  ;～$86fc
  .dc.b 0
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
  .dc.b 0
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


.bss
.quad

CompositeBuffer: .ds.b BYTES_PER_TEXTLINE*FONT_HEIGHT


.end
