.title getassign - DOS _ASSIGN (MD = 0; getassign)

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0

  pea (Buffer,pc)
  pea (a0)
  move #ASSIGNMD_GET,-(sp)
  DOS _ASSIGN
  lea (10,sp),sp
  move.l d0,d7

  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  tst.l d7
  bmi @f
    DOS_PRINT (Buffer,pc)
    DOS_PRINT_CRLF
  @@:
  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.bss
.even

Buffer: .ds.b 256


.end ProgramStart
