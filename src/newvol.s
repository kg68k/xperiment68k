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

  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

Usage: .dc.b 'usage: newvol <name>',CR,LF,0


.end
