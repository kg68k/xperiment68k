.title bgexecd - bgexec daemon

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
.include dosdef.mac
.include console.mac
.include doscall.mac
.include process.mac

.include xputil.mac


CMD_EXEC: .equ $0000
sizeof_PrcctrlDataBuffer: .equ 512


.cpu 68000
.text

;プログラム先頭
ProcessMemoryBock: .equ $-sizeof_PSP

BgKeepStart:
BgThreadName: .dc.b 'bgexecd',0
.even


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
  bra Awaken

UnknownCommand:
  bsr PrintUnknownCommand
Sleep:
  bsr SleepPr
Awaken:
  move (PrcctrlBuffer+PRCCTRL_COMMAND,pc),d0
  cmpi #THREAD_ISBUSY,d0
  beq Sleep  ;DOS _SEND_PR(CMDNO=$fffb)で起こされた
  cmpi #THREAD_SLEEP,d0
  beq Sleep
  cmpi #THREAD_KILL,d0
  beq Kill
  cmpi #CMD_EXEC,d0
  bne UnknownCommand

  move.b (ProcessMemoryBock+MEMBLK_Parent,pc),d0
  cmpi.b #MEMBLK_TYPE_KEEP,d0
  beq @f
    ;このスレッドを作ったプロセスが常駐終了するまで実行しない
    lea (NotTerminated,pc),a1
    bsr PrintWithHeader
    bra Sleep
  @@:

  lea (ExecuteMessage,pc),a1
  bsr PrintWithHeader
  movea.l (PrcctrlBuffer+PRCCTRL_BUF_PTR,pc),a4
  IOCS_B_PRINT (a4)

  lea (a4),a5
  STREND a5,+1  ;コマンドライン引数
  move.b (a5),d1
  move.b #' ',(a5)
  IOCS_B_PRINT (a5)
  move.b d1,(a5)

  IOCS_B_PRINT (CrLf,pc)

  clr.l -(sp)
  pea (a5)
  pea (a4)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  move.l d0,d7
  bpl 1f
    bsr ExecError
    bra @f
  1:
    lea (ExecDoneMessage,pc),a1
    bsr PrintWithHeader
  @@:

  ;もし子プロセス実行直後にDOS _KILL_PRするなら、スレッド管理情報内の
  ;PSP IDが実行終了した子プロセスの値のままになっていることがあり、
  ;_CHANGE_PRで他のスレッドに切り替えることにより現在の値を保存させる
  ;必要がある。
  ;DOS _CHANGE_PR
  ;bra Kill

  bra Sleep


Kill:
  bsr WaitForTerminate  ;このスレッドを作ったプロセスが常駐終了するまで_KILL_PRしない
  DOS _KILL_PR


InitPrcctrlBuffer:
  lea (PrcctrlBuffer,pc),a0
  move.l #sizeof_PrcctrlDataBuffer,(PRCCTRL_LENGTH,a0)
  move #THREAD_ISBUSY,(PRCCTRL_COMMAND,a0)
  move #-1,(PRCCTRL_YOUR_ID,a0)
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
  move (PrcctrlBuffer+PRCCTRL_COMMAND,pc),d0
  lea (sp),a0
  bsr ToHexString4
  IOCS_B_PRINT (sp)
  IOCS_B_PRINT (CrLf,pc)
  unlk a6
  rts


ExecError:
  link a6,#-16
  move.l d0,-(sp)
  lea (ExecErrorMessage,pc),a1
  bsr PrintWithHeader
  move.l (sp)+,d0
  lea (sp),a0
  bsr ToHexString4_4
  IOCS_B_PRINT (sp)
  IOCS_B_PRINT (CrLf,pc)
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


PrcctrlBuffer:
  .dc.l sizeof_PrcctrlDataBuffer
  .dc.l PrcctrlDataBuffer
  .dc THREAD_ISBUSY
  .dc -1

MessageHeader: .dc.b 'bgexecd: ',0
ThreadAlreadyStarted: .dc.b '開始済みのスレッドが再び実行開始されました。',0
UnknownCmdMessage:    .dc.b '非対応のコマンド番号です: $',0
NotTerminated:        .dc.b 'プロセスがまだ終了していません。',CR,LF,0
ExecuteMessage:       .dc.b 'ファイルを実行します: ',0
ExecDoneMessage:      .dc.b '実行終了しました。',CR,LF,0
ExecErrorMessage:     .dc.b '実行エラー: d0.l = $',0

CrLf: .dc.b CR,LF,0

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

  clr.l -(sp)  ;SLEEP_TIME
  pea (PrcctrlBuffer,pc)
  pea (BgThreadStart,pc)
  clr -(sp)  ;INIT_SR
  pea (BgSysStackBottom,pc)
  pea (BgUsrStackBottom)
  move #2,-(sp)  ;COUNT
  pea (BgThreadName,pc)
  DOS _OPEN_PR
  lea (28,sp),sp
  move.l d0,d7  ;スレッドID
  bpl @f
    DOS_PRINT (OpenPrErrorMessage,pc)
    move.l d7,d0
    bsr PrintD0$4_4
    DOS_PRINT (CrLf,pc)

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
