.title dosbuserr - DOS _BUS_ERR

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


.include include/doscall.mac

.text
.cpu 68000


;指定アドレスを読みこんでバスエラーが発生するか調べる。
;in  a0.l ... アドレス
;out d0.b/w/l ... 読み込んだデータ
;    ccr  ....... Z=1:正常終了 Z=0:バスエラーが発生した

DosBusErrByte::
  move #1,-(sp)
  move.l sp,-(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  moveq #0,d0
  move.b (8,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
  rts

DosBusErrWord::
  move #2,-(sp)
  move.l sp,-(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  moveq #0,d0
  move (8,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
  rts

DosBusErrLong::
  move #4,-(sp)
  subq.l #4,sp
  move.l sp,(sp)
  move.l a0,-(sp)
  DOS _BUS_ERR
  move.l d0,(sp)
  move.l (4,sp),d0
  tst.l (sp)+
  addq.l #10-4,sp
  rts


.end
