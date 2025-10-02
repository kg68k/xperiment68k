.title iocs_akconv - IOCS _AKCONV

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


.cpu 68000
.text

ProgramStart:
  lea (1,a2),a0
  SKIP_SPACE a0
  bne @f
    PRINT_1LINE_USAGE 'usage: iocs_akconv <code>'
    DOS _EXIT
  @@:
  bsr ParseIntWord
  move d0,d7

  moveq #0<<16,d1  ;ひらがなに変換
  move d7,d1
  lea (strHiragana,pc),a1
  bsr Akconv

  move.l #1<<16,d1  ;カタカナに変換
  move d7,d1
  lea (strKatakana,pc),a1
  bsr Akconv

  DOS _EXIT

Akconv:
  link a6,#-64
  lea (sp),a0
  STRCPY a1,a0,-1

  IOCS _AKCONV
  move.l d0,d1
  bsr ToHexString$4_4
  move.b #' ',(a0)+

  move d1,-(sp)
  move.b (sp)+,(a0)+  ;上位バイト
  bne @f
    subq.l #1,a0
  @@:
  move.b d1,(a0)+  ;下位バイト

  lea (strCrLf,pc),a1
  STRCPY a1,a0

  DOS_PRINT (sp)
  unlk a6
  rts


  DEFINE_PARSEINT ParseIntWord
  DEFINE_TOHEXSTRING$4_4 ToHexString$4_4


.data

strHiragana: .dc.b 'ひらがな: ',0
strKatakana: .dc.b 'カタカナ: ',0

strCrLf: .dc.b CR,LF,0


.end ProgramStart
