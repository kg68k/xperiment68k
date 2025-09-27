.title rewind - DOS _SEEK to position -1 from the end of the file

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
  bne @f
    PRINT_1LINE_USAGE 'usage: rewind <filename>'
    bra error
  @@:

  clr -(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  bpl @f
    DOS_PRINT (FileOpenErrorMessage,pc)
    move.l d7,d0
    bsr PrintD0$4_4
    DOS_PRINT (CrLf,pc)
    bra error
  @@:
  move #SEEKMODE_END,-(sp)
  pea (-1)
  move d7,-(sp)
  DOS _SEEK
  addq.l #8,sp

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT

error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

FileOpenErrorMessage: .dc.b 'file open error: ',0

CrLf: .dc.b CR,LF,0


.end ProgramStart
