.title dumpstupreg - dump startup MPU registers

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

ProgramStart:
  movem.l d0-d7/a0-a7,(RegValues)

  lea (strDataRegs,pc),a0
  lea (DataRegValues,pc),a1
  bsr PrintRegisters

  lea (strAddrRegs,pc),a0
  lea (AddrRegValues,pc),a1
  bsr PrintRegisters

  DOS _EXIT


PrintRegisters:
  DOS_PRINT (a0)
  moveq #8-1,d2
  bra 1f
  @@:
    DOS_PRINT (Comma,pc)
    1:
    move.l (a1)+,d0
    bsr Print$8
  dbra d2,@b
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_PRINT$8 Print$8


.data

strDataRegs: .dc.b 'd0-d7: ',0
strAddrRegs: .dc.b 'a0-a7: ',0
Comma: .dc.b ', ',0

CrLf: .dc.b CR,LF,0

.bss

.even
RegValues:
DataRegValues: .ds.b .sizeof.(d0-d7)
AddrRegValues: .ds.b .sizeof.(a0-a7)


.end ProgramStart
