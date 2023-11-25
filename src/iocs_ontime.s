.title iocs_ontime - IOCS _ONTIME

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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
  moveq #0,d7  ;秒数を表示する
  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    moveq #1,d7  ;日数を表示する
  @@:

  IOCS _ONTIME
  tst.l d7
  beq @f
    move.l d1,d0
  @@:
  lea (Buffer,pc),a0
  FPACK __LTOS

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


.data

CrLf: .dc.b CR,LF,0


.bss

Buffer: .ds.b 128


.end ProgramStart
