.title iocs_ms_offtm - IOCS _MS_OFFTM

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
  moveq #0,d1  ;引数省略時は左ボタンを調べる
  moveq #0,d2  ;引数省略時は時間無制限

  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    bsr ParseInt
    move.l d0,d1  ;ボタンの指定
    SKIP_SPACE a0
    beq @f
      bsr ParseInt
      move.l d0,d2  ;待ち時間
  @@:
  IOCS _MS_OFFTM
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
