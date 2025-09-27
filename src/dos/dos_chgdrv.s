.title dos_chgdrv - DOS _CHGDRV

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
  addq.l #1,a2
  SKIP_SPACE a2
  beq PrintUsage
  cmpi.b #'@',(a2)
  bne 1f
    moveq #-1,d0  ;DOS _CHGDRV が必ずエラーになる値
    bra @f
  1:
    moveq #$20,d0
    or.b (a2),d0
    subi.b #'a',d0  ;0=A: 1=B: ... 25=Z:
    cmpi.b #'z'-'a',d0
    bhi PrintUsage
  @@:
  move d0,-(sp)
  DOS _CHGDRV
  addq.l #2,sp

  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: dos_chgdrv <drive or @>'
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

CrLf: .dc.b CR,LF,0


.end ProgramStart
