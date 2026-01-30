.title zm3_exg_memid - Z-MUSIC v3 ZM_EXCHANGE_MEMID

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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

.include vector.mac
.include zmusic3.mac

.include xputil.mac
.include xp_zmsc3.mac


ARG_REGS: .reg d1/d2/d3/a1

.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  lea (ArgStart,pc),a1
  lea (ArgEnd,pc),a2
  bsr AnalyzeArguments
  tst.l d0
  bmi PrintUsage

  bsr EnsureZmsc3

  movem.l (ArgStart,pc),ARG_REGS
  ZM3 ZM_EXCHANGE_MEMID
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'zm3_exg_memid <mode> <old_ID> <new_ID> <address>'
  DOS _EXIT


AnalyzeArguments:
  @@:
    SKIP_SPACE a0
    beq 9f  ;引数が足りない
    bsr ParseInt
    move.l d0,(a1)+
  cmpa.l a1,a2
  bne @b

  moveq #0,d0  ;すべての引数を受け取った
  rts
9:
  moveq #-1,d0
  rts


  DEFINE_ENSUREZMSC3 EnsureZmsc3
  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.bss

.even
ArgStart:
  .ds.b .sizeof.(ARG_REGS)
ArgEnd:


.end ProgramStart
