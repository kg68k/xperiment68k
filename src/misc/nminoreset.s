.title nminoreset - NMI handler without NMI reset

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

.include vector.mac

.include xputil.mac


.cpu 68000
.text

;常駐部
KeepStart:

OldNmiVector:
  .ds.l 1
IdString:
  .dc.b 'NmiNoReset',0
  .even

NmiHandler:
  ;move.b #%1100,(SYS_P4)  ;NMIリセットはしない

  save_regs: .reg d0-d7/a0-a6
  movem.l save_regs,-(sp)

  move #$301f,d7  ;エラー番号
  lea (.sizeof.(save_regs),sp),a6  ;ssp
  trap #14

  movem.l (sp)+,save_regs
  rte

KeepEnd:
;常駐部ここまで


ProgramStart:
  pea (NmiHandler,pc)
  move #NMI_VEC,-(sp)
  DOS _INTVCS
  addq.l #6,sp
  move.l d0,(OldNmiVector)  ;特に使わないが一応保存する。

  DOS_PRINT (strKeep,pc)

  clr -(sp)
  pea (KeepEnd-KeepStart)
  DOS _KEEPPR


.data

strKeep: .dc.b 'NMIスイッチ処理を差し替えて常駐しました。',CR,LF,0


.end ProgramStart
