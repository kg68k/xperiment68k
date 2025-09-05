.title exchr_hex - external character font generator (hex)

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
.include dosdef.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

KeepStart:

ProgramIdString: .dc.b 'exchr_hex',0
.quad
OldExchrVec: .dc.l 0


SET_FONT_SIZE: .macro xdot,ydot,dreg1,dreg2
  .if xdot<=8
    moveq #xdot,dreg1
    swap dreg1
  .else
    move.l #(xdot<<16)|((xdot+7)/8-1),dreg1
  .endif
  moveq #ydot-1,dreg2
  .endm


;拡張外字フォント取得ルーチン
;in d0.b ... 文字コード(内部形式) 下位バイト
;   d1.b ... 文字コード(内部形式) 上位バイト
;   d2.b ... パターンの大きさ(6, 8, 12)
;out d0.l .... パターンのアドレス
;    d1.hw ... Xドット数
;    d1.w .... Xバイト数-1
;    d2.w .... Yドット数-1
ExchrHandler:
  cmpi.b #8,d2
  beq Exchr_8
  tst.b d2
  beq Exchr_8
  subq.b #6,d2
  beq Exchr_6
  bra Exchr_12

;24x24ドット
Exchr_12:
  move.l #FontBuffer24x24,d0
  SET_FONT_SIZE 24,24,d1,d2
  rts

;12x12ドット
Exchr_6:
  move.l #FontBuffer12x12,d0
  SET_FONT_SIZE 12,12,d1,d2
  rts

;16x16ドット
Exchr_8:
  lea (FontBuffer16x16,pc),a0
  PUSH d3/a0-a1

  ror.b #4,d1   ;左上
  bsr Copy8x8Into16x16
  addq.l #1,a0  ;右上
  ror.b #4,d1
  bsr Copy8x8Into16x16

  lea (2*8-1,a0),a0  ;左下
  move.b d0,d1
  ror.b #4,d1
  bsr Copy8x8Into16x16
  addq.l #1,a0  ;右下
  ror.b #4,d1
  bsr Copy8x8Into16x16

  POP d3/a0-a1
  move.l a0,d0
  SET_FONT_SIZE 16,16,d1,d2
  rts

Copy8x8Into16x16:
  moveq #$f,d2
  and d1,d2
  lsl #3,d2
  lea (HexFont8x8,pc,d2.w),a1
  .irp n,0,1,2,3,4,5,6,7
    move.b (a1)+,(n*2,a0)
  .endm
  rts


.quad
HexFont8x8:
  .dc.b %00000000  ;0
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %00000000

  .dc.b %00000000  ;1
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00001000
  .dc.b %00000000

  .dc.b %00000000  ;2
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %00111100
  .dc.b %01000000
  .dc.b %01000000
  .dc.b %00111110
  .dc.b %00000000

  .dc.b %00000000  ;3
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %01111100
  .dc.b %00000010
  .dc.b %00000010
  .dc.b %01111100
  .dc.b %00000000

  .dc.b %00000000  ;4
  .dc.b %01000100
  .dc.b %01000100
  .dc.b %00111110
  .dc.b %00000100
  .dc.b %00000100
  .dc.b %00000100
  .dc.b %00000000

  .dc.b %00000000  ;5
  .dc.b %00111110
  .dc.b %01000000
  .dc.b %00111100
  .dc.b %00000010
  .dc.b %00000010
  .dc.b %01111100
  .dc.b %00000000

  .dc.b %00000000  ;6
  .dc.b %00111110
  .dc.b %01000000
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %00000000

  .dc.b %00000000  ;7
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00000010
  .dc.b %00000010
  .dc.b %00000010
  .dc.b %00000000

  .dc.b %00000000  ;8
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %00000000

  .dc.b %00000000  ;9
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %00111110
  .dc.b %00000010
  .dc.b %00000010
  .dc.b %01111100
  .dc.b %00000000

  .dc.b %00000000  ;A
  .dc.b %00011000
  .dc.b %00100100
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %00000000

  .dc.b %00000000  ;B
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01111100
  .dc.b %00000000

  .dc.b %00000000  ;C
  .dc.b %00111100
  .dc.b %01000010
  .dc.b %01000000
  .dc.b %01000000
  .dc.b %01000010
  .dc.b %00111100
  .dc.b %00000000

  .dc.b %00000000  ;D
  .dc.b %01111100
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01000010
  .dc.b %01111100
  .dc.b %00000000

  .dc.b %00000000  ;E
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01000000
  .dc.b %01111110
  .dc.b %00000000

  .dc.b %00000000  ;F
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01111110
  .dc.b %01000000
  .dc.b %01000000
  .dc.b %01000000
  .dc.b %00000000

FontBuffer24x24:
  .dc.b %00000000,%00000000,%00000000
  .dc.b %01111111,%11111111,%11111110
  .dc.b %01100000,%00000000,%00000110
  .dc.b %01010000,%00000000,%00001010
  .dc.b %01001000,%00000000,%00010010
  .dc.b %01000100,%00000000,%00100010
  .dc.b %01000010,%00000000,%01000010
  .dc.b %01000001,%00000000,%10000010
  .dc.b %01000000,%10000001,%00000010
  .dc.b %01000000,%01000010,%00000010
  .dc.b %01000000,%00100100,%00000010
  .dc.b %01000000,%00011000,%00000010
  .dc.b %01000000,%00011000,%00000010
  .dc.b %01000000,%00100100,%00000010
  .dc.b %01000000,%01000010,%00000010
  .dc.b %01000000,%10000001,%00000010
  .dc.b %01000001,%00000000,%10000010
  .dc.b %01000010,%00000000,%01000010
  .dc.b %01000100,%00000000,%00100010
  .dc.b %01001000,%00000000,%00010010
  .dc.b %01010000,%00000000,%00001010
  .dc.b %01100000,%00000000,%00000110
  .dc.b %01111111,%11111111,%11111110
  .dc.b %00000000,%00000000,%00000000

FontBuffer12x12:
  .dc %000000000000<<4
  .dc %011111111110<<4
  .dc %011000000110<<4
  .dc %010100001010<<4
  .dc %010010010010<<4
  .dc %010001100010<<4
  .dc %010001100010<<4
  .dc %010010010010<<4
  .dc %010100001010<<4
  .dc %011000000110<<4
  .dc %011111111110<<4
  .dc %000000000000<<4

.quad
FontBuffer16x16:
  .ds.b 2*16

KeepEnd:
;ここまで常駐部


;ここから非常駐部
Start:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  moveq #0,d2
  tas d2  ;d2 = $0000_0080
  IOCS _SETFNTADR  ;拡張外字処理アドレスへのポインタを得る
  tst.l d0
  bpl @f
    DOS_PRINT (ExchrErrorMessage,pc)
    move #EXIT_FAILURE,-(sp)
    DOS _EXIT2
  @@:
  movea.l d0,a0
  lea (OldExchrVec,pc),a1
  move.l (a0),(a1)  ;現在の処理アドレスを退避(未使用)
  lea (ExchrHandler,pc),a1
  move.l a1,(a0)    ;新しい処理アドレスを設定

  DOS_PRINT (KeepMessage,pc)
  clr -(sp)
  pea (KeepEnd-KeepStart)
  DOS _KEEPPR


.data

ExchrErrorMessage: .dc.b 'IOCSが拡張外字に対応していません。',CR,LF,0
KeepMessage: .dc.b '常駐しました。',CR,LF,0


.end Start
