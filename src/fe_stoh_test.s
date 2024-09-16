.title fe_stoh_test - FPACK __STOH test

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
.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.offset 0
TC_NEXT:   .ds 1
TC_SEP:
TC_STR:  ;サイズ不定
.text

TC: .macro str
  .dc @next-$  ;次のテーブルへのオフセット
  .dc.b str,0  ;文字列
  .even
@next:
.endm

TC_TITLE: .macro str
  .dc -(@next-$)
  .dc.b '---- ',str,' ----',CR,LF,0
  .even
@next
.endm

TC_END: .macro
  .dc 0
.endm


.cpu 68000
.text

ProgramStart:
  lea (TestCase,pc),a0
  bsr testStoh
  DOS _EXIT


testStoh:
  PUSH d2/d6-d7/a2/a4
  lea (a0),a4

  loop:
    tst (TC_NEXT,a4)
    bpl @f
      DOS_PRINT (TC_SEP,a4)
      sub (TC_NEXT,a4),a4
      bra next
    @@:

    lea (TC_STR,a4),a0
    DOS_PRINT (Mes1,pc)
    DOS_PRINT (a0)
    DOS_PRINT (Mes2,pc)

    FPACK __STOH
    move sr,d2
    lea (a0),a2
    bsr Print$4_4  ;変換結果

    DOS_PRINT (Mes3,pc)
    DOS_PRINT (a2)  ;続きの文字列
    DOS_PRINT (Mes4,pc)

    move d2,d0
    bsr PrintCcr

    DOS_PRINT (CrLf,pc)

    adda (TC_NEXT,a4),a4
  next:
  tst (TC_NEXT,a4)
  bne loop

  POP d2/d6-d7/a2/a4
  rts


PrintCcr:
  lea (Buffer,pc),a0
  pea (a0)
  move.l #'XNZV',(a0)
  move #'C'<<8,(4,a0)
  lsl.b #7-CCR_X,d0  ;%XNZV_C000
  moveq #5-1,d1
  1:
    add.b d0,d0
    bcs @f
      move.b #'_',(a0)
    @@:
    addq.l #1,a0
  dbra d1,1b
  DOS _PRINT
  addq.l #4,sp
  rts


  DEFINE_PRINT$4_4 Print$4_4


.data

Mes1: .dc.b 'stoh("',0
Mes2: .dc.b '") -> ',0
Mes3: .dc.b ', a0="',0
Mes4: .dc.b '", ccr=',0

CrLf: .dc.b CR,LF,0


.even
TestCase:
  TC_TITLE '正常'
  TC '0'
  TC '00000000'
  TC 'ffffffff'
  TC 'FFFFFFFF'
  TC '00000000FFFFFFFF'
  TC 'abcdef'
  TC 'ABCDEF'

  TC_TITLE '後続文字列あり'
  TC '0x0'
  TC '0 a'
  TC <'0',TAB,'a'>

  TC_TITLE 'エラー'
  TC ''  ;空文字列
  TC ' 0'
  TC <TAB,'0'>
  TC '$0'
  TC 'g'
  TC 'G'
  TC '123456789'  ;オーバーフロー

  TC_END


.bss

.even
Buffer: .ds.b 1024


.end ProgramStart
