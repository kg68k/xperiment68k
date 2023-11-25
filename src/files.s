.title files - DOS _FILES/_NFILES

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr SkipBlank

  tst.b (a0)
  bne @f
    lea (DefaultFindPath,pc),a0
  @@:

  move #$00ff,-(sp)
  pea (a0)
  pea (FilesBuffer,pc)
  DOS _FILES
  addq.l #10-4,sp
  move.l d0,(sp)+
  bpl @f
    bsr filesError
    bra 9f
  @@:
  filesLoop:
    lea (FilesBuffer,pc),a0
    bsr PrintFilesResult
  
    pea (FilesBuffer,pc)
    DOS _NFILES
    move.l d0,(sp)+
  bpl filesLoop

  moveq #DOSE_NOENT,d1  ;_NFILESの「ファイルが見つからない」エラーは正常終了として扱う
  cmp.l d1,d0
  beq @f
    bsr nfilesError
  @@:
9:
  DOS _EXIT


filesError:
  move.l d0,-(sp)
  DOS_PRINT (FilesError,pc)
  move.l (sp)+,d0
  bsr PrintResult
  rts

nfilesError:
  move.l d0,-(sp)
  DOS_PRINT (NfilesError,pc)
  move.l (sp)+,d0
  bsr PrintResult
  rts


PrintFilesResult:
  DOS_PRINT (FILES_FileName,a0)
  DOS_PRINT (CrLf,pc)
  rts


PrintResult:
  lea (Buffer,pc),a0
  move.b #'$',(a0)+
  bsr ToHexString4_4

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)
  rts


SkipBlank:
  @@:
    move.b (a0)+,d0
    beq 9f
    cmpi.b #' ',d0
    beq @b
  9:
  subq.l #1,a0
  rts


  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

DefaultFindPath: .dc.b '*.*',0

FilesError:  .dc.b 'DOS _FILES error: ',0
NfilesError: .dc.b 'DOS _NFILES error: ',0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 128

.even
FilesBuffer: .ds.b sizeof_FILES


.end ProgramStart
