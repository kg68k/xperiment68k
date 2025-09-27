.title appendbytes - append padding data to file

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
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


MAX_LENGTH: .equ 10
MAX_DATA_SIZE: .equ 64*1024


.cpu 68000
.text

Start:
  lea (1,a2),a0
  SKIP_SPACE a0
  lea (LengthTable,pc),a1
  bsr AnalyzeArgument
  beq @f
    PRINT_1LINE_USAGE 'usage: appendbytes <length<[,...] <filename>'
    DOS _EXIT
  @@:

  bsr OpenFile
  move.l d0,d7
  bpl @f
    lea (strFileOpenError,pc),a0
    bra error
  @@:
  move #SEEKMODE_END,-(sp)
  clr.l -(sp)
  move d7,-(sp)
  DOS _SEEK
  addq.l #8,sp
  tst.l d0
  bpl @f
    lea (strFileSeekError,pc),a0
    bra error
  @@:

  lea (LengthTable+4,pc),a5
  moveq #0,d6
  1:
    move.l (a5)+,d5  ;バイト数
    moveq #'0',d0
    add.b d6,d0  ;'0'～'9'
    move.l d5,d1
    lea (Buffer,pc),a0
    bsr FillBuffer

    move.l d5,-(sp)
    pea (Buffer,pc)
    move d7,-(sp)
    DOS _WRITE
    addq.l #10-4,sp
    move.l d0,(sp)+
    bpl @f
      lea (strFileWriteError,pc),a0
      bra error
    @@:
    cmp.l d0,d5
    beq @f
      DOS_PRINT (strDiskFull,pc)
      bra error2
    @@:
  addq.l #1,d6
  cmp.l (LengthTable,pc),d6
  bcs 1b

  DOS _EXIT

error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)
error2:
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


OpenFile:
  move #OPENMODE_WRITE,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  tst.l d0
  bpl @f  ;既存ファイルを書き込みオープンできた
    move #1<<FILEATR_ARCHIVE,-(sp)
    pea (a0)
    DOS _CREATE
    addq.l #6,sp
    tst.l d0
  @@:
  rts


FillBuffer:
  .rept 4
    move.b d0,(a0)+
  .endm
  move.l -(a0),d0
  addq.l #4-1,d1
  lsr.l #2,d1  ;ロングワード数(端数切り上げ)
  beq 1f
    subq #1,d1
    @@:
      move.l d0,(a0)+
    dbra d1,@b
  1:
  rts


AnalyzeArgument:
  lea (4,a1),a2

  ;バイト数
  @@:
    cmpi.l #MAX_LENGTH,(a1)
    bcc 8f  ;バイト数の指定が多すぎる
    FPACK __STOL
    bcs 8f
    cmpi.l #MAX_DATA_SIZE,d0
    bhi 8f
      addq.l #1,(a1)   ;バイト数を指定した回数
      move.l d0,(a2)+  ;バイト数
  cmpi.b #',',(a0)+
  beq @b

  ;残りがファイル名
  cmpi.b #' ',-(a0)
  bne 8f
  SKIP_SPACE a0
  beq 8f
    moveq #0,d0
    bra 9f
8:
  moveq #-1,d0
9:
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strFileOpenError:  .dc.b 'file open error: ',0
strFileSeekError:  .dc.b 'file seek error: ',0
strFileWriteError: .dc.b 'file write error: ',0
strDiskFull: .dc.b 'disk full',CR,LF,0
CrLf: .dc.b CR,LF,0


.bss

.quad
LengthTable:
  .ds.l 0           ;バイト数を指定した回数
  .ds.l MAX_LENGTH  ;バイト数の配列

.quad
Buffer: .ds.b MAX_DATA_SIZE


.end
