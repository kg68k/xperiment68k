.title m_init - OPM _M_ALLOC

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
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage
  bsr GetUint16Value
  move d0,d2  ;トラック番号
  swap d2

  SKIP_SPACE a0
  bsr GetUint16Value
  move d0,d2  ;バッファサイズ

  OPM _M_ALLOC
  bsr Print$4_4
  DOS_PRINT (CrLf,pc)

  DOS _EXIT


GetUint16Value:
  FPACK __STOL
  bcs NumberError
  cmpi.l #$0001_0000,d0
  bcc NumberError
  rts


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT

NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT


  DEFINE_PRINT$4_4 Print$4_4


.data

strUsage:
  .dc.b 'usage: m_alloc <track_no> <size>',CR,LF,0

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart
