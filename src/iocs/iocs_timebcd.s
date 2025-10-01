.title iocs_timebcd - IOCS _TIMEBCD

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
  bne 1f
    IOCS _TIMEGET  ;省略時は現在の時刻
    move.l d0,d1
    IOCS _TIMEBIN
    bra @f
  1:
    bsr ParseInt
  @@:
  move.l d0,d1
  IOCS _TIMEBCD

  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
