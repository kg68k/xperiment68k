.title defchr_7621 - modify JIS:$7621(SJIS:$eb9f) font

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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

CHAR_CODE: .equ $7621


.cpu 68000
.text

Start:
  move.l #8<<16+CHAR_CODE,d1
  lea (Buffer,pc),a1
  IOCS _FNTGET

  move.l #8<<16+CHAR_CODE,d1
  lea (Buffer+4,pc),a1  ;Xサイズ、Yサイズを飛ばす
  move.l #$deadbeef,(a1)
  IOCS _DEFCHR

  DOS_PRINT (ModifyMessage,pc)
  DOS _EXIT


.data

ModifyMessage: .dc.b 'JIS:$7621(SJIS:$eb9f)のフォントを書き換えました。',CR,LF,0


.bss
.even

Buffer: .ds.b 64


.end
