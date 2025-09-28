.title ioctrl12 - DOS _IOCTRL (MD=12, F_CODE=0)

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
.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  moveq #0,d7  ;引数省略時はファイルハンドル0(標準入力)
  addq.l #1,a2
  SKIP_SPACE a2
  beq @f
    clr -(sp)
    pea (a2)
    DOS _OPEN
    addq.l #6,sp
    move.l d0,d7
    bmi FileOpenError
  @@:

  pea (IoctrlBuffer,pc)
  clr -(sp)  ;F_MODE=0
  move d7,-(sp)
  move #12,-(sp)
  DOS _IOCTRL
  lea (10,sp),sp

  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  moveq #16,d0
  lea (IoctrlBuffer,pc),a0
  bsr DumpMemory

  DOS _EXIT


FileOpenError:
  move.l d0,-(sp)
  DOS_PRINT (FileOpenErrorMessage,pc)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT_CRLF

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


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
  DOS_PRINT_CRLF

  POP d2/a2
  rts


  DEFINE_TOHEXSTRING4 ToHexString4
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

FileOpenErrorMessage: .dc.b 'ファイルがオープンできませんでした: ',0


.bss

Buffer: .ds.b 64

IoctrlBuffer: .ds.b 64*1024


.end
