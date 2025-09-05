.title closerewindatr - DOS _CLOSE rewinds the file attribute

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

.include dosdef.mac
.include macro.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

Start:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (Usage,pc)
    DOS _EXIT
  @@:

  DOS_PRINT (OpenMessage,pc)  ;ファイルをオープン
  move #OPENMODE_WRITE,-(sp)
  pea (a2)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  lea (DosOpenMessage,pc),a0
  bmi error

  move #SEEKMODE_END,-(sp)  ;ファイル末尾にシーク
  clr.l -(sp)
  move d7,-(sp)
  DOS _SEEK
  addq.l #8,sp
  lea (DosSeekMessage,pc),a0
  bmi error

  bsr GetAndPrintFileAttribute  ;現在のファイル属性を表示
  bmi chmodError
  move.l d0,d6

  DOS_PRINT (ReverseRMessage,pc)
  move d6,d0
  bchg #FILEATR_READONLY,d0  ;読み込み専用属性を反転
  move d0,-(sp)
  pea (a2)
  DOS _CHMOD
  addq.l #6,sp
  tst.l d0
  bmi chmodError

  bsr GetAndPrintFileAttribute  ;変更後のファイル属性を表示
  bmi chmodError

  ;ファイルクローズ時にディレクトリエントリの更新が行われるように
  ;ファイルに書き込みを行う(FCB内のデータ更新フラグがセットされる)
  DOS_PRINT (WriteMessage,pc)
  move d7,-(sp)
  move #LF,-(sp)
  DOS _FPUTC
  move.l d0,(sp)+
  lea (DosFputcMessage,pc),a0
  bmi error

  DOS_PRINT (CloseMessage,pc)  ;ファイルをクローズ
  move d7,-(sp)
  DOS _CLOSE
  addq.l #2,sp
  tst.l d0
  lea (DosCloseMessage,pc),a0
  bmi error

  bsr GetAndPrintFileAttribute  ;クローズ直後のファイル属性を表示
  bmi chmodError

  DOS _EXIT


chmodError:
  lea (DosChmodMessage,pc),a0
error:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0$4_4
  DOS_PRINT (CrLf,pc)

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


GetAndPrintFileAttribute:
  move #-1,-(sp)
  pea (a2)
  DOS _CHMOD
  addq.l #6,sp
  move.l d0,-(sp)
  bmi @f
    DOS_PRINT (FileAttributeMessage,pc)
    move.l (sp),d0
    bsr PrintFileAttribute
    DOS_PRINT (CrLf,pc)
  @@:
  move.l (sp)+,d0
  rts


PrintFileAttribute:
  link a6,#-12
  lea (sp),a0
  lea (FileAttributes,pc),a1
  moveq #8-1,d2
  1:
    moveq #'_',d1
    add.b d0,d0
    bcc @f
      move.b (a1),d1
    @@:
    addq.l #1,a1
    move.b d1,(a0)+
  dbra d2,1b
  clr.b (a0)

  DOS_PRINT (sp)
  unlk a6
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

Usage: .dc.b 'usage: closerewindatr <file>',CR,LF,0

DosOpenMessage: .dc.b 'DOS _OPEN エラー: ',0
DosSeekMessage: .dc.b 'DOS _SEEK エラー: ',0
DosChmodMessage: .dc.b 'DOS _CHMOD エラー: ',0
DosFputcMessage: .dc.b 'DOS _FPUTC エラー: ',0
DosCloseMessage: .dc.b 'DOS _CLOSE エラー: ',0

FileAttributeMessage: .dc.b 'ファイル属性 = ',0
FileAttributes: .dc.b 'XLADVSHR'

OpenMessage: .dc.b 'ファイルをオープンします。',CR,LF,0
ReverseRMessage: .dc.b '読み込み専用属性を変更します。',CR,LF,0
WriteMessage: .dc.b 'ファイルに書き込みを行います。',CR,LF,0
CloseMessage: .dc.b 'ファイルをクローズします。',CR,LF,0

CrLf: .dc.b CR,LF,0


.end
