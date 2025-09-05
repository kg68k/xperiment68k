.title defchr_81f8 - define SJIS:$81f8 font (music natural sign)

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

.include dosdef.mac
.include console.mac
.include doscall.mac
.include iocscall.mac

.include xputil.mac


FONT_WIDTH: .equ 16
FONT_HEIGHT: .equ 16

CHAR_CODE: .equ $81f8


.cpu 68000
.text

Start:
  move #CHAR_CODE,d1
  moveq #8,d2
  IOCS _FNTADR
  movea.l d0,a2  ;パターンアドレス

  cmpa.l #$f0_0000,a2
  bcs @f
    lea (strRomFontError,pc),a0
    bra error
  @@:
  moveq #FONT_HEIGHT-1,d0
  subi.l #FONT_WIDTH<<16+(FONT_WIDTH/8-1),d1
  subx d0,d2
  beq @f
    lea (strFontSizeMismatch,pc),a0
    bra error
  @@:

  lea (Natural16x16,pc),a1
  moveq #(FONT_WIDTH/8)*FONT_HEIGHT-1,d1
  IOCS _B_MEMSTR  ;*a2++ = *a1++

  DOS_PRINT (strSuccess,pc)
  DOS _EXIT

error:
  DOS_PRINT (a0)
  move #EXIT_FAILURE,-(sp)
  DOS _EXIT2


.data

.even
Natural16x16:
  .dc %0000000000000000
  .dc %0001000000000000
  .dc %0001000000000000
  .dc %0001000000001000
  .dc %0001000000111000
  .dc %0001001111001000
  .dc %0001110000001000
  .dc %0001000000001000
  .dc %0001000000001000
  .dc %0001000000111000
  .dc %0001001111001000
  .dc %0001110000001000
  .dc %0001000000001000
  .dc %0000000000001000
  .dc %0000000000001000
  .dc %0000000000000000

strSuccess:
  .dc.b 'SJIS:$81f8“'
  .dc.b CHAR_CODE>>8,CHAR_CODE.and.$ff
  .dc.b '”のフォントを書き換えました。',CR,LF,0

strRomFontError:
  .dc.b 'フォントがROM上にあるため書き換えできません。',CR,LF,0

strFontSizeMismatch:
  .dc.b 'フォントサイズが違うため書き換えできません。',CR,LF,0


.end
