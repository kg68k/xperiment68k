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
  ;move from srを実行するまでsr/ccrの値を変化させないこと
  movem.l d0-d7/a0-a7,(RegValues)
  movem (MoveFromSr,pc),d6  ;命令が書き換わるかの検出用に保存しておく
  MoveFromSr: move sr,d7

  pea (GetSsp,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  move.l d0,d5

  lea (strDataRegs,pc),a0
  lea (DataRegValues,pc),a1
  bsr PrintRegisters

  lea (strAddrRegs,pc),a0
  lea (AddrRegValues,pc),a1
  bsr PrintRegisters

  DOS_PRINT (strSsp,pc)
  move.l d5,d0
  bsr Print$8
  DOS_PRINT (CrLf,pc)

  lea (strSr,pc),a0
  cmp (MoveFromSr,pc),d6
  beq @f
    lea (strCcr,pc),a0  ;move sr,d7がmove ccr,d7に書き換わっていた(68010以上)
  @@:
  DOS_PRINT (a0)
  move d7,d0
  bsr Print$4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


GetSsp:
  move.l sp,d0
  rts


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


  DEFINE_PRINT$4 Print$4
  DEFINE_PRINT$8 Print$8


.data

strDataRegs: .dc.b 'd0-d7: ',0
strAddrRegs: .dc.b 'a0-a7: ',0
strSsp: .dc.b 'ssp (approximate): ',0
strSr:  .dc.b 'sr: ',0
strCcr: .dc.b 'ccr: ',0
Comma: .dc.b ', ',0

CrLf: .dc.b CR,LF,0

.bss

.even
RegValues:
DataRegValues: .ds.b .sizeof.(d0-d7)
AddrRegValues: .ds.b .sizeof.(a0-a7)


.end ProgramStart
