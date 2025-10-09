.title divu32 - Divide unsigned 32bit (d0/d1 -> d0...d1)

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

.include xputil.mac


.offset 0
~divident:  .ds.l 1
~divisor:   .ds.l 1
~quotient:  .ds.l 1
~remainder: .ds.l 1
sizeof_TestCase:
.text


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  beq @f
    bsr ExecuteCommandline
    DOS _EXIT
  @@:
  bsr Test
  move d0,-(sp)
  DOS _EXIT2


PrintUsage:
  PRINT_1LINE_USAGE 'usage: divu32 [<divident> <divisor>]'
  DOS _EXIT


ExecuteCommandline:
  link a6,#-64
  bsr ParseInt  ;被除数
  move.l d0,d1
  SKIP_SPACE a0
  beq PrintUsage
  bsr ParseInt  ;除数
  exg d0,d1
  bsr Divu32

  lea (sp),a0
  lea (strQuot,pc), a1
  STRCPY a1,a0,-1
  bsr ToHexString$4_4
  lea (strRem,pc),a1
  STRCPY a1,a0,-1
  move.l d1,d0
  bsr ToHexString$4_4
  lea (strCrLf,pc),a1
  STRCPY a1,a0,-1

  DOS_PRINT (sp)
  unlk a6
  rts


Test:
  moveq #0,d5
  moveq #0,d6
  move.l #(TestCaseEnd-TestCase)/sizeof_TestCase,d7
  lea (TestCase,pc),a5
  1:
    move.l (~divident,a5),d0
    move.l (~divisor,a5),d1
    bsr Divu32
    cmp.l (~quotient,a5),d0
    bne @f
      cmp.l (~remainder,a5),d1
      beq 2f
      @@:
        bsr PrintTestCaseResult
        addq.l #1,d5
    2:
    lea (sizeof_TestCase,a5),a5
    addq.l #1,d6
  cmp.l d7,d6
  bcs 1b

  move.l d7,d0
  sub.l d5,d0
  move.l d5,d1
  bsr PrintTestResult

  moveq #EXIT_SUCCESS,d0
  tst.l d5
  beq @f
    moveq #EXIT_FAILURE,d0
  @@:
  rts


PrintTestResult:
  link a6,#-128
  lea (sp),a0
  lea (strSuccess,pc),a1
  STRCPY a1,a0,-1
  bsr ToDecString

  lea (strFailure,pc),a1
  STRCPY a1,a0,-1
  move.l d1,d0
  bsr ToDecString

  lea (strCrLf,pc),a1
  STRCPY a1,a0
  DOS_PRINT (sp)
  unlk a6
  rts


PrintTestCaseResult:
  PUSH d4-d5/d7
  link a6,#-128
  move.l d0,d4
  move.l d1,d5
  moveq #'.',d7

  lea (sp),a0
  move.b #'[',(a0)+
  move.l d6,d0
  bsr ToDecString
  move.b #']',(a0)+
  move.b #' ',(a0)+

  move.l (~divident,a5),d0
  bsr ToHexString$4_4
  move.b #'/',(a0)+
  move.l (~divisor,a5),d0
  bsr ToHexString$4_4

  lea (strExpected,pc),a1
  STRCPY a1,a0,-1
  move.l (~quotient,a5),d0
  bsr ToHexString$4_4
  move.b d7,(a0)+
  move.b d7,(a0)+
  move.b d7,(a0)+
  move.l (~remainder,a5),d0
  bsr ToHexString$4_4

  lea (strActual,pc),a1
  STRCPY a1,a0,-1
  move.l d4,d0
  bsr ToHexString$4_4
  move.b d7,(a0)+
  move.b d7,(a0)+
  move.b d7,(a0)+
  move.l d5,d0
  bsr ToHexString$4_4

  lea (strCrLf,pc),a1
  STRCPY a1,a0,-1

  DOS_PRINT (sp)
  unlk a6
  POP d4-d5/d7
  rts


  DEFINE_DIVU32 Divu32
  DEFINE_PARSEINT ParseInt
  DEFINE_TODECSTRING ToDecString
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4
  DEFINE_TOHEXSTRING2 ToHexString2


.data

.quad
TestCase:
  .dc.l $dead_beef,0,$dead_beef,0
  .dc.l $ffff,13,5041,2
  .dc.l $789a_bcde,$f0e1,$802c,$d632
  .dc.l $ffff_ffff,$1_0000,$ffff,$ffff

  .dc.l 0,$ffff_ffff,0,0
  .dc.l 1,$0001_0000,0,1
TestCaseEnd:

strExpected: .dc.b ' -> expected ',0
strActual: .dc.b ', actual ',0

strSuccess: .dc.b 'success: ',0
strFailure: .dc.b ', failure: ',0

strQuot: .dc.b 'quotient = ',0
strRem:  .dc.b ', remainder = ',0

strCrLf: .dc.b CR,LF,0


.end ProgramStart
