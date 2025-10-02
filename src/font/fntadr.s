.title fntadr - IOCS _FNTADR

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


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr getArguments
  move.l d1,d2
  move.l d0,d1
  IOCS _FNTADR

  lea (Buffer,pc),a0
  lea (strD0equ,pc),a1
  STRCPY a1,a0,-1
  bsr ToHexString8

  lea (strD1equ,pc),a1
  STRCPY a1,a0,-1
  move.l d1,d0
  bsr ToHexString4_4

  lea (strD2equ,pc),a1
  STRCPY a1,a0,-1
  move.l d2,d0
  bsr ToHexString4_4

  lea (strCrLf,pc),a1
  STRCPY a1,a0
  DOS_PRINT (Buffer,pc)

  DOS _EXIT


getArguments:
  PUSH d5-d7
  moveq #0,d5
  moveq #0,d6  ;文字コード
  moveq #8,d7  ;フォントサイズ
  1:
    SKIP_SPACE a0
    beq 9f

    cmpi.b #'-',(a0)
    bne 2f
      move.b (1,a0),d0
      cmpi.b #'f',d0
      bne @f
        addq.l #2,a0  ;-f<size> フォントサイズの指定
        SKIP_SPACE a0
        beq PrintUsage

        bsr ParseInt  ;IOCS _FNTADRが対応しているのは6,8,12だが
        move.l d0,d7  ;特に制限せず指定されたものをそのまま使う
        bra 1b
      @@:
      cmpi.b #'c',d0
      bne @f
        addq.l #2,a0  ;-c<code> 文字コードによる文字の指定
        SKIP_SPACE a0
        beq PrintUsage

        bsr ParseInt
        move.l d0,d6
        moveq #-1,d5  ;文字指定あり
        bra 1b
      @@:
      bra PrintUsage
    2:
    bsr GetChar
    move.l d0,d6
    moveq #-1,d5  ;文字指定あり
    bra 1b
  9:
  tst.l d5
  beq PrintUsage  ;文字が指定されなかった

  move.l d6,d0
  move.l d7,d1
  POP d5-d7
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


  DEFINE_TOHEXSTRING8 ToHexString8
  DEFINE_TOHEXSTRING4_4 ToHexString4_4
  DEFINE_PARSEINTWORD ParseInt
  DEFINE_FATAL Fatal


.data

strUsage:
  .dc.b 'usage: fntadr [options] <char>',CR,LF
  .dc.b 'options:',CR,LF
  .dc.b '  -c<code> ... character code',CR,LF
  .dc.b '  -f<size> ... font size (<size>=6,8,12)',CR,LF
  .dc.b 0

strD0equ: .dc.b 'd0.l = $',0
strD1equ: .dc.b ', d1.l = $',0
strD2equ: .dc.b ', d2.l = $',0

strCrLf: .dc.b CR,LF,0


.bss
.even

Buffer:
  .ds.b 256


.end ProgramStart
