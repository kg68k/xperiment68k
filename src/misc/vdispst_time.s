.title vdispst_time - print time to interrupt of IOCS _VDISPST

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

.include iomap.mac
.include macro.mac
.include fefunc.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #1,d0  ;カウンター省略時は1
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d0,d7
  bmi exit

  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,d5

  IOCS _ONTIME
  move.l d0,d6  ;開始時間

  move d7,d1
  lea (TimerAInterrupt,pc),a1
  move.l d7,d0
  swap d0
  bsr Vdispst
  tst.l d0
  beq @f
    DOS_PRINT (AlreadyUsed,pc)
    bra exit
  @@:

  @@:
    move.b (TimerACalled,pc),d0  ;割り込みが発生するまで待つ
  beq @b

  IOCS _ONTIME
  move.l d0,d7  ;終了時間

  moveq #0,d1
  suba.l a1,a1
  IOCS _VDISPST

  movea.l d5,a1
  IOCS _B_SUPER

  move.l d7,d0
  cmp.l d6,d0
  bcc @f
    addi.l #24*60*60,d0  ;起動後24時間を跨いだ
  @@:
  sub.l d6,d0  ;経過時間(1/100秒単位)
  bsr PrintD0Dec
  DOS_PRINT_CRLF
exit:
  DOS _EXIT


AnalyzeArgument:
  move.l d7,-(sp)
  move.l d0,d7
  SKIP_SPACE a0
  1:
    move.b (a0)+,d0
    beq 9f
    cmpi.b #' ',d0
    beq 1b
    cmpi.b #'a',d0
    bne @f
      ori.l #$00ff_0000,d7  ;-a 不具合回避を行う
      bra 1b
    @@:
    subq.l #1,a0
    FPACK __STOL
    bcs @f
    cmpi.l #255,d0
    bls 2f
    @@:
      DOS_PRINT (CounterError,pc)
      moveq #-1,d7
      bra 9f
    2:
    move.b d0,d7
  bra 1b
9:
  move.l d7,d0
  move.l (sp)+,d7
  rts


TimerAInterrupt:
  st (TimerACalled)
  rte


;IOCS _VDISPSTを呼び出す
;in d0.b ... 0以外なら不具合を回避して割り込みを設定する
;  スーパーバイザモードで呼び出すこと。
Vdispst:
  tst.b d0
  bne @f
    IOCS _VDISPST
    rts
  @@:
  PUSH d1/a1
  lea (VdispstRte,pc),a1
  moveq #0<<8+1,d1  ;ほかのプログラムで使用中にTACRを書き換えないように
  IOCS _VDISPST     ;ダミーの割り込みを設定してみて使用中かどうかを調べる
  POP d1/a1
  tst.l d0
  bne @f  ;使用中ならエラー終了
    PUSH d1/a1
    moveq #0<<8+1,d1  ;ダミーの割り込みが設定できたら解除する
    suba.l a1,a1
    IOCS _VDISPST
    POP d1/a1

    move.l a0,-(sp)
    lea (MFP_TACR),a0
    move.b (a0),-(sp)
    move.b #%0_0000,(a0)  ;タイマー停止
    IOCS _VDISPST  ;目的の割り込みを設定する
    move.b (sp)+,(a0)  ;タイマーを元の動作モードに戻す
    movea.l (sp)+,a0
  @@:
  rts

VdispstRte:
  rte


PrintD0Dec:
  lea (Buffer,pc),a0
  pea (a0)
  FPACK __LTOS
  DOS _PRINT
  addq.l #4,sp
  rts


.data

CounterError: .dc.b '割り込みカウンターは0～255で指定してください。',CR,LF,0
AlreadyUsed: .dc.b 'IOCS _VDISPSTは既に設定されています。',CR,LF,0


.bss
.even

Buffer: .ds.b 256

TimerACalled: .ds.b 1


.end ProgramStart
