.title dos_getenv - DOS _GETENV

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

.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    DOS_PRINT (Usage,pc)
    bra error2
  @@:

  pea (Buffer,pc)
  clr.l -(sp)
  pea (a0)
  DOS _GETENV
  addq.l #12-4,sp
  move.l d0,(sp)+
  bmi error

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)

  DOS _EXIT

error:
  bsr PrintD0
  DOS_PRINT (CrLf,pc)
error2:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


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

Usage: .dc.b 'usage: dos_getenv <name>'
CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 256


.end ProgramStart
