.title openkeep - open file and keeppr

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

Start:
  bra.s @f
    FileHandle: .dc 0
    .dc.b 'openkeep',0
    .align 16,0
End:  ;常駐部末尾
  @@:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    PRINT_1LINE_USAGE 'usage: openkeep <file>'
    bra error
  @@:

  clr -(sp)
  pea (a2)
  DOS _OPEN
  addq.l #6,sp
  tst.l d0
  bpl @f
    DOS_PRINT (OpenErrorMessage,pc)
    bra error
  @@:
  move d0,(FileHandle)

  clr -(sp)
  pea (End-Start).w
  DOS _KEEPPR

error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


.data

OpenErrorMessage: .dc.b 'file open error',CR,LF,0


.end
