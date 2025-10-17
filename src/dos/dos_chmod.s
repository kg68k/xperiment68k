.title dos_chmod - DOS _CHMOD

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

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr AnalyzeArguments

  move d0,-(sp)
  pea (a0)
  DOS _CHMOD
  addq.l #6,sp
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: dos_chmod [-c<atr>] <filename>'
  DOS _EXIT


AnalyzeArguments:
  moveq #-1,d0  ;-cで指定した属性 省略時-1
  1:
    SKIP_SPACE a0
    beq 9f  ;ファイル名なしは許容する
    cmpi.b #'-',(a0)
    bne 9f  ;ファイル名あり

    addq.l #1,a0
    cmpi.b #'c',(a0)+
    bne PrintUsage
    SKIP_SPACE a0  ;-c<atr>
    beq PrintUsage

    bsr ParseIntWord
    bra 1b
9:
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
