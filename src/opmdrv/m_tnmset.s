.title m_tnmset - OPM _M_TNMSET

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

.include opmdrv.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    PRINT_1LINE_USAGE 'uasge: m_tnmset <tone_no(1-200)> [name]'
    DOS _EXIT
  @@:
  bsr ParseInt
  move.l d0,d2  ;音色番号
  SKIP_SPACE a0
  lea (a0),a1  ;音色名

  OPM _M_TNMSET
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
