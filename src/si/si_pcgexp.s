.title si_pcgexp - show information: PCG expantion

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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
.include iomap.mac

.include xputil.mac


SPRC_CONTROL: .equ $00eb0808
SPRC_PATTERN: .equ $00eb8000


.cpu 68000
.text

ProgramStart:
  pea (PcgExpantion_IsExpanded,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  lea (strNotInst,pc),a0
  tst.l d0
  beq @f
    lea (strInst,pc),a0
  @@:
  DOS_PRINT (strPcgExp,pc)
  DOS_PRINT (a0)

  DOS _EXIT


.data
strPcgExp:  .dc.b 'PCG expansion: ',0
strNotInst: .dc.b 'not installed',CR,LF,0
strInst:    .dc.b 'installed',CR,LF,0


.offset 0
~scr_locate: .ds.w 2  ;x, y
~scr_consol: .ds.l 2  ;x, y
~scr_crtmod: .ds.w 1
sizeof_scr:
.text

;画面モードを保存する
;in a0.l 保存バッファ(sizeof_scr バイト)
ScreenSettings_Save:
  PUSH d1-d2

  moveq #-1,d1
  IOCS _B_LOCATE
  move.l d0,(~scr_locate,a0)

  moveq #-1,d1
  moveq #-1,d2
  IOCS _B_CONSOL
  movem.l d1-d2,(~scr_consol,a0)

  moveq #-1,d1
  IOCS _CRTMOD
  move d0,(~scr_crtmod,a0)

  POP d1-d2
  rts

;画面モードを復元する
;in a0.l 保存バッファ(sizeof_scr バイト)
ScreenSettings_Restore:
  PUSH d1-d2

  move (~scr_crtmod,a0),d1
  ori #$100,d1
  IOCS _CRTMOD

  movem.l (~scr_consol,a0),d1-d2
  IOCS _B_CONSOL

  movem.w (~scr_locate,a0),d1/d2
  IOCS _B_LOCATE

  POP d1-d2
  rts


;増設していないときに読み出される$ffff以外の値にすること
PCG_CHECK_PATTERN: .equ $aa55
.fail PCG_CHECK_PATTERN.eq.$ffff

;PCGメモリが増設されているか調べる。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 0:なし 1:あり
PcgExpantion_IsExpanded::
  link a6,#-sizeof_scr
  PUSH d1-d3/d7/a0-a1
  moveq #%10,d7
  and (CRTC_R20),d7
  beq @f  ;水平256または512ドットならPCGアクセス可能
    lea (-sizeof_scr,a6),a0
    bsr ScreenSettings_Save
    move #$100+12,d1  ;31kHz,512x512,64k
    IOCS _CRTMOD      ;PCGアクセス可能な画面モードに変更する
  @@:

  lea (SPRC_CONTROL),a0
  lea (SPRC_PATTERN),a1
  move sr,d3
  DI
  move (a0),d2
  move #%100_0000_0000,(a0)  ;バンク1を選択
  move (a1),d0
  move #PCG_CHECK_PATTERN,(a1)
  move (a1),d1  ;PCGメモリが増設されていなければ$ffffが読み出される
  move d0,(a1)
  move d2,(a0)
  move d3,sr

  tst d7
  beq @f
    lea (-sizeof_scr,a6),a0  ;画面モードを変更していたら元に戻す
    bsr ScreenSettings_Restore
  @@:
  moveq #0,d0
  cmpi #PCG_CHECK_PATTERN,d1
  bne @f
    moveq #1,d0  ;PCGメモリが増設されている
  @@:
  POP d1-d3/d7/a0-a1
  unlk a6
  rts


.end ProgramStart
