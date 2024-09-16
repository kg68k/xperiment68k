.title exfiles - DOS _FILES (EX mode)

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

.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    lea (DefaultFindPath,pc),a2
  @@:

  DOS_PRINT (Argument,pc)
  DOS_PRINT (a2)
  DOS_PRINT (CrLf,pc)

  move #$00ff,-(sp)
  pea (a2)
  pea (FilesBuffer,pc)
  tas (sp)  ;バッファの最上位ビットを%1にする
  DOS _FILES
  lea (10,sp),sp
  move.l d0,d7

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  DOS_PRINT (FilesFound,pc)
  lea (FilesBuffer,pc),a0
  tst.l d7
  bmi @f
    DOS_PRINT (FILES_FileName,a0)
  @@:
  DOS_PRINT (CrLf,pc)

  bsr PrintExfilesData

  DOS _EXIT


PrintExfilesData:
  move.l a3,-(sp)
  lea (a0),a3

  DOS_PRINT (ExfilesPath,pc)
  DOS_PRINT (FILES_EX_Drive,a3)
  DOS_PRINT (CrLf,pc)

  lea (ExfilesName1,pc),a0
  lea (FILES_EX_Name1,a3),a1
  lea (sizeof_FILES_EX_Name1,a1),a2
  bsr PrintNamestsSub

  lea (ExfilesExt,pc),a0
  lea (FILES_EX_Ext,a3),a1
  lea (sizeof_FILES_EX_Ext,a1),a2
  bsr PrintNamestsSub

  lea (ExfilesName2,pc),a0
  lea (FILES_EX_Name2,a3),a1
  lea (sizeof_FILES_EX_Name2,a1),a2
  bsr PrintNamestsSub

  movea.l (sp)+,a3
  rts

PrintNamestsSub:
  DOS_PRINT (a0)
  move.b (a2),d1
  clr.b (a2)
  DOS_PRINT (a1)
  move.b d1,(a2)
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

DefaultFindPath: .dc.b '*.*',0

Argument: .dc.b 'Argument = ',0
FilesFound: .dc.b 'Found = ',0
CrLf: .dc.b CR,LF,0

ExfilesPath:  .dc.b 'Path  = ',0
ExfilesName1: .dc.b 'Name1 = ',0
ExfilesExt:   .dc.b 'Ext   = ',0
ExfilesName2: .dc.b 'Name2 = ',0


.bss
.even

FilesBuffer: .ds.b sizeof_FILES_EX+1


.end ProgramStart
