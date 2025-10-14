.title m_mdreg - OPM _M_MDREG

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
.include opmdrvdef.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr ParseArguments
  move.l d1,d3  ;書き込むデータ
  move.l d0,d2  ;グループ番号、アドレス番号
  OPM _M_MDREG
  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


ParseArguments:
  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntWord
  move d0,d1  ;グループ番号
  swap d1

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseIntWord
  move d0,d1  ;アドレス番号

  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseInt  ;書き込むデータ
  exg.l d0,d1
  rts


PrintUsage:
  PRINT_1LINE_USAGE 'usage: m_mdreg <group_no> <addr_no> <data>'
  DOS _EXIT


  DEFINE_PARSEINT ParseInt
  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
