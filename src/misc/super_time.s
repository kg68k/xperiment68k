.title super_time - benchmark of IOCS _B_SUPER, DOS _SUPER and DOS _SUPER_JSR

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
.include iocscall.mac

.include xputil.mac


LOOP_COUNT: .equ 100000

DUMMY_INSTRUCTION: .macro
  nop
.endm


.cpu 68000
.text

ProgramStart:
  DOS_PRINT (strLoopCount,pc)
  move.l #LOOP_COUNT,d0
  bsr PrintD0Dec
  DOS_PRINT_CRLF

  bsr CountTime_Empty
  lea (strEmptyJob,pc),a0
  bsr PrintTime

 bsr CountTime_IocsBSuper
  lea (strIocsBSuper,pc),a0
  bsr PrintTime

  bsr CountTimeSuper_IocsBSuper
  lea (strIocsBSuper2,pc),a0
  bsr PrintTime

  bsr CountTime_DosSuper
  lea (strDosSuper,pc),a0
  bsr PrintTime

  bsr CountTimeSuper_DosSuper
  lea (strDosSuper2,pc),a0
  bsr PrintTime

  bsr CountTime_DosSuperJsr
  lea (strDosSuperJsr,pc),a0
  bsr PrintTime

  bsr CountTimeSuper_DosSuperJsr
  lea (strDosSuperJsr2,pc),a0
  bsr PrintTime

  DOS _EXIT


COUNT_TIME: .macro super,job
  PUSH d5-d7
  .if super
    clr.l -(sp)
    DOS _SUPER
    move.l d0,(sp)
  .endif

  move.l #LOOP_COUNT-1,d6
  move.l d6,d5
  swap d5  ;ループカウンタ上位ワード

  IOCS _ONTIME
  move.l d0,d7  ;開始時間
  @loop:
    job super
  dbra d6,@loop
  dbra d5,@loop
  IOCS _ONTIME
  move.l d0,d6  ;終了時間

  .if super
    DOS _SUPER
    addq.l #4,sp
  .endif

  move.l d6,d0
  sub.l d7,d0  ;経過時間
  POP d5-d7
  rts
.endm


CountTime_Empty:
  COUNT_TIME 0,nop
  rts


IOCS_B_SUPER: .macro super
  suba.l a1,a1
  IOCS _B_SUPER
  move.l d0,d1

  DUMMY_INSTRUCTION

  .if super
    tst.l d1
    bmi @skip
      movea.l d1,a1
      IOCS _B_SUPER
    @skip:
  .else
    movea.l d1,a1
    IOCS _B_SUPER
  .endif
.endm

CountTime_IocsBSuper:
  COUNT_TIME 0,IOCS_B_SUPER
  rts

CountTimeSuper_IocsBSuper:
  COUNT_TIME 1,IOCS_B_SUPER
  rts


DOS_SUPER: .macro super
  clr.l -(sp)
  DOS _SUPER
  move.l d0,(sp)

  DUMMY_INSTRUCTION

  .if super
    tst.b (sp)
    bmi @skip
      DOS _SUPER
    @skip:
  .else
    DOS _SUPER
  .endif
  addq.l #4,sp
.endm

CountTime_DosSuper:
  COUNT_TIME 0,DOS_SUPER
  rts

CountTimeSuper_DosSuper:
  COUNT_TIME 1,DOS_SUPER
  rts


DummyInstruction:
  DUMMY_INSTRUCTION
  rts

DOS_SUPER_JSR: .macro super
  pea (DummyInstruction,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
.endm

CountTime_DosSuperJsr:
  COUNT_TIME 0,DOS_SUPER_JSR
  rts

CountTimeSuper_DosSuperJsr:
  COUNT_TIME 1,DOS_SUPER_JSR
  rts


PrintTime:
  move.l d0,-(sp)
  DOS_PRINT (a0)
  move.l (sp)+,d0
  bsr PrintD0Dec
  DOS_PRINT_CRLF
  rts


PrintD0Dec:
  link a6,#-16
  lea (sp),a0
  FPACK __LTOS
  DOS_PRINT (sp)
  unlk a6
  rts


.data

strLoopCount: .dc.b 'ループ回数=',0

strEmptyJob:     .dc.b '空処理: ',0 
strIocsBSuper:   .dc.b 'IOCS _B_SUPER: ',0
strIocsBSuper2:  .dc.b 'IOCS _B_SUPER (in supervisor mode): ',0
strDosSuper:     .dc.b 'DOS _SUPER: ',0
strDosSuper2:    .dc.b 'DOS _SUPER (in supervisor mode): ',0
strDosSuperJsr:  .dc.b 'DOS _SUPER_JSR: ',0
strDosSuperJsr2: .dc.b 'DOS _SUPER_JSR (in supervisor mode): ',0


.end ProgramStart
