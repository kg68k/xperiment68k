.title chxdummy - fill sram before installing ch30*.sys

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

.include sram.mac
.include iomap.mac
.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


SRAM_MAX_PROGRAM_SIZE: .equ SRAM_16KB_END-SRAM_PROG

MARGIN: .equ $20  ;for chxinst.x 0.2.8

.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq NoFilename

  bsr GetFileSize
  move.l d0,d7
  bmi FileError

  moveq #.not.%11,d0
  and.l d7,d0
  addq.l #4,d0
  .ifdef MARGIN
    addi.l #MARGIN,d0
  .endif
  move.l #SRAM_MAX_PROGRAM_SIZE,d6
  sub.l d0,d6  ;SRAMのプログラム領域の余りバイト数
  moveq #sizeof_SramDummyProgram,d0
  cmp.l d0,d6
  blt FileSizeError  ;ch30*.sysが大きすぎる

  clr.l -(sp)
  DOS _SUPER
  addq.l #4,sp

  lea (SRAM_PROG),a5
  tst.b (SRAM_USEMODE)
  bne SramAlreadyUsed

  bsr Sram_EnableWrite

  ;SRAM起動コードとして有効なダミープログラムを書き込む
  lea (SramDummyProgram,pc),a0
  lea (a5),a1
  moveq #sizeof_SramDummyProgram/4-1,d1
  @@:
    move.l (a0)+,(a1)+
  dbra d1,@b

  ;残りを$ffff_ffffで埋める
  move.l d6,d1
  subq #sizeof_SramDummyProgram,d1
  lsr.l #2,d1
  moveq #$ff,d0
  bra 1f
  @@:
    move.l d0,(a1)+
  1:
  dbra d1,@b

  ;空き領域を$0000_0000で埋める
  move.l #SRAM_16KB_END,d1
  sub.l a1,d1
  lsr.l #2,d1
  moveq #$00,d0
  bra 1f
  @@:
    move.l d0,(a1)+
  1:
  dbra d1,@b

  move.l a5,(SRAM_SRAMBOOT)
  move #$b000,(SRAM_BOOT)   ;SRAM起動
  move.b #2,(SRAM_USEMODE)  ;プログラムで使用
  bsr Sram_DisableWrite

  pea (DoneMsg,pc)
  DOS _PRINT
  addq.l #4,sp

  DOS _EXIT


NoFilename:
  pea (NoFilenameMsg,pc)
  bra @f
FileError:
  pea (FileErrorMsg,pc)
  bra @f
FileSizeError:
  pea (FileSizeErrorMsg,pc)
  bra @f
SramAlreadyUsed:
  pea (SramUsedMsg,pc)
  bra @f
@@:
  DOS _PRINT
  DOS _EXIT
.data
NoFilenameMsg: .dc.b 'ファイル名が指定されていません。',CR,LF,0
FileErrorMsg: .dc.b 'ファイルエラー。',CR,LF,0
FileSizeErrorMsg: .dc.b 'ファイルサイズが大きすぎます。',CR,LF,0
SramUsedMsg: .dc.b 'SRAMは使用中です。',CR,LF,0
DoneMsg: .dc.b 'SRAMにダミープログラムを書き込みました。',CR,LF,0
.text


.quad
SramDummyProgram:
  bra.s @f
  nop
@@:
  rts
.quad
SramDummyProgram_End:
sizeof_SramDummyProgram: equ SramDummyProgram_End-SramDummyProgram


Sram_EnableWrite:
  move.b #$31,(SYS_P7)
  rts

Sram_DisableWrite:
  move.b #$00,(SYS_P7)
  rts


GetFileSize:
  clr -(sp)
  pea (a0)
  DOS _OPEN
  addq.l #6,sp
  tst.l d0
  bmi 9f
    move #2,-(sp)
    clr.l -(sp)
    move d0,-(sp)
    DOS _SEEK
    move.l d0,d1
    DOS _CLOSE
    addq.l #8,sp
    move.l d1,d0
9:
  rts


.end ProgramStart
