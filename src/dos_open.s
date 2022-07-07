.title dosopen - DOS _OPEN

# This file is part of Xperiment68k
# Copyright (C) 2022 TcbnErik
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


.include console.mac
.include doscall.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr SkipBlank
  tst.b (a0)
  beq NoArgError

  pea (ArgMessage,pc)
  DOS _PRINT
  pea (a0)
  DOS _PRINT
  addq.l #8,sp
  bsr PrintCrLf

  clr -(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7

  pea (ResultMessage,pc)
  DOS _PRINT
  addq.l #4,sp
  move.l d7,d0
  bsr PrintD0
  bsr PrintCrLf

  DOS _EXIT

NoArgError:
  pea (NoArgMessage,pc)
  DOS _PRINT
  move #1,-(sp)
  DOS _EXIT2


SkipBlank:
  @@:
    move.b (a0)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @b
    cmpi.b #TAB,d0
    beq @b
  @@:
  subq.l #1,a0
  rts


PrintCrLf:
  pea (CrLf,pc)
  DOS _PRINT
  addq.l #4,sp
  rts

PrintD0:
  lea (Buffer,pc),a0
  pea (a0)
  bsr ToHexString
  DOS _PRINT
  addq.l #4,sp
  rts

ToHexString:
  bsr ToHexString4
  move.b #'_',(a0)+
  bsr ToHexString4
  clr.b (a0)
  rts

ToHexString4:
  moveq #4-1,d2
  @@:
    rol.l #4,d0
    moveq #$f,d1
    and.b d0,d1
    move.b (HexTable,pc,d1.w),(a0)+
  dbra d2,@b
  rts


.data
.quad

HexTable: .dc.b '0123456789abcdef'

NoArgMessage: .dc.b 'no filename',13,10,0
ArgMessage: .dc.b 'argument: ',0
ResultMessage: .dc.b 'result: $',0
CrLf: .dc.b 13,10,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart
