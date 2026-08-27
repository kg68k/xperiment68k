.title keep_undersized - DOS _KEEPPR with a undersized memory block

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

.include process.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d0  ;メモリ管理ポインタ + PSPだけのサイズに変更する
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    move.l #-(sizeof_PSP-sizeof_MEMBLK),d0  ;メモリ管理ポインタだけのサイズに変更する
  @@:
  clr -(sp)
  move.l d0,-(sp)
  DOS _KEEPPR


.end ProgramStart
