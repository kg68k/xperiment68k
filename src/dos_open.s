.title dos_open - DOS _OPEN

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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
  beq NoArgError

  DOS_PRINT (ArgMessage,pc)
  DOS_PRINT (a0)
  bsr PrintCrLf

  clr -(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7

  DOS_PRINT (ResultMessage,pc)
  move.l d7,d0
  bsr PrintD0
  bsr PrintCrLf

  DOS _EXIT

NoArgError:
  DOS_PRINT (NoArgMessage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


PrintCrLf:
  DOS_PRINT (CrLf,pc)
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

NoArgMessage: .dc.b 'no filename',13,10,0
ArgMessage: .dc.b 'argument: ',0
ResultMessage: .dc.b 'result: $',0
CrLf: .dc.b 13,10,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart
