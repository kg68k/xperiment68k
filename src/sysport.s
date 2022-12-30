.title sysport - print system port

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

.include macro.mac
.include console.mac
.include doscall.mac

.xref DosBusErrByte

.cpu 68000
.text

Start:
  lea ($00e8e000),a2
  lea (headers,pc),a3
  moveq #$10-1,d7
  @@:
    lea (a2),a0
    lea (a3),a1
    bsr printSysPort
    addq.l #1,a2
    STRLEN a3,d0
    addq.l #1,d0
    adda.l d0,a3
  dbra d7,@b
  DOS _EXIT

printSysPort:
  pea (a1)
  DOS _PRINT
  addq.l #4,sp

  bsr DosBusErrByte
  beq @f
    pea (strBusErr,pc)
    DOS _PRINT
    addq.l #4,sp
    bra 9f
  @@:
    lea (buffer,pc),a0
    pea (a0)
    move.b #'$',(a0)+
    bsr toHexString2
    clr.b (a0)
    DOS _PRINT
    addq.l #4,sp
9:
  pea (crlf,pc)
  DOS _PRINT
  addq.l #4,sp
  rts


toHexString2:
  move.l d2,-(sp)
  moveq #2-1,d2
  @@:
    rol.b #4,d0
    moveq #$f,d1
    and.b d0,d1
    move.b (hexTable,pc,d1.w),(a0)+
  dbra d2,@b
  move.l (sp)+,d2
  rts


.data

.even
hexTable: .dc.b '0123456789abcdef'

headers:
  .dc.b '$00e8e000   n/a  : ',0
  .dc.b '$00e8e001 #1(r/w): ',0
  .dc.b '$00e8e002   n/a  : ',0
  .dc.b '$00e8e003 #2(r/w): ',0
  .dc.b '$00e8e004   n/a  : ',0
  .dc.b '$00e8e005 #3(  w): ',0
  .dc.b '$00e8e006   n/a  : ',0
  .dc.b '$00e8e007 #4(r/w): ',0
  .dc.b '$00e8e008   n/a  : ',0
  .dc.b '$00e8e009 #5(  w): ',0
  .dc.b '$00e8e00a   n/a  : ',0
  .dc.b '$00e8e00b #6(r  ): ',0
  .dc.b '$00e8e00c   n/a  : ',0
  .dc.b '$00e8e00d #7(  w): ',0
  .dc.b '$00e8e00e   n/a  : ',0
  .dc.b '$00e8e00f #8(  w): ',0

strBusErr: .dc.b 'bus error',0
crlf: .dc.b CR,LF,0


.bss

.even
buffer: .ds.b 16

.end
