.title bgzombie - testing to killing a thread without saving psp into thread data

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


.cpu 68000
.text

;プログラム先頭
ProcessMemoryBock: .equ $-sizeof_PSP

BgKeepStart:
BgThreadName: .dc.b 'bgzombie',0
.even


BgThreadStart:
Awaken:
  move.b (ProcessMemoryBock+MEMBLK_Parent,pc),d0
  cmpi.b #MEMBLK_TYPE_KEEP,d0
  beq @f
    ;このスレッドを作ったプロセスが常駐終了するまで実行しない
    move.l #2,-(sp)
    DOS _SLEEP_PR
    addq.l #4,sp
    bra Awaken
  @@:

  tas (IsThreadStarted)
  beq @f
    lea (ThreadAlreadyStarted,pc),a1
    bsr PrintWithHeader
    bra Kill
  @@:

  clr.l -(sp)
  pea (CmdlineBuffer,pc)
  pea (FileBuffer,pc)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  move.l d0,d7
  bpl @f
    bsr ExecError
  @@:

  ;子プロセス実行直後にDOS _KILL_PRすると、スレッド管理情報内の
  ;PSP IDが実行終了した子プロセスの値のままになっていることがあり、
  ;スレッド管理情報が削除されず不正なスレッドが残ってしまう。
Kill:
  DOS _KILL_PR


ExecError:
  link a6,#-16
  move.l d0,-(sp)
  lea (ExecErrorMessage,pc),a1
  bsr PrintWithHeader
  move.l (sp)+,d0
  lea (sp),a0
  bsr ToHexString4_4
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


  DEFINE_TOHEXSTRING4_4 ToHexString4_4


PrcctrlBuffer:
  .dc.l 0
  .dc.l 0
  .dc THREAD_ISBUSY
  .dc -1

MessageHeader: .dc.b 'bgzombie: ',0
ThreadAlreadyStarted: .dc.b '開始済みのスレッドが再び実行開始されました。',0
ExecErrorMessage:     .dc.b '実行エラー: d0.l = $',0

IsThreadStarted: .dc.b 0
.even

FileBuffer: .ds.b 256
CmdlineBuffer: .ds.b 256
.even

;ここまでバックグラウンドスレッドのコード
;ただしバッファは.bss、スタックは.stackにある。


;ここから起動プロセスのコード
ProgramStart:
  lea (a0),a3

  lea (sizeof_MEMBLK,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  addq.l #1,a2
  SKIP_SPACE a2
  cmpi.b #'-',(a2)
  bne @f
    cmpi.b #'c',(1,a2)
    beq OptionC
  @@:

  lea (FileBuffer,pc),a0  ;自分自身を -c オプション付きで実行させる
  lea (PSP_Drive,a3),a1
  STRCPY a1,a0,-1
  lea (PSP_Filename,a3),a1
  STRCPY a1,a0
  lea (CmdlineBuffer,pc),a0
  move.l #2<<24+'-c'<<8+0,(a0)

  move.l #2,-(sp)  ;SLEEP_TIME
  pea (PrcctrlBuffer,pc)
  pea (BgThreadStart,pc)
  move #1<<SR_S,-(sp)  ;INIT_SR
  pea (BgSysStackBottom,pc)
  pea (BgUsrStackBottom)
  move #2,-(sp)  ;COUNT
  pea (BgThreadName,pc)
  DOS _OPEN_PR
  lea (28,sp),sp
  move.l d0,d7  ;スレッドID
  bpl @f
    DOS_PRINT (OpenPrErrorMessage,pc)
    bra error
  @@:
  DOS_PRINT (KeepPrMessage,pc)

  clr -(sp)
  move.l #BgKeepEnd-BgKeepStart,-(sp)
  DOS _KEEPPR


OptionC:
  DOS _CHANGE_PR  ;スレッド管理情報にこのプロセスのPSPを保存させる
  tas (IsChangePrDone)
  beq @f
    lea (ProcessAlreadyStarted,pc),a1  ;本来であればこのコードが実行されることはない。
    IOCS _B_PRINT
    1:
      bra 1b
  @@:
  DOS _EXIT


error:
  move.l d7,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

OpenPrErrorMessage: .dc.b 'DOS _OPEN_PR エラー: ',0

KeepPrMessage: .dc.b '常駐しました。',CR,LF,0

ProcessAlreadyStarted:
  .dc.b '開始済みのプロセスが再び実行されました。',CR,LF
  .dc.b 'リセットしてください。',CR,LF
  .dc.b 0

IsChangePrDone: .dc.b 0


.stack
.quad

BgSysStack: .ds.b 16*1024
BgSysStackBottom:

BgUsrStack: .ds.b 64*1024
BgUsrStackBottom:

BgKeepEnd:


.end ProgramStart
