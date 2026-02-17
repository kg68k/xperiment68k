.title uskcg24 - draw uskcg table with 24dot font

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

.include xputil.mac

FILLER_CHAR: .reg '**'


TVRAM: .equ $00e00000
CRTC_R21: .equ $00e8002a

TEXTLINE_TO_BYTE_SHIFT: .equ 7
BYTES_PER_TEXTLINE: .equ 1<<TEXTLINE_TO_BYTE_SHIFT

CONSOLE_WIDTH:  .equ 768
CONSOLE_HEIGHT: .equ 512
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

  lea (Header,pc),a0
  lea (HeaderEnd,pc),a1
  move.l d6,d0
  bsr PrintLines
  move.l d0,d6

  move.l d7,d0
  bsr getText
  move.l d6,d0
  bsr PrintLines

  moveq #CONSOLE_FONT_HEIGHT,d2  ;-1すると表示ライン数が16の倍数のとき隙間がなくなるが
  add d0,d2                      ;コマンドプロンプトと密接して見づらいので隙間をあける
  lsr #CONSOLE_LINE_TO_TEXTLINE_SHIFT,d2
  moveq #0,d1
  IOCS _B_LOCATE

  IOCS _B_CURON
  DOS _EXIT


getText:
  cmpi #2,d0
  bhi @f
    lea (CodeTableA,pc),a0  ;1 -> A
    bcs CreateDumpList
      lea (CodeTableB,pc),a0  ;2 -> B
      bra CreateDumpList
  @@:
  bsr CreateCodeTable  ;$8000, $f000～$f500
  bra CreateDumpList


CreateCodeTable:
  lea (CodeTableBuffer,pc),a0
  moveq #0<<16+16,d1  ;スキップ文字数0、表示文字数16
  moveq #16-1,d2
  @@:
    move d0,(a0)+  ;文字コード
    move.l d1,(a0)+
    addi #16,d0
  dbra d2,@b
  lea (CodeTableBuffer,pc),a0
  rts


CreateDumpList:
  PUSH d3-d4
  lea (a0),a1
  lea (DumpListBuffer,pc),a0
  bra 8f
  1:
    bpl 7f  ;文字コード $00ff は空行
      move d3,d0
      bsr WriteIndex

      moveq #16,d4  ;残り文字数
      move (a1)+,d0  ;スキップ文字数
      beq @f
        sub d0,d4
        bsr WriteSkipChars
      @@:
      move (a1)+,d0  ;表示文字数(>0)
      sub d0,d4
      bsr WritePrintChars
      move d4,d0  ;残りのスキップ文字数
      beq @f
        bsr WriteSkipChars
      @@:
      subq.l #1,a0  ;最後の空白を消す
    7:
    clr.b (a0)+
  8:
  move (a1)+,d3  ;文字コード($xxx0)
  bne 1b

  ;文字コード $0000 はテーブル終了
  lea (a0),a1  ;末尾
  lea (DumpListBuffer,pc),a0  ;先頭
  POP d3-d4
  rts

WriteIndex:
  move.b #' ',(a0)+
  bsr ToHexString$4
  move.b #'│'>>8,(a0)+
  move.b #'│'.and.$ff,(a0)+
  rts

WriteSkipChars:
  subq #1,d0
  @@:
    move.b #FILLER_CHAR>>8,(a0)+
    move.b #FILLER_CHAR.and.$ff,(a0)+
    addq #1,d3
    move.b #' ',(a0)+
  dbra d0,@b
  rts

WritePrintChars:
  moveq #0,d1
  cmpi #$f000,d3
  bcc 1f
    move d3,-(sp)
    cmpi.b #$80,(sp)+
    bne @f
      1:
      moveq #' ',d1
  @@:
  subq #1,d0
  1:
    tst.b d1
    beq @f
      move.b d1,(a0)+  ;表示幅が半角なので空白を追加する
    @@:
    move d3,-(sp)
    move.b (sp)+,(a0)+
    move.b d3,(a0)+
    addq #1,d3
    move.b #' ',(a0)+
  dbra d0,1b
  rts


AnalyzeArgument:
  moveq #0,d0
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
    cmpi.b #'0',d0
    bcs @f
      cmpi.b #'5',d0
      bhi @f
        addi #$f0-'0',d0
        lsl #8,d0
        rts
    @@:
    cmpi.b #'8',d0
    bne @f
      move #$8000,d0
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


  DEFINE_TOHEXSTRING$4 ToHexString$4


.data

CT_NEWLINE:   .equ $00ff
CT_TABLE_END: .equ $0000

.even
CodeTableA:
  .dc $8690,15, 1  ;$869f
  .dc $86a0, 0,16
  .dc $86b0, 0,16
  .dc $86c0, 0,16
  .dc $86d0, 0,16
  .dc $86e0, 0,16
  .dc $86f0, 0,13  ;～$86fc
  .dc CT_NEWLINE
  .dc $8740, 0,16
  .dc $8750, 0,16
  .dc $8760, 0,16
  .dc $8770, 0,15  ;～$877e
  .dc $8780, 0,16
  .dc $8790, 0,15  ;～$879e
  .dc CT_TABLE_END

CodeTableB:
  .dc $eb90,15, 1  ;$eb9f
  .dc $eba0, 0,16
  .dc $ebb0, 0,16
  .dc $ebc0, 0,16
  .dc $ebd0, 0,16
  .dc $ebe0, 0,16
  .dc $ebf0, 0,13  ;～$ebfc
  .dc CT_NEWLINE
  .dc $ec40, 0,16
  .dc $ec50, 0,16
  .dc $ec60, 0,16
  .dc $ec70, 0,15  ;～$ec7e
  .dc $ec80, 0,16
  .dc $ec90, 0,15  ;～$ec9e
  .dc CT_TABLE_END

Header:
  .dc.b '      │+0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +a +b +c +d +e +f',0
  .dc.b '───┼────────────────────────',0
HeaderEnd:

Usage:
  .dc.b 'uskcg24: 外字の一覧を24ドットフォントで表示します。',CR,LF
  .dc.b '  a ... 外字A',CR,LF
  .dc.b '  b ... 外字B',CR,LF
  .dc.b '  4 ... 半角外字 $f400-$f4ff',CR,LF
  .dc.b '  5 ... 半角外字 $f500-$f5ff',CR,LF
  .dc.b 0


.bss
.quad

CompositeBuffer: .ds.b BYTES_PER_TEXTLINE*FONT_HEIGHT

DumpListBuffer: .ds.b (CONSOLE_WIDTH/FONT_WIDTH_HALF*2)*(CONSOLE_HEIGHT/FONT_HEIGHT)

.even
CodeTableBuffer: .ds.w 3*16+1


.end
