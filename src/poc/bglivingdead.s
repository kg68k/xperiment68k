.title bglivingdead - testing to killing a thread before terminating a process

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
.include dosdef.mac
.include console.mac
.include doscall.mac
.include process.mac

.include xputil.mac

RootPSP: .equ $1c04


.cpu 68000
.text

BgThreadName: .dc.b 'bglivingdead',0
.even


BgThreadStart:
  st (IsBgTaskDone)
  DOS _KILL_PR


PrcctrlBuffer:
  .dc.l 0
  .dc.l 0
  .dc THREAD_ISBUSY
  .dc 0

IsBgTaskDone: .dc.b 0
.even


ProgramStart:
  lea (a0),a5  ;PSP

  lea (BgThreadName,pc),a0
  bsr SetThreadName

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  move.l #1,-(sp)  ;SLEEP_TIME
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
    bra error2
  @@:

  ;バックグラウンドスレッドの処理が終了するまで待つ
  DOS_PRINT (WaitThreadDone,pc)
  @@:
    move.b (IsBgTaskDone,pc),d0
    bne @f
    DOS _CHANGE_PR
    bra @b
  @@:

  ;バックグラウンドスレッドが削除されるまで待つ
  DOS_PRINT (WaitThreadKill,pc)
  @@:
    moveq #-1,d0
    bsr GetPr
    tst.l d0
    bmi @f
    DOS _CHANGE_PR
    bra @b
  @@:
  DOS_PRINT (ThreadKillDone,pc)

  ;Human68kのメモリブロックのリンクから自分自身のPSPを探す。
  ;このプロセスはまだ終了していないので本来なら必ず見つかるはずだが、
  ;常駐終了前にスレッドが削除されるとメモリブロックが削除されてしまう。
  lea (a5),a0
  bsr FindMemoryBlock
  move.l a0,d0
  bne 1f
    DOS_PRINT (MemoryBlockNotFound,pc)
    bra @f
  1:
    DOS_PRINT (MemoryBlockFound,pc)
  @@:

  DOS _EXIT

error2:
  move.l d7,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (PrcptrBuffer+PRCPTR_name,pc),a1
  moveq #16-1,d0
  @@:
    move.b (a0)+,(a1)+
  dbeq d0,@b
  sne d0
  ext d0
  ext.l d0
  rts

GetPr:
  pea (PrcptrBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


;指定したメモリブロックをメモリブロックのリンクから探す
;in  a0.l  メモリ管理ポインタ
;out a0.l  引数と同じなら発見した、0なら見つからなかった
FindMemoryBlock:
  move.l (RootPSP),d0
  @@:
    cmpa.l d0,a0
    beq 9f  ;見つかった
    movea.l d0,a1
    move.l (MEMBLK_Next,a1),d0
  bne @b
  move.l d0,a0  ;見つからなかった
9:
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

OpenPrErrorMessage: .dc.b 'DOS _OPEN_PR エラー: ',0

WaitThreadDone: .dc.b 'BGスレッドのタスク終了を待ちます。',CR,LF,0
WaitThreadKill: .dc.b 'BGスレッドの自己削除を待ちます。',CR,LF,0
ThreadKillDone: .dc.b 'BGスレッドが削除されました。',CR,LF,0

MemoryBlockNotFound: .dc.b '自分自身のプロセスのメモリブロックが見つかりませんでした。',CR,LF,0
MemoryBlockFound     .dc.b '自分自身のプロセスのメモリブロックが見つかりました。',CR,LF,0

CrLf: .dc.b CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR


.stack
.quad

BgSysStack: .ds.b 16*1024
BgSysStackBottom:

BgUsrStack: .ds.b 16*1024
BgUsrStackBottom:


.end ProgramStart
