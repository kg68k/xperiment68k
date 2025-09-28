.title dos_keyctrl01 - DOS _KEYCTRL (md=0,1) test

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
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


.cpu 68000
.text

Start:
  bsr AnalyzeArgument
  move.l d0,d7  ;'0' or '1'

  IOCS_B_PRINT (strOpt12ToExit,pc)

  moveq #-1,d5
  moveq #0,d6
  loop:
    cmpi.b #'1',d7
    bne @f
      bsr DosKeyCtrl_md1
      tst.l d0
      beq loopNext  ;キー入力なし
    @@:
    bsr DosKeyCtrl_md0
  loopNext:
    addq.l #1,d6

    IOCS _B_SFTSNS
    andi.b #%0000_1100,d0  ;opt.1 opt.2
  beq loop
loopEnd:
  DOS _EXIT 


DosKeyCtrl_md0:
  clr -(sp)
  DOS _KEYCTRL
  addq.l #2,sp

  move.l d0,d1
  beq 1f
    moveq #-1,d5
    bra @f
  1:
    tst.l d5
    beq 9f  ;前回もMD=0で入力なしなら表示しない
    moveq #0,d5
  @@:
  lea (strMd0,pc),a1
  bsr PrintKeyCode
9:
  move.l d1,d0
  rts

DosKeyCtrl_md1:
  move #1,-(sp)
  DOS _KEYCTRL
  addq.l #2,sp

  move.l d0,d1
  beq 1f
    moveq #-1,d5
    bra @f
  1:
    tst.l d5
    bgt 9f  ;前回もMD=1で入力なしなら表示しない
    moveq #1,d5
  @@:
  lea (strMd1,pc),a1
  bsr PrintKeyCode
9:
  move.l d1,d0
  rts

PrintKeyCode:
  lea (buffer,pc),a0
  move.l d6,d0
  bsr PrintHex

  IOCS _B_PRINT

  lea (buffer,pc),a0
  move.l d1,d0
  bsr PrintHex

  B_PRINT_CRLF
  rts

PrintHex:
  PUSH d1/a1
  lea (a0),a1
  bsr ToHexString4_4
  IOCS _B_PRINT
  POP d1/a1
  rts

AnalyzeArgument:
  addq.l #1,a2
  moveq #'1',d0
@@:
  move.b (a2)+,d1
  beq 9f
  cmpi.b #'0',d1  ;use MD=0
  beq @f
  cmpi.b #'1',d1  ;use MD=1 and MD=0
  bne @b
@@:
    move.b d1,d0
9:
  rts


  DEFINE_TOHEXSTRING4_4 ToHexString4_4


.data

strOpt12ToExit: .dc.b 'OPT.1またはOPT.2キー押し下げで終了します。',CR,LF,0

strMd0: .dc.b ': md=0(input), key=',0
strMd1: .dc.b ': md=1(sense), key=',0


.bss
.even
buffer: .ds.b 64


.end
