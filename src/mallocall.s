.title mallocall - malloc all

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include include/macro.mac
.include include/console.mac
.include include/doscall.mac

.include include/xputil.mac


.cpu 68000
.text

OPTION_SHRINK:    .equ 0
OPTION_EXPAND:    .equ 1
OPTION_SETBLOCK2: .equ 2
OPTION_MALLOC3:   .equ 3


ProgramStart:
  bsr AnalyzeArgument
  move.l d0,d7  ;option

  ;プロセス自身のメモリブロックを縮小または拡大
  btst #OPTION_SHRINK,d7
  beq 1f
    suba.l a0,a1
    lea (-16,a1),a1  ;メモリ管理ポインタを除いたサイズ
    move.l a1,d0
    bsr SetBlock
    bra @f
  1:
  btst #OPTION_EXPAND,d7
  beq @f
    bsr SetBlockMax
  @@:

  lea (a0),a3
  bsr PrintMemoryBlock
  lea (a3),a0
  bsr PrintProcessFilename
  bsr PrintCrLf

  @@:
    bsr MallocMax
    bmi @f

    movea.l d0,a0
    lea (-16,a0),a0  ;メモリ管理ポインタ
    bsr PrintMemoryBlock
    bsr PrintCrLf
    bra @b
  @@:

  DOS _EXIT


;引数解析
AnalyzeArgument:
  moveq #0,d2
  addq.l #1,a2
  1:
  move.b (a2)+,d0
  beq 9f
    cmpi.b #'s',d0
    bne @f
      bclr #OPTION_EXPAND,d2
      bset #OPTION_SHRINK,d2
      bra 1b
    @@:
    cmpi.b #'e',d0
    bne @f
      bclr #OPTION_SHRINK,d2
      bset #OPTION_EXPAND,d2
      bra 1b
    @@:
    cmpi.b #'2',d0
    bne @f
      bset #OPTION_SETBLOCK2,d2
      bra 1b
    @@:
    cmpi.b #'3',d0
    bne @f
      bset #OPTION_MALLOC3,d2
      bra 1b
    @@:
  bra 1b
9:
  move.l d2,d0
  rts


;可能な最大サイズでメモリブロックを拡大する
SetBlockMax:
  moveq #-1,d0
  bsr SetBlock
  andi.l #$0fff_ffff,d0
  btst #OPTION_SETBLOCK2,d7
  bne @f
    andi.l #$00ff_ffff,d0
  @@:
  bra SetBlock


;メモリブロックのサイズを変更する
SetBlock:
  move.l d0,-(sp)
  pea (16,a0)
  btst #OPTION_SETBLOCK2,d7
  beq @f
    DOS _SETBLOCK2
    bra 9f
  @@:
    DOS _SETBLOCK
  9:
  addq.l #8,sp
  rts


;可能な最大サイズでメモリブロックを確保する
MallocMax:
  moveq #-1,d0
  bsr Malloc
  andi.l #$0fff_ffff,d0
  btst #OPTION_MALLOC3,d7
  bne @f
    andi.l #$00ff_ffff,d0
  @@:
  bra Malloc


;メモリブロックを確保する
Malloc:
  move.l d0,-(sp)
  btst #OPTION_MALLOC3,d7
  beq @f
    DOS _MALLOC3
    bra 9f
  @@:
    DOS _MALLOC
  9:
  move.l d0,(sp)+
  rts


;メモリブロックのアドレス、終端アドレス、サイズを表示する
;in a0.l メモリ管理ポインタ
PrintMemoryBlock:
  lea (a0),a1

  lea (Buffer,pc),a0
  move.l a1,d0  ;メモリ管理ポインタ
  bsr ToHexString8
  move.b #'-',(a0)+

  move.l (8,a1),d0  ;メモリブロックの終端+1
  bsr ToHexString8
  move.b #' ',(a0)+

  move.b #'(',(a0)+
  move.l (8,a1),d0
  sub.l a1,d0
  subi.l #16,d0  ;メモリ管理ポインタを除いたサイズ
  bsr ToHexString8
  move.b #')',(a0)+
  clr.b (a0)

  pea (Buffer,pc)
  DOS _PRINT
  addq.l #4,sp
  rts


;自分自身のプロセスの実行ファイル名を表示する
;in a0.l プロセス管理ポインタ
PrintProcessFilename:
  pea (Space,pc)
  DOS _PRINT
  pea ($80,a0)  ;パス名
  DOS _PRINT
  pea ($c4,a0)  ;ファイル名
  DOS _PRINT
  lea (12,sp),sp
  rts


PrintCrLf:
  pea (CrLf,pc)
  DOS _PRINT
  addq.l #4,sp
  rts


  DEFINE_TOHEXSTRING8 ToHexString8


.data
Space: .dc.b ' ',0
CrLf: .dc.b CR,LF,0


.bss
.even
Buffer: .ds.b 256


.end ProgramStart
