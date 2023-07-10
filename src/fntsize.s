.title fntsize - show font size by IOCS _FNTADR and _FNTGET

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
.include fefunc.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


MIN_SIZE: .equ 0
MAX_SIZE: .equ 24
WIDTH: .equ 2


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr getArgument
  move.l d0,d6  ;文字コード
  bne @f
    moveq #SPACE,d6
  @@:

  pea (title,pc)
  DOS _PRINT
  addq.l #4,sp

  moveq #MIN_SIZE,d7
  @@:
    move.l d7,d0
    lea (Buffer,pc),a0
    moveq #.sizeof.('size'),d1
    FPACK __IUSING

    move.l d6,d0
    move.l d7,d1
    bsr fntadr

    move.l d6,d0
    move.l d7,d1
    bsr fntget

    lea (NewLine,pc),a1
    STRCPY a1,a0

    pea (Buffer,pc)
    DOS _PRINT
    addq.l #4,sp

    addq #1,d7
  cmpi #MAX_SIZE,d7
  bls @b

  DOS _EXIT


fntadr:
  PUSH d2-d3
  move.l d1,d2
  move.l d0,d1
  IOCS _FNTADR
  move d1,d3

  move.l d1,d0
  clr d0
  swap d0
  moveq #.sizeof.('  Xdot'),d1
  FPACK __IUSING

  moveq #0,d0
  move d3,d0
  moveq #.sizeof.(' Xb-1'),d1
  FPACK __IUSING

  moveq #0,d0
  move d2,d0
  moveq #.sizeof.(' Yd-1'),d1
  FPACK __IUSING

  POP d2-d3
  rts


BUF_SIZE: .equ 256

fntget:
  link a6,#-BUF_SIZE

  swap d1
  move d0,d1
  lea (sp),a1
  IOCS _FNTGET
 
  moveq #0,d0
  move (0,sp),d0
  moveq #.sizeof.('   Xdot'),d1
  FPACK __IUSING

  moveq #0,d0
  move (2,sp),d0
  moveq #.sizeof.(' Ydot'),d1
  FPACK __IUSING

  unlk a6
  rts


getArgument:
  bsr skipBlank
  moveq #0,d0
  move.b (a0)+,d0
  beq @f
    move.b d0,d1
    lsr.b #5,d1
    btst d1,#%10010000
    beq @f
      lsl #8,d0
      move.b (a0)+,d0
  @@:
  rts

skipBlank:
@@:
  move.b (a0)+,d0
  beq @f
  cmpi.b #SPACE,d0
  beq @b
  cmpi.b #TAB,d0
  beq @b
@@:
  subq.l #1,a0
  rts


.data

title: .dc.b '    ┌─ _FNTADR ─┐┌ _FNTGET ┐',CR,LF
       .dc.b 'size  Xdot Xb-1 Yd-1   Xdot Ydot',CR,LF
       .dc.b 0

NewLine: .dc.b CR,LF,0


.bss
.even

Buffer: .ds.b 128


.end ProgramStart
