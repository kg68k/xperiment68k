.title dos_filedate - DOS _FILEDATE

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
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr GetArguments
  move.l d0,d7  ;タイムスタンプ(0なら取得のみ)

  moveq #OPENMODE_READ,d0  ;取得時は読み込みオープン
  tst.l d7
  beq @f
    moveq #OPENMODE_WRITE,d0  ;設定時は書き込みオープン
  @@:
  move d0,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d6
  bpl @f
    lea (strFileOpenError,pc),a0
    bra error
  @@:
  move.l d7,-(sp)
  move d6,-(sp)
  DOS _FILEDATE
  addq.l #6,sp
  tst.l d0
  bmi error2

  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
error2:
  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


PrintUsage:
  lea (strUsage,pc),a0
  bra Fatal


GetArguments:
  moveq #0,d1  ;-tで指定したタイムスタンプ 省略時0
1:
  SKIP_SPACE a0
  beq PrintUsage  ;ファイル名なし
  cmpi.b #'-',(a0)
  bne 9f  ;ファイル名あり

  addq.l #1,a0
  cmpi.b #'t',(a0)+
  bne PrintUsage
    SKIP_SPACE a0  ;-t<n>
    beq PrintUsage

    bsr ParseInt
    move.l d0,d1
    bra 1b
9:
  move.l d1,d0
  rts


  DEFINE_FATAL Fatal
  DEFINE_PARSEINT ParseInt
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strUsage:
  .dc.b 'usage: dos_filedate [option] <filename>',CR,LF
  .dc.b 'option:',CR,LF
  .dc.b '  -t<datetime>  set filedate(DOS timestamp format)',CR,LF
  .dc.b 0

strFileOpenError: .dc.b 'file open error: ',0


.end ProgramStart
