.title bg1pr2th - create 2 threads in one process

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
.include process.mac

.include xputil.mac


sizeof_PrcctrlDataBuffer: .equ 512


.cpu 68000
.text

;プログラム先頭
ProcessMemoryBock: .equ $-sizeof_PSP

BgKeepStart:

BgThreadName1: .dc.b 'bgthread1',0
.even
BgThreadStart1:
  lea (PrcctrlBuffer1,pc),a5
  bsr BtThreadLoop


BgThreadName2: .dc.b 'bgthread2',0
.even
BgThreadStart2:
  lea (PrcctrlBuffer2,pc),a5
  bsr BtThreadLoop


BtThreadLoop:
Awaken:
  move (PRCCTRL_COMMAND,a5),d0
  cmpi #THREAD_ISBUSY,d0
  beq Sleep  ;DOS _SEND_PR(CMDNO=$fffb)で起こされた
  cmpi #THREAD_SLEEP,d0
  beq Sleep
  cmpi #THREAD_KILL,d0
  beq Kill

  bsr PrintUnknownCommand
Sleep:
  bsr SleepPr
  bra Awaken


Kill:
  bsr WaitForTerminate  ;このスレッドを作ったプロセスが常駐終了するまで_KILL_PRしない
  DOS _KILL_PR


InitPrcctrlBuffer:
  move.l #sizeof_PrcctrlDataBuffer,(PRCCTRL_LENGTH,a5)
  move #THREAD_ISBUSY,(PRCCTRL_COMMAND,a5)
  move #-1,(PRCCTRL_YOUR_ID,a5)
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


PrintUnknownCommand:
  link a6,#-16
  lea (UnknownCmdMessage,pc),a1
  bsr PrintWithHeader
  move (PRCCTRL_COMMAND,a5),d0
  lea (sp),a0
  bsr ToHexString4
  IOCS_B_PRINT (sp)
  B_PRINT_CRLF
  unlk a6
  rts


PrintWithHeader:
  pea (a1)
  IOCS_B_PRINT (MessageHeader,pc)
  movea.l (sp)+,a1
  IOCS _B_PRINT
  rts


  DEFINE_TOHEXSTRING4   ToHexString4
  DEFINE_TOHEXSTRING4_4 ToHexString4_4


PrcctrlBuffer1:
  .dc.l sizeof_PrcctrlDataBuffer
  .dc.l PrcctrlDataBuffer1
  .dc THREAD_ISBUSY
  .dc -1

PrcctrlBuffer2:
  .dc.l sizeof_PrcctrlDataBuffer
  .dc.l PrcctrlDataBuffer2
  .dc THREAD_ISBUSY
  .dc -1

MessageHeader: .dc.b 'bgexecd: ',0
UnknownCmdMessage:    .dc.b '非対応のコマンド番号です: $',0

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

  clr.l -(sp)  ;SLEEP_TIME
  pea (PrcctrlBuffer1,pc)
  pea (BgThreadStart1,pc)
  clr -(sp)  ;INIT_SR
  pea (BgSysStackBottom1,pc)
  pea (BgUsrStackBottom1)
  move #2,-(sp)  ;COUNT
  pea (BgThreadName1,pc)
  DOS _OPEN_PR
  lea (28,sp),sp
  move.l d0,d7  ;スレッドID
  bpl @f
    bsr PrintOpenPrError
    move #EXIT_FAILURE,-(sp)
    DOS _EXIT2
  @@:

  clr.l -(sp)  ;SLEEP_TIME
  pea (PrcctrlBuffer2,pc)
  pea (BgThreadStart2,pc)
  clr -(sp)  ;INIT_SR
  pea (BgSysStackBottom2)
  pea (BgUsrStackBottom2)
  move #2,-(sp)  ;COUNT
  pea (BgThreadName2,pc)
  DOS _OPEN_PR
  lea (28,sp),sp
  move.l d0,d6  ;スレッドID
  bpl @f
    ;ここでDOS _EXIT2で終了すると一つ目のスレッドが残ってしまうので
    ;エラー表示だけして常駐終了する。
    bsr PrintOpenPrError
  @@:

  DOS_PRINT (KeepPrMessage,pc)

  clr -(sp)
  move.l #BgKeepEnd-BgKeepStart,-(sp)
  DOS _KEEPPR


PrintOpenPrError:
  move.l d0,-(sp)
  DOS_PRINT (OpenPrErrorMessage,pc)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  rts

  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

KeepPrMessage: .dc.b '常駐しました。',CR,LF,0
OpenPrErrorMessage: .dc.b 'DOS _OPEN_PR エラー: ',0


.bss
.quad

PrcctrlDataBuffer1: .ds.b sizeof_PrcctrlDataBuffer
PrcctrlDataBuffer2: .ds.b sizeof_PrcctrlDataBuffer


.stack
.quad

BgSysStack1: .ds.b 16*1024
BgSysStackBottom1:

BgUsrStack1: .ds.b 64*1024
BgUsrStackBottom1:

BgSysStack2: .ds.b 16*1024
BgSysStackBottom2:

BgUsrStack2: .ds.b 64*1024
BgUsrStackBottom2:

BgKeepEnd:


.end ProgramStart
