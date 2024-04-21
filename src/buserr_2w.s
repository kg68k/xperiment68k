.title buserr_2w - cause bus error at second word access

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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
.include console.mac
.include doscall.mac

.include xputil.mac


GVRAM: .equ $00c0_0000


.cpu 68000
.text

Start:
  bsr GetMainMemorySize
  movea.l d0,a0
  subq.l #2,a0

  DOS_PRINT (Message,pc)

  move.l (a0),d0  ;バスエラーを発生させる

  DOS _EXIT


GetMainMemorySize:
  suba.l a0,a0
  @@:
    adda.l #$0010_0000,a0
    bsr DosBusErrorWord
    bne @f
      cmpa.l #GVRAM,a0
      bne @b
  @@:
  move.l a0,d0
  rts

  DEFINE_DOSBUSERRWORD DosBusErrorWord


.data

Message: .dc.b 'バスエラーを発生させます。',CR,LF,0


.end
