.title prefetchtest - MC68000 prefetch test

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


OP_NOP: .equ %0100_111001_110001


.cpu 68000
.text

Start:
  lea (Buffer,pc),a0
  move.l #OP_NOP<<16+OP_NOP,d7

  moveq #0,d0
  lea (@f,pc),a1
  move.w #OP_NOP,(a1)
  @@:
  addq.b #1,d0  ;nopに書き換える(1)
  addq.b #2,d0
  bsr StringifyResult

  moveq #0,d0
  lea (@f,pc),a1
  move.w d7,(a1)
  @@:
  addq.b #1,d0  ;nopに書き換える(1)
  addq.b #2,d0
  bsr StringifyResult

  moveq #0,d0
  lea (@f,pc),a1
  move.l #OP_NOP<<16+OP_NOP,(a1)
  @@:
  addq.b #1,d0  ;nopに書き換える(1)
  addq.b #2,d0  ;nopに書き換える(2)
  bsr StringifyResult

  moveq #0,d0
  lea (@f,pc),a1
  move.l d7,(a1)
  @@:
  addq.b #1,d0  ;nopに書き換える(1)
  addq.b #2,d0  ;nopに書き換える(2)
  bsr StringifyResult

  WRITE_CRLF_NUL a0
  DOS_PRINT (Buffer+.sizeof.(', '),pc)
  DOS _EXIT


StringifyResult:
  move.b #',',(a0)+
  move.b #' ',(a0)+
  bsr ToHexString$2
  rts


  DEFINE_TOHEXSTRING$2 ToHexString$2


.bss
.even

Buffer: .ds.b 128


.end
