.title dos_mkdir - DOS _MKDIR

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
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  addq.l #1,a2
  SKIP_SPACE a2  ;空文字列も受け付ける(挙動確認用)

  pea (a2)
  DOS _MKDIR
  addq.l #4,sp
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT 


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

CrLf: .dc.b CR,LF,0


.end
