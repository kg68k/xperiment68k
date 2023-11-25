.title sq64k - square 64k color mode

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

.include iomap.mac
.include macro.mac
.include doscall.mac
.include iocscall.mac
.include iocswork.mac

.include xputil.mac

CRTMOD_512x512_64K_31kHz: .equ 12
CRTMOD_768x512_16_31kHz:  .equ 16

.cpu 68000
.text

Start:
  USE_GVRAM
  bsr setScreenMode0
  bsr setColor64k
  GM_MASK_REQUEST
  DOS _EXIT

setScreenMode0:
  move.l #16<<16+$ffff,-(sp)
  DOS _CONCTRL
  move.l d0,(sp)+
  beq @f
    move.l #16<<16+0,-(sp)  ;画面モード0(IOCS _CRTMOD 16番、グラフィックなし)
    DOS _CONCTRL
    move.l #14<<16+0,(sp)  ;ファンクションキー表示
    DOS _CONCTRL
    addq.l #4,sp
  @@:
  rts

setColor64k:
  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,-(sp)

  move.l #GVRAM,(GRADR)
  move #$ffff,(GRCOLMAX)
  moveq #%011,d0
  move.b d0,(CRTC_R20H)  ;色数設定
  move d0,(VC_R0)        ;色数設定
  move.l #512*2,(GRLLEN)
  clr.l (GRXMIN)                ;GRXMIN, GRYMIN
  move.l #511<<16+511,(GRXMAX)  ;GRXMAX, GRYMAX
  move.b #1,(GRPAGE)

  bsr setPalette64k
  bsr setScrollToCenter

  move #$003f,(VC_R2)  ;テキスト・グラフィック画面表示

  movea.l (sp)+,a1
  IOCS _B_SUPER
  rts

setPalette64k:
  lea (GPALET),a0
  move.l #$0001_0001,d1
  movea.l #$0202_0202,a1
  moveq #256/2-1,d0
  @@:
    move.l d1,(a0)+
    add.l a1,d1
  dbra d0,@b
  rts

setScrollToCenter:
  move.l #(512-(768-512)/2)<<16+0,d0
  lea (CRTC_R12),a0
  .rept 4
    move.l d0,(a0)+
  .endm
  rts


.end
