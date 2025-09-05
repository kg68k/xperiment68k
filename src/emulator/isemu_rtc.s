.title isemu_rtc - detect if you're on an emulator by RTC

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
.include iomap.mac
.include vector.mac
.include console.mac
.include doscall.mac
.include iocswork.mac

.include xputil.mac


RTC_1HZ_ON:   .equ %0000
RTC_1HZ_OFF:  .equ %1000
RTC_16HZ_ON:  .equ %0000
RTC_16HZ_OFF: .equ %0100


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  bsr IsEmulator
  tst.l d0
  bne 1f
    DOS_PRINT (strNotEmu,pc)
    bra @f
  1:
    DOS_PRINT (strEmu,pc)
  @@:
  DOS _EXIT


.data
strEmu:    .dc.b 'エミュレータです。',CR,LF,0
strNotEmu: .dc.b '実機です。',CR,LF,0
.even
.text


SAVE_MFP_REG: .macro adr,mask,dreg
  moveq #mask,dreg
  and.b (adr),dreg
  move.b dreg,-(sp)
.endm

RESTORE_MFP_REG: .macro adr,mask,dreg
  moveq #.not.(mask),dreg
  and.b (adr),dreg
  or.b (sp)+,dreg
  move.b dreg,(adr)
.endm

;エミュレータ上で実行されているか判別する。
;  スーパーバイザモードで呼び出すこと。
;out d0.l ... 0:実機 1:エミュレータ
IsEmulator:
  PUSH d7
  move sr,d7
  DI
  move.b (RTC_RESET),-(sp)
  move.b #RTC_1HZ_OFF+RTC_16HZ_OFF,(RTC_RESET)
  SAVE_MFP_REG MFP_IMRB,1<<0,d0
  SAVE_MFP_REG MFP_IERB,1<<0,d0
  move.l (RTC1HZ_VEC*4),-(sp)

  move.l #RtcInterrupt,(RTC1HZ_VEC*4)
  ori.b #1<<0,(MFP_IMRB)
  ori.b #1<<0,(MFP_IERB)
  move d7,sr
  move.b #RTC_1HZ_ON+RTC_16HZ_ON,(RTC_RESET)

  @@:
    move.b (HalfSecond,pc),d0
    bne @f
    cmpi #10,(IntCount)
  bls @b
  @@:

  move.b #RTC_1HZ_OFF+RTC_16HZ_OFF,(RTC_RESET)
  move sr,d7
  DI
  move.l (sp)+,(RTC1HZ_VEC*4)
  RESTORE_MFP_REG MFP_IERB,1<<0,d0
  RESTORE_MFP_REG MFP_IMRB,1<<0,d0
  move.b (sp)+,(RTC_RESET)
  move d7,sr

  moveq #0,d0
  move.b (HalfSecond,pc),d0
  addq.b #1,d0
  POP d7
  rts


RtcInterrupt:
  PUSH d0-d2/a0
  lea (IntCount,pc),a0
  move (a0),d2
  addq #1,(a0)+

  DI
  move.l (RUNTIME),d1
  mulu #60*100,d1  ;起動後1日以上経過している場合を考慮していない手抜き
  moveq #0,d0
  move (ALMTINIT),d0
  sub (ALMTIMER),d0
  add.l d1,d0  ;起動後の経過時間(1/100秒単位)

  move.l (a0),d1  ;Ontime
  move.l d0,(a0)+

  tst d2
  beq @f  ;初回の割り込み
    sub.l d1,d0  ;前回の割り込みからの経過時間
    cmpi.l #0.5*100,d0
    scc d0
    or.b d0,(a0)  ;HalfSecond
  @@:

  POP d0-d2/a0
  rte


.even
IntCount:   .dc.w 0
Ontime:     .dc.l 0
HalfSecond: .dc.b 0
.even


.end
