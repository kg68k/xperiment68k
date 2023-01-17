.title putmes24 - draw text with 24dot font

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include include/macro.mac
.include include/console.mac
.include include/iocscall.mac
.include include/doscall.mac


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
  bsr getArgument
  tst.b (a2)
  beq @f
    lea (a2),a0
    bsr Putmes24
  @@:
  DOS _EXIT

getArgument:
  addq.l #1,a2
  @@:
    move.b (a2)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @b
    cmpi.b #TAB,d0
    beq @b
  @@:
  subq.l #1,a2
  rts


Putmes24:
  PUSH d7/a2
  lea (CompositeBuffer,pc),a1
  bsr getBitmap
  move d0,d7

  bsr AllocateTextVram
  movea.l d0,a1

  move d7,d0
  addq #DOTS_PER_BYTE-1,d0
  lsr #DOT_TO_BYTE_SHIFT,d0  ;横幅バイト数
  moveq #FONT_HEIGHT-1,d1    ;ライン数
  lea (CompositeBuffer,pc),a0
  bsr putBitmap

  POP d7/a2
  rts


;24ドットフォントを表示するのに必要なコンソール行数
REQUIRED_LINES: .equ (FONT_HEIGHT+CONSOLE_FONT_HEIGHT-1)/CONSOLE_FONT_HEIGHT
;上下に余るテキスト行数
MARGIN_TEXTLINE: .equ (REQUIRED_LINES*CONSOLE_FONT_HEIGHT-FONT_HEIGHT)/2

AllocateTextVram:
  PUSH d2
  moveq #REQUIRED_LINES-1,d1
  @@:
    IOCS _B_DOWN_S
  dbra d1,@b

  moveq #-1,d1
  moveq #-1,d2
  IOCS _B_CONSOL
  move d1,d2  ;表示開始Y座標

  moveq #-1,d1
  IOCS _B_LOCATE
  ext.l d0
  subq #REQUIRED_LINES,d0
  bcc @f
    moveq #0,d0
  @@:
  lsl #CONSOLE_LINE_TO_TEXTLINE_SHIFT,d0  ;コンソール上の(論理的な)表示ライン位置
  add d2,d0  ;TVRAM上の(物理的な)表示ライン位置
  addq #MARGIN_TEXTLINE,d0
  lsl #TEXTLINE_TO_BYTE_SHIFT,d0
  addi.l #TVRAM,d0
  POP d2
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
  IOCS _B_CUROFF
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
  IOCS _B_CURON
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


.bss
.quad

CompositeBuffer: .ds.b BYTES_PER_TEXTLINE*FONT_HEIGHT


.end
