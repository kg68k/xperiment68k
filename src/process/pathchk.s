.title pathchk - DOS _EXEC (md=2)

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

.include xputil.mac


.cpu 68000
.text

Start:
  addq.l #1,a2
  SKIP_SPACE a2
  lea (FileBuffer,pc),a0
  STRCPY a2,a0

  clr.l -(sp)
  pea (CmdlineBuffer,pc)
  pea (FileBuffer,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  move.l d0,d7

  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  tst.l d7
  bmi @f
    DOS_PRINT (File,pc)
    DOS_PRINT (FileBuffer,pc)
    DOS_PRINT_CRLF

    DOS_PRINT (CmdlineLen,pc)
    move.b (CmdlineBuffer,pc),d0
    bsr Print$2
    DOS_PRINT_CRLF

    DOS_PRINT (CmdlineStr,pc)
    DOS_PRINT (CmdlineBuffer+1,pc)
    DOS_PRINT_CRLF
  @@:
  DOS _EXIT


  DEFINE_PRINT$2 Print$2
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

File: .dc.b 'file: ',0
CmdlineLen: .dc.b 'cmdline length: ',0
CmdlineStr: .dc.b 'cmdline string: ',0


.bss
.even

FileBuffer: .ds.b 256
CmdlineBuffer: .ds.b 256


.end
