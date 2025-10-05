.title todecstrbench - ToDecString benchmark

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

.include xputil.mac


U32_DECIMAL_DIGITS: .equ 10  ;.sizeof.('4294967295')


.cpu 68000
.text

ProgramStart:
  move.l #NoOps_end-NoOps,d0
  lea (strNoOps,pc),a0
  lea (NoOps,pc),a1
  bsr Measure

  move.l #ToDecString_type1_end-ToDecString_type1,d0
  lea (strType1,pc),a0
  lea (ToDecString_type1,pc),a1
  bsr Measure

  move.l #ToDecString_type2_end-ToDecString_type2,d0
  lea (strType2,pc),a0
  lea (ToDecString_type2,pc),a1
  bsr Measure

  move.l #ToDecString_type3_end-ToDecString_type3,d0
  lea (strType3,pc),a0
  lea (ToDecString_type3,pc),a1
  bsr Measure

  move.l #ToDecString_type4_end-ToDecString_type4,d0
  lea (strType4,pc),a0
  lea (ToDecString_type4,pc),a1
  bsr Measure

  DOS _EXIT


NoOps:
  rts
NoOps_end:


ToDecString_type1:
  PUSH d1-d2/a1
  lea (Table1,pc),a1
  moveq #'0',d2
  move.l (a1)+,d1
  1:
    cmp.l d1,d0
    bcc 3f
  move.l (a1)+,d1
  bne 1b
  bra 9f
  2:
    cmp.l d1,d0
    bcs 4f
      3:
        addq.b #1,d2
        sub.l d1,d0
      cmp.l d1,d0
      bcc 3b
    4:
    move.b d2,(a0)+
    moveq #'0',d2
  move.l (a1)+,d1
  bne 2b
9:
  add.b d0,d2
  move.b d2,(a0)+
  clr.b (a0)
  POP d1-d2/a1
  rts

.quad
Table1:
  ;     4294967295
  .dc.l 1000000000
  .dc.l 100000000
  .dc.l 10000000
  .dc.l 1000000
  .dc.l 100000
  .dc.l 10000
  .dc.l 1000
  .dc.l 100
  .dc.l 10
  .dc.l 0
ToDecString_type1_end:


ToDecString_type2:
  PUSH d1-d2/a1
  cmpi.l #10000,d0
  bcs 5f

  lea (Table2a,pc),a1
  moveq #'0',d2
  move.l (a1)+,d1
  1:
    cmp.l d1,d0
    bcc 3f
  move.l (a1)+,d1
  bne 1b
  bra 5f
  2:
    cmp.l d1,d0
    bcs 4f
      3:
        addq.b #1,d2
        sub.l d1,d0
      cmp.l d1,d0
      bcc 3b
    4:
    move.b d2,(a0)+
    moveq #'0',d2
  move.l (a1)+,d1
  bne 2b
5:
  lea (Table2b,pc),a1
  moveq #'0',d2
  move (a1)+,d1
  1:
    cmp d1,d0
    bcc 3f
  move (a1)+,d1
  bne 1b
  bra 9f
  2:
    cmp d1,d0
    bcs 4f
      3:
        addq.b #1,d2
        sub d1,d0
      cmp d1,d0
      bcc 3b
    4:
    move.b d2,(a0)+
    moveq #'0',d2
  move (a1)+,d1
  bne 2b
9:
  add.b d0,d2
  move.b d2,(a0)+
  clr.b (a0)
  POP d1-d2/a1
  rts

.quad
Table2a:
  ;     4294967295
  .dc.l 1000000000
  .dc.l 100000000
  .dc.l 10000000
  .dc.l 1000000
  .dc.l 100000
  .dc.l 10000
  .dc.l 0
Table2b:
  .dc 1000
  .dc 100
  .dc 10
  .dc 0
ToDecString_type2_end:


ToDecString_type3:
  PUSH d1-d2/a1

  cmp.l (n100000,pc),d0
  bcs 5f
    cmp.l (n10000000,pc),d0
    bcs 7f
      cmp.l (n100000000,pc),d0
      bcs 8f
        move.l #1000000000,d2
        cmp.l d2,d0
        bcs 9f
          ;10桁 4294967295～1000000000
          ;最上位桁の最大値が4なので、最大値9の桁とは別に扱う
          moveq #'0'-1,d1
          @@:
            addq.b #1,d1
            sub.l d2,d0
          bcc @b
          add.l d2,d0  ;引きすぎた分を戻す
          move.b d1,(a0)+  ;10億の位
        9:
        ;9桁 999999999～100000000
        lea (n100000000,pc),a1
        bra 100f
      8:
      ;8桁 99999999～10000000
      lea (n10000000,pc),a1
      bra 100f
    7:
    cmp.l (n1000000,pc),d0
    bcs 6f
      ;7桁 9999999～1000000
      lea (n1000000,pc),a1
      bra 100f
    6:
    ;6桁 999999～100000
    lea (n100000,pc),a1
    bra 100f

  100:
  move.l (a1)+,d2
  beq 55f
    lsl.l #2,d2  ;4n
    moveq #'0',d1
    .rept 2
      cmp.l d2,d0
      bcs @f
        sub.l d2,d0
        addq.b #4,d1
      @@:
    .endm
    lsr.l #1,d2  ;2n
    cmp.l d2,d0
    bcs @f
      sub.l d2,d0
      addq.b #2,d1
    @@:
    lsr.l #1,d2  ;n
    cmp.l d2,d0
    bcs @f
      sub.l d2,d0
      addq.b #1,d1
    @@:
    move.b d1,(a0)+
  bra 100b

  5:
  cmpi.l #1000,d0
  bcs 3f
    cmpi.l #10000,d0
    bcs 4f
      55:
      ;5桁 99999～10000
      divu #10000,d0
      addi.b #'0',d0
      move.b d0,(a0)+  ;10000の位
      clr d0
      swap d0
    4:
    ;4桁 9999～1000
    divu #100,d0
    moveq #0,d1
    move d0,d1
    divu #10,d1
    addi.l #'0'<<16+'0',d1
    move.b d1,(a0)+  ;1000の位
    swap d1
    move.b d1,(a0)+  ;100の位
    clr d0
    swap d0
    bra 22f
  3:
  cmpi #100,d0
  bcs 2f
    ;3桁 999～100
    divu #100,d0
    addi.b #'0',d0
    move.b d0,(a0)+  ;100の位
    clr d0
    swap d0
    bra 22f
  2:
  cmpi #10,d0
  bcs 1f
    22:
    ;2桁 99～10
    divu #10,d0
    addi.b #'0',d0
    move.b d0,(a0)+  ;10の位
    swap d0
  1:
  ;1桁 9～0
  addi.b #'0',d0
  move.b d0,(a0)+  ;1の位
  clr.b (a0)

  POP d1-d2/a1
  rts

.quad
n100000000: .dc.l 100000000
 n10000000: .dc.l 10000000
  n1000000: .dc.l 1000000
   n100000: .dc.l 100000
            .dc.l 0
ToDecString_type3_end:


ToDecString_type4:
  PUSH d1-d2
  move.l sp,d2
  @@:
    bsr Divu10
    addi.b #'0',d1
    move.b d1,-(sp)
  tst.l d0
  bne @b
  sub.l sp,d2  ;スタックに積んだ桁数(ワード数)*2
  neg d2
  jmp (@f,pc,d2.w)
  .rept U32_DECIMAL_DIGITS
    move.b (sp)+,(a0)+
  .endm
  @@:
  clr.b (a0)
  POP d1-d2
  rts

Divu10:
  moveq #10,d1
  divu d1,d0
  bvs @f  ;商が16ビットに収まらなかった
    swap d0
    move d0,d1  ;余り(d1.hwは0なのでクリア不要)
    clr d0
    swap d0  ;商
    rts
  @@:
  move.l d2,-(sp)  ;65536進数2桁÷1桁として計算する
  moveq #0,d2
  swap d0
  move d0,d2
  divu d1,d2
  move d2,d0
  swap d0
  move d0,d2
  divu d1,d2

  move d2,d0
  swap d2
  move d2,d1
  move.l (sp)+,d2
  rts
ToDecString_type4_end:


Measure:
  PUSH d3-d7/a2
  link a6,#-64
  lea (sp),a2
  move.l d0,d1
  DOS_PRINT (a0)

  move.l d1,d0
  lea (a2),a0
  FPACK __LTOS
  DOS_PRINT (sp)
  DOS_PRINT (strTime,pc)

  move.l #65536,d7
  IOCS _ONTIME
  PUSH d0-d1
  @@:
    move.l d7,d0
    lea (a2),a0
    jsr (a1)
  dbra d7,@b

  moveq #-1,d7
  move.l #54321,d6
  @@:
    move.l d7,d0
    lea (a2),a0
    jsr (a1)
    sub.l d6,d7
  bcc @b

  IOCS _ONTIME
  POP d2-d3

  cmp.l d3,d1
  beq @f
    addi.l #24*60*60*100,d0
  @@:
  sub.l d2,d0

  lea (a2),a0
  FPACK __LTOS
  DOS_PRINT (sp)
  DOS_PRINT_CRLF

  unlk a6
  POP d3-d7/a2
  rts


.data

strNoOps: .dc.b 'noops: size=',0
strType1: .dc.b 'type1: size=',0
strType2: .dc.b 'type2: size=',0
strType3: .dc.b 'type3: size=',0
strType4: .dc.b 'type4: size=',0
strTime:  .dc.b ', time=',0


.end ProgramStart
