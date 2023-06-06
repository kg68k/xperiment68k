.title has060c4 - validate HAS060.X -c4

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

.include include/macro.mac
.include include/fefunc.mac
.include include/console.mac
.include include/doscall.mac

.include include/xputil.mac

.cpu 68000
.text

ProgramStart:
  bsr PrintAssemblerVersion

  bsr testAdda8000
  move d0,d7
  bsr PrintSeparator
  bsr testSuba8000
  or d0,d7

  move d7,-(sp)
  DOS _EXIT2


testAdda8000:
  PUSH d6-d7

  suba.l a0,a0
  adda.w #$8000.w,a0  ;符号拡張した #$ffff_8000 を加算する
  move.l a0,d7

  suba.l a0,a0
  adda.w #$8000,a0  ;HAS060.X v3.09+89 -c4 では suba.w #$8000,a0 に変更されてしまう
  move.l a0,d6

  move.l d7,d0
  lea (adda8000w,pc),a0
  bsr printResult
  move.l d6,d0
  lea (adda8000,pc),a0
  bsr printResult

  moveq #0,d0
  cmp.l d6,d7
  beq @f
    moveq #1,d0
  @@:
  POP d6-d7
  rts


testSuba8000:
  PUSH d6-d7

  suba.l a0,a0
  suba.w #$8000.w,a0  ;符号拡張した #$ffff_8000 を減算する
  move.l a0,d7

  suba.l a0,a0
  suba.w #$8000,a0  ;HAS060.X v3.09+89 -c4 では lea ($8000,a0),a0 に変更されてしまう
  move.l a0,d6

  move.l d7,d0
  lea (suba8000w,pc),a0
  bsr printResult
  move.l d6,d0
  lea (suba8000,pc),a0
  bsr printResult

  moveq #0,d0
  cmp.l d6,d7
  beq @f
    moveq #1,d0
  @@:
  POP d6-d7
  rts


printResult:
  move.l d0,-(sp)
  bsr PrintA0
  move.l (sp)+,d0
  bsr PrintD0l
  bsr PrintNewLine
  rts

PrintSeparator:
  lea (Separator,pc),a0
  bsr PrintA0
  rts


PrintAssemblerVersion:
  .ifdef __HAS__
    lea (hasIs,pc),a0
    bsr PrintA0
    move.l #__HAS__,d0
    bsr PrintD0dec
  .else
    lea (hasNotDefined,pc),a0
    bsr PrintA0
  .endif

  .ifdef __HAS060__
    lea (has060Is,pc),a0
    bsr PrintA0
    move.l #__HAS060__,d0
    bsr PrintD0dec
  .endif

  .ifdef __HAS060X__
    lea (has060xIs,pc),a0
    bsr PrintA0
    move.l #__HAS060X__,d0
    bsr PrintD0l
  .endif

  bsr PrintNewLine
  rts


PrintA0:
  pea (a0)
  DOS _PRINT
  addq.l #4,sp
  rts

PrintNewLine:
  pea (NewLine,pc)
  DOS _PRINT
  addq.l #4,sp
  rts

PrintD0l:
  lea (Buffer,pc),a0
  bsr ToHexString4_4

  lea (Buffer,pc),a0
  bsr PrintA0
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


PrintD0dec:
  lea (Buffer,pc),a0
  FPACK __LTOS
  lea (Buffer,pc),a0
  bsr PrintA0
  rts


.data
.even

adda8000w: .dc.b 'suba.l a0,a0 || adda.w #$8000.w,a0 ... a0 = $',0
adda8000:  .dc.b 'suba.l a0,a0 || adda.w #$8000,a0 ..... a0 = $',0
suba8000w: .dc.b 'suba.l a0,a0 || suba.w #$8000.w,a0 ... a0 = $',0
suba8000:  .dc.b 'suba.l a0,a0 || suba.w #$8000,a0 ..... a0 = $',0

.ifndef __HAS__
hasNotDefined: .dc.b '__HAS__ is not defined.',0
.endif
hasIs:     .dc.b '__HAS__ = ',0
has060Is:  .dc.b ', __HAS060__ = ',0
has060xIs: .dc.b ', __HAS060X__ = $',0

Separator: .dc.b '----------------------------------------------------------------'  ;,CR,LF,0
NewLine: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 96


.end ProgramStart
