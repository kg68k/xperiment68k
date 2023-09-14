.title dumpenv - dump environment variables

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

.include macro.mac
.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2

  cmpa.l #-1,a3
  bne @f
    lea (NoEnvBuffer,pc),a0  ;環境変数領域が確保されていない
    bsr PrintErrA0
    bra 9f
  @@:

  ;環境変数領域のサイズを飛ばす
  ;  この値はHuman68k内部ではDOS _SETENVで参照しているが、DOS _GETENVでは参照していない。
  ;  よって自分で変数を読む場合でも無視して構わない。
  ;  (常に正しい値が設定されていると見なしてよい)
  lea (4,a3),a0

  bsr printAllEnv
9:
  moveq #EXIT_SUCCESS,d7
  tst.b (a2)
  beq @f
    moveq #EXIT_FAILURE,d7   ;引数付きならキー入力待ち、終了コード1
    lea (WaitMessage,pc),a0
    bsr PrintErrA0
    DOS _INKEY
  @@:
  move d7,-(sp)
  DOS _EXIT2


printAllEnv:
  bra 1f
  @@:
    DOS_PRINT (a0)
    DOS_PRINT (CrLf,pc)
    STREND a0
    addq.l #1,a0
  1:
  tst.b (a0)
  bne @b
  rts


PrintErrA0:
  move #STDERR,-(sp)
  pea (a0)
  DOS _FPUTS
  addq.l #6,sp
  rts


.data

NoEnvBuffer: .dc.b '環境変数領域が確保されていません。',CR,LF,0
CrLf: .dc.b CR,LF,0

WaitMessage:
  .dc.b '----',CR,LF
  .dc.b '何かキーを入力して下さい。',CR,LF,0


.end ProgramStart
