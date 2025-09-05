.title trap15trace - trap #15 handler that supports tracing

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
.include vector.mac
.include iocswork.mac

.include xputil.mac


.cpu 68000
.text

;常駐部
KeepStart:

OldTrap15Vector:
  .ds.l 1
IdString:
  .dc.b 'trap15trace',0
  .even


Trap15Handler:
  move.l a0,-(sp)
  andi #$00ff,d0
  ext.l d0
  move d0,(IOCSNUM)
  movea.l d0,a0
  adda a0,a0
  adda a0,a0
  movea.l ($400,a0),a0
  jsr (a0)
  move #-1,(IOCSNUM)
  movea.l (sp)+,a0

  .fail SR_T.ne.15
  tst (sp)
  bpl @f  ;トレース無効
    ori #1<<SR_T,sr  ;トレース有効時の細工
  @@:
  rte


KeepEnd:
;常駐部ここまで


ProgramStart:
  pea (Trap15Handler,pc)
  move #TRAP15_VEC,-(sp)
  DOS _INTVCS
  addq.l #6,sp
  move.l d0,(OldTrap15Vector)  ;特に使わないが一応保存する。

  clr -(sp)
  pea (KeepEnd-KeepStart)
  DOS _KEEPPR


.end ProgramStart
