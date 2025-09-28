.title midi_reg - show YM3802 registers

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
.include console.mac
.include doscall.mac

.include xputil.mac


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
  PUSH d1/a0-a1
  link a6,#-16
  lea (sp),a0
  STRCPY a1,a0,-1   ;ヘッダ
  bsr ToHexString2  ;値
  lea (strCrLf,pc),a1
  STRCPY a1,a0
  DOS_PRINT (sp)
  unlk a6
  POP d1/a0-a1
  rts


  DEFINE_TOHEXSTRING2 ToHexString2


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

strCrLf: .dc.b CR,LF,0


.end ProgramStart
