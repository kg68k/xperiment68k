.title bgontime - display the results of IOCS_ONTIME in the background

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

.include console.mac
.include doscall.mac
.include process.mac
.include iocscall.mac

.include xputil.mac


sizeof_PrcctrlDataBuffer: .equ 4

ONTIME_WIDTH: .equ 8


.cpu 68000
.text

;プログラム先頭
ProcessMemoryBock: .equ $-sizeof_PSP

BgKeepStart:
BgThreadName: .dc.b 'bgontime',0
.even
PreviousOntime: .dc.l 0


BgThreadStart:
  ;ここには、DOS _OPEN_PRで作成されたスレッドのスリープが
  ;はじめて解除されたときしか来ないはず。
  tas (IsThreadStarted)
  beq @f
    lea (ThreadAlreadyStarted,pc),a1
    bsr PrintWithHeader
    bra Kill
  @@:
  pea (Kill,pc)
  move #_ERRJVC,-(sp)
  DOS _INTVCS
  move #_CTRLVC,(sp)
  DOS _INTVCS
  addq.l #6,sp

  IOCS _ONTIME
  bsr DisplayOntime  ;初回の表示
  bra Awaken

Sleep:
  bsr SleepPr
Awaken:
  move (PrcctrlBuffer+PRCCTRL_command,pc),d0
  cmpi #THREAD_SLEEP,d0
  beq Sleep
  cmpi #THREAD_KILL,d0
  beq Kill

  ;他のコマンドは無視する
  bsr InitPrcctrlBuffer
BgLoop:
  move (PrcctrlBuffer+PRCCTRL_your_id,pc),d0
  cmpi #-1,d0
  bne Awaken

  IOCS _ONTIME
  cmp.l (PreviousOntime,pc),d0
  beq @f
    bsr DisplayOntime  ;結果が変化したら再表示
  @@:
  bra BgLoop


DisplayOntime:
  link a6,#-12
  move.l d0,(PreviousOntime)

  lea (sp),a0
  bsr ToHexString8
  clr.b (a0)

  moveq #1,d1
  moveq #96-ONTIME_WIDTH,d2
  moveq #0,d3
  moveq #ONTIME_WIDTH-1,d4
  lea (sp),a1
  IOCS _B_PUTMES

  unlk a6
  rts


Kill:
  bsr WaitForTerminate  ;このスレッドを作ったプロセスが常駐終了するまで_KILL_PRしない
  DOS _KILL_PR


InitPrcctrlBuffer:
  lea (PrcctrlBuffer,pc),a0
  move.l #sizeof_PrcctrlDataBuffer,(PRCCTRL_length,a0)
  move #THREAD_ISBUSY,(PRCCTRL_command,a0)
  move #-1,(PRCCTRL_your_id,a0)
  rts


SleepPr:
  bsr InitPrcctrlBuffer
  clr.l -(sp)
  DOS _SLEEP_PR
  addq.l #4,sp
  rts


WaitForTerminate:
  bra 1f
  @@:
    bsr SleepPr
    1:
    move.b (ProcessMemoryBock+MEMBLK_Parent,pc),d0
  cmpi.b #MEMBLK_TYPE_KEEP,d0
  bne @b
  rts




PrintWithHeader:
  pea (a1)
  IOCS_B_PRINT (MessageHeader,pc)
  movea.l (sp)+,a1
  IOCS _B_PRINT
  rts


  DEFINE_TOHEXSTRING8 ToHexString8


PrcctrlBuffer:
  .dc.l sizeof_PrcctrlDataBuffer
  .dc.l PrcctrlDataBuffer
  .dc THREAD_ISBUSY
  .dc -1

MessageHeader: .dc.b 'bgontime: ',0
ThreadAlreadyStarted: .dc.b '開始済みのスレッドが再び実行開始されました。',0

IsThreadStarted: .dc.b 0
.even

;ここまでバックグラウンドスレッドのコード
;ただしバッファは.bss、スタックは.stackにある。


;ここから起動プロセスのコード
ProgramStart:
  lea (sizeof_MEMBLK,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  pea (1)  ;SLEEP_TIME
  pea (PrcctrlBuffer,pc)
  pea (BgThreadStart,pc)
  clr -(sp)  ;INIT_SR
  pea (BgSysStackBottom,pc)
  pea (BgUsrStackBottom)
  move #10,-(sp)  ;COUNT
  pea (BgThreadName,pc)
  DOS _OPEN_PR
  lea (28,sp),sp
  move.l d0,d7  ;スレッドID
  bpl @f
    DOS_PRINT (OpenPrErrorMessage,pc)
    move.l d7,d0
    bsr PrintD0$4_4
    DOS_PRINT_CRLF

    move #EXIT_FAILURE,-(sp)
    DOS _EXIT2
  @@:
  DOS_PRINT (KeepPrMessage,pc)

  clr -(sp)
  move.l #BgKeepEnd-BgKeepStart,-(sp)
  DOS _KEEPPR


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

KeepPrMessage: .dc.b '常駐しました。',CR,LF,0
OpenPrErrorMessage: .dc.b 'DOS _OPEN_PR エラー: ',0


.bss
.quad

PrcctrlDataBuffer: .ds.b sizeof_PrcctrlDataBuffer


.stack
.quad

BgSysStack: .ds.b 16*1024
BgSysStackBottom:

BgUsrStack: .ds.b 64*1024
BgUsrStackBottom:

BgKeepEnd:


.end ProgramStart
