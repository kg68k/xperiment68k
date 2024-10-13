.title fileopen - open file

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

.include dosdef.mac
.include console.mac
.include doscall.mac
.include filesys.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  addq.l #1,a2
  SKIP_SPACE a2
  bne @f
    DOS_PRINT (strUsage,pc)
    DOS _EXIT
  @@:
  lea (a2),a4  ;コマンド

  bsr SkipCommand
  lea (a2),a5  ;ファイル名(空文字列を許容する)

  DOS_PRINT (strFilename,pc)
  DOS_PRINT (a5)
  DOS_PRINT (strCrLf,pc)

  @@:
    move.b (a4)+,d0
    beq @f
    cmpi.b #' ',d0
    beq @f
      lea (a5),a0
      bsr DoCommand
    tst.l d0
    beq @b
  @@:
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


DoCommand:
  lea (CommandTable,pc),a1
  @@:
    movem (a1)+,d1-d3  ;コマンド文字、処理ルーチン、表示文字列
    cmp.b d0,d1
    beq @f
      tst (a1)
      beq 8f
    bra @b
  @@:
  subq.l #6,a1
  DOS_PRINT (a1,d3.l)

  moveq #1<<FILEATR_ARCHIVE,d0
  jsr (a1,d2.l)
  bsr PrintD0$4_4
  DOS_PRINT (strCrLf,pc)

  moveq #0,d0
  bra 9f
8:
  DOS_PRINT (strUnknownCommand,pc)
  moveq #-1,d0
9:
  rts


CommandTable:
  .dc 'c',Command_c-*,strDosCreate-*
  .dc 'f',Command_f-*,strDosCreateFast-*
  .dc 'n',Command_n-*,strDosNewfile-*
  .dc 'r',Command_r-*,strDosOpenRead-*
  .dc 'w',Command_w-*,strDosOpenWrite-*
  .dc 'a',Command_a-*,strDosOpenReadWrite-*


Command_c:
  move d0,-(sp)
  pea (a0)
  DOS _CREATE
  addq.l #6,sp
  rts

Command_f:
  move d0,-(sp)
  tas (sp)  ;ATR.wの最上位ビットを%1にする
  pea (a0)
  DOS _CREATE
  addq.l #6,sp
  rts

Command_n:
  move d0,-(sp)
  pea (a0)
  DOS _NEWFILE
  addq.l #6,sp
  rts

Command_r:
  move #OPENMODE_READ,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts

Command_w:
  move #OPENMODE_WRITE,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts

Command_a:
  move #OPENMODE_READ_WRITE,-(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  rts


  DEFINE_PRINTD0$4_4 PrintD0$4_4


.data

strUsage:
  .dc.b 'usage: fileopen <Command...> <filename>',CR,LF
  .dc.b 'Command:',CR,LF
  .dc.b '  c ... DOS _CREATE',CR,LF
  .dc.b '  f ... DOS _CREATE (fast mode)',CR,LF
  .dc.b '  n ... DOS _NEWFILE',CR,LF
  .dc.b '  r ... DOS _OPEN (read)',CR,LF
  .dc.b '  w ... DOS _OPEN (write)',CR,LF
  .dc.b '  a ... DOS _OPEN (read and write)',CR,LF
  .dc.b 0

strFilename: .dc.b 'filename: ',0

strDosCreate:        .dc.b 'DOS _CREATE: ',0
strDosCreateFast:    .dc.b 'DOS _CREATE (fast mode): ',0
strDosNewfile:       .dc.b 'DOS _NEWFILE: ',0
strDosOpenRead:      .dc.b 'DOS _OPEN (read): ',0
strDosOpenWrite:     .dc.b 'DOS _OPEN (write): ',0
strDosOpenReadWrite: .dc.b 'DOS _OPEN (read and write): ',0

strUnknownCommand: .dc.b '対応していないコマンドです。',CR,LF,0

strCrLf: .dc.b CR,LF,0


.end ProgramStart
