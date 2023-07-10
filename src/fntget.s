.title fntget - show font data

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

.include macro.mac
.include fefunc.mac
.include console.mac
.include doscall.mac
.include iocscall.mac


BLANK_CHAR: .equ '□'
DOT_CHAR:   .equ '■'


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr getArgument
  move.l d0,d1
  bmi error

  lea (FntgetBuffer,pc),a1
  IOCS _FNTGET

  lea (Buffer,pc),a0
  bsr stringifyFontData

  lea (Buffer,pc),a0
  bsr PrintA0

  DOS _EXIT

error:
  lea (Usage,pc),a0
  bsr PrintA0
  move #1,-(sp)
  DOS _EXIT2


PrintA0:
  pea (a0)
  DOS _PRINT
  addq.l #4,sp
  rts


stringifyFontData:
  PUSH d2-d7
  move #BLANK_CHAR,d2
  move #DOT_CHAR,d3
  move (a1)+,d6  ;横ドット数
  move (a1)+,d7  ;縦ドット数
  subq #1,d7
  1:
    move d6,d5  ;残りドット数
    2:
      moveq #8,d4  ;今回のループ数
      sub d4,d5
      bcc @f
        add d5,d4    ;7ドット以下の端数の場合
        moveq #0,d5  ;残りなし
      @@:
      move.b (a1)+,d1
      subq #1,d4
      3:
        add.b d1,d1
        bcc @f
          move d3,(a0)+  ;%1のドット
          bra 4f
        @@:
          move d2,(a0)+  ;%0のドット
        4:
      dbra d4,3b
    tst d5
    bne 2b
    move #CR<<8+LF,(a0)+
  dbra d7,1b

  clr.b (a0)
  POP d2-d7
  rts


getArgument:
  PUSH d7
  moveq #0,d7
  1:
    bsr skipBlank
    move.l a0,-(sp)
    bsr getHexLength
    movea.l (sp)+,a0
    subq.l #2,d0
    bcs 2f
      FPACK __STOH  ;2桁以上の16進数なら文字コードの指定
      bcs 8f
      move d0,d7
      bra 1b
    2:
    moveq #0,d0
    move.b (a0)+,d0
    beq 9f

    cmpi.b #'-',d0
    bne 3f
      FPACK __STOL  ;フォントサイズの指定 -6, -8, -12
      bcs 8f
      swap d7
      move d0,d7
      swap d7
      bra 1b
  3:
    move.b d0,d1  ;文字の指定
    lsr.b #5,d1
    btst d1,#%10010000
    beq @f
      lsl #8,d0  ;2バイト文字
      move.b (a0)+,d0
    @@:
    move d0,d7
    bra 1b
  8:
    moveq #-1,d7
9:
  move.l d7,d0
  tst d0
  bne @f
    moveq #-1,d0
  @@:
  POP d7
  rts


skipBlank:
@@:
  move.b (a0)+,d0
  beq @f
  cmpi.b #SPACE,d0
  beq @b
@@:
  subq.l #1,a0
  rts


getHexLength:
  lea (a0),a1
  1:
    move.b (a0)+,d0
    beq 9f
    cmpi.b #'0',d0
    bcs 9f
    cmpi.b #'9',d0
    bls 1b
    ori.b #$20,d0
    cmpi.b #'a',d0
    bcs 9f
    cmpi.b #'f',d0
    bls 1b
9:
  subq.l #1,a0
  suba.l a1,a0
  move.l a0,d0
  rts


.data

Usage:
  .dc.b 'fntget [option] <char or hex>',CR,LF
  .dc.b '  -6, -8, -12 ... font size',CR,LF
  .dc.b 0


.bss
.even

FntgetBuffer:
  .ds 1
  .ds 1
  .ds.b (24/8)*24

Buffer:
  .ds.b (2*24+2)*24
  .ds.b 16


.end ProgramStart
