.title dos_setenv - DOS _SETENV

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
  beq PrintUsage

  lea (Buffer,pc),a1  ;空の変数名、値も許容する(値がからの場合は変数削除)
  @@:
    move.b (a0)+,d0
    beq PrintUsage
    cmpi.b #'=',d0
    beq @f
    move.b d0,(a1)+
    bra @b
  @@:
  clr.b (a1)  ;変数名終了、a0が値

  pea (a0)
  clr.l -(sp)
  pea (Buffer,pc)
  DOS _SETENV
  addq.l #12-4,sp
  move.l d0,(sp)+
  bmi error

  DOS _EXIT

error:
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


PrintUsage:
  PRINT_1LINE_USAGE 'usage: dos_setenv name=value'
  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.bss
.even

Buffer: .ds.b 256


.end ProgramStart
