.title spchecker - display sprite in a checkerboard pattern

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
.include doscall.mac
.include iocscall.mac


;左上256x256の範囲にだけ表示する。
SCREEN_WIDTH:  .equ 256
SCREEN_HEIGHT: .equ 256

SP_COUNT: .equ 128
SP_OFFSET_X: .equ 16
SP_OFFSET_Y: .equ 16
SP_WIDTH:  .equ 16
SP_HEIGHT: .equ 16

SP_PER_LINE: .equ 8

;パレットブロック0はテキスト画面で使っているので避ける。
USE_PALBLK_FROM: .equ $1
USE_PALBLK_TO:   .equ $f

USE_PCG_FROM:  .equ $f1
USE_PCG_TO:    .equ $ff
USE_PCG_COUNT: .equ (USE_PCG_TO-USE_PCG_FROM+1)

NO_VSYNC: .equ (1<<31)
SP_SIZE_16x16: .equ 1


.cpu 68000
.text

Start:
  move.l #16<<16+2,-(sp)  ;512x512 no color
  DOS _CONCTRL
  addq.l #4,sp

  moveq #0,d1
  moveq #SCREEN_HEIGHT/16,d2
  IOCS _B_LOCATE  ;スプライトに重ならない位置にカーソルを移動する。

  IOCS _SP_INIT
  IOCS _SP_ON

  bsr definePcg
  bsr setSpPallete
  bsr setSpRegister

  DOS _EXIT


definePcg:
  PUSH d4-d7
  move.l #USE_PCG_FROM,d4
  move.l #$1111_1111,d5
  move.l d5,d6
  moveq #USE_PCG_COUNT-1,d7
  @@:
    move.l d6,d0
    lea (PcgBuffer,pc),a0
    bsr fillPcg16x16

    move.l d4,d1
    moveq #SP_SIZE_16x16,d2
    lea (PcgBuffer,pc),a1
    IOCS _SP_DEFCG

    addq.b #1,d4
    add.l d5,d6
  dbra d7,@b
  POP d4-d7
  rts

fillPcg16x16:
  moveq #32*4/4-1,d1
  @@:
    move.l d0,(a0)+
  dbra d1,@b
  rts


setSpPallete:
  PUSH d3-d7
  move.l #NO_VSYNC+USE_PALBLK_FROM*16,d6
  moveq #0,d2  ;パレットブロック指定なし(d1.bで16～255のパレットコードを指定)。
  move.l #0<<16+$1f<<8+$1f,d5  ;hsv
  move.l #1<<16,d4  ;h 増加分
  move #256-16-1,d7
  1:
    cmpi.l #%110_00000_000_00000_000_00000,d5
    bcs @f
      move.l #0<<16+$1f<<8+$1f,d5  ;hsv
    @@:
    move.l d5,d1
    IOCS _HSVTORGB
    move.l d0,d3
    move.l d6,d1
    IOCS _SPALET

    moveq #$f,d0
    and.b d6,d0
    beq @f
      add.l d4,d5
      eori.l #%11<<16,d4
    @@:
    addq #1,d6
  dbra d7,1b

  POP d3-d7
  rts

err: .dc.b 'hsv error',13,10,0
.even

setSpRegister:
  PUSH d2-d6
  moveq #0<<16+SP_WIDTH,d6  ;行ごとにX座標をずらす。
  move.l #NO_VSYNC+0,d1
  move.l #USE_PALBLK_FROM<<8+USE_PCG_FROM,d4
  move.l #3,d5
  moveq #SP_OFFSET_Y,d3  ;上から下へ
  1:
    moveq #SP_OFFSET_X,d2  ;左から右へ
    add d6,d2  ;偶数行は1個分右へずらす
    swap d6
    2:
      IOCS _SP_REGST

      .fail USE_PCG_TO.ne.$ff
      addq.b #1,d4  ;pattern code += 1
      bne @f
        move.b #USE_PCG_FROM,d4
        addi #1<<8,d4  ;palette block += 1
        cmpi #(USE_PALBLK_TO+1)<<8,d4
        bcs @f
          move #USE_PALBLK_FROM<<8+USE_PCG_FROM,d4
      @@:
      addq.b #1,d1  ;sprite no += 1
    addi #SCREEN_WIDTH/SP_PER_LINE,d2  ;x += 32
    cmpi #SP_OFFSET_X+SCREEN_WIDTH,d2
    bcs 2b
  addi #SP_HEIGHT,d3  ;y += 16
  cmpi #SP_OFFSET_Y+SCREEN_HEIGHT,d3
  bcs 1b

  POP d2-d6
  rts


.bss

.even
PcgBuffer: .ds.b 32*4


.end
