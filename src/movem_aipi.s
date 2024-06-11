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
  bsr PrintD0
  DOS_PRINT (CrLf,pc)

  move.l #1,(a0)
  ;a0にはポストインクリメント後の実効アドレスの値が入る
  ;(メモリから読み込んだ値は捨てられる)
  movem.l (a0)+,a0

  DOS_PRINT (AfterMessage,pc)
  move.l a0,d0
  bsr PrintD0
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


PrintD0:
  move.l a0,-(sp)
  lea (Buffer,pc),a0
  pea (a0)
  bsr ToHexString4_4
  DOS _PRINT
  addq.l #4,sp
  movea.l (sp)+,a0
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

BeforeMessage: .dc.b 'before: $',0
AfterMessage:  .dc.b 'after:  $',0
CrLf: .dc.b CR,LF,0


.bss
.align 16

Buffer: .ds.b 64


.end
