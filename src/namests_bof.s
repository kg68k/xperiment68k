.title namests_bof - DOS _NAMESTS buffer overflow PoC

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
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


MARGIN_SIZE: .equ 128

.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    lea (LongFilename,pc),a2
  @@:

  bsr PrintCwd
  DOS_PRINT (ArgMessage,pc)
  DOS_PRINT (a2)
  DOS_PRINT (CrLf,pc)

  lea (NamestsBuffer,pc),a0
  bsr InitNamestsBuffer
  pea (NamestsBuffer,pc)
  pea (a2)
  DOS _NAMESTS
  addq.l #8,sp
  move.l d0,d7

  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  tst.l d7
  bmi @f
    lea (NamestsBuffer,pc),a0
    bsr PrintNamests
  @@:

  lea (MarginBuffer,pc),a0
  bsr IsMarginBroken
  beq @f
    DOS_PRINT (OverflowMessage,pc)
    move #MARGIN_SIZE,d0
    lea (MarginBuffer,pc),a0
    bsr DumpByte
  @@:

  DOS _EXIT


InitNamestsBuffer:
  .fail (sizeof_NAMESTS.mod.4).or.(MARGIN_SIZE.mod.4)
  moveq #0,d0
  moveq #sizeof_NAMESTS/4-1,d1
  @@:
    move.l d0,(a0)+
  dbra d1,@b

  moveq #$ff,d0
  moveq #MARGIN_SIZE/4-1,d1
  @@:
    move.l d0,(a0)+
  dbra d1,@b
  rts

IsMarginBroken:
  moveq #$ff,d0
  moveq #MARGIN_SIZE/4-1,d1
  @@:
    cmp.l (a0)+,d0
  dbne d1,@b
  rts


DumpByte:
  PUSH d2-d6/a2
  lea (a0),a2
  moveq #0,d3   ;メモリオフセット
  moveq #16,d4  ;一行に表示するバイト数
  move d0,d5    ;残りバイト数
  moveq #'_',d6

  DumpByte_loop:
    lea (Buffer,pc),a0
    move #'+$',(a0)+
    move d3,d0
    bsr ToHexString2
    move #': ',(a0)+

    move d4,d2
    subq #1,d2
    1:
      move.b (a2)+,d0
      cmpi.b #$ff,d0
      beq 2f
        bsr ToHexString2
        bra 3f
      2:
        move.b d6,(a0)+
        move.b d6,(a0)+
      3:
      move.b #' ',(a0)+
    dbra d2,1b
    clr.b -(a0)
    DOS_PRINT (Buffer,pc)
    DOS_PRINT (CrLf,pc)

    add d4,d3
  sub d4,d5
  bhi DumpByte_loop

  POP d2-d6/a2
  rts


PrintCwd:
  pea (Buffer,pc)
  clr -(sp)
  DOS _CURDIR
  addq.l #6,sp
  tst.l d0
  bmi @f
    DOS_PRINT (CwdMessage,pc)
    DOS_PRINT (Buffer,pc)
    DOS_PRINT (CrLf,pc)
  @@:
  rts


PrintNamests:
  PUSH a2-a3
  lea (a0),a3

  lea (WildMessage,pc),a0
  move.b (NAMESTS_Wild,a3),d0
  bsr PrintNamestsD0b

  lea (DriveMessage,pc),a0
  move.b (NAMESTS_Drive,a3),d0
  bsr PrintNamestsD0b

  lea (PathMessage,pc),a0
  lea (NAMESTS_Path,a3),a1
  lea (sizeof_NAMESTS_Path,a1),a2
  bsr PrintNamestsSub

  lea (Name1Message,pc),a0
  lea (NAMESTS_Name1,a3),a1
  lea (sizeof_NAMESTS_Name1,a1),a2
  bsr PrintNamestsSub

  lea (ExtMessage,pc),a0
  lea (NAMESTS_Ext,a3),a1
  lea (sizeof_NAMESTS_Ext,a1),a2
  bsr PrintNamestsSub

  lea (Name2Message,pc),a0
  lea (NAMESTS_Name2,a3),a1
  lea (sizeof_NAMESTS_Name2,a1),a2
  bsr PrintNamestsSub

  POP a2-a3
  rts

PrintNamestsD0b:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr Print$2
  DOS_PRINT (CrLf,pc)
  rts

PrintNamestsSub:
  DOS_PRINT (a0)
  move.b (a2),d1
  clr.b (a2)
  DOS_PRINT (a1)
  move.b d1,(a2)
  DOS_PRINT (CrLf,pc)
  rts


  DEFINE_TOHEXSTRING2 ToHexString2
  DEFINE_PRINT$2 Print$2
  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

CwdMessage:    .dc.b 'Cwd:      ',0
ArgMessage:    .dc.b 'Argument: ',0
CrLf: .dc.b CR,LF,0

WildMessage:  .dc.b 'Wildcard: ',0
DriveMessage: .dc.b 'Drive:    ',0
PathMessage:  .dc.b 'Path:  ',0
Name1Message: .dc.b 'Name1: ',0
ExtMessage:   .dc.b 'Ext:   ',0
Name2Message: .dc.b 'Name2: ',0

OverflowMessage:
  .dc.b CR,LF
  .dc.b 'バッファーオーバーフローが発生しました。',CR,LF
  .dc.b 0

;89バイトのファイル名(パス名)
LongFilename:
  .dc.b 'aaaaaaaaa\'
  .dc.b 'bbbbbbbbb\'
  .dc.b 'ccccccccc\'
  .dc.b 'ddddddddd\'
  .dc.b 'eeeeeeeee\'
  .dc.b 'fffffffff\'
  .dc.b 'ggggggggg\'
  .dc.b 'hhhhhhhhh\'
  .dc.b 'iiiiiiii\',0


.bss
.quad

Buffer: .ds.b 128

.quad
NamestsBuffer: .ds.b sizeof_NAMESTS
MarginBuffer:  .ds.b MARGIN_SIZE


.end ProgramStart
