.title keepcmem - DOS _KEEPPR with a memory block in the ceiling of memory

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

.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  bra.s @f
    .dc.b 'keepcmem',0,0
    AllocedMemory: .dc.l 0
  @@:

  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  moveq #0,d7  ;常駐サイズおよび確保サイズ
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    moveq #16,d7
  @@:

  clr.l -(sp)
  move #2,-(sp)  ;上位から
  DOS _MALLOC2
  addq.l #6,sp
  lea (AllocedMemory,pc),a0
  move.l d0,(a0)
  bmi error

  clr -(sp)
  move.l d7,-(sp)
  DOS _KEEPPR

error:
  DOS_PRINT (strMallocError,pc)
  DOS _EXIT


.data

strMallocError: .dc.b 'DOS _MALLOC2 error',CR,LF,0


.end
