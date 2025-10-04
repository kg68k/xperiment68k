.title m_vset - OPM _M_VGET

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

.include filesys.mac
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  bsr ParseInt
  move.l d0,d7
  SKIP_SPACE a0
  beq PrintUsage

  bsr ReadToneFromFile
  move.l d7,d2  ;音色番号
  lea (ToneBuffer,pc),a1
  OPM _M_VSET

  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: m_vset <tone_no> <filename>'
  DOS _EXIT


ReadToneFromFile:
  moveq #FM_TONE_V_SIZE,d0
  lea (ToneBuffer,pc),a1
  bsr ReadFileToBuffer
  tst.l d0
  bpl @f
    FATAL_ERROR 'file read error'
  @@:
  cmpi.l #FM_TONE_V_SIZE,d0
  beq @f
    FATAL_ERROR 'file size error'
  @@:
  rts


ReadFileToBuffer:
  move.l d0,d2  ;読み込みサイズ

  move #OPENMODE_READ,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d1
  bmi 9f
    move.l d2,-(sp)
    pea (a1)
    move d1,-(sp)
    DOS _READ
    lea (10,sp),sp

    move.l d0,d2
    move d1,-(sp)
    DOS _CLOSE
    addq.l #2,sp
    move.l d2,d0
  9:
  rts


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.bss

.even
ToneBuffer: .ds.b FM_TONE_V_SIZE


.end ProgramStart
