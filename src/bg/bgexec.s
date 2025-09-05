.title bgexec - execute file in bgexecd

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


CMD_EXEC: .equ $0000


.cpu 68000
.text

ProgramStart:
  lea (sizeof_MEMBLK,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (Usage,pc)
    bra error
  @@:
  lea (FileBuffer,pc),a0
  STRCPY a2,a0

  clr.l -(sp)
  pea (CmdlineBuffer,pc)
  pea (FileBuffer,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  move.l d0,d7
  bpl @f
    DOS_PRINT (PathchkErrorMessage,pc)
    bra error2
  @@:

  lea (FileBuffer,pc),a3
  STREND a3,+1
  lea (CmdlineBuffer,pc),a0
  move.b (a0)+,(a3)+  ;コマンドライン文字数(0～255)
  STRCPY a0,a3        ;コマンドライン文字列
  lea (FileBuffer,pc),a0
  suba.l a0,a3  ;ファイル名+コマンドラインの長さ(それぞれ終端NUL文字含む)

  moveq #-2,d0  ;自分自身のスレッドIDを得る
  bsr GetPr
  move.l d0,d6
  bpl @f
    move.l d6,d7
    DOS_PRINT (GetPrErrorMessage,pc)
    bra error2
  @@:

  lea (BgThreadName,pc),a0
  bsr SetThreadName
retry:
  moveq #-1,d0  ;送信先のスレッドIDを得る
  bsr GetPr
  move.l d0,d7
  bpl @f
    DOS_PRINT (GetPrErrorMessage,pc)
    bra error2
  @@:

  ;対象スレッドがタスク間通信を受信して処理中に、ほかのスレッドからDOS _SUSPEND_PR
  ;で強制スリープ状態にされた場合、通信バッファが受信可能状態になっていないので
  ;DOS _SEND_PRで直接目的のコマンドを送ることができない(d0.l = -28 のエラーが返る)。
  ;そこで特別扱いのコマンド$fffbを送信して起こす。
  ;(強制スリープ状態ではない可能性もあるが気にしない)
  clr.l -(sp)
  pea (FileBuffer,pc)
  move #THREAD_WAKEUP,-(sp)
  move d7,-(sp)
  move d6,-(sp)
  DOS _SEND_PR
  lea (14,sp),sp
  tst.l d0
  bmi retry  ;目的のスレッドが終了しているかもしれないので取得しなおす

  ;本命のコマンドを送信する
  move.l a3,-(sp)
  pea (FileBuffer,pc)
  move #CMD_EXEC,-(sp)
  move d7,-(sp)
  move d6,-(sp)
  DOS _SEND_PR
  lea (14,sp),sp
  move.l d0,d7
  bpl @f
    ;起こした直後に、他の通信を受信した、強制スリープされた、スレッドが終了した、
    ;などが起きた可能性を考慮してやり直す。
    moveq #DOSE_CANTSEND,d1
    cmp.l d0,d1
    beq retry

    DOS_PRINT (SendPrErrorMessage,pc)
    bra error2
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


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

BgThreadName: .dc.b 'bgexecd',0

Usage: .dc.b 'usage: bgexec file [arg...]',CR,LF,0

PathchkErrorMessage: .dc.b 'DOS _EXEC (pathchk) エラー: ',0
GetPrErrorMessage: .dc.b 'DOS _GET_PR エラー: ',0
SendPrErrorMessage: .dc.b 'DOS _SEND_PR エラー: ',0

CrLf: .dc.b CR,LF,0


.bss
.quad

PrcptrBuffer: .ds.b sizeof_PRCPTR

;ファイル名の後ろにコマンドラインを詰めるので、順番を変えないこと
FileBuffer: .ds.b 256
CmdlineBuffer: .ds.b 256


.end ProgramStart
