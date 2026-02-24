.title iocs_b_recali - IOCS _B_RECALI

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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

.include xputil.mac


PDA_FDD0:       .equ $9000
PDA_NEXT_DRIVE: .equ $0100


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne 1f
    bsr RecalibrateAllFdd  ;引数省略時はFDD 0～3の接続検査を行う
    bra @f
  1:
    bsr ParseIntWord
    move d0,d1  ;PDA
    IOCS _B_RECALI
    bsr Print$4_4
    DOS_PRINT_CRLF
  @@:
  DOS _EXIT


RecalibrateAllFdd:
  lea (strDrives,pc),a1
  move #PDA_FDD0+$ff,d1  ;強制レディ状態での検査
  moveq #4-1,d2
  @@:
    DOS_PRINT (a1)
    IOCS _B_RECALI
    bsr Print$4_4
    DOS_PRINT_CRLF

    addi #PDA_NEXT_DRIVE,d1
    STREND a1,+1
  dbra d2,@b
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PRINT$4_4 Print$4_4


.data

strDrives:
  .dc.b 'FDD 0: ',0
  .dc.b 'FDD 1: ',0
  .dc.b 'FDD 2: ',0
  .dc.b 'FDD 3: ',0


.end ProgramStart
