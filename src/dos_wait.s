.title dos_wait - DOS _WAIT

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

.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

DeviceHeader:
  .dc.l -1
  .dc %1000_0000_0000_0000
  .dc.l Strategy
  .dc.l Interrupt
  .dc.b '?_WAIT*?'

RequestHeader:
  .ds.l 1

Strategy:
  move.l a5,(RequestHeader)
  rts

Interrupt:
  movem.l d0-d7/a0-a6,-(sp)
  movea.l (RequestHeader,pc),a5
  tst.b (2,a5)
  beq cmd00
    move #$1001,d0
    bra 9f
  cmd00:
    bsr Cmd00_Init
  9:
  move.b d0,(3,a5)     ;error code low
  move d0,-(sp)
  move.b (sp)+,(4,a5)  ;error code high
  movem.l (sp)+,d0-d7/a0-a6
  rts

Cmd00_Init:
  DOS_PRINT (Title,pc)
  bsr PrintExitCode
  move #$700d,d0
  rts


ProgramStart:
  bsr PrintExitCode
  DOS _EXIT


PrintExitCode:
  DOS _WAIT
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

Title:
  .dc.b CR,LF
  .dc.b 'DOS _WAIT: '
  .dc.b 0

CrLf: .dc.b CR,LF,0


.end ProgramStart
