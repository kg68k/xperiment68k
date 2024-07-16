.title dos_namests - DOS _NAMESTS

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

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2

  DOS_PRINT (ArgMessage,pc)
  DOS_PRINT (a2)
  bsr PrintCrLf

  pea (NamestsBuffer,pc)
  pea (a2)
  DOS _NAMESTS
  addq.l #8,sp

  move.l d0,d7

  DOS_PRINT (ResultMessage,pc)
  move.l d7,d0
  bsr PrintD0
  bsr PrintCrLf

  tst.l d7
  bmi @f
    lea (NamestsBuffer,pc),a0
    bsr PrintNamests
  @@:

  DOS _EXIT


PrintNamests:
  PUSH a2-a3
  lea (a0),a3

  lea (WildMessage,pc),a0
  move.b (NAMESTS_Wild,a3),d0
  bsr PrintNamestsD0b

  lea (DriveMessage,pc),a0
  move.b (NAMESTS_Drive,a3),d0
  bsr PrintNamestsD0b

  lea (PathMessage,pc),a0
  lea (NAMESTS_Path,a3),a1
  lea (sizeof_NAMESTS_Path,a1),a2
  bsr PrintNamestsSub

  lea (Name1Message,pc),a0
  lea (NAMESTS_Name1,a3),a1
  lea (sizeof_NAMESTS_Name1,a1),a2
  bsr PrintNamestsSub

  lea (ExtMessage,pc),a0
  lea (NAMESTS_Ext,a3),a1
  lea (sizeof_NAMESTS_Ext,a1),a2
  bsr PrintNamestsSub

  lea (Name2Message,pc),a0
  lea (NAMESTS_Name2,a3),a1
  lea (sizeof_NAMESTS_Name2,a1),a2
  bsr PrintNamestsSub

  POP a2-a3
  rts

PrintNamestsD0b:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0

  lea (Buffer,pc),a0
  bsr ToHexString2
  DOS_PRINT (Buffer,pc)
  bra PrintCrLf

PrintNamestsSub:
  DOS_PRINT (a0)
  move.b (a2),d1
  clr.b (a2)
  DOS_PRINT (a1)
  move.b d1,(a2)
  bra PrintCrLf

PrintCrLf:
  DOS_PRINT (CrLf,pc)
  rts

PrintD0:
  lea (Buffer,pc),a0
  bsr ToHexString4_4

  DOS_PRINT (Buffer,pc)
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4
  DEFINE_TOHEXSTRING2 ToHexString2


.data

ArgMessage:    .dc.b 'argument: ',0
ResultMessage: .dc.b 'result:   $',0
CrLf: .dc.b CR,LF,0

WildMessage:  .dc.b 'Wildcard: $',0
DriveMessage: .dc.b 'Drive:    $',0
PathMessage:  .dc.b 'Path:  ',0
Name1Message: .dc.b 'Name1: ',0
ExtMessage:   .dc.b 'Ext:   ',0
Name2Message: .dc.b 'Name2: ',0


.bss
.quad

Buffer: .ds.b 64

NamestsBuffer: .ds.b sizeof_NAMESTS+1
.even


.end ProgramStart
