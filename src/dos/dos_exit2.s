.title dos_exit2 - DOS _EXIT2

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

.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d0  ;引数省略時は0

  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    FPACK __STOH
    bcs NumberError
    cmpi.l #$0001_0000,d0
    bcc NumberError
  @@:

  move d0,-(sp)
  DOS _EXIT2


NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


.data

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0


.end ProgramStart
