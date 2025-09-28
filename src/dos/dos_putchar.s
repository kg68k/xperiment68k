.title dos_putchar - DOS _PUTCHAR

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
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    PRINT_1LINE_USAGE 'usage: dos_putchar <string...>'
    DOS _EXIT
  @@:

  bra 8f
  1:
    move d0,-(sp)
    DOS _PUTCHAR
    addq.l #2,sp
  8:
  moveq #0,d0
  move.b (a2)+,d0
  bne 1b

  ;ファイルへのリダイレクト時に指定コードだけが保存されるように、IOCSで改行を表示する
  B_PRINT_CRLF

  DOS _EXIT


.end ProgramStart
