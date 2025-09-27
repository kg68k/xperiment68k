.title dos_conctrl - DOS _CONCTRL

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


MD_MIN: .equ 0
MD_MAX: .equ 18


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    PRINT_1LINE_USAGE 'usage: dos_conctrl <md(0..18)> [param...]'
    DOS _EXIT
  @@:

  ;MD(0～18)
  FPACK __STOL
  bcs NumberError
  cmpi.l #MD_MAX,d0
  bhi NumberError
  move.l d0,d7

  add d0,d0
  move (MdJumpTable,pc,d0.w),d0
  jsr (MdJumpTable,pc,d0.w)

  bsr Print$4_4
  DOS_PRINT (CrLf,pc)
  DOS _EXIT

MdJumpTable:
  ~md:=0
  .rept MD_MAX-MD_MIN+1
    .dc Md%~md-MdJumpTable
    ~md:=~md+1
  .endm


NumberError:
  DOS_PRINT (strNumberError,pc)
  DOS _EXIT

NoArgumentError:
  DOS_PRINT (strNoArgError,pc)
  DOS _EXIT


ParseUint16:
  FPACK __STOL
  bcs NumberError
  cmpi.l #$0001_0000,d0
  bcc NumberError
  rts


;MD=0 1バイトの文字を表示する
Md0:
  moveq #0,d0
  SKIP_SPACE a0  ;引数省略時はCODE=0
  beq @f
    move.b (a0)+,d0
    move.b d0,d1
    lsr #5,d1
    btst d1,#%10010000
    beq @f
      move.b (a0)+,d1
      beq @f
        lsl #8,d0  ;2バイト文字
        move.b d1,d0
  @@:
  move d0,-(sp)
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #4,sp
  bra IocsPrintCrLf

IocsPrintCrLf:
  PUSH d0/a1
  lea (CrLf,pc),a1
  IOCS _B_PRINT
  POP d0/a1
  rts


;MD=1 文字列を表示する
Md1:
  SKIP_SPACE a0  ;引数省略時は空文字列

  pea (a0)
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #6,sp
  bra IocsPrintCrLf

;MD=2 文字属性を設定する
;MD=14 ファンクションキー行のモードを設定する
;MD=16 画面モードを設定する
Md2:
Md14:
Md16:
  moveq #-1,d0
  SKIP_SPACE a0  ;引数省略時はATR=-1、またはMOD=-1
  beq @f
    bsr ParseUint16
  @@:
  move d0,-(sp)
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #4,sp
  rts

;MD=3 カーソルの位置を設定する
Md3:
  moveq #-1,d5  ;X
  moveq #-1,d6  ;Y
  SKIP_SPACE a0  ;引数省略時はX=-1
  beq @f
    bsr ParseUint16
    move.l d0,d5
    SKIP_SPACE a0
    beq @f
      bsr ParseUint16
      move.l d0,d6
  @@:
  move d6,-(sp)  ;Y
  move d5,-(sp)  ;X
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #6,sp
  rts

;MD=4 カーソルを1行下に移動する
;MD=5 カーソルを1行上に移動する
;MD=17 カーソルを表示する
;MD=18 カーソルを表示しない
Md4:
Md5:
Md17:
Md18:
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #2,sp
  rts

;MD=6 カーソルを上に移動する
;MD=7 カーソルを下に移動する
;MD=8 カーソルを右に移動する
;MD=9 カーソルを左に移動する
;MD=10 画面を消去する
;MD=11 現在行を消去する
;MD=12 カーソル行に空行を挿入する
;MD=13 カーソル行から行を削除する
Md6:
Md7:
Md8:
Md9:
Md10:
Md11:
Md12:
Md13:
  moveq #0,d0
  SKIP_SPACE a0  ;引数省略時はN=0(またはMOD=0)
  beq @f
    bsr ParseUint16
  @@:
  move d0,-(sp)
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #4,sp
  rts

;MD=15 スクロール範囲を設定する
Md15:
  SKIP_SPACE a0        ;引数省略時の自然な既定値がないので
  beq NoArgumentError  ;エラーにする

  bsr ParseUint16
  move.l d0,d5
  SKIP_SPACE a0
  beq NoArgumentError

  bsr ParseUint16
  move.l d0,d6

  move d6,-(sp)  ;YL
  move d5,-(sp)  ;YS
  move d7,-(sp)
  DOS _CONCTRL
  addq.l #6,sp
  rts


 DEFINE_PRINT$4_4 Print$4_4


.data

strNumberError:
  .dc.b '数値の指定が正しくありません。',CR,LF,0

strNoArgError:
  .dc.b '引数が足りません',CR,LF,0

CrLf: .dc.b CR,LF,0


.end ProgramStart
