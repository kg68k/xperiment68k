.title fntget - show font data

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

.include xputil.mac


BLANK_CHAR: .equ '□'
DOT_CHAR:   .equ '■'


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr getArguments

  move.l d0,d1
  lea (FntgetBuffer,pc),a1
  IOCS _FNTGET

  lea (Buffer,pc),a0
  bsr stringifyFontData
  DOS_PRINT (Buffer,pc)

  DOS _EXIT


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


getArguments:
  PUSH d6-d7
  moveq #0,d6  ;文字コード
  moveq #0,d7  ;フォントサイズ
  1:
    SKIP_SPACE a0
    beq 9f

    cmpi.b #'-',(a0)
    bne 2f
      move.b (1,a0),d0
      cmpi.b #'f',d0
      bne @f
        addq.l #2,a0  ;-f<n> フォントサイズの指定
        SKIP_SPACE a0
        beq PrintUsage

        bsr ParseIntWord  ;IOCS _FNTGETが対応しているのは0,6,8,12だが
        move d0,d7        ;特に制限せず指定されたものをそのまま使う
        bra 1b
      @@:
      cmpi.b #'c',d0
      bne @f
        addq.l #2,a0  ;-c<n> 文字コードによる文字の指定
        SKIP_SPACE a0
        beq PrintUsage

        bsr ParseIntWord
        moveq #-1,d6  ;文字指定あり
        move d0,d6
        bra 1b
      @@:
      bra PrintUsage
    2:
    bsr GetChar
    moveq #-1,d6  ;文字指定あり
    move d0,d6
    bra 1b
  9:
  tst.l d6
  bpl PrintUsage  ;文字が指定されなかった

  move d7,d0
  swap d0
  move d6,d0
  POP d6-d7
  rts

GetChar:
  moveq #0,d0
  move.b (a0)+,d0
  move.b d0,d1
  lsr.b #5,d1
  btst d1,#%10010000
  beq @f
    tst.b (a0)
    beq @f
      lsl #8,d0  ;2バイト文字
      move.b (a0)+,d0
  @@:
  rts


PrintUsage:
  lea (strUsage,pc),a0
  bra Fatal


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_FATAL Fatal


.data

strUsage:
  .dc.b 'usage: fntget [options] <char>',CR,LF
  .dc.b 'options:',CR,LF
  .dc.b '  -c<n> ... character code',CR,LF
  .dc.b '  -f<n> ... font size (n=6,8,12)',CR,LF
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
