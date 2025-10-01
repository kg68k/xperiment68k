.title iocs_txrascpy - IOCS _TXRASCPY sample

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

.include fefunc.mac
.include dosdef.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac

DEFAULT_DIRECTION: .equ 0
DEFAULT_PLANE: .equ %0011

.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntByte
  move.b d0,-(sp)
  move (sp)+,d1  ;コピー元ラスタ番号

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntByte
  move.b d0,d1  ;コピー先ラスタ番号

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntWord
  move d0,d2  ;ラスタ数

  moveq #DEFAULT_DIRECTION<<8,d3  ;省略時は下方向
  SKIP_SPACE a0
  beq @f
    bsr ParseIntByte
    move.b d0,-(sp)
    move (sp)+,d3  ;ポインタ移動方向
  @@:

  move.b #DEFAULT_PLANE,d3  ;省略時はプレーン0,1
  SKIP_SPACE a0
  beq @f
    bsr ParseIntByte
    move.b d0,d3  ;テキストプレーン
  @@:

  IOCS _B_CUROFF
  IOCS _TXRASCPY
  IOCS _B_CURON

  DOS _EXIT


PrintUsage:
  lea (strUsage,pc),a0
  bra Fatal


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PARSEINTBYTE ParseIntByte
  DEFINE_FATAL Fatal


.data

strUsage:
  .dc.b 'usage: iocs_txrascpy '
  .dc.b '<コピー元> <コピー先> <ラスタ数> [移動方向(0:下,-1:上)] [テキストプレーン]'
  .dc.b CR,LF,0


.end ProgramStart
