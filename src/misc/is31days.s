.title is31days - Identify whether a month has up to 31 days

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

.include macro.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #1,d7
  @@:
    move.l d7,d0
    bsr PrintIs32days
    addq #1,d7
    cmpi #12,d7
  bls @b
  DOS _EXIT


PrintIs32days:
  link a6,#-32
  lea (sp),a0
  move.l d0,d1
  divu #10,d1
  move.b (SpaceOrOne,pc,d1.w),(a0)+
  swap d1
  addi.b #'0',d1
  move.b d1,(a0)+
  bsr Is31days
  lea (strFalse,pc),a1
  tst d0
  beq @f
    lea (strTrue,pc),a1
  @@:
  STRCPY a1,a0
  DOS_PRINT (sp)
  unlk a6
  rts

SpaceOrOne: .dc.b ' ','1'
.even


;指定した月が31日まであるか判定する
;  original idea (Z80): https://x.com/koizuka/status/1994315585937690912
;in d0.l 月(1-12)
;out d0.l 0:いいえ 1:はい
;clob d1
Is31days:
  subq #8,d0
  moveq #1,d1
  addx d1,d0
  and.l d1,d0
  rts


.data

strFalse: .dc.b ': false',CR,LF,0
strTrue:  .dc.b ': true',CR,LF,0


.end ProgramStart
