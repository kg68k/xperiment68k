.title execas - make exec file alias

# This file is part of Xperiment68k
# Copyright (C) 2023 TcbnErik
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

.include macro.mac
.include dosdef.mac
.include console.mac
.include doscall.mac

.include xputil.mac


PSP_EXE_PATH: .equ $80
PSP_EXE_NAME: .equ $c4
sizeof_PSP: .equ $100


.cpu 68000
.text

ProgramStart:
  bsr getArg
  beq printUsage

  pea (0<<16+STDOUT)
  DOS _IOCTRL
  move.l d0,(sp)+
  bmi printUsage
  tst.b d0
  bpl @f  ;ブロックデバイスならOK(ファイルにリダイレクトされている)
    lsr #2,d0  ;キャラクタデバイスの場合
    bcs printUsage  ;標準出力デバイスならリダイレクトされていない
  @@:

  lea (fileBuffer,pc),a0
  lea (a2),a1
  STRCPY a1,a0

  clr.l -(sp)
  pea (cmdlineBuffer,pc)
  pea (fileBuffer,pc)
  move #EXEC_PATHCHK,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bpl @f
    lea (notFoundError,pc),a0
    bra makeError
  @@:

  lea (fileBuffer,pc),a0
  andi.b #$df,(a0)  ;ドライブ名を大文字化
  lea (TargetPath,pc),a1
  STRCPY a0,a1

  move a1,d0
  lsr #1,d0
  bcc @f
    clr.b (a1)+  ;even
  @@:

  lea (RuntimeStart,pc),a0
  suba.l a0,a1
  move.l a1,-(sp)
  pea (a0)
  move #STDOUT,-(sp)
  DOS _WRITE
  addq.l #10-4,sp
  cmp.l (sp)+,d0
  beq @f
    lea (writeError,pc),a0
    lea (TargetPath,pc),a2
    bra makeError
  @@:
  DOS _EXIT

getArg:
  addq.l #1,a2
  @@:
    move.b (a2)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @b
  @@:
  tst.b -(a2)
  rts


printUsage:
  lea (Usage,pc),a0
  suba.l a2,a2
  bra makeError

makeError:
  move #STDERR,-(sp)
  pea (a0)
  DOS _FPUTS
  move.l a2,(sp)
  beq @f
    DOS _FPUTS
  @@:
  move #EXIT_FAILURE,(sp)
  DOS _EXIT2


Usage: .dc.b 'usage: execas 実行ファイル名 > 新ファイル名.r',CR,LF,0

notFoundError: .dc.b 'execas: not found: ',0
writeError:    .dc.b 'execas: write error: ',0
.even


;;;;;;;; ランタイムコードここから ;;;;;;;;

RuntimeStart:
  bra.s @f
    .dc.b '#HUPAIR',0
    .dc.b 'execas 1.0.0',0
    .dc.b 'License: GNU GPL v3 or later.',0
    .even
  @@:
  lea (16,a0),a0
  suba.l a0,a1
  movem.l a0-a1,-(sp)
  DOS _SETBLOCK
  addq.l #8,sp

  clr.l -(sp)
  pea (a2)
  pea (TargetPath,pc)
  move #EXEC_LOAD,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  tst.l d0
  bpl @f
    lea (LoadError,pc),a0
    bra error
  @@:

  lea (2,a4),a1
  cmpi.l #'#HUP',(a1)+
  bne 1f
  cmpi.l #'AIR'<<8,(a1)+
  beq @f
  1:
    bsr execDummy
    lea (NoHupairError,pc),a0
    bra error
  @@:

  move #PSP_EXE_PATH,d0
  bsr comparePspString
  bne @f
    move #PSP_EXE_NAME,d0
    bsr comparePspString
    bne @f
      bsr execDummy
      lea (recursiveError,pc),a0
      bra error
  @@:

  move #PSP_EXE_PATH,d0
  bsr copyPspString
  move #PSP_EXE_NAME,d0
  bsr copyPspString

exec:
  bsr execOnly
exit2:
  move d0,-(sp)
  DOS _EXIT2

dummyEntry:
  DOS _EXIT


execDummy:
  lea (dummyEntry,pc),a4
execOnly:
  pea (a4)
  move #EXEC_EXEC,-(sp)
  DOS _EXEC
  addq.l #6,sp
  rts


comparePspString:
  lea (a0,d0.w),a1
  lea (RuntimeStart-sizeof_PSP,pc),a2
  adda d0,a2
  @@:
    move.b (a1)+,d0
    cmp.b (a2)+,d0
    bne 9f
  tst.b d0
  bne @b
9:
  rts

copyPspString:
  lea (a0,d0.w),a1
  lea (RuntimeStart-sizeof_PSP,pc),a2
  adda d0,a2
  STRCPY a2,a1
  rts


error:
  move #STDERR,-(sp)
  pea (a0)
  DOS _FPUTS
  addq.l #4,sp
  pea (TargetPath,pc)
  DOS _FPUTS
  addq.l #4,sp
  pea (CrLf,pc)
  DOS _FPUTS

  moveq #-1,d0
  bra exit2


LoadError:      .dc.b 'execas: load error: ',0
NoHupairError:  .dc.b 'execas: no HUPAIR mark: ',0
recursiveError: .dc.b 'execas: recursive execution: ',0

CrLf: .dc.b CR,LF,0
.even

TargetPath: .ds.b 90
.even

RuntimeEnd:

;;;;;;;; ランタイムコードここまで ;;;;;;;;


.bss

.even
fileBuffer:    .ds.b 256
cmdlineBuffer: .ds.b 256


.end ProgramStart
