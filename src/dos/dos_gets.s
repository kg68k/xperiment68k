.title dos_gets - DOS _GETS

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

.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (Buffer,pc),a0
  move #255<<8+0,(INPPTR_MAX,a0)

  pea (a0)
  DOS _GETS
  addq.l #4,sp
  move.l d0,d7
  IOCS _B_DOWN_S

  move.l d7,d0
  bsr PrintD0$4_4
  tst.l d7
  bmi exit

    DOS_PRINT (strLength,pc)
    moveq #0,d0
    move.b (INPPTR_LENGTH,a0),d0
    bsr Print$2
    DOS_PRINT_CRLF

    DOS_PRINT (INPPTR_BUFFER,a0)
exit:
  DOS_PRINT_CRLF
  DOS _EXIT


  DEFINE_PRINTD0$4_4 PrintD0$4_4
  DEFINE_PRINT$2 Print$2


.data

strLength: .dc.b ', length = ',0


.bss
.quad

Buffer: .ds.b sizeof_INPPTR


.end ProgramStart
