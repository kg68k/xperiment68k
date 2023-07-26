.title sp3tx0gr2 - vc priority test (sp=%11 tx=%00 gr=%10)

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
.include dosdef.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


VC_R1: .equ $00e82500
VC_R2: .equ $00e82600

SCREEN_WIDTH:  .equ 512
SCREEN_HEIGHT: .equ 512

SP_OFFSET_X: .equ 16
SP_OFFSET_Y: .equ 16
SP_WIDTH:  .equ 16
SP_HEIGHT: .equ 16


.cpu 68000
.text

Start:
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d0,d7  ;option

  USE_GVRAM
  TO_SUPER

  bsr initScreen
  bsr drawText
  bsr drawGraphic
  bsr drawSprite

  move.l d7,d0
  bsr setVcReg

  DOS _EXIT


AnalyzeArgument:
  SKIP_SPACE a0
  beq 8f
    moveq #1,d0
    bra 9f
  8:
    moveq #0,d0
  9:
  rts


initScreen:
  move.l #16<<16+4,-(sp)  ;512x512 256 color
  DOS _CONCTRL
  addq.l #4,sp

  moveq #1,d1
  move.l #$f83e,d2
  IOCS _TPALET

  IOCS _G_CLR_ON
  rts


;VC R1 priority
SP_PR: .equ %11
TX_PR: .equ %00
GR_PR: .equ %10

;VC R2
YS:   .equ %1
AH:   .equ %0
EXON: .equ %1
HP:   .equ %1
BP:   .equ %1
GG:   .equ %1
GT:   .equ %0

setVcReg:
  move #SP_PR<<12+TX_PR<<10+GR_PR<<8+%1110_0100,(VC_R1)

  tst.l d0
  beq @f
    move #YS<<15+AH<<14+EXON<<12+HP<<11+BP<<10+GG<<9+GT<<8+%0110_1111,(VC_R2)
  @@:
  rts


drawText:
  lea (txfillData,pc),a1
  IOCS _TXFILL
  rts

txfillData:
  .dc 0
  .dc (SCREEN_WIDTH-128)/2,(SCREEN_HEIGHT/2)-32
  .dc 128,32
  .dc $ffff


drawGraphic:
  moveq #2,d1
  move.l #%01100_11111_01100_0,d2
  IOCS _GPALET

  moveq #0,d1
  IOCS _APAGE

  lea (fillData,pc),a1
  IOCS _FILL
  rts

fillData:
  .dc SCREEN_WIDTH/2-24,(SCREEN_HEIGHT-128)/2
  .dc SCREEN_WIDTH/2-1,(SCREEN_HEIGHT+128)/2-1
  .dc 2


drawSprite:
  PUSH d2-d5
  IOCS _SP_INIT
  IOCS _SP_ON

  bsr definePcg

  move.l #1<<31+0,d1
  move.l #SP_OFFSET_X+(SCREEN_WIDTH-SP_WIDTH)/2,d2
  move.l #SP_OFFSET_Y+(SCREEN_HEIGHT-SP_HEIGHT)/2,d3
  move.l #0<<8+0,d4
  move.l #1,d5
  IOCS _SP_REGST

  POP d2-d5
  rts

definePcg:
  move.l #$2222_2222,d0
  lea (PcgBuffer,pc),a0
  bsr fillPcg16x16

  moveq #0,d1
  moveq #1,d2  ;16x16
  lea (PcgBuffer,pc),a1
  IOCS _SP_DEFCG
  rts

fillPcg16x16:
  moveq #32*4/4-1,d1
  @@:
    move.l d0,(a0)+
  dbra d1,@b
  rts


.bss

PcgBuffer: .ds.b 32*4


.end
