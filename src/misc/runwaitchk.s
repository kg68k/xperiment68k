.title runwaitchk - memory wait checker

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

.include iomap.mac
.include macro.mac
.include iocswork.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  USE_GVRAM

  clr -(sp)  ;768x512,グラフィックなし
  move #16,-(sp)
  DOS _CONCTRL
  addq.l #4,sp

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  bsr PrintSystemStatus

  bsr WriteCodeToGvram

  lea (OnMainReadMain,pc),a0
  lea (LoopCode,pc),a1
  lea (LoopCode,pc),a2
  bsr Measure

  lea (OnMainReadGvram,pc),a0
  lea (LoopCode,pc),a1
  lea (GVRAM),a2
  bsr Measure

  lea (OnGvramReadMain,pc),a0
  lea (GVRAM),a1
  lea (LoopCode,pc),a2
  bsr Measure

  lea (OnGvramReadGvram,pc),a0
  lea (GVRAM),a1
  lea (GVRAM),a2
  bsr Measure

  DOS _EXIT


Measure:
  PUSH d3/d6-d7
  DOS_PRINT (a0)
  lea (a2),a0

  moveq #10-1,d6
  move #$ffff,d7
  IOCS _ONTIME
  movem.l d0-d1,-(sp)
  jsr (a1)
  IOCS _ONTIME
  movem.l (sp)+,d2-d3

  cmp.l d3,d1
  beq @f
    addi.l #24*60*60*100,d0
  @@:
  sub.l d2,d0

  bsr PrintDecString
  DOS_PRINT_CRLF

  POP d3/d6-d7
  rts


WriteCodeToGvram:
  lea (LoopCode,pc),a0
  lea (GVRAM),a1
  moveq #(LoopCodeEnd-LoopCode)/2-1,d0
  @@:
    move (a0)+,(a1)+
  dbra d0,@b
  CACHE_FLUSH
  rts


.align 16
LoopCode:
  1:
    2:
      move.l (a0),d0
      move.l (a0),d0
    dbra d7,2b
    move.l (a0),d0
    move.l (a0),d0
  dbra d6,1b
  rts
LoopCodeEnd:


PrintSystemStatus:
  link a6,#-128
  lea (sp),a0

  lea (strMpuType,pc),a1
  STRCPY a1,a0,-1
  move.b (MPUTYPE),d0
  bsr ToHexString$2

  lea (strRomCnt,pc),a1
  STRCPY a1,a0,-1
  move (ROMCNT),d0
  bsr ToHexString$4

  lea (strRamCnt,pc),a1
  STRCPY a1,a0,-1
  move (RAMCNT),d0
  bsr ToHexString$4

  lea (strSysPort6,pc),a1
  STRCPY a1,a0,-1
  move.b (SYS_P6),d0
  bsr ToHexString$2

  WRITE_CRLF_NUL a0
  DOS_PRINT (sp)
  unlk a6
  rts


  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING$4 ToHexString$4
  DEFINE_PRINTDECSTRING PrintDecString


.data

OnMainReadMain:   .dc.b 'on main memory, read main memory: ',0
OnMainReadGvram:  .dc.b 'on main memory, read gvram: ',0
OnGvramReadMain:  .dc.b 'on gvram, read main memory: ',0
OnGvramReadGvram: .dc.b 'on gvram, read gvram: ',0

strMpuType:  .dc.b 'mputype = ',0
strRomCnt:   .dc.b ', romcnt = ',0
strRamCnt:   .dc.b ', ramcnt = ',0
strSysPort6: .dc.b ', sysport6 = ',0


.end
