.title openedfiles - show opened files

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
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  clr.l -(sp)
  DOS _SUPER
  move.l d0,(sp)

  moveq #0,d7
  @@:
    move.l d7,d0
    bsr showFile
    addq.b #1,d7
    beq @f  ;念のため中断チェック
  tst.l d0
  beq @b
  @@:

  DOS _SUPER
  addq.l #4,sp
  DOS _EXIT


showFile:
  PUSH d3/a3
  move.l d0,d3

  move d3,-(sp)
  DOS _GET_FCB_ADR
  addq.l #2,sp
  movea.l d0,a3
  tst.l d0
  bpl @f
    cmpi.l #DOSE_MFILE,d0
    beq showFileEnd  ;ファイルハンドルが大きすぎる
    bra showFileDone  ;オープンされていない
  @@:
  move d3,d0  ;ファイルハンドルを表示する
  bsr Print$2
  DOS_PRINT (Colon,pc)

  lea (a3),a0  ;FCB内のファイル名を表示する
  lea (Buffer,pc),a1
  bsr copyFilename
  DOS_PRINT (Buffer,pc)
  DOS_PRINT_CRLF
showFileDone:
  moveq #0,d0
showFileEnd:
  POP d3/a3
  rts


copyFilename:
  moveq #$20,d1

  lea (FCB_FileName1,a0),a2
  moveq #8-1,d0  ;ファイル名1をコピー
  @@:
    move.b (a2)+,(a1)+
  dbra d0,@b
  lea (FCB_FileName2,a0),a2
  tst.b (a2)
  bne 1f
    moveq #8-1,d0  ;ファイル名末尾のスペースを削る
    @@:
      cmp.b -(a1),d1
    dbne d0,@b
    addq.l #1,a1
    bra 2f
  1:
    moveq #10-1,d0  ;ファイル名2をコピー
    @@:
      move.b (a2)+,(a1)+
    dbeq d0,@b
    bne @f
      subq.l #1,a1
    @@:
  2:

  lea (FCB_Ext,a0),a2
  tst.b (a2)
  beq 3f  ;拡張子なし(キャラクタデバイス)
    move.b #'.',(a1)+
    moveq #3-1,d0  ;拡張子をコピー
    @@:
      move.b (a2)+,(a1)+
    dbra d0,@b
  
    moveq #3-1,d0  ;拡張子名末尾のスペースを削る
    @@:
      cmp.b -(a1),d1
    dbne d0,@b
    addq.l #1,a1
    bne @f  ;拡張子あり
      subq.l #2,a1  ;拡張子がなければ'.'以降を削除する
    @@:
  3:

  clr.b (a1)
  rts


  DEFINE_PRINT$2 Print$2


.data

Colon: .dc.b ': ',0


.bss
.even

Buffer: .ds.b 256


.end ProgramStart
