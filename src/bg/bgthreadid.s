.title bgthreadid - print thread id

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
  bne 1f
    moveq #-2,d0  ;自分自身のIDを得る
    bra @f
  1:
    bsr SetThreadName
    bmi error
    moveq #-1,d0  ;バッファで指定した名前のIDを得る
  @@:
  bsr GetPr
  move.l d0,d7
  bsr Print$8
  DOS_PRINT_CRLF
  tst.l d7
  bmi error

  DOS _EXIT

error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (PrcptrBuffer+PRCPTR_name,pc),a0
  moveq #16-1,d1
  @@:
    move.b (a2)+,(a0)+
  dbeq d1,@b
  beq @f
    DOS_PRINT (ThreadNameTooLong,pc)
    moveq #-1,d0
    rts
  @@:
  moveq #0,d0
  rts


GetPr:
  pea (PrcptrBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


  DEFINE_PRINT$8 Print$8


.data

ThreadNameTooLong: .dc.b 'スレッド名が長すぎます。',CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR


.end ProgramStart
