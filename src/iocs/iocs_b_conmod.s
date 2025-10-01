.title iocs_b_conmod - IOCS _B_CONMOD

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

.include fefunc.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  bsr ParseInt
  move.l d0,d1  ;モード
  .irp %md,0,1,2,3,16,17,18
    moveq #%md,d0
    cmp.l d0,d1
    beq b_conmod_%md
  .endm
PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT


b_conmod_0:
b_conmod_1:
b_conmod_17:
b_conmod_18:
  IOCS _B_CONMOD
  DOS _EXIT

b_conmod_2:
  SKIP_SPACE a0
  beq PrintUsage
  FPACK __STOH
  bcs NumberError
  move.l d0,d2
  IOCS _B_CONMOD
  DOS _EXIT

b_conmod_3:
  lea (CursorBuffer,pc),a1
  moveq #(16+16)/4-1,d2  ;プレーン0、1の各16バイトを4バイト単位で指定する
  @@:
    SKIP_SPACE a0
    beq PrintUsage
    FPACK __STOH
    bcs NumberError
    move.l d0,(a1)+
  dbra d2,@b

  move.l #CursorBuffer,d2
  IOCS _B_CONMOD
  DOS _EXIT

b_conmod_16:
  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseInt
  move.l d0,d2
  IOCS _B_CONMOD
  DOS _EXIT


NumberError:
  FATAL_ERROR '数値の指定が正しくありません。'


  DEFINE_PARSEINT ParseInt


.data

strUsage:
  .dc.b 'usage: iocs_b_conmod <md> ...',CR,LF
  .dc.b '   0 ... カーソル点滅許可',CR,LF
  .dc.b '   1 ... カーソル点滅禁止',CR,LF
  .dc.b '   2 <hex> ... カーソルパターン指定',CR,LF
  .dc.b '   3 <hex hex hex hex> <hex hex hex hex> ... カーソルパターン定義',CR,LF
  .dc.b '  16 <n> ... スムーススクロール指定(n = 0..3)',CR,LF
  .dc.b '  17 ... ラスタコピースクロール指定',CR,LF
  .dc.b '  18 ... ソフトコピースクロール指定',CR,LF
  .dc.b 0


.bss

.even
CursorBuffer: .ds.b 16


.end ProgramStart
