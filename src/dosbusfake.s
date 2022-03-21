.title dosbusfake - DOS _BUS_ERR fake

# This file is part of Xperiment68k
# Copyright (C) 2022 TcbnErik
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


.include macro.mac
.include dosdef.mac
.include console.mac
.include doscall.mac


DosBusFake_END::    .equ 0
DosBusFake_ZERO::   .equ -1
DosBusFake_BUSERR:: .equ -2


.text
.cpu 68000


;初期化
;in a0.l ... メモリ割り当て情報
DosBusFake_init::
  PUSH a0/a4
  lea (MemoryMap,pc),a4
  move.l a0,(a4)
  lea (a0),a4

  1:
  move.l (a4),d0
  beq 9f
    bmi 8f

      ;ファイルを割り当てる
      movea.l d0,a0  ;ファイル名
      move.l (8,a4),d0
      sub.l (4,a4),d0  ;読み込みサイズ
      bsr readFromFile
      move.l a0,(a4)
    8:
    lea (12,a4),a4
  bra 1b
9:
  POP a0/a4
  rts


readFromFile:
  PUSH d1-d3
  move.l d0,d1

  clr -(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d2
  bmi fatalError

  move.l d1,-(sp)
  DOS _MALLOC
  move.l d0,(sp)+
  bmi fatalError
  movea.l d0,a0

  move.l d1,-(sp)
  pea (a0)
  move d2,-(sp)
  DOS _READ
  move.l d0,d3
  DOS _CLOSE
  lea (10,sp),sp

  tst.l d3
  bmi fatalError
  cmp.l d3,d1
  bne fatalError

  POP d1-d3
  rts


fatalError:
  move #STDERR,-(sp)
  pea (strReadError,pc)
  DOS _FPUTS
  move #EXIT_FAILURE,(sp)
  DOS _EXIT2


;ファイルが割り当てられたアドレスを変換する。
;in
;  a0.l ... アドレス
;out
;  a0.l ... 変換後のアドレス
;break d0
DosBusFake_translate::
  move.l a4,-(sp)
  move.l (MemoryMap,pc),d0
  beq 9f
  movea.l d0,a4
  bra @f

  transLoop:
    addq.l #8,a4
  @@:
    move.l (a4)+,d0
    beq 9f
    cmpa.l (a4),a0
    bcs transLoop
    cmpa.l (4,a4),a0
    bhi transLoop
    tst.l d0
    bmi 9f  ;ファイル割り当てでないなら変換しない

      suba.l (a4),a0
      adda.l d0,a0
9:
  movea.l (sp)+,a4
  rts


;メモリ割り当て情報に従ってメモリ読み込み結果を偽装する。
;in
;  d0.w ... サイズ(1,2,4)
;  a0.l ... アドレス
;out
;  d0.l ... 読み込んだ値
;  ccr ... Z=1:成功 Z=0,N=0:バスエラー発生 Z=0,N=1:非対象アドレス
DosBusFake_read:
  PUSH d1/a4
  move d0,d1
  move.l (MemoryMap,pc),d0
  beq readMiss
  movea.l d0,a4
  bra @f

  readLoop:
    addq.l #8,a4
  @@:
    move.l (a4)+,d0
    beq readMiss
    cmpa.l (a4),a0
    bcs readLoop
    cmpa.l (4,a4),a0
    bhi readLoop
    tst.l d0
    bmi readZeroOrErr

      suba.l (a4),a0 
      adda.l d0,a0  ;代わりに読み込むメモリ
      moveq #0,d0
      move.b (a0),d0
      subq #2,d1
      bhi 4f
      bcs @f
        move (a0),d0
        bra @f
      4:
        move.l (a0),d0
      @@:
      moveq #0,d1  ;ccrZ=1
      bra 9f
readZeroOrErr:
  addq.l #-DosBusFake_ZERO,d0
  bne readBusErr
    moveq #0,d0  ;ccrZ=1 0という値の読み込み成功を偽装する
    bra 9f
readBusErr:
  moveq #0,d0
  moveq #2,d1  ;ccrZ=0,N=0 バスエラー発生を偽装
  bra 9f
readMiss:
  moveq #-1,d0  ;ccrZ=0,N=1 非対象アドレスだった
9:
  POP d1/a4
  rts


;指定アドレスを読みこんでバスエラーが発生するか調べる。
;in  a0.l ... アドレス
;out d0.b/w/l ... 読み込んだデータ
;    ccr  ....... Z=1:正常終了 Z=0:バスエラーが発生した

DosBusErrByte::
  moveq #1,d0
  bsr DosBusFake_read
  bpl 9f

  move #1,-(sp)
  move.l sp,-(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  moveq #0,d0
  move.b (8,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
9:
  rts

DosBusErrWord::
  moveq #2,d0
  bsr DosBusFake_read
  bpl 9f

  move #2,-(sp)
  move.l sp,-(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  moveq #0,d0
  move (8,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
9:
  rts

DosBusErrLong::
  moveq #4,d0
  bsr DosBusFake_read
  bpl 9f

  move #4,-(sp)
  subq.l #4,sp
  move.l sp,(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  move.l (4,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
9:
  rts


.data

strReadError: .dc.b 'DosBusFake: file read error',CR,LF,0


.bss
.quad

MemoryMap: .ds.l 1


.end
