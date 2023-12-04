.title pathchk - DOS _EXEC (md=2)

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

  lea (Buffer,pc),a0
  bsr ToHexString4_4
  lea (Result,pc),a0
  lea (Buffer,pc),a1
  bsr printLine

  tst.l d7
  bmi @f
    lea (File,pc),a0
    lea (FileBuffer,pc),a1
    bsr printLine

    moveq #0,d0
    move.b (CmdlineBuffer,pc),d0
    lea (Buffer,pc),a0
    bsr ToHexString2
    lea (CmdlineLen,pc),a0
    lea (Buffer,pc),a1
    bsr printLine

    lea (CmdlineStr,pc),a0
    lea (CmdlineBuffer+1,pc),a1
    bsr printLine
  @@:
  DOS _EXIT


printLine:
  DOS_PRINT (a0)
  DOS_PRINT (a1)
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

Result:  .dc.b 'result: $',0
File:    .dc.b 'file: ',0
CmdlineLen: .dc.b 'cmdline length: $',0
CmdlineStr: .dc.b 'cmdline string: ',0

CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 64

FileBuffer: .ds.b 256
CmdlineBuffer: .ds.b 256


.end
