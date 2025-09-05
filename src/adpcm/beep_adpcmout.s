.title beep_adpcmout - play beep with IOCS _ADPCMOUT

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
.include iocscall.mac
.include iocswork.mac

.include xputil.mac

PLAY_FREQ: .equ 4
PLAY_PAN:  .equ 3


.cpu 68000
.text

ProgramStart:
  pea (GetBeepData,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  bsr IsValidBeepData
  bne @f
    DOS_PRINT (InvalidBeepDataMessage,pc)
    bra exit
  @@:

  move #PLAY_FREQ<<8+PLAY_PAN,d1
  IOCS _ADPCMOUT
exit:
  DOS _EXIT


;システムに登録されているビープ音の情報を取得する
;out  d2.l  バイト数($ffff以下)
;     a1.l  アドレス
GetBeepData:
  moveq #0,d2
  move (BEEPLEN).w,d2
  movea.l (BEEPADR).w,a1
  rts

IsValidBeepData:
  tst.l d2
  beq @f
  move.l a1,d0
  beq @f
    moveq #1,d0
    rts
  @@:
  moveq #0,d0
  rts


.data

InvalidBeepDataMessage: .dc.b 'BEEP音データが登録されていません。',CR,LF,0


.end ProgramStart
