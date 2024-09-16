.title dos_create - DOS _CREATE

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  beq NoArgError

  moveq #1<<FILEATR_ARCHIVE,d0
  lea (a2),a0
  bsr CreateFile

  DOS _EXIT


NoArgError:
  DOS_PRINT (NoArgMessage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


CreateFile:
  move d0,-(sp)
  pea (a0)
  DOS _CREATE
  addq.l #6,sp

  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

NoArgMessage: .dc.b 'no filename',CR,LF,0


.end ProgramStart
