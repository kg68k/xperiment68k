.title iocs_txfill - IOCS _TXFILL sample

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

.include doscall.mac
.include iocsdef.mac
.include iocscall.mac

.include xputil.mac

.cpu 68000
.text

ProgramStart:
  lea (txfillBuf,pc),a1
  move #$8000+3,(TXFILL_PLANE,a1)
  move #32,(TXFILL_XS,a1)
  move #32,(TXFILL_YS,a1)
  move #16,(TXFILL_XL,a1)
  move #16,(TXFILL_YL,a1)
  move #$ffff,(TXFILL_LINE,a1)

  moveq #24-1,d1
  @@:
    IOCS _TXFILL
    subq.b #1,(TXFILL_PLANE+1,a1)
    bne 1f
      move.b #3,(TXFILL_PLANE+1,a1)
    1:
    move (TXFILL_XL,a1),d0
    addq #3,d0
    add d0,(TXFILL_XS,a1)
    addq #1,(TXFILL_XL,a1)
    addq #1,(TXFILL_YL,a1)
  dbra d1,@b

  move #$8000+3,(TXFILL_PLANE,a1)
  move #32,(TXFILL_XS,a1)
  move #32+64,(TXFILL_YS,a1)
  move #16,(TXFILL_XL,a1)
  move #16,(TXFILL_YL,a1)
  move #$c33c,(TXFILL_LINE,a1)

  moveq #24-1,d1
  @@:
    IOCS _TXFILL
    subq.b #1,(TXFILL_PLANE+1,a1)
    bne 1f
      move.b #3,(TXFILL_PLANE+1,a1)
    1:
    move (TXFILL_XL,a1),d0
    addq #3,d0
    add d0,(TXFILL_XS,a1)
    addq #1,(TXFILL_XL,a1)
    addq #1,(TXFILL_YL,a1)
    not (TXFILL_LINE,a1)
  dbra d1,@b

  move #$8000+3,(TXFILL_PLANE,a1)
  move #32,(TXFILL_XS,a1)
  move #32+64*2,(TXFILL_YS,a1)
  move #16,(TXFILL_XL,a1)
  move #16,(TXFILL_YL,a1)
  move #$ff00,(TXFILL_LINE,a1)

  moveq #24-1,d1
  @@:
    IOCS _TXFILL
    subq.b #1,(TXFILL_PLANE+1,a1)
    bne 1f
      move.b #3,(TXFILL_PLANE+1,a1)
    1:
    move (TXFILL_XL,a1),d0
    addq #3,d0
    add d0,(TXFILL_XS,a1)
    addq #1,(TXFILL_XL,a1)
    addq #1,(TXFILL_YL,a1)
    not (TXFILL_LINE,a1)
  dbra d1,@b

  DOS _EXIT


.bss
.quad

txfillBuf: .ds.b sizeof_TXFILL


.end ProgramStart
