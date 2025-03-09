.title dos_curdir - DOS _CURDIR

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

.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d7  ;ドライブ名省略時はカレントドライブ
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    moveq #$20,d0
    or.b (a0),d0
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
    bsr PrintD0$4_4
    bra exit
  @@:
  DOS_PRINT (CurdirBuffer,pc)
exit:
  DOS_PRINT (CrLf,pc)
  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

CrLf: .dc.b CR,LF,0


.bss

CurdirBuffer: .ds.b 65


.end ProgramStart
