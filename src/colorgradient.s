.title colorgradient - draw color gradients

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

.include doscall.mac

.include xputil.mac


GVRAM: .equ $c00000
COLOR_DEPTH:        .equ 32
COLOR_DEPTH_WITH_I: .equ COLOR_DEPTH*2
DOTS_PER_LINE: .equ 512
BYTES_PER_LINE: .equ DOTS_PER_LINE*2

BOX_WIDTH: .equ DOTS_PER_LINE/COLOR_DEPTH_WITH_I
BOX_HEIGHT: .equ 24

COLORS: .equ 7  ;BRGの組み合わせ、ただし黒は除く

TOTAL_HEIGHT: .equ BOX_HEIGHT*COLORS
CENTER_MARGIN: .equ BOX_HEIGHT/2


.cpu 68000
.text

ProgramStart:
  USE_GVRAM

  move #5,-(sp)  ;512x512, 65536色
  move #16,-(sp)
  DOS _CONCTRL
  addq.l #4,sp

  clr.l -(sp)
  DOS _SUPER

  moveq #0,d0  ;輝度なし
  lea (GVRAM+(256-CENTER_MARGIN-TOTAL_HEIGHT)*BYTES_PER_LINE),a0
  bsr DrawGradients

  moveq #1,d0  ;輝度あり
  lea (GVRAM+(256+CENTER_MARGIN)*BYTES_PER_LINE),a0
  bsr DrawGradients

  DOS _EXIT


DrawGradients:
  move d0,d5
  swap d5
  move d0,d5
  lea (a0),a5

  lea (PalleteTable,pc),a6
  moveq #COLORS-1,d7
  1:
    lea (a5),a4
    moveq #COLOR_DEPTH_WITH_I-1,d6
    2:
      move (a6),d0  ;パレットコード
      swap d0
      move (a6),d0

      btst #0,d6
      bne @f
        addq.l #2,a6  ;右ブロックなら次回用のパレットに進めておく
        or.l d5,d0  ;輝度ありの右ブロックなら、輝度ビットを1にする
      @@:

      regs: .reg d0-d3
      .fail .sizeof.(regs).ne.(BOX_WIDTH*2)
      .irp reg,d1,d2,d3
        move.l d0,reg
      .endm

      lea (a4),a3
      n:=0
      .rept BOX_HEIGHT
        movem.l regs,(n*BYTES_PER_LINE,a3)
        n:=n+1
      .endm
      lea (BOX_WIDTH*2,a4),a4
    dbra d6,2b

    adda.l #BYTES_PER_LINE*BOX_HEIGHT,a5
  dbra d7,1b
  rts


.data

.even
PalleteTable:
  cc:=1
  .rept COLORS
    n:=0
    .rept COLOR_DEPTH
      g:=((cc>>2).and.1)*n
      r:=((cc>>1).and.1)*n
      b:=((cc>>0).and.1)*n
      .dc (g<<11)+(r<<6)+(b<<1)
      n:=n+1
    .endm
    cc:=cc+1
  .endm


.end
