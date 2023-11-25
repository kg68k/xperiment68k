.title joyget - show IOCS _JOYGET result

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

.include macro.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  moveq #-1,d7  ;前回の状態
  bra 1f

  loop:
    DOS _CHANGE_PR
  1:
    bsr getJoyData
    cmp.l d0,d7
    beq @f
      move.l d0,d7
      bsr printJoyData
    @@:
  IOCS _B_KEYSNS
  tst.l d0
  beq loop
  IOCS _B_KEYINP

  DOS _EXIT


getJoyData:
  moveq #1,d1
  @@:
    IOCS _JOYGET
    move d0,-(sp)
  dbra d1,@b
  move.l (sp)+,d0
  rts

printJoyData:
  move.l d0,-(sp)

  lea (Buffer,pc),a0
  lea (strTime,pc),a1
  STRCPY a1,a0,-1

  IOCS _ONTIME
  bsr ToHexString8

  move (sp),d0
  lea (strJ0,pc),a1
  bsr stringifyJoyData

  move.l (sp),d0
  lea (strJ1,pc),a1
  bsr stringifyJoyData

  lea (CrLf,pc),a1
  STRCPY a1,a0

  lea (Buffer,pc),a1
  IOCS _B_PRINT

  addq.l #4,sp
  rts

stringifyJoyData:
  move.l d7,-(sp)
  move.l d0,d7

  STRCPY a1,a0,-1
  bsr ToHexString2
  move.b #' ',(a0)+

  lea (joyNameTable,pc),a1
  moveq #8-1,d1
  1:
    move (a1)+,d0
    add.b d7,d7
    bcc @f
      move #'＿',d0  ;ボタン・レバー入力なし
    @@:
    move d0,-(sp)
    move.b (sp)+,(a0)+
    move.b d0,(a0)+
  dbra d1,1b
  clr.b (a0)

  move.l (sp)+,d7
  rts


  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_TOHEXSTRING8 ToHexString8


.data

.even
joyNameTable: .dc '？ＢＡ？→←↓↑'

strTime: .dc.b 'time=$',0
strJ0: .dc.b ', #0=$',0
strJ1: .dc.b ', #1=$',0
CrLf: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 128


.end
