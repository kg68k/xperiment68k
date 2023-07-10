.title con_scroll - console scroll test

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

.include console.mac
.include doscall.mac
.include iocscall.mac

.cpu 68000
.text

  moveq #18,d1  ;ソフトコピー
  IOCS _B_CONMOD

  lea (strSoftCopy,pc),a0
  bsr Scroll

  moveq #17,d1  ;ラスタコピー
  IOCS _B_CONMOD

  moveq #1,d0
  lea (strRaster4dot,pc),a0
  bsr RasterScroll

  moveq #2,d0
  lea (strRaster8dot,pc),a0
  bsr RasterScroll

  moveq #3,d0
  lea (strRaster16dot,pc),a0
  bsr RasterScroll

  moveq #0,d0
  lea (strRasterJump,pc),a0
  bsr RasterScroll

  DOS _EXIT


RasterScroll:
  moveq #16,d1
  move.l d0,d2
  IOCS _B_CONMOD
  bsr Scroll
  rts

Scroll:
  moveq #0,d1
  moveq #15,d2
  IOCS _B_LOCATE
  movea.l a0,a1
  IOCS _B_PRINT
  @@:
    bsr ScrollUp
    bsr ScrollDown
    IOCS _B_KEYSNS
  tst.b d0
  beq @b
  IOCS _B_KEYINP
  rts

ScrollUp:
  moveq #0,d1
  moveq #30,d2
  IOCS _B_LOCATE

  moveq #8-1,d1
  @@:
    IOCS _B_DOWN_S
  dbra d1,@b
  rts

ScrollDown:
  moveq #0,d1
  moveq #0,d2
  IOCS _B_LOCATE

  moveq #8-1,d1
  @@:
    IOCS _B_UP_S
  dbra d1,@b
  rts


.data

strSoftCopy:    .dc.b 'ソフトコピー                     ',13,10,0
strRasterJump:  .dc.b 'ラスターコピー ジャンプスクロール',13,10,0
strRaster4dot:  .dc.b 'ラスターコピー  4ドットスクロール',13,10,0
strRaster8dot:  .dc.b 'ラスターコピー  8ドットスクロール',13,10,0
strRaster16dot: .dc.b 'ラスターコピー 16ドットスクロール',13,10,0


.end
