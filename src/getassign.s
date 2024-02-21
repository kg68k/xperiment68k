.title getassign - DOS _ASSIGN (MD = 0; getassign)

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0

  pea (Buffer2,pc)
  pea (a0)
  move #ASSIGNMD_GET,-(sp)
  DOS _ASSIGN
  lea (10,sp),sp
  move.l d0,d7

  bsr PrintD0
  DOS_PRINT (CrLf,pc)

  tst.l d7
  bmi @f
    DOS_PRINT (Buffer2,pc)
    DOS_PRINT (CrLf,pc)
  @@:
  DOS _EXIT


PrintD0:
  lea (Buffer,pc),a0
  pea (a0)
  move.b #'$',(a0)+
  bsr ToHexString4_4
  DOS _PRINT
  addq.l #4,sp
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

CrLf: .dc.b CR,LF,0


.bss
.even

Buffer:  .ds.b 256
Buffer2: .ds.b 256


.end ProgramStart
