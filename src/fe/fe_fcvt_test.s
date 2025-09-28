.title fe_fcvt_test - FPACK __FCVT test

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

.include xputil.mac


.offset 0
TC_NEXT:   .ds 1
TC_SEP:
TC_DOUBLE: .ds.d 1
TC_DIGIT:  .ds.l 1
TC_STR:  ;サイズ不定
.text

TC: .macro str,dbl,digit
  .dc @next-$  ;次のテーブルへのオフセット
  .dc.d dbl    ;倍精度浮動小数点数
  .dc.l digit  ;小数点以下の桁数
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
  bsr testFcvt
  DOS _EXIT


testFcvt:
  PUSH d2/d6-d7/a4
  lea (a0),a4

  loop:
    tst (TC_NEXT,a4)
    bpl @f
      DOS_PRINT (TC_SEP,a4)
      sub (TC_NEXT,a4),a4
      bra next
    @@:
    DOS_PRINT (Mes1,pc)
    DOS_PRINT (TC_STR,a4)  ;文字列化した浮動小数点数

    DOS_PRINT (Mes2,pc)
    move.l (TC_DIGIT,a4),d0  ;d2の値
    bsr PrintD0dec

    DOS_PRINT (Mes3,pc)
    lea (Buffer,pc),a0
    movem.l (TC_DOUBLE,a4),d0-d1
    move.l (TC_DIGIT,a4),d2
    FPACK __FCVT
    move.l d0,d6
    move.l d1,d7
    DOS_PRINT (Buffer,pc)

    DOS_PRINT (Mes4,pc)
    move.l d6,d0  ;小数点の位置
    bsr PrintD0dec

    DOS_PRINT (Mes5,pc)
    move.l d7,d0  ;符号
    bsr PrintD0dec

    DOS_PRINT_CRLF

    adda (TC_NEXT,a4),a4
  next:
  tst (TC_NEXT,a4)
  bne loop

  POP d2/d6-d7/a4
  rts


PrintD0dec:
  link a6,#-128
  lea (sp),a0
  FPACK __LTOS
  DOS_PRINT (sp)
  unlk a6
  rts


.data

Mes1: .dc.b 'fcvt(',0
Mes2: .dc.b ', ',0
Mes3: .dc.b ') -> "',0
Mes4: .dc.b '", point=',0
Mes5: .dc.b ', sign=',0


.even
TestCase:
  TC_TITLE '1.0未満の値'
  TC '0.0',<0.0>,0
  TC '0.0',<0.0>,1
  TC '0.0',<0.0>,255

  TC '0.1',<0.1>,0
  TC '0.1',<0.1>,1
  TC '0.1',<0.1>,255

  TC '0.01',<0.01>,0
  TC '0.01',<0.01>,1
  TC '0.01',<0.01>,2
  TC '0.01',<0.01>,255

  TC_TITLE '1.0以上の値'
  TC '1.0',<1.0>,0
  TC '1.0',<1.0>,1
  TC '1.0',<1.0>,255

  TC '99.0',<99.0>,0
  TC '99.0',<99.0>,1
  TC '99.0',<99.0>,255

  TC '1234567890.0123456789',<1234567890.0123456789>,0
  TC '1234567890.0123456789',<1234567890.0123456789>,255

  TC_TITLE '巨大数'
  TC '1e253',<1e253>,0
  TC '1e254',<1e254>,0
  TC '1e255',<1e255>,0

  TC '1e253',<1e253>,1
  TC '1e254',<1e254>,1
  TC '1e255',<1e255>,1

  TC_TITLE '微小数'
  TC '1e-254',<1e-254>,255
  TC '1e-255',<1e-255>,255
  TC '1e-256',<1e-256>,255
  TC '1e-257',<1e-257>,255

  TC_TITLE '最大値/最小値'
  TC 'Double.max',<!7fefffff_ffffffff>,0
  TC 'Double.max',<!7fefffff_ffffffff>,255
  TC 'Double.min',<!00100000_00000000>,0
  TC 'Double.min',<!00100000_00000000>,255

  TC_TITLE '無限大/非数'
  TC  'INF',<!7ff00000_00000000>,0
  TC  'NaN.min',<!7ff00000_00000001>,0
  TC  'NaN.max',<!7fffffff_ffffffff>,0

  TC_TITLE '負数'
  TC '-0.0',<-0.0>,0
  TC '-0.0',<-0.0>,1
  TC '-1.0',<-1.0>,0
  TC '-1.0',<-1.0>,1
  TC '-INF',<!fff00000_00000000>,0
  TC '-NaN.min',<!fff00000_00000001>,0
  TC '-NaN.max',<!ffffffff_ffffffff>,0

  TC_END


.bss

.even
Buffer: .ds.b 1024


.end ProgramStart
