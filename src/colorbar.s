.title colorbar - draw a pattern like a color bar

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

;ref. http://elm-chan.org/docs/vits/test.html

.include include/iomap.mac
.include include/macro.mac
.include include/doscall.mac
.include include/iocscall.mac
.include include/iocswork.mac

.include include/xputil.mac

CRTMOD_512x512_64K_31kHz: .equ 12
CRTMOD_768x512_16_31kHz:  .equ 16

.cpu 68000
.text

Start:
  USE_GVRAM
  bsr changeScreenMode0
  bsr execGClrOn64k
  GM_MASK_REQUEST
  bsr drawColorBar
  bsr drawText
  DOS _EXIT


changeScreenMode0:
  move.l #16<<16+0,-(sp)  ;画面モード0(IOCS _CRTMOD 16番、グラフィックなし)
  DOS _CONCTRL
  move.l #14<<16+0,(sp)  ;ファンクションキー表示
  DOS _CONCTRL
  addq.l #4,sp
  rts

execGClrOn64k:
  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,-(sp)

  ;CRTMOD 12番に見せかける
  move.b #1,(GRPAGE)
  move.l #511<<16+511,(GRXMAX)  ;GRXMAX, GRYMAX
  move.b #CRTMOD_512x512_64K_31kHz,(CRTMOD)

  IOCS _G_CLR_ON

  ;CRTMOD 16番に戻す
  move.b #CRTMOD_768x512_16_31kHz,(CRTMOD)

  bsr setScrollToCenter

  movea.l (sp)+,a1
  IOCS _B_SUPER
  rts

setScrollToCenter:
  move.l #(512-(768-512)/2)<<16+0,d0
  lea (CRTC_R12),a0
  .rept 4
    move.l d0,(a0)+
  .endm
  rts


drawColorBar:
  lea (fillData,pc),a1
  @@:
    IOCS _FILL
    lea (sizeof_FILL,a1),a1
  tst (a1)
  bpl @b
  rts

drawText:
  lea (MPUTYPE),a1
  IOCS _B_BPEEK
  lea (symbolText+.sizeof.('X680'),pc),a1
  add.b d0,(a1)  ;X68000 -> X68030

  lea (symbolData,pc),a1
  IOCS _SYMBOL
  rts


.data
.even

;startX,startY,endX,endY,palette
sizeof_FILL: .equ 10

G: .equ %10111_00000_00000_0
R: .equ %00000_10111_00000_0
B: .equ %00000_00000_10111_0
I: .equ %00000_00000_00000_1
_: .equ 0

fillData:
  .dc   0,0, 72,340,R+G+B  ;W
  .dc  73,0,145,340,R+G+_  ;Y
  .dc 146,0,218,340,_+G+B  ;Cy
  .dc 219,0,292,340,_+G+_  ;G
  .dc 293,0,365,340,R+_+B  ;Mg
  .dc 366,0,438,340,R+_+_  ;R
  .dc 439,0,511,340,_+_+B  ;B

  .dc   0,341, 72,383,_+_+B  ;B
  .dc  73,341,145,383,_      ;Bk
  .dc 146,341,218,383,R+_+B  ;Mg
  .dc 219,341,292,383,_      ;Bk
  .dc 293,341,365,383,_+G+B  ;Cy
  .dc 366,341,438,383,_      ;Bk
  .dc 439,341,511,383,R+G+B  ;W

  .dc   0,384, 84,511,%00000_00100_01011_0  ;-I
  .dc  85,384,170,511,%11111_11111_11111_0  ;100% W
  .dc 171,384,255,511,%01000_00000_01111_0  ;+Q
  .dc 256,384,365,511,_  ;Bk
  .dc 366,384,389,511,%00000_00000_00000_0  ;Bk-4IRE
  .dc 490,384,414,511,%00000_00000_00000_1  ;Bk
  .dc 415,384,438,511,%00001_00001_00001_0  ;Bk+4IRE
  .dc 439,384,511,511,_  ;B

  .dc -1

symbolData:
  .dc.w 256+(256-(12*2*.sizeof.('X68000')))/2,384+(128-(24*2))/2
  .dc.l symbolText
  .dc.b 2,2
  .dc.w R+G+B
  .dc.b 2,0

symbolText:
  .dc.b 'X68000',0


.end
