.title ankfont - draw ANK fonts

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


TVRAM: .equ $00e00000
CRTC_R21: .equ $00e8002a

TEXTLINE_TO_BYTE_SHIFT: .equ 7
BYTES_PER_TEXTLINE: .equ 1<<TEXTLINE_TO_BYTE_SHIFT

CONSOLE_LINE_TO_TEXTLINE_SHIFT: .equ 4

FONT_HEIGHT: .equ 16

.cpu 68000
.text

ProgramStart:
  lea (IocsFntadr,pc),a0
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    lea (GetRomAnkFont,pc),a0
  @@:

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  IOCS _B_CUROFF
  bsr DrawAnkFontTable
  IOCS _B_CURON

  DOS _EXIT


IocsFntadr:
  moveq #8,d2
  IOCS _FNTADR
  movea.l d0,a1
  rts

GetRomAnkFont:
  lea ($00f3a800),a1  ;8x16 ANKフォント
  ext.l d1
  lsl #4,d1
  adda.l d1,a1
  rts


DRAW_CHAR: .macro fontAreg,vramAreg
  @i:=0
  .rept FONT_HEIGHT
    move.b (fontAreg)+,(@i*BYTES_PER_TEXTLINE,vramAreg)
    @i:=@i+1
  .endm
.endm

DrawAnkFontTable:
  PUSH d3-d7/a4-a5
  lea (a0),a4  ;フォント取得ルーチン
  lea (CRTC_R21),a5
  move (a5),d7

  lea (strHeader1,pc),a0
  bsr DrawLineAndCursorDown
  lea (strHeader2,pc),a0
  bsr DrawLineAndCursorDown

  moveq #0,d3
  moveq #0,d4  ;文字コード
  moveq #16-1,d6
  1:
    bsr GetTvramAddressAtCursorLine

    move d4,d0
    bsr GetHeaderRow
    bsr DrawLine

    move #%01_0011_0011,(a5)  ;プレーン0,1同時アクセス、ラスタコピー
    moveq #16-1,d5
    2:
      move d4,d1
      jsr (a4)  ;IOCS _FNTADR
      DRAW_CHAR a1,a0

      addq.l #2,a0  ;1文字ごとに間をあける
      addq.b #1,d4
    dbra d5,2b

    move d7,(a5)  ;CRTC R21を戻す
    IOCS _B_DOWN_S
  dbra d6,1b

  POP d3-d7/a4-a5
  rts

GetHeaderRow:
  lea (strHeaderRow,pc),a0
  lsr #4,d0
  move.b (HexTable,pc,d0.w),(.sizeof.('$'),a0)
  rts

HexTable: .dc.b '0123456789abcdef'
.even


DrawLineAndCursorDown:
  bsr DrawLine
  IOCS _B_DOWN_S
  rts

DrawLine:
  lea (a0),a2
  bsr GetTvramAddressAtCursorLine
  move #%01_0011_0000,(a5)  ;プレーン0,1同時アクセス、ラスタコピー
  bra 8f
  1:
    moveq #8,d2
    IOCS _FNTADR
    movea.l d0,a1
    DRAW_CHAR a1,a0
    addq.l #1,a0
  8:
  moveq #0,d1
  move.b (a2)+,d1
  bne 1b

  move d7,(a5)  ;CRTC R21を戻す
  rts


GetTvramAddressAtCursorLine:
  moveq #-1,d1
  IOCS _B_LOCATE
  bra GetTvramAddressAtConsoleLine

GetTvramAddressAtConsoleLine:
  lea (TVRAM),a0
  ext d0
  lsl #CONSOLE_LINE_TO_TEXTLINE_SHIFT,d0
  lsl.l #TEXTLINE_TO_BYTE_SHIFT,d0
  adda.l d0,a0
  rts


.data

strHeader1:
  .dc.b '    | 0 1 2 3 4 5 6 7 8 9 a b c d e f',0
strHeader2:
  .dc.b '----+--------------------------------',0

strHeaderRow:
  .dc.b '$00 | ',0


.end
