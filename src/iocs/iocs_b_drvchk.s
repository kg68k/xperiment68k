.title iocs_b_drvchk - IOCS _B_DRVCHK

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
  SKIP_SPACE a0
  beq PrintUsage
  cmpi.b #'-',(a0)
  bne 1f
    cmpi.b #'p',(1,a0)
    bne 1f
      addq.l #2,a0  ;-p 指定時は PDA による指定
      SKIP_SPACE a0
      beq PrintUsage
      bsr ParseInt
      bra 2f
  1:
    bsr ParseInt
    cmpi.l #4,d0
    bcs @f
      FATAL_ERROR 'ドライブ番号は0-3で指定してください。'
    @@:
    ori.b #$90,d0
    lsl #8,d0
  2:
  move.l d0,d1  ;PDA

  moveq #0,d2  ;機能番号の省略時は0=状態検査1
  SKIP_SPACE a0
  beq @f
    bsr ParseInt
    move.l d0,d2
  @@:

  IOCS _B_DRVCHK
  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: iocs_b_drvchk <drive_no(0-3) | -p<pda>> [func_no]'
  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
