.title m_tempo - OPM _M_TEMPO

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

.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne 1f
    bsr PrintCurrentTempo  ;テンポ省略時は現在値を表示する
    bra @f
  1:
    bsr SetTempo
  @@:
  DOS _EXIT


PrintCurrentTempo:
  moveq #O3_TEMPO_INQUIRY,d2
  OPM _M_TEMPO
  cmpi.l #O3_TEMPO_MIN,d0
  bcs 1f
  cmpi.l #O3_TEMPO_MAX,d0
  bhi 1f
    bsr PrintDecString
    bra @f
  1:
    bsr Print$4_4  ;エラーコードは16進数で表示する
  @@:
  DOS_PRINT_CRLF
  rts


SetTempo:
  bsr ParseInt
  move.l d0,d2  ;テンポ
  OPM _M_TEMPO
  bsr Print$4_4
  DOS_PRINT_CRLF
  rts


  DEFINE_PRINTDECSTRING PrintDecString
  DEFINE_PRINT$4_4 Print$4_4
  DEFINE_PARSEINT ParseInt


.end ProgramStart
