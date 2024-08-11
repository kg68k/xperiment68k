.title bgsprocess - set sub memory with `DOS _S_PROCESS`

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

.include dosdef.mac
.include console.mac
.include doscall.mac
.include process.mac

.include xputil.mac


SUB_MEMORY_SIZE: .equ 512*1024


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
    DOS _EXIT
  @@:
  bsr SetThreadName
  bmi error

  ;サブのメモリ管理用のメモリブロックを確保する
  move.l #SUB_MEMORY_SIZE,-(sp)
  move #2,-(sp)  ;上位から
  DOS _MALLOC2
  addq.l #6,sp
  move.l d0,d6
  bpl @f
    move.l d6,d7
    lea (MallocErrorMessage,pc),a0
    bra error2
  @@:

  moveq #-1,d0  ;バッファで指定した名前のIDを得る
  bsr GetPr
  move.l d0,d7
  bpl @f
    lea (GetPrErrorMessage,pc),a0
    bra error2
  @@:

  ;サブのメモリ管理を設定する
  pea (16)  ;先頭に確保するブロックの大きさ
  move.l #SUB_MEMORY_SIZE,-(sp)
  move.l d6,-(sp)
  move d7,-(sp)
  DOS _S_PROCESS
  lea (14,sp),sp
  move.l d0,d7
  bpl @f
    lea (SProcessErrorMessage,pc),a0
    bra error2
  @@:
  DOS_PRINT (SetSubMemoryMessage,pc)
  move.l d7,d0
  bsr PrintD0Hex
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


error2:
  DOS_PRINT (a0)
  move.l d7,d0
  bsr PrintD0Hex
  DOS_PRINT (CrLf,pc)
error:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


SetThreadName:
  lea (BgBuffer+BG_Name,pc),a0
  moveq #16-1,d1
  @@:
    move.b (a2)+,(a0)+
  dbeq d1,@b
  beq @f
    DOS_PRINT (ThreadNameTooLong,pc)
    moveq #-1,d0
    rts
  @@:
  moveq #0,d0
  rts


GetPr:
  pea (BgBuffer,pc)
  move d0,-(sp)
  DOS _GET_PR
  addq.l #6,sp
  rts


PrintD0Hex:
  link a6,#-16
  lea (sp),a0
  move.b #'$',(a0)+
  bsr ToHexString4_4
  DOS_PRINT (sp)
  addq.l #4,sp
  unlk a6
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

Usage: .dc.b 'bgsprocess thread_name',CR,LF,0

ThreadNameTooLong: .dc.b 'スレッド名が長すぎます。',CR,LF,0
MallocErrorMessage:   .dc.b 'DOS _MALLOC エラー: d0.l = ',0
GetPrErrorMessage:    .dc.b 'DOS _GET_PR エラー: d0.l = ',0
SProcessErrorMessage: .dc.b 'DOS _S_PROCESS エラー: d0.l = ',0
SetSubMemoryMessage:  .dc.b 'サブのメモリ管理を設定しました: d0.l = ',0

CrLf: .dc.b CR,LF,0


.bss
.quad

BgBuffer: .ds.b sizeof_BG


.end ProgramStart
