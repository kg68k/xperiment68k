.title dos_maketmp - DOS _MAKETMP

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

.include macro.mac
.include dosdef.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  lea (Filename,pc),a1
  STRCPY a0,a1

  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (Filename,pc)
  DOS _MAKETMP
  addq.l #6,sp

  bsr PrintD0$4_4
  DOS_PRINT (Comma,pc)
  DOS_PRINT (Filename,pc)
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


PrintUsage:
  DOS_PRINT (Usage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

Usage: .dc.b 'usage: dos_maketmp filename',CR,LF,0
Comma: .dc.b ', ',0

CrLf: .dc.b CR,LF,0


.bss
.quad

Filename: .ds.b 256


.end ProgramStart
