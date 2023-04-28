.title iocs_txyline - IOCS _TXFILL sample

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

.include include/doscall.mac
.include include/iocsdef.mac
.include include/iocscall.mac

.include include/xputil.mac

.cpu 68000
.text

ProgramStart:
  lea (txylineBuf,pc),a1
  move #$8000+3,(TXYLINE_PLANE,a1)
  move #32,(TXYLINE_XS,a1)
  move #32,(TXYLINE_YS,a1)
  move #256,(TXYLINE_YL,a1)
  move #$00ff,(TXYLINE_LINE,a1)

  moveq #32-1,d1
  @@:
    IOCS _TXYLINE
    subq.b #1,(TXYLINE_PLANE+1,a1)
    bne 1f
      move.b #3,(TXYLINE_PLANE+1,a1)
    1:
    addq #4,(TXYLINE_XS,a1)
    addq #1,(TXYLINE_YL,a1)
  dbra d1,@b

  moveq #32-1,d1
  @@:
    IOCS _TXYLINE
    subq.b #1,(TXYLINE_PLANE+1,a1)
    bne 1f
      move.b #3,(TXYLINE_PLANE+1,a1)
    1:
    addq #4,(TXYLINE_XS,a1)
    addq #1,(TXYLINE_YS,a1)
    subq #1,(TXYLINE_YL,a1)
  dbra d1,@b

  move #$8000+3,(TXYLINE_PLANE,a1)
  move #384,(TXYLINE_XS,a1)
  move #32,(TXYLINE_YS,a1)
  move #256,(TXYLINE_YL,a1)
  move #$00cc,(TXYLINE_LINE,a1)

  moveq #32-1,d1
  @@:
    IOCS _TXYLINE
    subq.b #1,(TXYLINE_PLANE+1,a1)
    bne 1f
      move.b #3,(TXYLINE_PLANE+1,a1)
    1:
    addq #4,(TXYLINE_XS,a1)
    addq #1,(TXYLINE_YL,a1)
    not.b (TXYLINE_LINE+1,a1)
  dbra d1,@b

  moveq #32-1,d1
  @@:
    IOCS _TXYLINE
    subq.b #1,(TXYLINE_PLANE+1,a1)
    bne 1f
      move.b #3,(TXYLINE_PLANE+1,a1)
    1:
    addq #4,(TXYLINE_XS,a1)
    addq #1,(TXYLINE_YS,a1)
    subq #1,(TXYLINE_YL,a1)
    not.b (TXYLINE_LINE+1,a1)
  dbra d1,@b

  DOS _EXIT


.bss
.quad

txylineBuf: .ds.b sizeof_TXYLINE


.end ProgramStart
