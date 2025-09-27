.title ioctrl13 - DOS _IOCTRL (MD=13, F_CODE=0)

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
  moveq #0,d7  ;ドライブ省略時はカレントドライブ

  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    moveq #$20,d0
    or.b (a2),d0
    cmpi.b #'a',d0
    bcs PrintUsage
    cmpi.b #'z',d0
    bhi PrintUsage
    moveq #$1f,d7
    and.b d0,d7
  @@:

  pea (IoctrlBuffer,pc)
  clr -(sp)  ;F_MODE=0
  move d7,-(sp)
  move #13,-(sp)
  DOS _IOCTRL
  lea (10,sp),sp

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  moveq #16,d0
  lea (IoctrlBuffer,pc),a0
  bsr DumpMemory

  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: ioctrl13 [d:]'
  DOS _EXIT


DumpMemory:
  PUSH d2/a2
  move d0,d2
  lsr #1,d2
  lea (a0),a2
  lea (Buffer,pc),a0
  subq #1,d2
  @@:
    move (a2)+,d0
    bsr ToHexString4
    move.b #' ',(a0)+
  dbra d2,@b
  clr.b -(a0)

  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)

  POP d2/a2
  rts


  DEFINE_TOHEXSTRING4 ToHexString4
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

CrLf: .dc.b CR,LF,0


.bss

Buffer: .ds.b 64

IoctrlBuffer: .ds.b 64*1024


.end
