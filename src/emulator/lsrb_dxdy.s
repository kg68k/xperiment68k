.title lsrb_dxdy - verify LSR.B Dx,Dy instruction

;This file is part of Xperiment68k
;Copyright (C) 2026 TcbnErik
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


.cpu 68000
.text

Start:
  moveq #0,d7  ;不一致数

  moveq #0,d6
  1:
    moveq #0,d5
    2:
      move.l d6,d3
      move.l d5,d4
      bsr TestLsrbD3D4
      add.l d0,d7
    addq.b #1,d5
    bne 2b
  addq.b #1,d6
  bne 1b

  move.l d7,d0
  beq @f
    moveq #1,d0
  @@:
  move d0,-(sp)
  DOS _EXIT2


TestLsrbD3D4:
  PUSH d3-d4/d6-d7/a3/a5
  move #0,ccr
  bsr EmulateLsrbD3D4
  move sr,d7  ;move ccr,d7
  movea.l d4,a5

  movem.l (sp),d3-d4
  move #0,ccr
  lsr.b d3,d4
  move sr,d6  ;move ccr,d6
  movea.l d4,a3

  move.l a5,d1
  move.l a3,d0
  eor.l d0,d1  ;シフト結果が異なるビットが1
  moveq #0,d0
  move.b d7,d0
  eor.b d6,d0  ;ccrが異なるビットが1
  or.l d1,d0
  beq 9f  ;演算結果が一致した
    lea (Buffer,pc),a0
    lea (strD3Equ,pc),a1
    STRCPY a1,a0,-1
    move.l (sp),d0  ;lsr.bのソース(d3)の値
    bsr ToHexString$8
    lea (strD4Equ,pc),a1
    STRCPY a1,a0,-1
    move.l (4,sp),d0  ;lsr.bのディスティネーション(d4)の値
    bsr ToHexString$8

    lea (strExpected,pc),a1
    STRCPY a1,a0,-1
    move d7,d0
    bsr ToHexString$2
    lea (strD4Equ,pc),a1
    STRCPY a1,a0,-1
    move.l a5,d0
    bsr ToHexString$8

    lea (strActual,pc),a1
    STRCPY a1,a0,-1
    move d6,d0
    bsr ToHexString$2
    lea (strD4Equ,pc),a1
    STRCPY a1,a0,-1
    move.l a3,d0
    bsr ToHexString$8

    WRITE_CRLF_NUL a0
    DOS_PRINT (Buffer,pc)
    moveq #1,d0
  9:
  POP d3-d4/d6-d7/a3/a5
  rts


EmulateLsrbD3D4:
  moveq #$3f,d0
  and.b d3,d0  ;シフト回数は64の余り
  bne @f  ;ここまでCCRのXフラグが変化する命令は使わないこと

    ;シフト回数0の場合
    ;X:変化せず N:結果が負数ならセット Z:結果が0ならセット V:常に0 C:常に0
    tst.b d4  ;CCRの変化について同じ結果を得られる
    rts

  ;シフト回数1～63の場合
  @@:
  move.b d0,-(sp)
  move (sp)+,d0
  move.b d4,d0
  add d0,d0
  lea (LsrTable,pc),a0
  adda d0,a0
  move.b (a0),d4
  move (a0),ccr
  rts


  DEFINE_TOHEXSTRING$2 ToHexString$2
  DEFINE_TOHEXSTRING$8 ToHexString$8


.data
.even

Buffer: .ds.b 128

strD3Equ: .dc.b 'd3=',0
strD4Equ: .dc.b ' d4=',0
strExpected: .dc.b ' expected: ccr=',0
strActual: .dc.b ' actual: ccr=',0

.even
LsrTable:
  ;シフト回数0は特別扱いしているので参照されない
  .dcb 256,0

  ;シフト回数1～8
  ShiftCount:=1
  .rept 8
    Value:=0
    .rept 256
      Result:=Value>>ShiftCount
      Carry:=(Value>>(ShiftCount-1)).and.1
      Negative:=(Result>>7).and.1
      Zero:=(Result.eq.0).and.1
      .dc.b Result,(Carry<<4)+(Negative<<3)+(Zero<<2)+(0<<1)+Carry

      Value:=Value+1
    .endm
    ShiftCount:=ShiftCount+1
  .endm

  ;シフト回数9～63
  .rept 64-1-8
    .dcb 256,0<<8+%00100
  .endm


.end
