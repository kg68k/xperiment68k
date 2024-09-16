.title malloc_ba_exec - malloc before and after exec

;This file is part of Xperiment68k
;Copyright (C) 2024 TcbnErik
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

ProgramStart:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (Usage,pc)
    DOS _EXIT
  @@:
  lea (Execfile,pc),a0
  STRCPY a2,a0

  bsr pathchk
  tst.l d0
  bpl @f
    DOS_PRINT (PathchkErrorMessage,pc)
    DOS _EXIT
  @@:
  bsr malloc
  bsr exec
  bsr malloc

  DOS _EXIT


pathchk:
  clr.l -(sp)
  pea (Cmdline,pc)
  pea (Execfile,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  rts


exec:
  DOS_PRINT (Execfile,pc)
  DOS_PRINT (Space,pc)
  DOS_PRINT (Cmdline,pc)
  DOS_PRINT (CrLf,pc)

  clr.l -(sp)
  pea (Cmdline,pc)
  pea (Execfile,pc)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
  rts


malloc:
  pea (16)
  DOS _MALLOC
  move.l d0,(sp)

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  tst.l (sp)
  bmi @f
    DOS _MFREE
  @@:
  addq.l #4,sp
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data
Usage: .dc.b 'usage: malloc_ba_exec <command...>',CR,LF,0
PathchkErrorMessage: .dc.b 'pathchk error',CR,LF,0

Space: .dc.b ' ',0
CrLf: .dc.b CR,LF,0


.bss
.even

Cmdline: .ds.b 256
Execfile: .ds.b 256


.end ProgramStart
