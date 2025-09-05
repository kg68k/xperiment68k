.title fe_power_test - FPACK __POWER test

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

;FLOAT4.X version 1.02で無限大のマイナス無限大乗を計算するとバスエラーが発生する。
; https://stdkmd.net/bugsx68k/#float_powerinfinf
;このプログラムでは特に対策をしていない。


.include macro.mac
.include fefunc.mac
.include console.mac
.include doscall.mac

.include xputil.mac


.offset 0
DOUBLE_value: .ds.d 1
DOUBLE_str:   .ds.l 1
sizeof_DOUBLE_DATA:
.text

DOUBLE_DATA: .macro val,str
  .dc.d val
  .dc.l str
.endm


.cpu 68000
.text

ProgramStart:
  lea (DoubleValuesEnd,pc),a3
  lea (DoubleValues,pc),a0
  1:
    lea (DoubleValues,pc),a1
    2:
      bsr testPower
      lea (sizeof_DOUBLE_DATA,a1),a1
    cmpa.l a1,a3
    bne 2b
    lea (sizeof_DOUBLE_DATA,a0),a0
  cmpa.l a0,a3
  bne 1b
  DOS _EXIT


testPower:
  PUSH d1-d2/d4-d7/a0-a1
  link a6,#-256

  DOS_PRINT (Mes1,pc)
  movea.l (DOUBLE_str,a0),a2
  DOS_PRINT (a2)
  DOS_PRINT (Mes2,pc)
  movea.l (DOUBLE_str,a1),a2
  DOS_PRINT (a2)
  DOS_PRINT (Mes3,pc)

  movem.l (DOUBLE_value,a0),d0-d1  ;被羃乗数
  movem.l (DOUBLE_value,a1),d2-d3  ;羃乗数
  FPACK __POWER
  move sr,d5  ;ccrを破壊する前に保存する
  move.l d0,d6
  move.l d1,d7

  move d5,d0
  bsr PrintCcr
  DOS_PRINT (Mes4,pc)

  ;演算結果d0:d1を文字列形式で表示する
  lea (sp),a0
  move.l d6,d0
  move.l d7,d1
  FPACK __DTOS  ;d2レジスタが破壊されるので注意
  DOS_PRINT (sp)
  DOS_PRINT (Mes5,pc)

  ;演算結果d0:d1を内部表現(!xxxxxxxx_xxxxxxxx)で表示する
  lea (sp),a0
  move.b #'!',(a0)+
  move.l d6,d0
  bsr ToHexString8
  move.l d7,d0
  bsr ToHexString8
  DOS_PRINT (sp)
  DOS_PRINT (Mes6,pc)

  unlk a6
  POP d1-d2/d4-d7/a0-a1
  rts


  DEFINE_TOHEXSTRING8 ToHexString8
  DEFINE_PRINTCCR PrintCcr


.data

Mes1: .dc.b 'power(',0
Mes2: .dc.b ',',0
Mes3: .dc.b ') -> ',0
Mes4: .dc.b ', d0:d1=',0
Mes5: .dc.b ' (',0
Mes6: .dc.b ')',CR,LF,0

.even
DoubleValues:
  DOUBLE_DATA +0.0,strPlusZero
  DOUBLE_DATA -0.0,strMinusZero
  DOUBLE_DATA +1.0,strPlusOne
  DOUBLE_DATA -1.0,strMinusOne
  DOUBLE_DATA <!7ff00000_00000000>,strPlusInfinity
  DOUBLE_DATA <!fff00000_00000000>,strMinusInfinity
  DOUBLE_DATA <!7fffffff_ffffffff>,strPlusNaN
  DOUBLE_DATA <!ffffffff_ffffffff>,strMinusNaN
DoubleValuesEnd:

strPlusZero:      .dc.b ' +0.0',0
strMinusZero:     .dc.b ' -0.0',0
strPlusOne:       .dc.b ' +1.0',0
strMinusOne:      .dc.b ' -1.0',0
strPlusInfinity:  .dc.b '+#INF',0
strMinusInfinity: .dc.b '-#INF',0
strPlusNaN:       .dc.b '+#NAN',0
strMinusNaN:      .dc.b '-#NAN',0


.end ProgramStart
