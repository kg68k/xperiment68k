.title m_intcall - OPM $1f (intcall)

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
.include opmdrvdef.mac

.include xputil.mac


COUNTER_WIDTH: .equ 8


.cpu 68000
.text

;プログラム先頭
ProcessMemoryBock: .equ $-sizeof_PSP

KeepStart:
  .dc.b 'm_intcall',0

.quad
Count: .dc.l 0

UserInt:
  PUSH d0-d4/a0-a1
  lea (Count,pc),a0
  addq.l #1,(a0)
  move.l (a0),d0
  bsr DisplayCounter
  POP d0-d4/a0-a1
  rts

DisplayCounter:
  link a6,#-12
  lea (sp),a0
  bsr ToHexString8
  clr.b (a0)

  moveq #1,d1
  moveq #96-COUNTER_WIDTH,d2
  moveq #0,d3
  moveq #COUNTER_WIDTH-1,d4
  lea (sp),a1
  IOCS _B_PUTMES

  unlk a6
  rts

  DEFINE_TOHEXSTRING8 ToHexString8


KeepEnd:
;ここまで常駐部


ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    moveq #-1,d2  ;コマンドライン引数がなければ登録情報のアドレスを表示
    bsr NotRegisterCall
    DOS _EXIT
  @@:
  bsr ParseInt
  move.l d0,d2
  tst d2
  bgt @f
    bsr NotRegisterCall  ;d2.w=0なら機能なし、d2.w<0なら登録情報のアドレスを取得
    DOS _EXIT
  @@:

  ;d2.w>0
  SKIP_SPACE a0
  bne @f
    bsr NotRegisterCall  ;d2.w>0のみ指定した場合は呼び出し停止
    DOS _EXIT
  @@:

  cmpi.b #'-',(a0)
  bne @f
    cmpi.b #'r',(1,a0)
    bne 1f
      FATAL_ERROR '常駐解除は実装されていません。'
    1:
    cmpi.b #'k',(1,a0)  ;d2.w>0、-kで登録して常駐終了
    beq Keep
  @@:

  bsr ParseInt
  tst.l d0
  ble @f
    ;d2.w>0、a1.l>0での呼び出しはユーザーサブルーチンの登録になる。
    ;サブルーチンが用意されていないといけないので、ここではエラーにする。
    FATAL_ERROR '第1引数が正数(d2.w>0)のときは、第2引数に正数(a1.l>0)を指定できません。'
  @@:
  ;d2.w>0、a1.l<=0なら呼び出し停止
  movea.l d0,a1
  bsr NotRegisterCall2
  DOS _EXIT


NotRegisterCall:
  suba.l a1,a1
NotRegisterCall2:
  OPM _M_INTCALL
  bsr Print$8
  DOS_PRINT (strCrLf,pc)
  rts


Keep:
  lea (UserInt,pc),a1
  OPM _M_INTCALL
  bsr Print$8
  DOS_PRINT (strCrLf,pc)

  DOS_PRINT (strKeeped,pc)

  clr -(sp)
  move.l #KeepEnd-KeepStart,-(sp)
  DOS _KEEPPR


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$8 Print$8


.data

strKeeped: .dc.b '常駐しました。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.end ProgramStart
