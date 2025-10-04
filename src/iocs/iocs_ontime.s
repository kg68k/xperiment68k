.title iocs_ontime - IOCS _ONTIME

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
.include fefunc.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (Buffer,pc),a0

  addq.l #1,a2
  SKIP_SPACE a2
  beq 1f
    bsr PrintOntimeDHMS
    bra @f
  1:
    bsr PrintOntimeHex
  @@:

  lea (CrLf,pc),a1
  STRCPY a1,a0
  DOS_PRINT (Buffer,pc)
  DOS _EXIT


PrintOntimeHex:
  IOCS _ONTIME
  move.l d1,d3

  lea (strD0,pc),a1
  STRCPY a1,a0,-1
  bsr ToHexString$4_4

  move.l d3,d0
  lea (strD1,pc),a1
  STRCPY a1,a0,-1
  bsr ToHexString$4_4
  rts


PrintOntimeDHMS:
  IOCS _ONTIME
  move.l d0,d3

  moveq #0,d0
  move d1,d0  ;日数
  FPACK __LTOS
  lea (strDays,pc),a1
  STRCPY a1,a0,-1

  move.l d3,d0
  moveq #100,d1
  bsr Divu32
  move.l d1,d7  ;1/100秒(0...99)

  moveq #60,d1
  bsr Divu32
  move.l d1,d6  ;秒数(0...59)

  bsr Divu32
  move.l d1,d5  ;分数(0...59)

  ;d0.w = 時間(0...23)
  bsr ToDecimalString02
  lea (strHours,pc),a1
  STRCPY a1,a0,-1

  move.l d5,d0
  bsr ToDecimalString02
  lea (strMinutes,pc),a1
  STRCPY a1,a0,-1

  move.l d6,d0
  bsr ToDecimalString02
  lea (strSeconds,pc),a1
  STRCPY a1,a0,-1

  move.l d7,d0
  bsr ToDecimalString02
  rts


ToDecimalString02:
  divu #10,d0
  addi.l #'0'<<16+'0',d0
  move.b d0,(a0)+
  swap d0
  move.b d0,(a0)+
  clr.b (a0)
  rts


  DEFINE_DIVU32 Divu32
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4


.data

strD0: .dc.b 'd0.l = ',0
strD1: .dc.b ', d1.l = ',0

strDays:    .dc.b 'd ',0
strHours:   .dc.b ':',0
strMinutes: .dc.b ':',0
strSeconds: .dc.b '"',0

CrLf: .dc.b CR,LF,0


.bss

Buffer: .ds.b 128


.end ProgramStart
