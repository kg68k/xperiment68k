.title bkeyinpd3 - IOCS _B_KEYINP test

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

.include macro.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  move.l #$deadbeef,d3
  DOS_PRINT (StartupMesssage,pc)
  move.l d3,d0
  bsr PrintD0Hex
  DOS_PRINT (CrLf,pc)
  @@:
    IOCS _B_KEYINP
    move.l d0,d7
    DOS_PRINT (ResultD0,pc)
    move.l d7,d0
    bsr PrintD0Hex

    DOS_PRINT (ResultD3,pc)
    move.l d3,d0
    bsr PrintD0Hex
    DOS_PRINT (CrLf,pc)
  cmpi.b #$1b,d7
  bne @b

  DOS _EXIT


PrintD0Hex:
  lea (Buffer,pc),a0
  pea (a0)
  move.b #'$',(a0)+
  bsr ToHexString4_4
  DOS _PRINT
  addq.l #4,sp
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

StartupMesssage: .dc.b 'ESCキーで終了します。d3 = ',0
ResultD0: .dc.b 'd0 = ',0
ResultD3: .dc.b ', d3 = ',0
CrLf: .dc.b CR,LF,0


.bss
.quad

Buffer: .ds.b 64


.end ProgramStart
