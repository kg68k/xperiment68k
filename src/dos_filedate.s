.title dos_filedate - DOS _FILEDATE

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
.include fefunc.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d7  ;タイムスタンプ(0なら取得のみ)

  lea (1,a2),a0
  bsr GetArgument
  tst.l d0
  bmi PrintUsage
  move.l d1,d7

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
    lea (OpenErrMessage,pc),a0
    bsr PrintError
    moveq #EXIT_FAILURE,d0
    bra 9f
  @@:
  move.l d7,-(sp)
  move d6,-(sp)
  DOS _FILEDATE
  addq.l #6,sp
  bsr PrintResult

  moveq #EXIT_SUCCESS,d0
9:
  move d0,-(sp)
  DOS _EXIT2


PrintError:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintResult
  rts


PrintResult:
  lea (Buffer,pc),a0
  move.b #'$',(a0)+
  bsr ToHexString4_4

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)
  rts


PrintUsage:
  DOS_PRINT (UsageMessage,pc)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


GetArgument:
  moveq #0,d1  ;-dまたは-xで指定したタイムスタンプ 省略時0
1:
  SKIP_SPACE a0
  beq 8f  ;ファイル名なし
  cmpi.b #'-',(a0)
  bne 7f  ;ファイル名あり

  addq.l #1,a0
  move.b (a0)+,d0
  cmpi.b #'d',d0
  bne @f
    SKIP_SPACE a0  ;-d<decimal>
    beq 8f
    FPACK __STOL
    bcs 8f
    move.l d0,d1
    bra 1b
  @@:
  cmpi.b #'x',d0
  bne 8f
    SKIP_SPACE a0  ;-x<hex>
    beq 8f
    FPACK __STOH
    bcs 8f
    move.l d0,d1
    bra 1b
7:
  moveq #0,d0
  bra 9f
8:
  moveq #-1,d0
9:
  rts


  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

UsageMessage:
  .dc.b 'usage: dos_filedate [option] <filename>',CR,LF
  .dc.b '  -s<hex>      set filedate',CR,LF
  .dc.b '  -d<decimal>  set filedate',CR,LF
  .dc.b 0

OpenErrMessage:.dc.b 'file open error: ',0

CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart
