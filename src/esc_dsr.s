.title esc_dsr - show response of escape sequence DSR

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include macro.mac
.include console.mac
.include doscall.mac
.include iocscall.mac


.cpu 68000
.text

ProgramStart:
  lea (strDsr,pc),a1
  IOCS _B_PRINT

  lea (Buffer,pc),a0
  move #(BufferEnd-Buffer)-2,d1
  @@:
    bsr Input
    move.b d0,(a0)+
  dbeq d1,@b
  clr.b (a0)

  lea (Buffer,pc),a0
  lea (strEsc,pc),a1
  moveq #0,d1
  bra 5f
  1:
    cmpi.b #ESC,d1
    bne @f
      IOCS _B_PRINT
      bra 5f
    @@:
    IOCS _B_PUTC
  5:
  move.b (a0)+,d1
  bne 1b

  lea (strCrLf,pc),a1
  IOCS _B_PRINT

  DOS _EXIT


Input:
  move #1,-(sp)
  DOS _KEYCTRL
  move d0,(sp)+
  beq @f
    clr -(sp)
    DOS _KEYCTRL
    addq.l #2,sp
  @@:
  rts


.bss
.quad

Buffer: .ds.b 256
BufferEnd:


.data

strEsc: .dc.b ESC,'[32m','[ESC]',ESC,'[33m',0
strDsr: .dc.b ESC,'[6n'
strCrLf: .dc.b CR,LF,0


.end ProgramStart
