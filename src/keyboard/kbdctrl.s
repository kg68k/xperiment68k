.title kbdctrl - send keyboard control code

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

.include iomap.mac
.include macro.mac

.include xputil.mac


DEFAULT_CODE: .equ $47  ;省略時はCompactキーボード判別コマンド


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr ParseArguments
  move.l d0,d7

  suba.l a1,a1
  IOCS _B_SUPER

  move.l d7,d0
  bsr OutputKeyboardControl

  DOS _EXIT


OutputKeyboardControl:
  move sr,d1
  @@:
    move d1,sr
    nop
    DI
    tst.b (MFP_TSR)
  bpl @b

  move.b d0,(MFP_UDR)
  move d1,sr
  rts


ParseArguments:
  moveq #DEFAULT_CODE,d0
  SKIP_SPACE a0
  beq @f
    bsr ParseIntByte
    andi.l #$ff,d0
  @@:
  rts


  DEFINE_PARSEINTBYTE ParseIntByte


.end ProgramStart
