.title a2arg - print argument/arg0 specified by a2

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

.include macro.mac
.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


HUPAIR_MARK:      .reg '#HUPAIR',0
HUPAIR_MARK_SIZE: .equ 8

.cpu 68000
.text

Start:
  bra.s @f
    HupairMark:
      .dc.b HUPAIR_MARK
    .even
  @@:

  bsr isHupairMarkExists
  bne 1f
    ;#HUPAIR あり
    bsr printHupairMark
    bsr printArgumentLength
    bsr printArgument
    bsr printArg0
    bra 9f
  1:
    ;#HUPAIR なし
    bsr printArgumentLength
    bsr printArgument
  9:
  DOS _EXIT


isHupairMarkExists:
  PUSH a0/a2
  lea (HupairMark,pc),a0
  subq.l #HUPAIR_MARK_SIZE,a2
  moveq #HUPAIR_MARK_SIZE-1,d0
  @@:
    cmpm.b (a0)+,(a2)+
  dbne d0,@b
  POP a0/a2
  rts

printHupairMark:
  DOS_PRINT (strHupairMark,pc)
  DOS_PRINT (-HUPAIR_MARK_SIZE,a2)
  DOS_PRINT_CRLF
  rts

printArgumentLength:
  moveq #0,d0
  move.b (a2),d0
  lea (buffer,pc),a0
  FPACK __LTOS

  DOS_PRINT (strLength,pc)
  DOS_PRINT (buffer,pc)
  DOS_PRINT_CRLF
  rts

printArgument:
  DOS_PRINT (strArgument,pc)
  DOS_PRINT (1,a2)
  DOS_PRINT_CRLF
  rts

printArg0:
  DOS_PRINT (strArg0,pc)
  lea (1,a2),a0
  STREND a0,+1
  DOS_PRINT (a0)
  DOS_PRINT_CRLF
  rts


.data

strHupairMark: .dc.b 'hupair_mark = ',0
strLength:     .dc.b 'length = ',0
strArgument:   .dc.b 'argument = ',0
strArg0:       .dc.b 'arg0 = ',0


.bss
.even

buffer: .dc.b 16


.end
