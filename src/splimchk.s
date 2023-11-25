.title splimchk - sprite limit checker

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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


SCREEN_WIDTH:  .equ 512
SCREEN_HEIGHT: .equ 512

SP_OFFSET_X: .equ 16
SP_OFFSET_Y: .equ 16
SP_WIDTH:  .equ 16
SP_HEIGHT: .equ 16

SINGLE_SP_PER_LINE: .equ 128
DOUBLE_SP_PER_LINE: .equ 128/2


.cpu 68000
.text

Start:
  bsr getOption
  move.l d0,d7

  move.l #16<<16+2,-(sp)  ;512x512 no color
  DOS _CONCTRL
  addq.l #4,sp

  IOCS _SP_INIT
  IOCS _SP_ON

  bsr definePcg
  bsr setSpPallete

  tst d7
  bne 2f
    bsr setSpRegSingle
    bra @f
  2:
    bsr setSpRegDouble
  @@:

  DOS _EXIT


getOption:
  PUSH a2
  addq.l #1,a2
  moveq #0,d1
  bra 8f
  1:
    cmpi.b #'1',d0
    bne @f
      moveq #0,d1  ;single line mode
      bra 8f
    @@:
    cmpi.b #'2',d0
    bne @f
      moveq #1,d1  ;double line mode
      bra 8f
    @@:
  8:
  move.b (a2)+,d0
  bne 1b

  move.l d1,d0
  POP a2
  rts


definePcg:
  PUSH d6-d7
  moveq #16-1,d7
  moveq #0,d6
  @@:
    move.l d6,d0
    lea (PcgBuffer,pc),a0
    bsr fillPcg16x16

    moveq #$f,d1
    and.b d6,d1
    moveq #1,d2  ;16x16
    lea (PcgBuffer,pc),a1
    IOCS _SP_DEFCG

    addi.l #$1111_1111,d6
  dbra d7,@b
  POP d6-d7
  rts

fillPcg16x16:
  moveq #32*4/4-1,d1
  @@:
    move.l d0,(a0)+
  dbra d1,@b
  rts


setSpPallete:
  PUSH d2-d7
  moveq #1,d6  ;palette code
  move.l #0<<16+$1f<<8+$1f,d5  ;hsv
  move.l #1<<16,d4  ;h 増加分
  moveq #15-1,d7
  @@:
    move.l d5,d1
    IOCS _HSVTORGB
    move.l d0,d2
    move.l d6,d1
    IOCS _TPALET2

    add.l d4,d5
    eori.l #%11<<16,d4
    addq #1,d6
  dbra d7,@b

  bset #31,d6  ;no v-sync
  moveq #0,d2  ;palette block
  moveq #(128-16)-1,d7
  @@:
    move.l d5,d1
    IOCS _HSVTORGB
    move.l d0,d3
    move.l d6,d1
    IOCS _SPALET

    add.l d4,d5
    eori.l #%11<<16,d4
    addq #1,d6
  dbra d7,@b

  POP d2-d7
  rts


setSpRegSingle:
  PUSH d2-d5
  move.l #1<<31+0,d1
  move.l #SP_OFFSET_X+SCREEN_WIDTH-(SCREEN_WIDTH/SINGLE_SP_PER_LINE),d2
  move.l #SP_OFFSET_Y+(SCREEN_HEIGHT-SP_HEIGHT)/2,d3
  move.l #0<<8+0,d4
  move.l #3,d5
  1:
    IOCS _SP_REGST
    subq #(SCREEN_WIDTH/SINGLE_SP_PER_LINE),d2  ;x -= 4
    addq.b #1,d4  ;pattern code += 1
    bclr #4,d4
    beq @f
      addi #1<<8,d4  ;palette block += 1; pattern code = 0
    @@:
  addq.b #1,d1  ;sprite no += 1
  bpl 1b  ;0-127

  POP d2-d5
  rts


setSpRegDouble:
  bsr setSpRegDoubleUpper
  bsr setSpRegDoubleLower
  rts

setSpRegDoubleUpper:
  PUSH d2-d5
  move.l #1<<31+0,d1
  move.l #SP_OFFSET_X+SCREEN_WIDTH-(SCREEN_WIDTH/DOUBLE_SP_PER_LINE),d2
  move.l #SP_OFFSET_Y+SCREEN_HEIGHT/2-SP_HEIGHT,d3
  move.l #0<<8+0,d4
  move.l #3,d5
  1:
    IOCS _SP_REGST
    subq #(SCREEN_WIDTH/DOUBLE_SP_PER_LINE),d2  ;x -= 8
    addq.b #1,d4  ;pattern code += 1
    bclr #4,d4
    beq @f
      addi #1<<8,d4  ;palette block += 1; pattern code = 0
    @@:
  addq.b #1,d1  ;sprite no += 1
  cmpi.b #DOUBLE_SP_PER_LINE,d1
  bne 1b  ;0-63

  POP d2-d5
  rts

setSpRegDoubleLower:
  PUSH d2-d5
  move.l #1<<31+DOUBLE_SP_PER_LINE,d1
  move.l #SP_OFFSET_X-SP_WIDTH+(SCREEN_WIDTH/DOUBLE_SP_PER_LINE),d2
  move.l #SP_OFFSET_Y+SCREEN_HEIGHT/2,d3
  move.l #(DOUBLE_SP_PER_LINE/16)<<8+0,d4
  move.l #3,d5
  1:
    IOCS _SP_REGST
    addq #(SCREEN_WIDTH/DOUBLE_SP_PER_LINE),d2  ;x += 8
    addq.b #1,d4  ;pattern code += 1
    bclr #4,d4
    beq @f
      addi #1<<8,d4  ;palette block += 1; pattern code = 0
    @@:
  addq.b #1,d1  ;sprite no += 1
  bpl 1b  ;64-127

  POP d2-d5
  rts


.bss

PcgBuffer: .ds.b 32*4


.end
