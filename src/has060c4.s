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

.include include/console.mac
.include include/doscall.mac

.include include/xputil.mac

.cpu 68000
.text

ProgramStart:
  suba.l a0,a0
  adda.w #$8000.w,a0  ;符号拡張した #$ffff_8000 をa0.l(=0)に加算する
  move.l a0,d0
  move.l a0,d6
  lea (adda8000w,pc),a0
  bsr printResult

  suba.l a0,a0
  adda.w #$8000,a0  ;HAS060.X v3.09+89 -c4 で suba.w #$8000,a0 に変更されてしまう
  move.l a0,d0
  move.l a0,d7
  lea (adda8000,pc),a0
  bsr printResult

  moveq #0,d0
  cmp.l d6,d7
  beq @f
    moveq #1,d0
  @@:
  move d0,-(sp)
  DOS _EXIT2


printResult:
  move.l d0,-(sp)
  bsr PrintA0
  move.l (sp)+,d0
  bsr PrintD0l
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


.data
.even

adda8000w: .dc.b 'suba.l a0,a0 || adda.w #$8000.w,a0 ... a0 = $',0
adda8000:  .dc.b 'suba.l a0,a0 || adda.w #$8000,a0 ..... a0 = $',0

NewLine: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 96


.end ProgramStart
