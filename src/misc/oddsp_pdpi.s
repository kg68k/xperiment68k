.title oddsp_pdpi - byte operation with -(sp) and (sp)+ on odd address

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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

Start:
  bsr Predecrement
  bsr Postincrement
  DOS _EXIT


Predecrement:
  lea (sp),a6
  clr.l -(sp)
  move.l #$11223344,-(sp)
  lea (3,sp),a5  ;奇数アドレスを指す。メモリ内容は$44
  clr.l -(sp)

  lea (a5),sp
  move.b -(sp),d0
  lea (sp),a4   ;実行後のスタックポインタ
  move.b d0,d7  ;読み取った値
  lea (a6),sp

  lea (strPredec,pc),a0
  bsr PrintResult
  rts


Postincrement:
  lea (sp),a6
  clr.l -(sp)
  move.l #$55667788,-(sp)
  lea (1,sp),a5  ;奇数アドレスを指す。メモリ内容は$66
  clr.l -(sp)

  lea (a5),sp
  move.b (sp)+,d0
  lea (sp),a4   ;実行後のスタックポインタ
  move.b d0,d7  ;読み取った値
  lea (a6),sp

  lea (strPostinc,pc),a0
  bsr PrintResult
  rts


PrintResult:
  pea (a0)  ;'move.b -(sp),d0' or 'move.b (sp)+,d0'

  lea (Buffer,pc),a0
  lea (strSpEqual,pc),a1
  STRCPY a1,a0,-1
  move.l a5,d0  ;実行前のスタックポインタ
  bsr ToHexString$4_4
  movea.l (sp)+,a1  ;冒頭でpushした文字列
  STRCPY a1,a0,-1
  lea (strSpEqual,pc),a1
  STRCPY a1,a0,-1
  move.l a4,d0  ;実行後のスタックポインタ
  bsr ToHexString$4_4
  lea (strD0Equ,pc),a1
  STRCPY a1,a0,-1
  move.b d7,d0  ;読み取った値
  bsr ToHexString$2

  WRITE_CRLF_NUL a0
  DOS_PRINT (Buffer,pc)
  rts


  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4


.data

strSpEqual: .dc.b 'sp = ',0
strPredec:  .dc.b '; move.b -(sp),d0; ',0
strPostinc: .dc.b '; move.b (sp)+,d0; ',0
strD0Equ:   .dc.b ', d0.b = ',0


.bss
.even

Buffer: .ds.b 128


.end
