.title movem_aipi - verify MOVEM.L from (An)+'s overwriting of An

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

.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  lea (Buffer,pc),a0

  DOS_PRINT (BeforeMessage,pc)
  move.l a0,d0
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)

  move.l #1,(a0)
  ;a0にはポストインクリメント後の実効アドレスの値が入る
  ;(メモリから読み込んだ値は捨てられる)
  movem.l (a0)+,a0

  DOS_PRINT (AfterMessage,pc)
  move.l a0,d0
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

BeforeMessage: .dc.b 'before: ',0
AfterMessage:  .dc.b 'after:  ',0
CrLf: .dc.b CR,LF,0


.bss
.align 16

Buffer: .ds.b 64


.end
