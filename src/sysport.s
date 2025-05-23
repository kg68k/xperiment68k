.title sysport - print system port

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
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  lea ($00e8e000),a2
  lea (headers,pc),a3
  moveq #$10-1,d7
  @@:
    lea (a2),a0
    lea (a3),a1
    bsr printSysPort
    addq.l #1,a2
    STREND a3,+1
  dbra d7,@b
  DOS _EXIT

printSysPort:
  pea (a1)
  DOS _PRINT
  addq.l #4,sp

  bsr DosBusErrByte
  beq @f
    pea (strBusErr,pc)
    DOS _PRINT
    addq.l #4,sp
    bra 9f
  @@:
    bsr Print$2
9:
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_PRINT$2 Print$2
  DEFINE_DOSBUSERRBYTE DosBusErrByte


.data

headers:
  .dc.b '$00e8e000   n/a  : ',0
  .dc.b '$00e8e001 #1(r/w): ',0
  .dc.b '$00e8e002   n/a  : ',0
  .dc.b '$00e8e003 #2(r/w): ',0
  .dc.b '$00e8e004   n/a  : ',0
  .dc.b '$00e8e005 #3(  w): ',0
  .dc.b '$00e8e006   n/a  : ',0
  .dc.b '$00e8e007 #4(r/w): ',0
  .dc.b '$00e8e008   n/a  : ',0
  .dc.b '$00e8e009 #5(  w): ',0
  .dc.b '$00e8e00a   n/a  : ',0
  .dc.b '$00e8e00b #6(r  ): ',0
  .dc.b '$00e8e00c   n/a  : ',0
  .dc.b '$00e8e00d #7(  w): ',0
  .dc.b '$00e8e00e   n/a  : ',0
  .dc.b '$00e8e00f #8(  w): ',0

strBusErr: .dc.b 'bus error',0

CrLf: .dc.b CR,LF,0


.end
