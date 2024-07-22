.title uskhw_hex - $f4xx nad $f5xx external character font generator (hex)

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
.include doscall.mac
.include iocscall.mac
.include iocswork.mac

.include xputil.mac


.cpu 68000
.text

Start:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  move.l (USKFONT2),d0
  lea (FontType2,pc),a0
  bsr ValidateFontBuffer
  beq @f
    bsr CreateUskFont8x16
  @@:

  move.l (USKFONT5),d0
  lea (FontType2,pc),a0
  bsr ValidateFontBuffer
  beq @f
    bsr CreateUskFont12x24
  @@:

  DOS _EXIT


ValidateFontBuffer:
  lea (NotAllocated,pc),a1
  tst.l d0
  beq @f
  lea (OddAddress,pc),a1
  btst #0,d0
  beq 9f
  @@:
    DOS_PRINT (a0)
    DOS_PRINT (a1)
    moveq #0,d0
  9:
  tst.l d0
  movea.l d0,a0
  rts


CreateUskFont8x16:
  PUSH d3-d5/a3-a5
  moveq #2-1,d5           ;$f4xx, $f5xx
  lea (HexFont8x4,pc),a5  ;4 or 5のフォント
  1:
    moveq #16-1,d4          ;上位ニブル
    lea (HexFont8x6,pc),a4  ;上位ニブルのフォント
    2:
      moveq #16-1,d3          ;下位ニブル
      lea (HexFont8x6,pc),a3  ;下位ニブルのフォント
      3:
        lea (a5),a1
        move.l (a1)+,(a0)+  ;4 or 5
        lea (a4),a1
        move.l (a1)+,(a0)+  ;上位ニブル
        move.w (a1)+,(a0)+
        lea (a3),a1
        move.w (a1)+,(a0)+  ;下位ニブル
        move.l (a1)+,(a0)+
        addq.l #6,a3
      dbra d3,3b
      addq.l #6,a4
    dbra d4,2b
    addq.l #4,a5
  dbra d5,1b
  POP d3-d5/a3-a5
  rts


CreateUskFont12x24:
  PUSH d3-d5/a3-a5
  moveq #2-1,d5  ;$f4xx, $f5xx
  lea (HexFont12x6+(6*2)*4,pc),a5  ;4 or 5のフォント
  1:
    moveq #16-1,d4           ;上位ニブル
    lea (HexFont12x6,pc),a4  ;上位ニブルのフォント
    2:
      moveq #16-1,d3           ;下位ニブル
      lea (HexFont12x6,pc),a3  ;下位ニブルのフォント
      3:
        lea (HexFont12x6+(6*2)*$f,pc),a1
        move.l (a1)+,(a0)+  ;F
        move.l (a1)+,(a0)+
        move.l (a1)+,(a0)+
        lea (a5),a1
        move.l (a1)+,(a0)+  ;4 or 5
        move.l (a1)+,(a0)+
        move.l (a1)+,(a0)+
        lea (a4),a1
        move.l (a1)+,(a0)+  ;上位ニブル
        move.l (a1)+,(a0)+
        move.l (a1)+,(a0)+
        lea (a3),a1
        move.l (a1)+,(a0)+  ;下位ニブル
        move.l (a1)+,(a0)+
        move.l (a1)+,(a0)+
        lea (6*2,a3),a3
      dbra d3,3b
      lea (6*2,a4),a4
    dbra d4,2b
    lea (6*2,a5),a5
  dbra d5,1b
  POP d3-d5/a3-a5
  rts


.data
.quad

HexFont8x4:
  .dc.b %01001000  ;4
  .dc.b %01001000
  .dc.b %01111110
  .dc.b %00001000

  .dc.b %01111110  ;5
  .dc.b %01110000
  .dc.b %00001100
  .dc.b %01110000

HexFont8x6:
  .dc.b %00000000  ;0
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00111100

  .dc.b %00000000  ;1
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000

  .dc.b %00000000  ;2
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %00111100
  .dc.b %01000000
  .dc.b %01111100

  .dc.b %00000000  ;3
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %00111100
  .dc.b %00000010
  .dc.b %01111100

  .dc.b %00000000  ;4
  .dc.b %01001000
  .dc.b %01001000
  .dc.b %01111110
  .dc.b %00001000
  .dc.b %00001000

  .dc.b %00000000  ;5
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %01111100

  .dc.b %00000000  ;6
  .dc.b %00111100
  .dc.b %01000000
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %00111100

  .dc.b %00000000  ;7
  .dc.b %01111100
  .dc.b %01000100
  .dc.b %00000100
  .dc.b %00000100
  .dc.b %00000100

  .dc.b %00000000  ;8
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %00111100

  .dc.b %00000000  ;9
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %00111100

  .dc.b %00000000  ;A
  .dc.b %00011000
  .dc.b %00100100
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010

  .dc.b %00000000  ;B
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01111100

  .dc.b %00000000  ;C
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000000
  .dc.b %01000010
  .dc.b %00111100

  .dc.b %00000000  ;D
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01111100

  .dc.b %00000000  ;E
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111110

  .dc.b %00000000  ;F
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01000000

HexFont12x6:
  .dc %000000000000<<4  ;0
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %001000000100<<4
  .dc %001000000100<<4
  .dc %000111111000<<4

  .dc %000000000000<<4  ;1
  .dc %000000100000<<4
  .dc %000000100000<<4
  .dc %000000100000<<4
  .dc %000000100000<<4
  .dc %000000100000<<4

  .dc %000000000000<<4  ;2
  .dc %001111111000<<4
  .dc %000000000100<<4
  .dc %000111111000<<4
  .dc %001000000000<<4
  .dc %001111111000<<4

  .dc %000000000000<<4  ;3
  .dc %001111111000<<4
  .dc %000000000100<<4
  .dc %000111111000<<4
  .dc %000000000100<<4
  .dc %001111111000<<4

  .dc %000000000000<<4  ;4
  .dc %001000100000<<4
  .dc %001000100000<<4
  .dc %001111111100<<4
  .dc %000000100000<<4
  .dc %000000100000<<4

  .dc %000000000000<<4  ;5
  .dc %001111111100<<4
  .dc %001000000000<<4
  .dc %001111111000<<4
  .dc %000000000100<<4
  .dc %001111111000<<4

  .dc %000000000000<<4  ;6
  .dc %000111111000<<4
  .dc %001000000000<<4
  .dc %001111111000<<4
  .dc %001000000100<<4
  .dc %000111111000<<4

  .dc %000000000000<<4  ;7
  .dc %001111111000<<4
  .dc %001000001000<<4
  .dc %000000001000<<4
  .dc %000000001000<<4
  .dc %000000001000<<4

  .dc %000000000000<<4  ;8
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %000111111000<<4

  .dc %000000000000<<4  ;9
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %001111111000<<4
  .dc %000000000100<<4
  .dc %000111111000<<4

  .dc %000000000000<<4  ;A
  .dc %000001100000<<4
  .dc %000010010000<<4
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %001000000100<<4

  .dc %000000000000<<4  ;B
  .dc %001111111000<<4
  .dc %001000000100<<4
  .dc %001111111000<<4
  .dc %001000000100<<4
  .dc %001111111000<<4

  .dc %000000000000<<4  ;C
  .dc %000111111000<<4
  .dc %001000000100<<4
  .dc %001000000000<<4
  .dc %001000000100<<4
  .dc %000111111000<<4

  .dc %000000000000<<4  ;D
  .dc %001111111000<<4
  .dc %001000000100<<4
  .dc %001000000100<<4
  .dc %001000000100<<4
  .dc %001111111000<<4

  .dc %000000000000<<4  ;E
  .dc %001111111100<<4
  .dc %001000000000<<4
  .dc %001111111100<<4
  .dc %001000000000<<4
  .dc %001111111100<<4

  .dc %000000000000<<4  ;F
  .dc %001111111100<<4
  .dc %001000000000<<4
  .dc %001111111100<<4
  .dc %001000000000<<4
  .dc %001000000000<<4


FontType2: .dc.b '半角外字(8x16)',0
FontType5: .dc.b '半角外字(12x24)',0

NotAllocated: .dc.b 'のフォントバッファが確保されていません。',CR,LF,0
OddAddress:   .dc.b 'のフォントバッファが奇数アドレスです。',CR,LF,0


.end Start
