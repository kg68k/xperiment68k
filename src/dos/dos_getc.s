.title dos_getc - DOS _GETC

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

.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  DOS _GETC
  move.l d0,d7
  bsr Print$4_4

  lsr.b #5,d7
  btst d7,#%1001_0000
  beq @f
    ;2バイト文字なら下位バイトも取得する
    DOS_PRINT (Space,pc)
    DOS _GETC
    bsr Print$4_4
  @@:
  DOS_PRINT_CRLF

  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

Space: .dc.b ' ',0


.end ProgramStart
