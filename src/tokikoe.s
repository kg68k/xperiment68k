.title tokikoe - toki wo, koeta.

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
.include iocsdef.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (moveFont24Up,pc),a1
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    lea (moveFont24UpRight,pc),a1
  @@:
  lea (MessageData,pc),a0
  bsr putString

  DOS _EXIT


putString:
  PUSH d2/a3-a4
  lea (a1),a2  ;フォント加工ルーチン
  suba.l a1,a1
  IOCS _B_SUPER
  movea.l d0,a4

  lea (CRTC_R21),a3
  moveq #%0001,d1
  IOCS _TCOLOR
  move (a3),d2
  move #%01_0011_0000,(a3)  ;テキストプレーン0,1 同時アクセス有効

  bsr putStringInner

  move d2,(a3)
  moveq #%0001,d1
  IOCS _TCOLOR

  lea (a4),a1
  IOCS _B_SUPER
  POP d2/a3-a4
  rts

putStringInner:
  PUSH d2-d3/a3
  lea (a0),a3
  move.l (a3)+,d3  ;X座標、Y座標
  bra 1f
  @@:
    move (a3)+,d1  ;フォント加工要求
    move.l d3,d2
    bsr putBitmap
    add (a3)+,d3  ;描画Y座標増分
  1:
  move (a3)+,d0  ;文字コード
  bne @b

  POP d2-d3/a3
  rts


putBitmap:
  movea.l d1,a0
  move #12,d1
  swap d1
  move d0,d1
  lea (FontBuffer,pc),a1
  IOCS _FNTGET

  move a0,d0
  beq @f
    jsr (a2)  ;フォント加工
  @@:

  move.l d2,d1
  swap d1
  lea (FontBuffer,pc),a1
  IOCS _TEXTPUT
  rts


moveFont24Up:
  addq.l #FNT_BUF,a1
  lea (3*12,a1),a0
  moveq #0,d0
  moveq #3*12/4-1,d1
  @@:
    move.l (a0),(a1)+
    move.l d0,(a0)+
  dbra d1,@b
  rts

moveFont24UpRight:
  PUSH d2-d4
  addq.l #FNT_BUF,a1
  lea (3*12,a1),a0
  moveq #0,d0
  move #$0fff,d4
  moveq #12/2-1,d1
  @@:
    ;2ライン分6バイトのデータを加工する
    ;$GH,$IJ,$KL,$MN,$OP,$QR -> $00,$0G,$HI,$00,$0M,$NO
    moveq #0,d2
    move (a0),d2    ;$00_00_GH_IJ
    lsl.l #4,d2     ;$00_0G_HI_J0
    clr.b d2        ;$00_0G_HI_00
    move.l d2,(a1)+
    move.l (a0),d3  ;$GH_IJ_KL_MN
    move.l d0,(a0)+

    move (a0),d2    ;$OP_QR
    move.b d3,d2    ;$OP_MN
    rol #4,d2       ;$PM_NO
    and d4,d2       ;$0M_NO
    move d2,(a1)+
    move d0,(a0)+
  dbra d1,@b
  POP d2-d4
  rts


.data

.even
MessageData:
  .dc 768-16-24,64  ;X座標、Y座標

; .dc 文字コード,フォント加工要求,描画Y座標増分
  .dc '時',0,24+18
  .dc 'を',0,24+0
  .dc '、',1,12+14
  .dc '超',0,24+18
  .dc 'え',0,24+18
  .dc 'た',0,24+0
  .dc '。',1,12+14
  .dc 0


.bss
.quad

FontBuffer: .ds.b sizeof_FNT


.end ProgramStart
