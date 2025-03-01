.title conctrl_so - DOS _CONCTRL stack overrun PoC

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


.include doscall.mac
.include process.mac


.cpu 68000
.text

ProgramStart:
  movea.l (MEMBLK_End,a0),sp  ;メモリブロックの末尾をスタックとして使う

  move #17,-(sp)
  DOS _CONCTRL
  addq.l #2,sp

  DOS _EXIT


.bss
.quad

Stack: .ds.b 16*1024


.end ProgramStart
