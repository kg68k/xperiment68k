.title newvol - create new volume label

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

.include macro.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

Start:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (Usage,pc)
    DOS _EXIT
  @@:
  move #1<<FILEATR_VOLUME,-(sp)
  pea (a2)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d7
  bsr PrintResult

  DOS _EXIT


PrintResult:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  DOS_PRINT (Result,pc)
  move.l (sp)+,d0
  bsr PrintD0
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

Usage: .dc.b 'usage: newvol <name>',CR,LF,0
Result: .dc.b 'result = $',0
CrLf: .dc.b CR,LF,0


.bss

Buffer: .ds.b 64


.end
