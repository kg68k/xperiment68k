.title divu10bench - Divu10 benchmark

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


;この値に特に根拠はない。
;divu命令1回で処理できる数の割合がどの程度かで傾向が変わる。
LOOP_COUNT: .equ 2000000


.cpu 68000
.text

ProgramStart:
  moveq #NoOps_end-NoOps,d0
  lea (strNoOps,pc),a0
  lea (NoOps,pc),a1
  bsr Measure

  moveq #Divu10_type1_end-Divu10_type1,d0
  lea (strType1,pc),a0
  lea (Divu10_type1,pc),a1
  bsr Measure

  moveq #Divu10_type2_end-Divu10_type2,d0
  lea (strType2,pc),a0
  lea (Divu10_type2,pc),a1
  bsr Measure

  moveq #Divu10_type3_end-Divu10_type3,d0
  lea (strType3,pc),a0
  lea (Divu10_type3,pc),a1
  bsr Measure

  moveq #Divu10_type4_end-Divu10_type4,d0
  lea (strType4,pc),a0
  lea (Divu10_type4,pc),a1
  bsr Measure

  DOS _EXIT


NoOps:
  rts
NoOps_end:


Divu10_type1:
  moveq #10,d1
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
Divu10_type1_end:


Divu10_type2:
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
Divu10_type2_end:


Divu10_type4:
  moveq #10,d1
  divu d1,d0
  bvs Divu10_type3  ;商が16ビットに収まらなかった
    swap d0
    move d0,d1  ;余り(d1.hwは0なのでクリア不要)
    clr d0
    swap d0  ;商
    rts


;ref. https://forum.arduino.cc/t/divmod10-a-fast-replacement-for-10-and-10-unsigned/163586/28
Divu10_type3:
  move.l d2,-(sp)
  move.l d0,d1  ;[d1] in 剰余の補正で最後に使う

  moveq #1,d2
  or.l d0,d2  ;(in|1)
  lsr.l #2,d0  ;(in>>2)
  sub.l d0,d2  ;[d2] x= (in|1) - (in>>2);

  move.l d2,d0
  lsr.l #4,d0  ;(x>>4)
  add.l d0,d2  ;[d2] q= (x>>4) + x;

  move.l d2,d0  ;[d0] x= q;
  .rept 4
    lsr.l #8,d2  ;(q>>8)
    add.l d0,d2  ;[d2] q= (q>>8) + x;
  .endm

  andi #.not.7,d2  ;[d2] q &= ~0x7;
  move.l d2,d0
  lsr.l #2,d0  ;[d0] x = (q >> 2);

  sub.l d2,d1
  sub.l d0,d1  ;[d1] mod = in - (q + x);
  lsr.l #1,d0  ;[d0] div = (x >> 1);

  move.l (sp)+,d2
  rts
Divu10_type3_end:

Divu10_type4_end:


.if 0
;ほかの5倍くらい時間がかかる。
Divu10_type901:
  PUSH d2-d3
  moveq #29-1,d3
  move.l #$a000_0000,d2
  move.l d0,d1
  moveq #-1,d0  ;最後にnotするので最上位3ビットは%111にしておく
  1:
    sub.l d2,d1
    bcc 2f
      addx.l d0,d0
      add.l d2,d1
      lsr.l #1,d2
      dbra d3,1b
      bra 3f
    2:
      add.l d0,d0
      lsr.l #1,d2
      dbra d3,1b
  3:
  not.l d0
  POP d2-d3
  rts
Divu10_type901_end:
.endif


Measure:
  PUSH d3-d7
  move.l d0,d1
  DOS_PRINT (a0)
  move.l d1,d0
  bsr PrintDecString
  DOS_PRINT (strTime,pc)

  move.l #LOOP_COUNT-1,d7
  IOCS _ONTIME
  movem.l d0-d1,-(sp)
  @@:
      move.l d7,d0
      jsr (a1)
    dbra d7,@b
  clr d7
  subq.l #1,d7
  bcc @b

  IOCS _ONTIME
  movem.l (sp)+,d2-d3

  cmp.l d3,d1
  beq @f
    addi.l #24*60*60*100,d0
  @@:
  sub.l d2,d0
  bsr PrintDecString
  DOS_PRINT_CRLF

  POP d3-d7
  rts


  DEFINE_PRINTDECSTRING PrintDecString


.data

strNoOps: .dc.b 'noops: size=',0
strType1: .dc.b 'type1: size=',0
strType2: .dc.b 'type2: size=',0
strType3: .dc.b 'type3: size=',0
strType4: .dc.b 'type4: size=',0
strTime:  .dc.b ', time=',0


.end ProgramStart
