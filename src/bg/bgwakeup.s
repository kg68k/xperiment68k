.title bgwakeup - send wake up request to thread

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
.include process.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (Usage,pc)
    bra error
  @@:
  lea (a2),a0
  bsr SetThreadName
  beq @f
    DOS_PRINT (ThreadNameTooLong,pc)
    bra error
  @@:

  moveq #-1,d0  ;バッファで指定した名前のIDを得る
  bsr GetPr
  move.l d0,d7
  bpl @f
    DOS_PRINT (GetPrErrorMessage,pc)
    bra error2
  @@:
  moveq #-2,d0  ;自分自身のスレッドIDを得る
  bsr GetPr
  move.l d0,d6
  bpl @f
    move.l d6,d7
    DOS_PRINT (GetPrErrorMessage,pc)
    bra error2
  @@:

  clr.l -(sp)  ;バイト数
  pea (sp)     ;バッファ(バイト数が0なのでダミー)
  move #THREAD_WAKEUP,-(sp)
  move d7,-(sp)
  move d6,-(sp)
  DOS _SEND_PR
  lea (14,sp),sp
  move.l d0,d7
  bpl @f
    DOS_PRINT (SendPrErrorMessage,pc)
    bra error2
  @@:

  DOS _EXIT


error2:
  move.l d7,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (PrcptrBuffer+PRCPTR_name,pc),a1
  moveq #16-1,d0
  @@:
    move.b (a0)+,(a1)+
  dbeq d0,@b
  sne d0
  ext d0
  ext.l d0
  rts


GetPr:
  pea (PrcptrBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

Usage: .dc.b 'usage: bgwakeup thread_name',CR,LF,0

ThreadNameTooLong: .dc.b 'スレッド名が長すぎます。',CR,LF,0
GetPrErrorMessage: .dc.b 'DOS _GET_PR エラー: ',0
SendPrErrorMessage: .dc.b 'DOS _SEND_PR エラー: ',0

CrLf: .dc.b CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR


.end ProgramStart
