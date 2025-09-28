.title dos_getenv - DOS _GETENV

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

.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0  ;空文字列も許容する

  pea (Buffer,pc)
  clr.l -(sp)
  pea (a0)
  DOS _GETENV
  addq.l #12-4,sp
  move.l d0,(sp)+
  bmi error

  DOS_PRINT (Buffer,pc)
  DOS_PRINT_CRLF

  DOS _EXIT

error:
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.bss
.even

Buffer: .ds.b 256


.end ProgramStart
