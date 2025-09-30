.title m_pcmon - OPM _M_PCMON

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

.include opmdrv.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    PRINT_1LINE_USAGE 'usage: m_pcmon <note_no(0..127)> [freq(0..4)] [pan(1..3)]'
    DOS _EXIT
  @@:
  bsr ParseArguments
  move.l d0,d2
  OPM _M_PCMON
  bsr Print$4_4
  DOS_PRINT_CRLF

  DOS _EXIT


ParseArguments:
  move.l #4<<8+3,d1  ;15.6kHz、ステレオ

  bsr ParseIntWord
  swap d1
  move d0,d1  ;ノート番号
  swap d1
  SKIP_SPACE a0
  beq 9f
    bsr ParseIntByte
    ror #8,d1
    move.b d0,d1  ;周波数
    ror #8,d1
    SKIP_SPACE a0
    beq 9f
      bsr ParseIntByte
      move.b d0,d1  ;パンポット
  9:
  move.l d1,d0
  rts


  DEFINE_PARSEINTWORD ParseIntWord
  DEFINE_PARSEINTBYTE ParseIntByte
  DEFINE_PRINT$4_4 Print$4_4


.end ProgramStart
