.title fileopengp - open file and read or write a byte

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

  lea (a2),a4  ;オープンコマンド
  bsr SkipCommand

  lea (FilenameBuffer,pc),a0
  bsr CopyFilename

  SKIP_SPACE a2
  lea (a2),a5  ;入出力コマンド

  DOS_PRINT (strFilename,pc)
  DOS_PRINT (FilenameBuffer,pc)
  DOS_PRINT (strCrLf,pc)

  ;オープンコマンドを処理
  @@:
    move.b (a4)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @f
      lea (FilenameBuffer,pc),a0
      bsr DoOpenCommand
    move.l d0,d7  ;ファイルハンドル
    bpl @b
  @@:

  ;入出力コマンドを処理
  lea (a5),a0
  @@:
    move.b (a0)+,d0
    beq @f
      move.l d7,d1
      bsr DoInputOutputCommand
      tst.l d0
      bmi @f
        SKIP_SPACE a0
        bne @b
  @@:

  DOS _EXIT


PrintUsage:
 DOS_PRINT (strUsage,pc)
 DOS _EXIT


SkipCommand:
  @@:
    move.b (a2)+,d0  ;コマンドを飛ばす
    beq 9f
  cmpi.b #' ',d0
  bne @b
  @@:
    cmp.b (a2)+,d0  ;空白を飛ばす
  beq @b
9:
  subq.l #1,a2
  rts


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


FindCommand:
  @@:
    movem (a1)+,d1-d3  ;コマンド文字、処理ルーチン、表示文字列
    cmp.b d0,d1
    beq @f
      tst (a1)
      bne @b
        DOS_PRINT (strUnknownCommand,pc)
        moveq #-1,d0
        rts
  @@:
  lea (-6,a1,d3.l),a2  ;表示文字列
  lea (-6,a1,d2.l),a1  ;処理ルーチン
  moveq #0,d0
  rts


DoOpenCommand:
  lea (OpenCommandTable,pc),a1
  bsr FindCommand
  bmi @f
    DOS_PRINT (a2)
    moveq #1<<FILEATR_ARCHIVE,d0
    jsr (a1)
    move.l d0,-(sp)
    bsr PrintD0$4_4
    DOS_PRINT (strCrLf,pc)
    move.l (sp)+,d0
  @@:
  rts

OpenCommandTable:
  .dc 'c',OpenCommand_c-*,strDosCreate-*
  .dc 'f',OpenCommand_f-*,strDosCreateFast-*
  .dc 'n',OpenCommand_n-*,strDosNewfile-*
  .dc 'r',OpenCommand_r-*,strDosOpenRead-*
  .dc 'w',OpenCommand_w-*,strDosOpenWrite-*
  .dc 'a',OpenCommand_a-*,strDosOpenReadWrite-*
  .dc 0


OpenCommand_c:
  move d0,-(sp)
  pea (a0)
  DOS _CREATE
  addq.l #6,sp
  rts

OpenCommand_f:
  move d0,-(sp)
  tas (sp)  ;ATR.wの最上位ビットを%1にする
  pea (a0)
  DOS _CREATE
  addq.l #6,sp
  rts

OpenCommand_n:
  move d0,-(sp)
  pea (a0)
  DOS _NEWFILE
  addq.l #6,sp
  rts

OpenCommand_r:
  move #OPENMODE_READ,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts

OpenCommand_w:
  move #OPENMODE_WRITE,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts

OpenCommand_a:
  move #OPENMODE_READ_WRITE,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts


DoInputOutputCommand:
  move.l d1,-(sp)
  lea (IoCommandTable,pc),a1
  bsr FindCommand
  bmi @f
    DOS_PRINT (a2)
    move.l (sp),d0  ;ファイルハンドル
    jsr (a1)
    move.l d0,-(sp)
    DOS_PRINT (strCrLf,pc)
    move.l (sp)+,d0
  @@:
  addq.l #4,sp
  rts

IoCommandTable:
  .dc 'g',IoCommand_g-*,strDosFgetc-*
  .dc 'p',IoCommand_p-*,strDosFputc-*
  .dc 'h',IoCommand_h-*,strDosSeekHead-*
  .dc 't',IoCommand_t-*,strDosSeekTail-*
  .dc 0

IoCommand_g:
  move d0,-(sp)
  DOS _FGETC
  addq.l #2,sp
  bra PrintResult

IoCommand_p:
  move.l d0,d1  ;ファイルハンドル

  SKIP_SPACE a0
  beq NoNumberError
  FPACK __STOH
  bcs NumberError
  cmpi.l #$ff,d0
  bhi NumberError
  SKIP_SPACE a0

  move d1,-(sp)
  move d0,-(sp)
  DOS _FPUTC
  addq.l #4,sp
  bra PrintResult

IoCommand_h:
  move #SEEKMODE_SET,-(sp)
  clr.l -(sp)
  move d0,-(sp)
  DOS _SEEK
  addq.l #8,sp
  bra PrintResult

IoCommand_t:
  move #SEEKMODE_END,-(sp)
  clr.l -(sp)
  move d0,-(sp)
  DOS _SEEK
  addq.l #8,sp
  bra PrintResult


PrintResult:
  move.l d0,-(sp)
  bsr PrintD0$4_4
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


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strUsage:
  .dc.b 'usage: fileopengp <OpenCommand...> <filename> [InputOutputCommand...]',CR,LF
  .dc.b 'OpenCommand:',CR,LF
  .dc.b '  c ... DOS _CREATE',CR,LF
  .dc.b '  f ... DOS _CREATE (fast mode)',CR,LF
  .dc.b '  n ... DOS _NEWFILE',CR,LF
  .dc.b '  r ... DOS _OPEN (read)',CR,LF
  .dc.b '  w ... DOS _OPEN (write)',CR,LF
  .dc.b '  a ... DOS _OPEN (read and write)',CR,LF
  .dc.b 'InputOutputCommand:',CR,LF
  .dc.b '  g ... DOS _FGETC',CR,LF
  .dc.b '  p <hex> ... DOS _FPUTC',CR,LF
  .dc.b '  h ... DOS _SEEK (head)',CR,LF
  .dc.b '  t ... DOS _SEEK (tail)',CR,LF
  .dc.b 0

strFilename: .dc.b 'filename: ',0

strDosCreate:        .dc.b 'DOS _CREATE: ',0
strDosCreateFast:    .dc.b 'DOS _CREATE (fast mode): ',0
strDosNewfile:       .dc.b 'DOS _NEWFILE: ',0
strDosOpenRead:      .dc.b 'DOS _OPEN (read): ',0
strDosOpenWrite:     .dc.b 'DOS _OPEN (write): ',0
strDosOpenReadWrite: .dc.b 'DOS _OPEN (read and write): ',0

strDosFgetc:    .dc.b 'DOS _FGETC: ',0
strDosFputc:    .dc.b 'DOS _FPUTC: ',0
strDosSeekHead: .dc.b 'DOS _SEEK (head): ',0
strDosSeekTail: .dc.b 'DOS _SEEK (tail): ',0

strUnknownCommand: .dc.b '対応していないコマンドです。',CR,LF,0
strNumberError:    .dc.b '数値の指定が正しくありません。',CR,LF,0
strNoNumberError:  .dc.b '出力する値が指定されていません。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.bss

FilenameBuffer: .ds.b 256


.end ProgramStart
