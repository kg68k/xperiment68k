.title incdir_test - increase directory test

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

;参考: X680x0 のメーカー純正ソフトウェアの不具合について
;  https://stdkmd.net/bugsx68k/#human_subdir
;  1.1. サブディレクトリ内のファイルが増えたときファイルなどが壊れることがある (Human68k 2.15/3.01/3.02)
FILLER_SIZE:      .equ 65299*1024
TARGET_SIZE:      .equ 512
PADDING_FILE_NUM: .equ 126+1


.include macro.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


BUFFER_SIZE: .equ 4*1024*1024

.cpu 68000
.text

ProgramStart:
  bsr PrepareFillerFile
  bmi error
  bsr CreateSubDir
  bmi error
  bsr CreateTargetFile
  bmi error
  bsr CreatePaddingFiles
  bmi error

  DOS_PRINT (DoneMessage,pc)
  DOS _EXIT
error:
  move #1,-(sp)
  DOS _EXIT2


;ルートディレクトリに65299KiBのファイルを用意する。
PrepareFillerFile:
  DOS_PRINT (CreateFillerFileMessage,pc)

  lea (FillerFilename,pc),a0
  bsr GetFileSize
  bpl @f
    lea (FillerFilename,pc),a0
    bsr CreateFillerFile
    bra 9f
  @@:
  cmpi.l #FILLER_SIZE,d0
  beq @f
    DOS_PRINT (FillerSizeMismatchMessage,pc)
    moveq #-1,d0
    bra 9f
  @@:
  DOS_PRINT (FillerExistsMessage,pc)
  moveq #0,d0
9:
  rts


GetFileSize:
  link a6,#-(sizeof_FILES+1)
  lea (sp),a1

  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (a0)
  pea (a1)
  DOS _FILES
  addq.l #10-4,sp
  move.l d0,(sp)+
  bmi @f
    move.l (FILES_FileSize,a1),d0
  @@:
  unlk a6
  rts


;ルートディレクトリに65299KiBのファイルを作る。
CreateFillerFile:
  PUSH d2-d7
  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (a0)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d7
  bpl @f
    bsr PrintError
    bra 9f
  @@:

  moveq #0,d5
  move.l #FILLER_SIZE,d6
  fillerLoop:
    move.l d6,d2
    sub.l d5,d2  ;残りサイズ
    beq fillerDone
    move.l #BUFFER_SIZE,d0
    cmp.l d0,d2
    bls @f
      move.l d0,d2  ;今回の書き込みサイズ
    @@:

    move.l d5,d0
    move.l d6,d1
    bsr PrintProgress

    move.l d2,-(sp)
    pea (WriteBuffer,pc)
    move d7,-(sp)
    DOS _WRITE
    lea (10,sp),sp
    cmp.l d0,d2
    beq @f
      tst.l d0
      bmi 1f
        DOS_PRINT (NoDiskSpaceMessage,pc)
        moveq #-1,d0
        bra 9f
      1:
        bsr PrintError
        bra 9f
    @@:
    add.l d2,d5
    bra fillerLoop
  fillerDone:

  move.l d5,d0
  move.l d6,d1
  bsr PrintProgress

  move d7,-(sp)
  DOS _CLOSE
  addq.l #2,sp
  moveq #0,d0
9:
  POP d2-d7
  rts


PrintProgress:
  lea (Buffer,pc),a0
  move.l d1,-(sp)

  move.b #'$',(a0)+
  bsr ToHexString4_4  ;書き込み済みサイズ

  move.b #'/',(a0)+
  move.l (sp)+,d0

  move.b #'$',(a0)+
  bsr ToHexString4_4  ;目標サイズ

  move.b #CR,(a0)+
  move.b #LF,(a0)+
  clr.b (a0)

  DOS_PRINT (Buffer,pc)
  rts


;ルートディレクトリにサブディレクトリを作る。
CreateSubDir:
  DOS_PRINT (CreateSubDirMessage,pc)

  pea (SubdirName,pc)
  DOS _MKDIR
  move.l d0,(sp)+
  bpl @f
    bsr PrintError
    bra 9f
  @@:
9:
  rts


;ルートディレクトリに破壊される予定のファイルを作る。
CreateTargetFile:
  PUSH d7
  DOS_PRINT (CreateTargetFileMessage,pc)

  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (TargetFilename,pc)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d7
  bpl @f
    bsr PrintError
    bra 9f
  @@:

  move.l #TARGET_SIZE,d1
  move.l d1,-(sp)
  pea (WriteBuffer,pc)
  move d7,-(sp)
  DOS _WRITE
  lea (10,sp),sp
  cmp.l d0,d1
  beq @f
    tst.l d0
    bmi 1f
      DOS_PRINT (NoDiskSpaceMessage,pc)
      moveq #-1,d0
      bra 9f
    1:
      bsr PrintError
      bra 9f
  @@:

  move d7,-(sp)
  DOS _CLOSE
  addq.l #2,sp
  moveq #0,d0
9:
  POP d7
  rts


;サブディレクトリ内に空ファイルを126+1個作る。
CreatePaddingFiles:
  PUSH d6-d7
  DOS_PRINT (CreatePaddingFilesMessage,pc)

  move #PADDING_FILE_NUM-1,d6
  paddingLoop:
    move #1<<FILEATR_ARCHIVE,-(sp)
    pea (PaddingFilename,pc)
    DOS _MAKETMP
    addq.l #6,sp
    tst.l d0
    bpl @f
      bsr PrintError
      bra 9f
    @@:
    move d0,-(sp)
    DOS _CLOSE
    addq.l #2,sp

    DOS_PRINT (PaddingFilename,pc)
    DOS_PRINT (CrLf,pc)
  dbra d6,paddingLoop

  moveq #0,d0
9:
  POP d6-d7
  rts


PrintError:
  move.l d0,-(sp)
  lea (Buffer,pc),a0
  bsr ToHexString4_4
  DOS_PRINT (ErrorMessage,pc)
  DOS_PRINT (Buffer,pc)
  DOS_PRINT (CrLf,pc)
  move.l (sp)+,d0
  rts

  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

FillerFilename: .dc.b '\FILLER.DAT',0
TargetFilename: .dc.b '\TARGET.DAT',0

SubdirName:      .dc.b '\SUBDIR',0
PaddingFilename: .dc.b '\SUBDIR\0001.DAT',0

CreateSubDirMessage: .dc.b 'creating sub directory...',CR,LF,0
CreateFillerFileMessage: .dc.b 'creating filler file...',CR,LF,0
CreateTargetFileMessage: .dc.b 'creating target file...',CR,LF,0
CreatePaddingFilesMessage: .dc.b 'creating padding files...',CR,LF,0
DoneMessage: .dc.b 'done.',CR,LF,0

FillerExistsMessage: .dc.b 'ファイルが存在するため、そのまま続行します。',CR,LF,0
FillerSizeMismatchMessage: .dc.b 'サイズの違うファイルが存在します。',CR,LF,0
NoDiskSpaceMessage: .dc.b 'ディスクの空き容量が足りません。',CR,LF,0
ErrorMessage: .dc.b 'error: $',0

CrLf: .dc.b CR,LF,0


.bss

.even
Buffer: .ds.b 128

.align 16
WriteBuffer: .ds.b BUFFER_SIZE


.end ProgramStart
