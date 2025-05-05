.title rtc_reg - show RTC(RP5C15) registers

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
.include iomap.mac
.include console.mac
.include doscall.mac

.include xputil.mac


RTC_REGS_PER_BANK: .equ 16


.cpu 68000
.text

ProgramStart:
  lea (RtcRegValues,pc),a0
  pea (ReadRtcRegValues,pc)
  DOS _SUPER_JSR
  addq.l #4,sp

  DOS_PRINT (strHeader,pc)
  lea (RtcRegValues,pc),a1
  lea (strBank0,pc),a0
  bsr PrintBank
  lea (strBank1,pc),a0
  bsr PrintBank

  DOS _EXIT


PrintBank:
  link a6,#-64  ;.sizeof.('xx ')*RTC_REGS_PER_BANK+.sizeof.('| ') より大きいこと
  DOS_PRINT (a0)

  lea (sp),a0
  moveq #RTC_REGS_PER_BANK-1,d2
  1:
    cmpi #8-1,d2
    bne @f
      move.b #'|',(a0)+  ;0fと01の間に仕切りを入れる
      move.b #' ',(a0)+
    @@:
    move.b (a1)+,d0
    bsr ToHexString2
    move.b #' ',(a0)+
  dbra d2,1b
  clr.b -(a0)
  DOS_PRINT (sp)

  DOS_PRINT (CrLf,pc)
  unlk a6
  rts


ReadRtcRegValues:
  PUSH d1/a0-a2
  lea (RTC),a1
  PUSH_SR_DI
  bsr ReadRtcRegValuesSub
  POP_SR
  POP d1/a0-a2
  rts


ReadRtcRegValuesSub:
  move.b (~RTC_MODE,a1),d1

  move.b d1,d0
  bclr #0,d0
  beq @f  ;もともとbank 0なら変更不要
    bsr WriteRtcMode  ;bank 0に変更
  @@:
  bsr ReadRtcBank

  move.b d1,d0
  bset #0,d0
  bsr WriteRtcMode  ;bank 1に変更
  bsr ReadRtcBank

  move.b d1,d0
  bclr #0,d0
  bne @f  ;もともとbank 1なら変更不要
    bsr WriteRtcMode
  @@:
  rts


ReadRtcBank:
  lea (~RTC_1SEC,a1),a2
  moveq #RTC_REGS_PER_BANK-1,d0
  @@:
    move.b (a2),(a0)+
    addq.l #2,a2
  dbra d0,@b
  rts


WriteRtcMode:
  move.b d0,(~RTC_MODE,a1)
  tst.b (JOYSTICK1)  ;バンク変更後のウェイト
  tst.b (JOYSTICK1)  ;
  rts


  DEFINE_TOHEXSTRING2 ToHexString2


.data

strHeader: .dc.b 'RTC     01 03 05 07 09 0b 0d 0f | 11 13 15 17 19 1b 1d 1f',CR,LF,0
strBank0:  .dc.b 'bank 0: ',0
strBank1:  .dc.b 'bank 1: ',0

CrLf: .dc.b CR,LF,0


.bss
.even

RtcRegValues: .ds.b RTC_REGS_PER_BANK*2


.end
