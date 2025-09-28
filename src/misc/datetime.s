.title datetime - print date and time obtained from IOCS

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

.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  IOCS _DATEGET
  move.l d0,d6
  @@:
    IOCS _TIMEGET
    move.l d0,d7
    IOCS _DATEGET
    exg d0,d6
  cmp.l d0,d6  ;時刻の取得中に日付が変わっていたらやり直す
  bne @b

  move.l d6,d0
  move.l d7,d1
  bsr PrintDateTimeBCD

  move.l d6,d1
  IOCS _DATEBIN
  move.l d0,d6
  move.l d7,d1
  IOCS _TIMEBIN
  move.l d0,d7

  moveq #4-1,d3  ;文字列形式0～3について繰り返す
  @@:
    moveq #4-1,d0
    sub d3,d0  ;文字列形式 3,2,1,0 -> 0,1,2,3
    move.l d6,d1
    move.l d7,d2
    bsr PrintDateTime
  dbra d3,@b

  DOS _EXIT


PrintDateTime:
  movea.l d1,a0  ;曜日を保存

  lea (Buffer,pc),a1
  andi.l #$0fff_ffff,d1  ;曜日カウンタを消す
  ror.l #4,d0
  or.l d0,d1  ;文字列形式
  IOCS _DATEASC

  move.b #'(',(a1)+
  move.l a0,d1
  rol.l #4,d1
  moveq #$f,d0
  and.l d0,d1
  IOCS _DAYASC
  move.b #')',(a1)+

  move.b #' ',(a1)+
  move.l d2,d1
  IOCS _TIMEASC

  DOS_PRINT (Buffer,pc)
  DOS_PRINT_CRLF
  rts


PrintDateTimeBCD:
  move.l d1,-(sp)
  move.l d0,-(sp)
  DOS_PRINT (BcdMessage,pc)
  move.l (sp)+,d0
  bsr Print$4_4
  DOS_PRINT (Space,pc)
  move.l (sp)+,d0
  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

BcdMessage: .dc.b 'BCD: ',0
Space: .dc.b ' ',0


.bss

Buffer: .ds.b 128


.end ProgramStart
