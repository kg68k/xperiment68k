.title zmsc2_oddopm - write Z-MUSIC v2 ZMD data to OPM from odd address

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  move #OPENMODE_WRITE,-(sp)
  pea (strOpm,pc)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  bpl @f
    lea (strFileOpenError,pc),a0
    bra error
  @@:

  moveq #ZmdDataEnd-ZmdData,d6
  move.l d6,-(sp)
  pea (ZmdData,pc)
  move d7,-(sp)
  DOS _WRITE
  lea (10,sp),sp
  cmp.l d0,d6
  beq @f
    lea (strFileWriteError,pc),a0
    bra error
  @@:

  move d7,-(sp)
  DOS _CLOSE
  addq.l #2,sp

  DOS _EXIT


error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strOpm: .dc.b 'OPM',0

.even
  .dc.b 0
ZmdData:          ;奇数アドレスに配置すること
  .dc.b $10       ;ダミーコード
  .dc.b 'ZmuSiC'  ;ZMDファイルID
  .dc.b $20       ;バージョン番号
  .dc.b $ff,$ff   ;共通コマンド終了コード
  .dc.b $00,$00   ;総トラック数(.w)
ZmdDataEnd:

strFileOpenError: .dc.b 'file open error: ',0
strFileWriteError: .dc.b 'file write error: ',0

CrLf: .dc.b CR,LF,0


.end ProgramStart
