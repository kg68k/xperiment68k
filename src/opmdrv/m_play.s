.title m_play - OPM _M_PLAY

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

.include fefunc.mac
.include opmdrv.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  moveq #0,d2  ;チャンネル番号の省略時は全チャンネル対象
  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    FPACK __STOL
    bcs NumberError
    move.l d0,d2  ;チャンネル番号
  @@:
  OPM _M_PLAY
  bsr Print$4_4
  DOS_PRINT (strCrLf,pc)

  DOS _EXIT


NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.end ProgramStart
