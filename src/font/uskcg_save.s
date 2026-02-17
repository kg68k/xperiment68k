.title uskcg_save - save all USKCG fonts to file

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
.include filesys.mac
.include iocsdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    PRINT_1LINE_USAGE 'usage: uskcg_save <file>'
    DOS _EXIT
  @@:
  lea (a2),a5  ;ファイル名

  lea (FontBuffer,pc),a0
  bsr GetUskcgFont
  move.l d0,d7  ;データサイズ

  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (a5)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d6
  bmi NewfileError

  move.l d7,-(sp)
  pea (FontBuffer,pc)
  move d6,-(sp)
  DOS _WRITE
  lea (10,sp),sp
  cmp.l d0,d7
  bne WriteError

  move d6,-(sp)
  DOS _CLOSE
  addq.l #2,sp

  DOS _EXIT


GetUskcgFont:
  move.l a0,-(sp)
  link a6,#-sizeof_FNT

  lea (strGenerator,pc),a1  ;ヘッダ
  lea (6,a0),a2
  STRCPY a1,a2
  lea (34,a0),a0  ;サイズ固定

  moveq #0,d0
  lea (sp),a1
  bsr GetUskFontAB

  moveq #0,d0
  lea (sp),a1
  bsr GetUskFontHalfWidth

  move #$ffff,(a0)+  ;フォントサイズを16x16ドットから24x24ドットへ切り換え

  moveq #12,d0
  lea (sp),a1
  bsr GetUskFontAB

  moveq #12,d0
  lea (sp),a1
  bsr GetUskFontHalfWidth

  unlk a6
  move.l a0,d0
  sub.l (sp)+,d0  ;データのバイト数
  rts


GetUskFontAB:
  PUSH d3/a3
  moveq #2*16/4-1,d2  ;16x16ドットフォントのパターンデータのロングワード数-1
  move d0,d1
  beq @f
    moveq #3*24/4-1,d2  ;24x24ドットフォントのパターンデータのロングワード数-1
  @@:
  swap d1
  lea (UskCodeTable,pc),a2
  bra 8f
  1:
    move (a2)+,d3  ;文字数
    subq #1,d3
    2:
      move d1,(a0)+  ;文字コード
      IOCS _FNTGET
      lea (FNT_BUF,a1),a3
      move d2,d0
      @@:
        move.l (a3)+,(a0)+  ;パターンデータ
      dbra d0,@b
      addq #1,d1
    dbra d3,2b
  8:
  move (a2)+,d1  ;文字コード
  bne 1b

  POP d3/a3
  rts


GetUskFontHalfWidth:
  moveq #1*16/4-1,d2  ;8x16ドットフォントのパターンデータのロングワード数-1
  move d0,d1
  beq @f
    moveq #2*24/4-1,d2  ;12x24ドットフォントのパターンデータのロングワード数-1
  @@:
  swap d1
  move #$f400,d1
  move #$100*2-1,d3
  1:
    move d1,(a0)+  ;文字コード
    IOCS _FNTGET
    lea (FNT_BUF,a1),a3
    move d2,d0
    @@:
      move.l (a3)+,(a0)+  ;パターンデータ
    dbra d0,@b
    addq #1,d1
  dbra d3,1b
  rts


NewfileError:
  lea (strDosNewfile,pc),a0
  bra Error
WriteError:
  lea (strDosWrite,pc),a0
  bra Error
Error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

.even
UskCodeTable:
  ;外字A
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

  ;外字B
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


strGenerator: .dc.b 'uskcg_save 1.0.0',0

strDosNewfile: .dc.b 'DOS _NEWFILE: ',0
strDosWrite:   .dc.b 'DOS _WRITE: ',0


.bss
.quad

FontBuffer:
  .ds.b 34  ;ヘッダ

  .ds.b (2+32)*188  ;外字A 16×16ドット
  .ds.b (2+32)*188  ;外字B 16×16ドット
  .ds.b (2+16)*256  ;$f4xx  8×16ドット
  .ds.b (2+16)*256  ;$f5xx  8×16ドット

  .ds.b 2  ;フォントサイズ切り替えコード

  .ds.b (2+72)*188  ;外字A 24×24ドット
  .ds.b (2+72)*188  ;外字B 24×24ドット
  .ds.b (2+48)*256  ;$f4xx 12×24ドット
  .ds.b (2+48)*256  ;$f5xx 12×16ドット

  .ds.b 1024  ;念の為


.end ProgramStart
