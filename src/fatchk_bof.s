.title fatchk_bof - DOS _FATCHK buffer overflow PoC

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

.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


FATCHK_BUF_SIZE: .equ 16


.cpu 68000
.text

ProgramStart:
  lea ($c4,a0),a5  ;"fatchk_bof.x" in PSP

  moveq #0,d0
  lea (a5),a0
  bsr Fatchk

  moveq #2,d0
  lea (a5),a0
  bsr Fatchk

  moveq #2+4,d0
  lea (a5),a0
  bsr Fatchk

  DOS _EXIT


Fatchk:
  PUSH d2
  move.l d0,d2
  lea (a0),a1

  lea (FatChkBuf,pc),a0
  moveq #FATCHK_BUF_SIZE/2-1,d1
  moveq #-1,d0
  @@:
    move d0,(a0)+
  dbra d1,@b

  lea (LengthMessage,pc),a0
  bsr PrintA0
  move.l d2,d0
  bsr PrintD0l
  bsr PrintCrLf

  move d2,-(sp)
  pea (FatChkBuf,pc)
  tas (sp)  ;ori.l #$8000_0000,(sp)
  pea (a1)
  DOS _FATCHK
  lea (10,sp),sp
  move.l d0,d1

  lea (ResultMessage,pc),a0
  bsr PrintA0
  move.l d1,d0
  bsr PrintD0l
  bsr PrintCrLf

  moveq #FATCHK_BUF_SIZE,d0
  lea (FatChkBuf,pc),a0
  bsr DumpMemory

  POP d2
  rts


PrintA0:
  pea (a0)
  DOS _PRINT
  addq.l #4,sp
  rts

PrintCrLf:
  pea (CrLf,pc)
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


DumpMemory:
  PUSH d2/a2
  move d0,d2
  lsr #1,d2
  lea (a0),a2
  lea (Buffer,pc),a0
  subq #1,d2
  @@:
    move (a2)+,d0
    bsr ToHexString4
    move.b #' ',(a0)+
  dbra d2,@b
  clr.b -(a0)

  lea (Buffer,pc),a0
  bsr PrintA0
  bsr PrintCrLf

  POP d2/a2
  rts

  DEFINE_TOHEXSTRING4 ToHexString4


.data

LengthMessage: .dc.b 'length = ',0
ResultMessage: .dc.b 'result: $',0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 64

.quad
.ds 1
FatChkBuf: .ds.b FATCHK_BUF_SIZE


.end ProgramStart
