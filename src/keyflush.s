.title keyflush - key flush test

# This file is part of Xperiment68k
# Copyright (C) 2022 TcbnErik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

.include include/console.mac
.include include/doscall.mac
.include include/iocscall.mac


.cpu 68000
.text

Start:
  bsr AnalyzeArgument
  move.l d0,d7  ;option

  lea (strShiftToExit,pc),a1
  IOCS _B_PRINT
loop:
  DOS _CHANGE_PR

  IOCS _B_SFTSNS
  andi.b #%0000_0001,d0  ;shift key
  beq loop

  bsr KeyFlush
  DOS _EXIT


KeyFlush:
  cmpi.b #'i',d7
  beq KeyFlushIocs
  cmpi.b #'c',d7
  beq KeyFlushDosKeyCtrl
  cmpi.b #'f',d7
  beq KeyFlushDosKeyFlush
  rts

KeyFlushIocs:
  bra 1f
@@:
  IOCS _B_KEYINP
1:
  IOCS _B_KEYSNS
  tst.l d0
  bne @b
  rts

KeyFlushDosKeyCtrl:
  bra 1f
@@:
  clr -(sp)
  DOS _KEYCTRL
  addq.l #2,sp
1:
  move #1,-(sp)
  DOS _KEYCTRL
  move d0,(sp)+
  bne @b
  rts

KeyFlushDosKeyFlush:
  move.l #(.low._INPOUT<<16)+$00ff,-(sp)
  DOS _KFLUSH
  addq.l #4,sp
  rts


AnalyzeArgument:
  addq.l #1,a2
  moveq #0,d0
@@:
  move.b (a2)+,d0
  beq @f
  cmpi.b #'i',d0  ;use IOCS _KEYINP
  beq 9f
  cmpi.b #'c',d0  ;use DOS _KEYCTRL
  beq 9f
  cmpi.b #'f',d0  ;use DOS _KEYFLUSH
  beq 9f
  bra @b
@@:
  moveq #'i',d0
9:
  rts


.data

strShiftToExit: .dc.b 'SHIFTキー押し下げで終了します。',CR,LF,0


.end
