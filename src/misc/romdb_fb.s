.title romdb_fb - IOCS $fb test

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

.include macro.mac

.include xputil.mac


.cpu 68000
.text

;常駐部
KeepStart:

OldIocsFBVector:
  .ds.l 1
IdString:
  .dc.b 'RomDb$fb'

.quad
RegValues:
DataRegValues: .ds.b .sizeof.(d0-d7)
AddrRegValues: .ds.b .sizeof.(a0-a7)


IocsFB:
  PUSH d1-d2/a1-a2
  movem.l d0-d7/a0-a7,(RegValues)
  lea (strCalled,pc),a1
  IOCS _B_PRINT

  lea (strDataRegs,pc),a0
  lea (DataRegValues,pc),a1
  bsr PrintRegisters

  lea (strAddrRegs,pc),a0
  lea (AddrRegValues,pc),a1
  bsr PrintRegisters

  lea (strStack,pc),a0
  lea (.sizeof.(d1-d2/a1-a2),sp),a1
  bsr PrintRegisters

  POP d1-d2/a1-a2
  moveq #-1,d0
  rts


strCalled: .dc.b 'IOCS $fbが呼ばれました。',CR,LF,0
strDataRegs: .dc.b 'd0-d7: ',0
strAddrRegs: .dc.b 'a0-a7: ',0
strStack: .dc.b 'stack: ',0
strComma: .dc.b ', ',0
strCrLf: .dc.b CR,LF,0
.even


PrintRegisters:
  link a6,#-128
  lea (a0),a2
  lea (sp),a0
  STRCPY a2,a0,-1

  moveq #8-1,d2
  bra 1f
  @@:
    lea (strComma,pc),a2
    STRCPY a2,a0,-1
    1:
    move.l (a1)+,d0
    bsr ToHexString$8
  dbra d2,@b
  lea (strCrLf,pc),a2
  STRCPY a2,a0,-1

  lea (sp),a1
  IOCS _B_PRINT
  unlk a6
  rts


  DEFINE_TOHEXSTRING$8 ToHexString$8


KeepEnd:
;常駐部ここまで


ProgramStart:
  pea (IocsFB,pc)
  move #$100+$fb,-(sp)
  DOS _INTVCS
  addq.l #6,sp
  move.l d0,(OldIocsFBVector)  ;特に使わないが一応保存する。

  DOS_PRINT (strKeep,pc)

  clr -(sp)
  pea (KeepEnd-KeepStart)
  DOS _KEEPPR


.data

strKeep: .dc.b 'IOCS $fbを差し替えて常駐しました。',CR,LF,0


.end ProgramStart
