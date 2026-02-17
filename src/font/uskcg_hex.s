.title uskcg_hex - uskcg font generator (hex)

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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
.include iocsdef.mac

.include xputil.mac


HEX_CHARS: .reg '0123456789ABCDEF'


.cpu 68000
.text

ProgramStart:
  lea (HexFont8x8,pc),a0
  bsr GetHexFont8x8

  lea (HexFont12x12Left,pc),a0
  lea (HexFont12x12Right,pc),a1
  bsr GetHexFont12x12

  bsr SetUskFonts
  DOS _EXIT


GetHexFont8x8:
  link a6,#-sizeof_FNT
  lea (HexTable,pc),a2
  move.l #0<<16+$f000,d1  ;フォントサイズ8x16、上付き1/4角片仮名
  moveq #16-1,d2
  @@:
    move.b (a2)+,d1  ;文字コード $f0xx
    lea (sp),a1
    IOCS _FNTGET
    addq.l #FNT_BUF,a1
    .rept 8  ;上半分だけ読み込む
      move.b (a1)+,(a0)+
    .endm
  dbra d2,@b
  unlk a6
  rts


GetHexFont12x12:
  PUSH d3/a3
  link a6,#-sizeof_FNT
  lea (a0),a2  ;左用バッファ
  lea (a1),a3  ;右用バッファ
  lea (HexTable,pc),a0
  move.l #12<<16+$f000,d1  ;フォントサイズ12x24、上付き1/4角片仮名
  moveq #16-1,d3
  1:
    move.b (a0)+,d1  ;文字コード $f0xx
    lea (sp),a1
    IOCS _FNTGET
    addq.l #FNT_BUF,a1
    moveq #12-1,d2  ;上半分だけ読み込む
    @@:
      move (a1)+,d0  ;%ffff_ffff_ffff_0000
      move d0,(a2)+  ;左側描画用

      lsr #4,d0      ;%0000_ffff_ffff_ffff
      move d0,(a3)+  ;右側描画用
    dbra d2,@b
  dbra d3,1b
  unlk a6
  POP d3/a3
  rts


SetUskFonts:
  lea (UskCodeTable,pc),a5
  bra 8f
  1:
    move (a5)+,d6  ;文字数
    subq #1,d6
    2:
      move d7,d0
      bsr SetUskFont16x16
      move d7,d0
      bsr SetUskFont24x24
      addq #1,d7
    dbra d6,2b
  8:
  move (a5)+,d7  ;文字コード
  bne 1b
  rts


SetUskFont16x16:
  move.l d7,-(sp)
  link a6,#-2*16
  move d0,d7
  lea (sp),a0
  bsr CreateUskFont16x16
  moveq #8,d1
  swap d1     ;フォントサイズ16x16
  move d7,d1  ;文字コード
  lea (sp),a1
  IOCS _DEFCHR
  unlk a6
  move.l (sp)+,d7
  rts


CreateUskFont16x16:
  bsr @f  ;$H___ を左上に、$_I__ を右上に描画
  bra @f  ;$__J_ を左下に、$___K を右下に描画
@@:
  bsr getFont8x8
  lea (a1),a2
  bsr getFont8x8
  .rept 8
    move.b (a2)+,(a0)+
    move.b (a1)+,(a0)+
  .endm
  rts

getFont8x8:
  lea (HexFont8x8,pc),a1
  rol #4,d0
  moveq #$f,d1
  and d0,d1
  lsl #3,d1  ;*8
  adda.l d1,a1
  rts


SetUskFont24x24:
  move.l d7,-(sp)
  link a6,#-3*24
  move d0,d7
  lea (sp),a0
  bsr CreateUskFont24x24
  moveq #12,d1
  swap d1     ;フォントサイズ24x24
  move d7,d1  ;文字コード
  lea (sp),a1
  IOCS _DEFCHR
  unlk a6
  move.l (sp)+,d7
  rts


CreateUskFont24x24:
  bsr @f  ;$H___ と $_I__ を合成して上半分に描画
  bra @f  ;$__J_ と $___K を合成して下半分に描画
@@:
  lea (HexFont12x12Left,pc),a1
  bsr getFont12x12
  lea (a1),a2

  lea (HexFont12x12Right,pc),a1
  bsr getFont12x12
  moveq #12-1,d2
  @@:
    move.b (a2)+,(a0)+  ;左側文字の左8ドット
    move.b (a2)+,d1     ;左側文字の右4ドット
    or.b (a1)+,d1       ;右側文字の左4ドット
    move.b d1,(a0)+
    move.b (a1)+,(a0)+  ;右側文字の右8ドット
  dbra d2,@b
  rts

getFont12x12:
  rol #4,d0
  moveq #$f,d1
  and d0,d1
  mulu #2*12,d1
  adda.l d1,a1
  rts


.data

.even
UskCodeTable:
  .dc $869f,1
  .dc $86a0,16
  .dc $86b0,16
  .dc $86c0,16
  .dc $86d0,16
  .dc $86e0,16
  .dc $86f0,13  ;～$86fc
  .dc $8740,16
  .dc $8750,16
  .dc $8760,16
  .dc $8770,15  ;～$877e
  .dc $8780,16
  .dc $8790,15  ;～$879e
  .dc $eb9f,1
  .dc $eba0,16
  .dc $ebb0,16
  .dc $ebc0,16
  .dc $ebd0,16
  .dc $ebe0,16
  .dc $ebf0,13  ;～$ebfc
  .dc $ec40,16
  .dc $ec50,16
  .dc $ec60,16
  .dc $ec70,15  ;～$ec7e
  .dc $ec80,16
  .dc $ec90,15  ;～$ec9e
  .dc 0

HexTable: .dc.b HEX_CHARS


.bss
.quad

HexFont8x8:
  .ds.b (1*8)*.sizeof.(HEX_CHARS)

HexFont12x12Left:
  .ds.b (2*12)*.sizeof.(HEX_CHARS)

HexFont12x12Right:
  .ds.b (2*12)*.sizeof.(HEX_CHARS)


.end ProgramStart
