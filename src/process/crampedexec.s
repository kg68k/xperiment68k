.title crampedexec - execute a file in cramped memory

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
.include process.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  lea (sizeof_MEMBLK,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  lea (1,a2),a0
  SKIP_SPACE a0
  beq PrintUsage

  bsr GetFreeMemorySize
  bne PrintUsage
  cmpi.b #' ',(a0)
  bne PrintUsage
  move.l d0,d7  ;残すメモリのバイト数
  ble PrintUsage

  moveq #16-1,d0  ;16バイト単位に切り上げ
  add.l d0,d7
  not.l d0
  and.l d0,d7

  ;確保するメモリブロックのメモリ管理ポインタと
  ;実行するプロセスのPSPの分も残す
  addi.l #sizeof_MEMBLK+sizeof_PSP,d7

  SKIP_SPACE a0
  beq PrintUsage
  lea (FilenameBuffer,pc),a1
  STRCPY a0,a1

  clr.l -(sp)
  pea (CmdlineBuffer,pc)
  pea (FilenameBuffer,pc)
  move #EXECMODE_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi PathchkError

  move.l #$00ffffff,-(sp)
  DOS _MALLOC
  and.l (sp)+,d0
  sub.l d7,d0
  bls NotEnoughMemory

  move.l d0,-(sp)
  DOS _MALLOC
  move.l d0,(sp)+
  bmi NotEnoughMemory

  clr.l -(sp)
  pea (CmdlineBuffer,pc)
  pea (FilenameBuffer,pc)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bmi LoadexecError

  DOS _EXIT


PrintUsage:
  DOS_PRINT (strUsage,pc)
  DOS _EXIT


GetFreeMemorySize:
  bsr ParseInt
  moveq #10,d1
  cmpi.b #'k',(a0)  ;KiB単位での指定
  beq 1f
  moveq #20,d1
  cmpi.b #'m',(a0)  ;MiB単位での指定
  bne 8f
    1:
    addq.l #1,a0
    lsl.l d1,d0
8:
  cmp d0,d0  ;ccrZ=1
  rts
9:
  moveq #-1,d0  ;ccrZ=0
  rts


NotEnoughMemory:
  DOS_PRINT (strNotEnoughMemory,pc)
  bra error2

MallocError:
  lea (strMallocError,pc),a0
  bra error
PathchkError:
  lea (strPathchkError,pc),a0
  bra error
LoadexecError:
  lea (strLoadexecError,pc),a0
error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
error2:
  DOS_PRINT_CRLF
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


  DEFINE_PARSEINT ParseInt
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strUsage:
  .dc.b 'usage: crampedexec <size> <file> [args...]',CR,LF
  .dc.b '  <size>[k,m] ... free memory size',CR,LF
  .dc.b '  <file> ... filename to execute',CR,LF
  .dc.b 0

strNotEnoughMemory: .dc.b 'メモリが不足しています。',0

strMallocError:   .dc.b 'DOS _MALLOC error: ',0
strPathchkError:  .dc.b 'DOS _EXEC (pathchk) error: ',0
strLoadexecError: .dc.b 'DOS _EXEC (loadexec) error: ',0


.bss
.even

FilenameBuffer: .ds.b 256
CmdlineBuffer:  .ds.b 256



.end ProgramStart
