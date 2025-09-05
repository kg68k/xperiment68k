.title zerounit - remote drive unit=0 PoC

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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

.cpu 68000
.text

DeviceHeader:
  .dc.l -1
  .dc %0010_0000_0000_0000
  .dc.l Strategy
  .dc.l Interrupt
  .dc.b $00,'ZEROUNT'

RequestHeader:
  .ds.l 1

Strategy:
  move.l a5,(RequestHeader)
  rts

Interrupt:
  movem.l d0-d7/a0-a6,-(sp)
  movea.l (RequestHeader,pc),a5
  cmpi.b #$40,(2,a5)
  beq cmd40
    move #$1001,d0
    bra 9f
  cmd40:
    bsr Cmd40_Init
  9:
  move.b d0,(3,a5)     ;error code low
  move d0,-(sp)
  move.b (sp)+,(4,a5)  ;error code high
  movem.l (sp)+,d0-d7/a0-a6
  rts

Cmd40_Init:
  pea (Title,pc)
  DOS _PRINT
  addq.l #4,sp

  clr.b (13,a5)  ;units
  move.l #DeviceDriverEnd,(14,a5)
  moveq #0,d0
  rts	

DeviceDriverEnd:

Title:
  .dc.b 13,10
  .dc.b 'zerounit PoC',13,10
  .dc.b 0


.end
