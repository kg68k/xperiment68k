.title bputmes_cur - IOCS _B_PUTMES cursor test

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
  lea (strPutKey,pc),a1
  IOCS _B_PRINT

  moveq #-1,d1
  IOCS _B_LOCATE
  move d0,d3  ;行位置

  IOCS _B_KEYINP

  moveq #3,d1  ;white
  moveq #0,d2
  moveq #96-1,d4
  lea (strTarget,pc),a1
  IOCS _B_PUTMES

  lea (CrLf,pc),a1
  IOCS _B_PRINT

  DOS _EXIT


.data

strPutKey: .dc.b 'カーソルが描画中のタイミングでなにかキーを押してください。',CR,LF,0
strTarget: .dc.b '★ ← タイミングがよければ、カーソルの反転描画が残ります。',0

CrLf: .dc.b CR,LF,0


.end ProgramStart
