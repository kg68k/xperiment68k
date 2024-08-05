.title bgthreadid - print thread id

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
  bsr PrintD0Hex
  DOS_PRINT (CrLf,pc)

  DOS _EXIT

error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (BgBuffer+BG_Name,pc),a0
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
  pea (BgBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


PrintD0Hex:
  lea (Buffer,pc),a0
  pea (a0)
  move.b #'$',(a0)+
  bsr ToHexString4_4
  DOS _PRINT
  addq.l #4,sp
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

ThreadNameTooLong: .dc.b 'スレッド名が長すぎます。',CR,LF,0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 128
BgBuffer: .ds.b sizeof_BG


.end ProgramStart
