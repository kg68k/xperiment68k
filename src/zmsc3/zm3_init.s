.title zm3_init - Z-MUSIC v3 ZM_INIT

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


.cpu 68000
.text

ProgramStart:
  bsr EnsureZmsc3

  moveq #0,d1  ;ダミー引数(将来の拡張に備えて必ず0を設定する)
  ZM3 ZM_INIT
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


  DEFINE_ENSUREZMSC3 EnsureZmsc3
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
