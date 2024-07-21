.title pt_dbhw - print text: double byte half width characters

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


.include macro.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.cpu 68000
.text

ProgramStart:
  bsr GetArg
  lea (Buffer,pc),a0
  bsr CreateCharTable

  move.l d0,-(sp)
  pea (a0)
  move #1,-(sp)  ;stdout
  DOS _WRITE
  lea (10,sp),sp

  DOS _EXIT


GetArg:
  addq.l #1,a2
  move.b (a2)+,d0
  cmpi.b #'f',d0
  bne 9f
    move.b (a2)+,d0
    cmpi.b #'0',d0
    bcs 9f
    cmpi.b #'5',d0
    bhi 9f
      addi.b #$f0-'0',d0
      rts
9:
  moveq #$80,d0
  rts


CreateCharTable:
  PUSH d5-d7/a0-a1
  move.b d0,d7

  bsr ToHexString2  ;上位バイト
  lea (HeaderCol+2,pc),a1
  STRCPY a1,a0,-1

  moveq #SPACE,d5
  moveq #$00,d6
  1:
    lea (HeaderRow,pc),a1
    move.b (a1)+,(a0)+
    move.b (a1)+,(a0)+
    move.b d6,d0
    bsr ToHexString2  ;下位バイト(の上位ニブル)
    addq.l #1,a1      ;下位ニブルを'_'で上書きする
    subq.l #1,a0
    STRCPY a1,a0,-1
    2:
      move.b d5,(a0)+
      move.b d7,(a0)+  ;lead byte
      move.b d6,(a0)+  ;trail byte
      move.b d5,(a0)+
      addq.b #1,d6
    moveq #$f,d0
    and.b d6,d0
    bne 2b
    subq.l #1,a0  ;最後の空白を取り消す
    move.b #CR,(a0)+
    move.b #LF,(a0)+
  tst.b d6
  bne 1b

  clr.b (a0)
  move.l a0,d0
  POP d5-d7/a0-a1
  sub.l a0,d0  ;length
  rts


  DEFINE_TOHEXSTRING2 ToHexString2


.bss
.quad

Buffer: .ds.b 2048


.data

HeaderCol:
  .dc.b 'XX__ | _0 _1 _2 _3 _4 _5 _6 _7 _8 _9 _a _b _c _d _e _f',CR,LF
  .dc.b '-----+------------------------------------------------',CR,LF,0
HeaderRow:
  .dc.b '  Y_ | ',0


.end ProgramStart
