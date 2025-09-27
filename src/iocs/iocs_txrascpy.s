.title iocs_txrascpy - IOCS _TXRASCPY sample

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

.include fefunc.mac
.include dosdef.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac

DEFAULT_PLANE: .equ %0011

.cpu 68000
.text

ProgramStart:
  moveq #0,d7
  not.b d7  ;d7.l = 255
  lea (1,a2),a0

  bsr getValue
  ble valueError
  cmp.l d7,d0
  bhi valueRangeError
  move.b d1,-(sp)
  move (sp)+,d6  ;コピー元ラスタ番号

  bsr getValue
  ble valueError
  cmp.l d7,d0
  bhi valueRangeError
  move.b d1,d6  ;コピー先ラスタ番号

  bsr getValue
  ble valueError
  cmp.l d7,d0
  bhi valueRangeError
  move d1,d2  ;ラスタ数

  moveq #$00<<8+DEFAULT_PLANE,d3
  bsr getValue
  bmi valueError
  beq @f  ;省略時は下方向
    tst.l d1
    beq @f  ;0なら下方向
      addq.l #1,d1
      bne valueRangeError
        move #$ff<<8+DEFAULT_PLANE,d3  ;-1なら上方向
  @@:
  bsr getValue
  bmi valueError
  beq @f  ;省略時はプレーン0,1
    moveq #%1111,d0
    cmp.l d0,d1
    bhi valueRangeError
      move.b d1,d3  ;テキストプレーン
  @@:

  IOCS _B_CUROFF
  move d6,d1
  IOCS _TXRASCPY
  IOCS _B_CURON

  DOS _EXIT


valueError:
  lea (strUsage,pc),a0
  tst.l d0
  beq error
  lea (strValueError,pc),a0
  bra error

valueRangeError:
  lea (strValueRangeError,pc),a0
  bra error

error:
  move #STDERR,-(sp)
  pea (a0)
  DOS _FPUTS
  addq.l #6,sp

  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


;文字列を数値化する
;in a0.l = 文字列
;out d0.l = 1: 成功, 0:数字がない -1:数値の指定が不正
;    d1.l = 数値
;    a0.l = 数値の末尾+1
getValue:
  moveq #0,d1
  SKIP_SPACE a0
  move.b (a0),d0
  bne @f
    moveq #0,d0
    bra 9f
  @@:
  cmpi.b #'$',d0
  bne @f
    addq.l #1,a0
    FPACK __STOH
    bra 7f
  @@:
  cmpi.b #'%',d0
  bne @f
    addq.l #1,a0
    FPACK __STOB
    bra 7f
  @@:
  cmpi.b #'0',d0
  bne @f
    cmpi.b #'x',(1,a0)
    bne 1f
      addq.l #2,a0
      FPACK __STOH
      bra 7f
    1:
    cmpi.b #'b',(1,a0)
    bne 1f
      addq.l #2,a0
      FPACK __STOB
      bra 7f
    1:
    ;0x 0b 以外なら0から始まる10進数
  @@:
    FPACK __STOL
  7:
  bcc @f
    8:
    moveq #-1,d0
    bra 9f
  @@:
  move.l d0,d1
  moveq #1,d0
9:
  rts


.data

strUsage:
  .dc.b 'usage: iocs_txrascpy '
  .dc.b 'コピー元 コピー先 ラスタ数 移動方向(0:下,-1:上) テキストプレーン'
  .dc.b CR,LF,0

strValueError: .dc.b '数値の指定が正しくありません。',CR,LF,0
strValueRangeError: .dc.b '数値の指定が範囲外です。',CR,LF,0


.end ProgramStart
