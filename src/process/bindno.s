.title bindno - DOS _EXEC (md=5)

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

.include xputil.mac


.cpu 68000
.text

Start:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  lea (OverlayFilename,pc),a1
  bsr CopyFilename

  SKIP_SPACE a0
  beq PrintUsage

  lea (ModuleFilename,pc),a1
  bsr CopyFilename

  pea (ModuleFilename,pc)
  pea (OverlayFilename,pc)
  move #EXECMODE_BINDNO,-(sp)
  DOS _EXEC
  lea (10,sp),sp

  bsr Print$4_4
  DOS_PRINT_CRLF
  DOS _EXIT


PrintUsage:
  PRINT_1LINE_USAGE 'usage: bindno <overlay_x_file> <module_x_file>'
  DOS _EXIT


CopyFilename:
  bra 5f
  1:
    move.b d0,(a1)+
    5:
  move.b (a0)+,d0
  beq 9f
  cmpi.b #' ',d0
  bne 1b
9:
  subq.l #1,a0
  clr.b (a1)
  rts


  DEFINE_PRINT$4_4 Print$4_4


.bss
.even

OverlayFilename: .ds.b 256
ModuleFilename:  .ds.b 256

.end
