.title exception - take an exception

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
.include vector.mac
.include console.mac
.include doscall.mac
.include iocswork.mac

.include xputil.mac


EXC_STRING_SIZE: .equ 12
.offset 0
EXC_STRING: .ds.b EXC_STRING_SIZE
EXC_REAL:   .ds.l 1
EXC_PSEUDO: .ds.l 1
sizeof_EXC:
.text

EXC: .macro str,real,pseudo
  .dc.b str,0
  .ds.b EXC_STRING_SIZE-(.sizeof.(str)+1)
  .dc.l real,pseudo
.endm


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  bsr AnalyzeArgument
  move.l d0,d7
  bmi PrintUsage

  tst d7
  movea.l (EXC_REAL,a0),a5
  beq 1f
    movea.l (EXC_PSEUDO,a0),a5

    lea (MPUTYPE),a1
    IOCS _B_BPEEK
    tst.b d0
    beq @f
      DOS_PRINT (strMpuIsnt68000,pc)
      DOS _EXIT
    @@:
    clr.l -(sp)  
    DOS _SUPER
    addq.l #4,sp
  1:

  moveq #0,d0
  moveq #0,d1
  movea.l d0,a0
  movea.l d0,a1
  jsr (a5)  ;例外ごとの処理を実行する

  DOS _EXIT


pseudoIllegal:
  movea.l (ILLEGAL_VEC*4),a5
  pea (raiseIllegal,pc)
  move sr,-(sp)
  jmp (a5)

raiseIllegal:
  illegal
  rts


pseudoAline:
  movea.l (ALINE_VEC*4),a5
  pea (raiseAline,pc)
  move sr,-(sp)
  jmp (a5)

raiseAline:
  .dc $a352  ;TSExit
  rts


pseudoTrap0:
  movea.l (TRAP0_VEC*4),a5
  pea (raiseTrap0,pc)
  move sr,-(sp)
  jmp (a5)

raiseTrap0:
  trap #0
  rts


pseudoSpurious:
  movea.l (SPURIOUS_VEC*4),a5
  pea (dummySpurious,pc)
  move sr,-(sp)
  jmp (a5)
dummySpurious:
  nop
  rts

raiseSpurious:
  DOS_PRINT (strSpuriousNotPseudoMode,pc)
  DOS _EXIT


AnalyzeArgument:
  PUSH d6-d7/a1-a3
  moveq #0,d7
  1:
    SKIP_SPACE a0
    move.b (a0),d0
    beq 8f
    cmpi.b #'-',d0
    bne 2f
      cmpi.b #'p',(1,a0)
      bne 8f
        moveq #1,d7  ;-p
        @@:
          cmpi.b #$20,(a0)+
        bhi @b
        subq.l #1,a0
        bra 1b
  2:
  lea (a0),a1
  @@:
    cmpi.b #$20,(a1)+
  bhi @b
  subq.l #1,a1
  suba.l a0,a1
  move.l a1,d6  ;例外名の長さ

  lea (ExceptionTable,pc),a3
  3:
    lea (EXC_STRING,a3),a2
    STRLEN a2,d0
    cmp.l d6,d0
    bne 5f
      lea (a0),a1
      @@:
        cmp.b (a1)+,(a2)+
      dbne d0,@b
      bne 5f
        lea (a3),a0  ;例外名が一致した
        bra 9f
    5:
    lea (sizeof_EXC,a3),a3
  tst.b (a3)
  bne 3b
8:
  moveq #-1,d7
  suba.l a0,a0
9:
  move.l d7,d0
  POP d6-d7/a1-a3
  rts


PrintUsage:
  lea (strUsage,pc),a0
  lea (ExceptionTable,pc),a3
  @@:
    DOS_PRINT (a0)  ;初回は使用法の本文、2回目以降は', 'を表示する
    lea (strComma,pc),a0

    DOS_PRINT (EXC_STRING,a3)
    lea (sizeof_EXC,a3),a3
  tst.b (EXC_STRING,a3)
  bne @b
  DOS_PRINT_CRLF
  DOS _EXIT


.data

.quad
ExceptionTable:
  EXC 'illegal', raiseIllegal, pseudoIllegal
  EXC 'aline',   raiseAline,   pseudoAline
  EXC 'trap#0',  raiseTrap0,   pseudoTrap0
  EXC 'spurious',raiseSpurious,pseudoSpurious
  .dc.b 0

strUsage:
  .dc.b 'usage: exception [-p] <Exception>',CR,LF
  .dc.b 'option: -p ... pseudo exception (mpu 68000 only)',CR,LF
  .dc.b CR,LF
  .dc.b 'Exception: '  ;ここに例外名を動的に表示する
  .dc.b 0

strComma: .dc.b ', ',0

strMpuIsnt68000:
  .dc.b 'MPU が 68000 ではありません。',CR,LF,0
strSpuriousNotPseudoMode:
  .dc.b 'spurious は -p の指定が必要です。',CR,LF,0


.end ProgramStart
