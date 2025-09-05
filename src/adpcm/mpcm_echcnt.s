.title mpcm_echcnt - set effect channel count of MPCM

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
.include vector.mac
.include console.mac
.include doscall.mac

.include xputil.mac


M_SET_ECHCNT: .equ $8006


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    DOS_PRINT (UsageMessage,pc)
    bra exit
  @@:
  FPACK __STOL
  bcc @f
    DOS_PRINT (NumErrorMessage,pc)
    bra exit
  @@:
  move.l d0,d1

  pea (GetMpcmVersion,pc)
  DOS _SUPER_JSR
  addq.l #4,sp
  tst.l d0
  bpl @f
    DOS_PRINT (NoMpcmMessage,pc)
    bra exit
  @@:

  move #M_SET_ECHCNT,d0
  trap #1
exit:
  DOS _EXIT


GetMpcmVersion:
  movea.l (TRAP1_VEC*4).w,a0
  move.l -(a0),d0  ;'/???' バージョン番号
  cmpi.b #'/',(a0)
  bne @f
  cmpi.l #'MPCM',-(a0)
  beq 9f
    @@:
    moveq #-1,d0
9:
  rts


.data
UsageMessage: .dc.b 'usage: mpcm_echcnt <n>  (0<=n<=8)',CR,LF,0
NumErrorMessage: .dc.b '数値の指定が正しくありません。',CR,LF,0
NoMpcmMessage: .dc.b 'MPCMが組み込まれていません。',CR,LF,0


.end ProgramStart
