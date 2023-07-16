.title dos_curdir - DOS _CURDIR

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

.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d7  ;ドライブ名省略時はカレントドライブ
  lea (1,a2),a0
  bsr SkipBlank
  move.b (a0),d0
  beq @f
    ori.b #$20,d0
    subi.b #'a',d0
    cmpi.b #'z'-'a',d0
    bhi @f
      addq.b #1,d0
      move.b d0,d7
  @@:
  pea (CurdirBuffer,pc)
  move d7,-(sp)
  DOS _CURDIR
  addq.l #6,sp
  tst.l d0
  bpl @f
    move.l d0,-(sp)
    DOS_PRINT (Error,pc)
    move.l (sp)+,d0
    bsr PrintD0
    bra exit
  @@:
  DOS_PRINT (CurdirBuffer,pc)
exit:
  DOS_PRINT (CrLf,pc)
  DOS _EXIT


SkipBlank:
  @@:
    move.b (a0)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @b
  @@:
  subq.l #1,a0
  rts


PrintD0:
  lea (Buffer,pc),a0
  pea (a0)
  bsr ToHexString4_4
  DOS _PRINT
  addq.l #4,sp
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

CrLf: .dc.b CR,LF,0
Error: .dc.b 'error $',0


.bss

Buffer: ;.ds.b 64
CurdirBuffer: .ds.b 65


.end ProgramStart
