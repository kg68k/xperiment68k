.title iocs_b_clr_st - IOCS _B_CLR_ST

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
  moveq #2,d1  ;引数省略時は画面全体を消去

  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    move.b (a2)+,d1
    subi.b #'0',d1
    cmpi.b #2,d1
    bhi NumberError
  @@:
  IOCS _B_CLR_ST

  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  DOS _EXIT


NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


 DEFINE_PRINT$4_4 Print$4_4


.data

strNumberError:
  .dc.b '範囲の指定が正しくありません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart
