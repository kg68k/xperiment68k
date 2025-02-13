.title tpalreset - reset text palette

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

.include doscall.mac
.include iocscall.mac


.cpu 68000
.text

ProgramStart:
  moveq #-2,d2  ;システム設定値に戻す
  moveq #8,d1
  IOCS _TPALET
  moveq #4,d1
  @@:
    IOCS _TPALET
  dbra d1,@b

  DOS _EXIT


.end ProgramStart
