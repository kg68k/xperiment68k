.title fileop - file operation test tool

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

.include fefunc.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  beq PrintUsage

  lea (FilenameBuffer,pc),a0  ;最初にファイル名を指定する
  bsr CopyFilename

  SKIP_SPACE a2  ;その後がコマンド列
  beq PrintUsage
  lea (a2),a4

  DOS_PRINT (strFilename,pc)
  DOS_PRINT (FilenameBuffer,pc)
  DOS_PRINT_CRLF

  moveq #-1,d7  ;ファイルハンドル(-1ならまだオープンしていない)
  lea (FilenameBuffer,pc),a5

  ;コマンドを処理
  @@:
    SKIP_SPACE a4
    beq @f
      move.b (a4)+,d0
      bsr DoCommand
      tst.l d0
      bpl @b  ;成功したら次のコマンドを実行する
  @@:

  DOS _EXIT


PrintUsage:
 DOS_PRINT (strUsage,pc)
 DOS _EXIT


CopyFilename:
  @@:
    move.b (a2),d0
    beq @f
    cmpi.b #' ',d0
    beq @f
      move.b (a2)+,(a0)+
      bra @b
  @@:
  clr.b (a0)
  rts


;コマンドを実行する
;in d7.l ... ファイルハンドル(-1ならまだオープンしていない)
;   a4.l ... コマンド列
;   a5.l ... ファイル名
;out d0.l ... エラーコード
;    d7.l ... (ファイルをオープンした場合)新しいファイルハンドル
;    a4.l ... (コマンド列から引数を取得した場合)次のコマンド列
DoCommand:
  lea (CommandTable,pc),a1
  bsr FindCommand
  bpl @f
    DOS_PRINT (strUnknownCommand,pc)
    bra 9f
  @@:
  beq @f  ;ファイルが未オープンでも使えるコマンド
    tst.l d7
    bpl @f  ;ファイルはオープン済み
      DOS_PRINT (a2)
      DOS_PRINT (strFileNotOpen,pc)
      bra 9f
  @@:
  DOS_PRINT (a2)
  jsr (a1)
  rts
9:
  moveq #-1,d0
  rts


CMD: .macro ch,need_handle,func,str
  @head:
  .dc.b need_handle  ;1ならファイルがオープン済みでないと使えないコマンド
  .dc.b ch
  .dc func-@head
  .dc str-@head
.endm

CMD_END: .macro
  .dc 0
.endm


FindCommand:
  @@:
    movem (a1)+,d1-d3  ;属性+コマンド文字、処理ルーチン、表示文字列
    cmp.b d0,d1
    beq @f
      tst (a1)
      bne @b
        moveq #-1,d0
        rts
  @@:
  lea (-6,a1,d3.l),a2  ;表示文字列
  lea (-6,a1,d2.l),a1  ;処理ルーチン

  moveq #0,d0
  move d1,-(sp)
  move.b (sp)+,d0  ;1ならファイルがオープン済みでないと使えないコマンド
  rts


CommandTable:
  ;新規ファイル作成
  CMD 'c',0,Command_c,strDosCreate
  CMD 'f',0,Command_f,strDosCreateFast
  CMD 'n',0,Command_n,strDosNewfile
  CMD 'a',0,Command_a,strSetAttribute

  ;既存ファイルのオープン
  CMD 'r',0,Command_r,strDosOpenRead
  CMD 'w',0,Command_w,strDosOpenWrite
  CMD 'b',0,Command_b,strDosOpenReadWrite

  ;1バイト入出力
  CMD 'g',1,Command_g,strDosFgetc
  CMD 'p',1,Command_p,strDosFputc

  ;ファイルのシーク
  CMD 'h',1,Command_h,strDosSeekHead
  CMD 't',1,Command_t,strDosSeekTail

  CMD_END


Command_c:
  move (FileAttribute,pc),-(sp)
  pea (a5)
  DOS _CREATE
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_f:
  move (FileAttribute,pc),-(sp)
  tas (sp)  ;ATR.wの最上位ビットを%1にする
  pea (a5)
  DOS _CREATE
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_n:
  move (FileAttribute,pc),-(sp)
  pea (a5)
  DOS _NEWFILE
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_a:
  lea (a4),a0  ;ファイル属性を引数として受け取る
  SKIP_SPACE a0
  beq NoNumberError
  FPACK __STOH
  bcs NumberError
  cmpi.l #$ff,d0
  bhi NumberError
  lea (a0),a4

  move d0,(FileAttribute)
  bsr PrintFileAttribute
  DOS_PRINT_CRLF
  rts

Command_r:
  move #OPENMODE_READ,-(sp)
  pea (a5)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_w:
  move #OPENMODE_WRITE,-(sp)
  pea (a5)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_b:
  move #OPENMODE_READ_WRITE,-(sp)
  pea (a5)
  DOS _OPEN
  addq.l #6,sp
  move.l d0,d7
  bra PrintResult

Command_g:
  move d7,-(sp)
  DOS _FGETC
  addq.l #2,sp
  bra PrintResult

Command_p:
  lea (a4),a0  ;出力する1バイト値を引数として受け取る
  SKIP_SPACE a0
  beq NoNumberError
  FPACK __STOH
  bcs NumberError
  cmpi.l #$ff,d0
  bhi NumberError
  lea (a0),a4

  move d7,-(sp)
  move d0,-(sp)
  DOS _FPUTC
  addq.l #4,sp
  bra PrintResult

Command_h:
  move #SEEKMODE_SET,-(sp)
  clr.l -(sp)
  move d7,-(sp)
  DOS _SEEK
  addq.l #8,sp
  bra PrintResult

Command_t:
  move #SEEKMODE_END,-(sp)
  clr.l -(sp)
  move d7,-(sp)
  DOS _SEEK
  addq.l #8,sp
  bra PrintResult


PrintResult:
  move.l d0,-(sp)
  bsr PrintD0$4_4
  DOS_PRINT_CRLF
  move.l (sp)+,d0
  rts

NumberError:
  DOS_PRINT (strNumberError,pc)
  moveq #-1,d0
  rts

NoNumberError:
  DOS_PRINT (strNoNumberError,pc)
  moveq #-1,d0
  rts


PrintFileAttribute:
  link a6,#-12
  lea (sp),a0
  lea (strFileAttributes,pc),a1
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
.even

FileAttribute: .dc 1<<FILEATR_ARCHIVE

strUsage:
  .dc.b 'usage: fileop <filename> <Command...>',CR,LF
  .dc.b 'Command:',CR,LF
  .dc.b '  c ... DOS _CREATE',CR,LF
  .dc.b '  f ... DOS _CREATE (fast mode)',CR,LF
  .dc.b '  n ... DOS _NEWFILE',CR,LF
  .dc.b '  a <hex> ... set file attribute on creation',CR,LF
  .dc.b '  r ... DOS _OPEN (read)',CR,LF
  .dc.b '  w ... DOS _OPEN (write)',CR,LF
  .dc.b '  b ... DOS _OPEN (read and write)',CR,LF
  .dc.b '  g ... DOS _FGETC',CR,LF
  .dc.b '  p <hex> ... DOS _FPUTC',CR,LF
  .dc.b '  h ... DOS _SEEK (head)',CR,LF
  .dc.b '  t ... DOS _SEEK (tail)',CR,LF
  .dc.b 0

strFilename: .dc.b 'filename: ',0
strFileAttributes: .dc.b 'XLADVSHR'

strDosCreate:        .dc.b 'DOS _CREATE: ',0
strDosCreateFast:    .dc.b 'DOS _CREATE (fast mode): ',0
strDosNewfile:       .dc.b 'DOS _NEWFILE: ',0
strSetAttribute:     .dc.b 'file attribute: ',0

strDosOpenRead:      .dc.b 'DOS _OPEN (read): ',0
strDosOpenWrite:     .dc.b 'DOS _OPEN (write): ',0
strDosOpenReadWrite: .dc.b 'DOS _OPEN (read and write): ',0

strDosFgetc:    .dc.b 'DOS _FGETC: ',0
strDosFputc:    .dc.b 'DOS _FPUTC: ',0
strDosSeekHead: .dc.b 'DOS _SEEK (head): ',0
strDosSeekTail: .dc.b 'DOS _SEEK (tail): ',0

strUnknownCommand: .dc.b '対応していないコマンドです。',CR,LF,0
strFileNotOpen:    .dc.b 'ファイルがまだオープンされていません。',CR,LF,0
strNumberError:    .dc.b '数値の指定が正しくありません。',CR,LF,0
strNoNumberError:  .dc.b '出力する値が指定されていません。',CR,LF,0


.bss

FilenameBuffer: .ds.b 256


.end ProgramStart
