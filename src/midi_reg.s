.title midi_reg - show YM3802 registers

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

.include include/macro.mac
.include include/console.mac
.include include/doscall.mac


MIDI1_EAFA00_BASE: .equ $eafa00

YM3802_R00_IVR: .equ $1
YM3802_R01_RGR: .equ $3


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  lea (MIDI1_EAFA00_BASE+YM3802_R00_IVR),a0

  PUSH_SR_DI
  move.b ($00*2,a0),d0
  POP_SR
  lea (R00,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b ($02*2,a0),d0
  POP_SR
  lea (R02,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$10>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($06*2,a0),d0
  POP_SR
  lea (R16,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$30>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($04*2,a0),d0
  POP_SR
  lea (R34,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$30>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($06*2,a0),d0
  POP_SR
  lea (R36,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$50>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($04*2,a0),d0
  POP_SR
  lea (R54,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$60>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($04*2,a0),d0
  POP_SR
  lea (R64,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$70>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($04*2,a0),d0
  POP_SR
  lea (R74,pc),a1
  bsr printReg

  PUSH_SR_DI
  move.b #$90>>4,(YM3802_R01_RGR-YM3802_R00_IVR,a0)
  move.b ($06*2,a0),d0
  POP_SR
  lea (R96,pc),a1
  bsr printReg

  DOS _EXIT


printReg:
  moveq #0,d1
  move.b d0,d1

  pea (a1)
  DOS _PRINT
  addq.l #4,sp

  clr.l -(sp)
  move d1,d0
  lsr.b #4,d0
  move.b (hex,pc,d0.w),(sp)
  moveq #$f,d0
  and.b d1,d0
  move.b (hex,pc,d0.w),(1,sp)
  pea (sp)
  DOS _PRINT
  addq.l #8,sp

  pea (strCrLf,pc)
  DOS _PRINT
  addq.l #4,sp
  rts

.data
R00: .dc.b 'R00: $',0
R02: .dc.b 'R02: $',0
R16: .dc.b 'R16: $',0
R34: .dc.b 'R34: $',0
R36: .dc.b 'R36: $',0
R54: .dc.b 'R54: $',0
R64: .dc.b 'R64: $',0
R74: .dc.b 'R74: $',0
R96: .dc.b 'R96: $',0

hex: .dc.b '0123456789abcdef'
strCrLf: .dc.b CR,LF,0
.text


.end ProgramStart
